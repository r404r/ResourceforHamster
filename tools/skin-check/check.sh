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
