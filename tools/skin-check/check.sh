#!/usr/bin/env bash
# WanxiangSkin 覆盖层检查（RIME-20260926-017）：渲染皮肤 → 用 expect.json 断言 r404r 个人定制仍然生效。
# 任何一项断言失败（例如合并上游后样式名变了、覆盖层静默失效）都会以非 0 退出。
# 用法：tools/skin-check/check.sh [输出目录]
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$HERE/../.." && pwd)"
OUT="${1:-$(mktemp -d)}"
python3 "$HERE/render.py" "$ROOT/Skin_Keyboard/万象-元书/WanxiangSkin/jsonnet" "$OUT"
python3 "$HERE/semantic_keys.py" - "$OUT" --expect "$HERE/expect.json" > "$OUT/assertions.txt" || {
  grep '^FAIL' "$OUT/assertions.txt" | head -50
  tail -n 1 "$OUT/assertions.txt"
  exit 1
}
tail -n 1 "$OUT/assertions.txt"
# 深色配色断言（RIME-20261127-006）：semantic_keys 不比较颜色，这里单独检查覆盖层的两个深色令牌仍然生效
python3 - "$OUT/dark/pinyin_26_portrait.yaml" <<'PY'
import sys, yaml
d = yaml.safe_load(open(sys.argv[1]))
want = {('alphabeticBackgroundStyle', 'normalColor'): 'D1D1D170', ('aButtonUpForegroundStyle', 'normalColor'): 'EBEBF0'}
bad = [f'{s}.{k} = {d.get(s, {}).get(k)!r} (want {v})' for (s, k), v in want.items() if str(d.get(s, {}).get(k, '')).upper() != v]
for b in bad: print('FAIL dark color', b)
print(f'dark color assertions failed: {len(bad)}')
sys.exit(1 if bad else 0)
PY
