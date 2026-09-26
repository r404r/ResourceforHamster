#!/usr/bin/env python3
"""渲染 WanxiangSkin（与元书内运行 main.jsonnet 的结果相同的键盘配置），输出到指定目录。

用法：render.py <jsonnet_dir> <out_dir>
"""
import json, os, sys, time
import _jsonnet

jdir, out = sys.argv[1], sys.argv[2]
t0 = time.time()
res = json.loads(_jsonnet.evaluate_file(os.path.join(jdir, 'main.jsonnet'), jpathdir=[jdir]))
for name, content in res.items():
    p = os.path.join(out, name)
    os.makedirs(os.path.dirname(p) or out, exist_ok=True)
    with open(p, 'w') as f:
        f.write(content if isinstance(content, str) else json.dumps(content, ensure_ascii=False, indent=1))
print(f'rendered {len(res)} files in {time.time() - t0:.1f}s -> {out}')
