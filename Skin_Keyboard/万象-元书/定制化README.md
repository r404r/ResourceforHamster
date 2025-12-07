## main.jsonnet 文件分析

### 整体结构

这个文件是输入键盘皮肤的主入口文件，负责生成多个 YAML 配置文件。

---

### 1. 配置定义 (config)

```
┌─────────────────────────────────────────────────────────────┐
│  config 对象                                                 │
├─────────────────────────────────────────────────────────────┤
│  author: 作者信息                                            │
│  name: 键盘名称                                              │
│                                                             │
│  键盘类型映射 (iPhone/iPad × portrait/landscape):             │
│  ├── pinyin      → pinyin_26_portrait/landscape             │
│  ├── alphabetic  → alphabetic_26_portrait/landscape         │
│  ├── numeric     → numeric_9_portrait/landscape             │
│  ├── symbolic    → symbolic_portrait                        │
│  ├── emoji       → emoji_portrait/landscape                 │
│  └── panel       → panel_portrait/landscape                 │
└─────────────────────────────────────────────────────────────┘
```

### 2. 模块导入

| 模块 | 文件 | 用途 | 
|------|------|------| 
| pinyin | keyboard/pinyin_26.jsonnet | 26键拼音键盘 | 
| alphabetic | keyboard/alphabetic_26.jsonnet | 26键字母键盘 | 
| numeric | keyboard/numeric_9.jsonnet | 9键数字键盘 | 
| symbolic | keyboard/symbolic_portrait.jsonnet | 符号键盘 | 
| emoji | keyboard/emoji_portrait.jsonnet | Emoji竖屏键盘 | 
| emojiLandscape | keyboard/emoji_landscape.jsonnet | Emoji横屏键盘 | 
| panel | keyboard/panel.jsonnet | 面板 |

---

### 3. 键盘实例化

每个键盘模块调用 `.new(theme, orientation)` 生成配置：

- __theme__: `'light'` 或 `'dark'` (浅色/深色主题)
- __orientation__: `'portrait'` 或 `'landscape'` (竖屏/横屏)

```javascript
生成的键盘实例:
├── 拼音: light/dark × portrait/landscape = 4个
├── 字母: light/dark × portrait/landscape = 4个
├── 数字: light/dark × portrait/landscape = 4个
├── 符号: light/dark × portrait = 2个
├── Emoji: light/dark × portrait/landscape = 4个
└── 面板: light/dark × portrait/landscape = 4个
                                    共计: 22个配置
```

---

### 4. 输出文件

最终输出一个 JSON 对象，键为文件路径，值为 YAML 内容：

```javascript
{
  'config.yaml'                    → 键盘配置
  'light/pinyin_26_portrait.yaml'  → 浅色竖屏拼音
  'dark/pinyin_26_portrait.yaml'   → 深色竖屏拼音
  ...
  'dark/panel_landscape.yaml'      → 深色横屏面板
}
```

使用 `jsonnet -m` 命令可将这些输出到对应的文件目录中。
