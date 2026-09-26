#!/usr/bin/env python3
"""从当前（已人工验收的）渲染结果生成覆盖层断言 expect.json（RIME-20260926-014）。

只收录覆盖层负责的路径；上游合并后运行
  semantic_keys.py <任意> <新渲染目录> --expect expect.json
任何一项变化都会 FAIL，提示覆盖层可能因上游改名而失效。
用法：make_expect.py <render_dir> > expect.json
"""
import json, os, re, sys
import yaml
from semantic_keys import semantics, flatten

RULES = {
    'light/pinyin_26_portrait.yaml': [
        r'^@keyboardStyle\.insets', r'^@layout', r'^[qwertyuiop]Button\.swipe(Up|Down)Action', r'^[qwertyuiop]Button\.foregroundStyle\[[12]\]\.text',
        r'^[qwertyuiop]Button\.hintStyle\.swipe(Up|Down)ForegroundStyle\.text',
        r'^[zxcvbnm]Button\.swipeDownAction', r'^[zxcvbnm]Button\.foregroundStyle\[2\]\.(text|systemImageName)',
        r'^shiftButton\.(swipeUpAction|swipeDownAction|notification\[0\]\.(action|swipeUpAction|foregroundStyle))',
        r'^backspaceButton\.swipe', r'^spaceRightButton\.(action|swipeUpAction|foregroundStyle|repeatAction|hintSymbolsStyle\.symbolStyles)',
        r'^cn2enButton\.hintSymbolsStyle\.symbolStyles', r'^spaceButton\.(foregroundStyle\[1\]\.text|swipeUpAction)',
        r'^enterButton\.foregroundStyle\[0\]\.styleName\.text', r'^(left|right)Button\.foregroundStyle\[0\]\.systemImageName',
        r'^123Button\.(type|swipeUpAction|dataSource)', r'^@toolbar',
        r'^backspaceButton\.notification', r'^@horizontalCandidatesLayout\[0\]\.HStack\.subviews\[1\]', r'^@candidateContextMenu',
    ],
    'light/pinyin_26_landscape.yaml': [r'^@layout', r'^spaceSecondButton\.(foregroundStyle\[1\]\.text|swipeUpAction)', r'^spaceRightButton\.(action|swipeUpAction)'],
    'light/alphabetic_26_portrait.yaml': [
        r'^@keyboardStyle\.insets', r'^@layout', r'^[qwertyuiop]Button\.swipe(Up|Down)Action', r'^[xcvb]Button\.swipeDownAction',
        r'^backspaceButton\.swipe', r'^spaceRightButton\.(action|swipeUpAction)', r'^@toolbar',
    ],
    'light/temp_pinyin_portrait.yaml': [r'^@keyboardStyle\.insets'],
    'light/numeric_9_portrait.yaml': [r'^@toolbar', r'^(left|right)Button\.foregroundStyle\[0\]\.systemImageName'],
    'light/panel_portrait.yaml': [r'^@layout', r'^@keyboardStyle\.insets', r'^@floatTargetScale', r'^[A-Za-z]+Button\.(action|foregroundStyle)'],
    'light/panel_landscape.yaml': [r'^@floatTargetScale'],
}

def main():
    root = sys.argv[1]
    out = {}
    for f, pats in RULES.items():
        flat = dict(flatten(semantics(yaml.safe_load(open(os.path.join(root, f))))))
        out[f] = {k: v for k, v in sorted(flat.items()) if any(re.search(p, k) for p in pats)}
    json.dump(out, sys.stdout, ensure_ascii=False, indent=1)
    print()

if __name__ == '__main__':
    main()
