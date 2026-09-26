# skin-check：WanxiangSkin 覆盖层检查

r404r 的个人定制不改上游源码，全部写在
`Skin_Keyboard/万象-元书/WanxiangSkin/jsonnet/overlay.libsonnet`（覆盖层，在渲染结果上做深合并），
另外还有 `Custom.libsonnet` 的几个选项与已提交的 `config.yaml` 显示名。

覆盖层引用的是渲染结果中的样式名（如 `qButtonUpForegroundStyle`）。上游改名或重构后，覆盖可能**静默失效**：
皮肤能正常生成，但你的按键习惯变回了上游的样子。这里的检查就是为了发现这种情况。

| 文件 | 作用 |
|---|---|
| `render.py` | 用 Python jsonnet 渲染 WanxiangSkin（与在元书中运行 `main.jsonnet` 的结果相同） |
| `semantic_keys.py` | 提取每个按键的"语义"：动作、上下划、长按、输入时通知、布局、候选栏、工具栏、面板尺寸等；可以对比两次渲染，也可以按 `expect.json` 断言 |
| `expect.json` | 覆盖层负责的约 490 条期望值（已人工验收的 v7 状态） |
| `make_expect.py` | 从验收过的渲染结果重新生成 `expect.json` |
| `check.sh` | 渲染 + 断言；任一断言失败即以非 0 退出 |

## 自动运行

- `.github/workflows/skin-check.yml`：推送涉及 `WanxiangSkin/` 或本目录时运行，也可以手动触发。
- `.github/workflows/cskin_release.yml`：打包前运行；**检查失败则不打包、不发布**。

## 本地运行

```sh
python3 -m venv .venv && . .venv/bin/activate
pip install -r tools/skin-check/requirements.txt
tools/skin-check/check.sh            # 最后一行应为 "assertions failed: 0"
```

## 有意修改覆盖层时

检查失败是预期的：先确认失败项正好是你想改的地方，再更新期望值。

```sh
tools/skin-check/check.sh /tmp/before || true                       # 可选：保留修改前的渲染
# …修改 overlay.libsonnet / Custom.libsonnet…
python3 tools/skin-check/render.py Skin_Keyboard/万象-元书/WanxiangSkin/jsonnet /tmp/after
python3 tools/skin-check/semantic_keys.py /tmp/before /tmp/after      # 只应出现预期的变化
python3 tools/skin-check/make_expect.py /tmp/after > tools/skin-check/expect.json
tools/skin-check/check.sh                                            # 0 失败
```

新增定制时，如果它不在 `make_expect.py` 的 `RULES` 覆盖范围内，要在 `RULES` 中加上对应的路径规则。

## 跟进上游（BlackCCCat/ResourceforHamster）

建议在上游发布新版时，或每月一次：

```sh
git remote add upstream https://github.com/BlackCCCat/ResourceforHamster.git   # 仅第一次
git fetch upstream
git switch -c merge/upstream-YYYYMMDD main
git merge upstream/main
```

1. **冲突**：上游源码一律以上游为准；`overlay.libsonnet`（上游没有这个文件）不会冲突；
   `main.jsonnet` 的覆盖层钩子（3 行）、`Custom.libsonnet` 中 r404r 改过的选项、`config.yaml` 的显示名要保留我方版本；
   `.github/workflows/cskin_release.yml` 保留我方版本。
2. `git push -u origin merge/upstream-YYYYMMDD` → `skin-check.yml` 自动运行。
3. 如果检查失败：对照失败项找到上游改名 / 改结构的地方，修改 `overlay.libsonnet`，直到检查通过。
   **不要**为了让检查通过而直接重新生成 `expect.json`，除非确认这项变化是你想要的。
4. 与合并前渲染做 `semantic_keys.py` 对比，看上游带来了哪些新行为，决定是否接受。
5. 快进合并到 `main`；导入测试包在真机上确认后，再打 `release/vX.Y.Z.W` tag 发布。
