#!/usr/bin/env python3
"""按键语义对比（RIME-20260926-014）。

比较两套已渲染的元书皮肤（render.py 的输出目录）中，同名键盘文件里每个按键的"语义"：
动作（action / 上下划 / 大写 / 重复）、长按菜单、通知（预编辑态等条件动作）、前景文字 / 图标、尺寸，
以及键盘布局（行与按键顺序、keyboardStyle 边距）。颜色、字号、动画等纯视觉字段不参与比较。

样式名引用会被递归展开，因此两边样式名不同但内容相同的按键视为一致。

用法：
  semantic_keys.py <old_render_dir> <new_render_dir> [--files pinyin_26_portrait,...] [--theme light]
  semantic_keys.py ... --expect expect.json   # 覆盖层断言：只检查 expect.json 中列出的路径与期望值
退出码：有差异（或断言失败）时为 1。
"""
import argparse, json, os, sys
import yaml

VISUAL = {
    'normalColor', 'highlightColor', 'color', 'fontSize', 'fontWeight', 'animation', 'backgroundStyle',
    'cornerRadius', 'shadowColor', 'shadowOffset', 'shadowRadius', 'borderColor', 'borderSize', 'targetScale',
    'normalLowerEdgeColor', 'highlightLowerEdgeColor', 'normalImage', 'highlightImage', 'center', 'selectedBackgroundStyle',
    'lowerEdgeColor', 'normalBorderColor', 'highlightBorderColor', 'fontFamily',
    'contentMode', 'insets',
}
KEEP_INSETS_UNDER = {'keyboardStyle'}  # 容器边距影响触摸区（ADR-0005），保留


def load(path):
    with open(path) as f:
        return yaml.safe_load(f)


def resolve(doc, value, seen=(), under=None):
    if isinstance(value, str) and value in doc and value not in seen and isinstance(doc[value], (dict, list)):
        return resolve(doc, doc[value], seen + (value,), under=value)
    if isinstance(value, dict):
        out = {}
        for k, v in value.items():
            if k in VISUAL and not (k == 'insets' and under in KEEP_INSETS_UNDER):
                continue
            out[k] = resolve(doc, v, seen, under=k if k != 'style' else (v if isinstance(v, str) else under))
        return out
    if isinstance(value, list):
        return [resolve(doc, v, seen, under) for v in value]
    return value


def cells(layout):
    """按行列出布局中的 Cell 名（保留嵌套结构的行分组）。"""
    rows = []
    def walk(node, row):
        if isinstance(node, dict):
            if 'Cell' in node:
                row.append(node['Cell'])
            for k in ('HStack', 'VStack'):
                if k in node:
                    sub = node[k].get('subviews', []) if isinstance(node[k], dict) else node[k]
                    # 行 = 直接包含 Cell 的 HStack；忽略空的占位 {}（上游 27 键条件项在 26 键下渲染为 {}）
                    if k == 'HStack' and any(isinstance(s, dict) and 'Cell' in s for s in sub) \
                            and all(isinstance(s, dict) and ('Cell' in s or not s) for s in sub):
                        rows.append([s['Cell'] for s in sub if s])
                    else:
                        for s in sub:
                            walk(s, row)
        elif isinstance(node, list):
            for n in node:
                walk(n, row)
    walk(layout, [])
    return rows


def all_cells(node):
    if isinstance(node, dict):
        if 'Cell' in node:
            yield node['Cell']
        for v in node.values():
            yield from all_cells(v)
    elif isinstance(node, list):
        for v in node:
            yield from all_cells(v)


def semantics(doc):
    sem = {'@layout': cells(doc.get('keyboardLayout')), '@keyboardStyle': resolve(doc, 'keyboardStyle')}
    for name in all_cells(doc.get('keyboardLayout')):
        sem[name] = resolve(doc, name)
    # 影响整体尺寸的根字段（浮动面板缩放、键盘高度）；RIME-014 曾因漏比 floatTargetScale 导致面板拥挤
    for k in ('floatTargetScale', 'keyboardHeight', 'toolbarHeight', 'preeditHeight'):
        if k in doc:
            sem['@' + k] = doc[k]
    # 候选栏 / 候选长按菜单（RIME-015 O8：RIME-014 曾漏比这两处）
    for k in ('horizontalCandidatesLayout', 'verticalCandidatesLayout', 'candidateContextMenu'):
        if k in doc:
            sem['@' + k] = resolve(doc, doc[k])
    if 'toolbarLayout' in doc:
        sem['@toolbar'] = [resolve(doc, c) for c in all_cells(doc['toolbarLayout'])]
    return sem


def flatten(obj, path=''):
    if isinstance(obj, dict):
        for k in sorted(obj):
            yield from flatten(obj[k], f'{path}.{k}' if path else k)
    elif isinstance(obj, list) and obj and all(isinstance(x, (dict, list)) for x in obj):
        for i, x in enumerate(obj):
            yield from flatten(x, f'{path}[{i}]')
    else:
        yield path, obj


def compare(a, b):
    fa, fb = dict(flatten(a)), dict(flatten(b))
    for k in sorted(set(fa) | set(fb)):
        if fa.get(k, '<absent>') != fb.get(k, '<absent>'):
            yield k, fa.get(k, '<absent>'), fb.get(k, '<absent>')


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('old'); ap.add_argument('new')
    ap.add_argument('--files', default='pinyin_26_portrait,pinyin_26_landscape,alphabetic_26_portrait,alphabetic_26_landscape')
    ap.add_argument('--theme', default='light')
    ap.add_argument('--expect', help='JSON: {file: {path: expected_value}}，只对新皮肤做断言')
    args = ap.parse_args()
    bad = 0
    if args.expect:
        exp = json.load(open(args.expect))
        for fname, checks in exp.items():
            flat = dict(flatten(semantics(load(os.path.join(args.new, fname)))))
            for path, want in checks.items():
                got = flat.get(path, '<absent>')
                ok = got == want
                bad += not ok
                print(('OK  ' if ok else 'FAIL'), fname, path, json.dumps(got, ensure_ascii=False), '' if ok else f'(want {json.dumps(want, ensure_ascii=False)})')
        print(f'assertions failed: {bad}')
        sys.exit(1 if bad else 0)
    for f in args.files.split(','):
        rel = os.path.join(args.theme, f + '.yaml')
        a, b = semantics(load(os.path.join(args.old, rel))), semantics(load(os.path.join(args.new, rel)))
        diffs = list(compare(a, b))
        bad += len(diffs)
        print(f'### {rel}: {len(diffs)} differences')
        for k, x, y in diffs:
            print(f'  {k}: {json.dumps(x, ensure_ascii=False)} -> {json.dumps(y, ensure_ascii=False)}')
    sys.exit(1 if bad else 0)


if __name__ == '__main__':
    main()
