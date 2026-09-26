// r404r 个人定制覆盖层（RIME-20260926-014，ADR-0006）
//
// 作用于 main.jsonnet 渲染出的键盘对象（std.toString 之前），用深合并覆盖上游结果；不修改上游源码。
// 这里引用的是输出层的样式名（如 qButtonUpForegroundStyle）。上游改名后覆盖可能静默失效，
// 所以每次合并上游后都要运行断言：p-research-rime/experiments/RIME-20260926-014_skin-upstream-merge-overlay/。
//
// 只使用基础 jsonnet 特性（对象合并、super 之外的显式 base 参数、隐藏字段），以兼容元书内置的 jsonnet 引擎。

local has(o, k) = std.objectHas(o, k);

// 前景标签：{ text: 'x' } 或 { image: 'sf.symbol' }；用隐藏字段去掉另一种标签
local label(spec) =
  if has(spec, 'text') then { buttonStyleType: 'text', text: spec.text, systemImageName:: null }
  else { buttonStyleType: 'systemImage', systemImageName: spec.image, text:: null };

// 设置某键某方向的划动动作，并同步按键上的角标与划动气泡
local swipe(base, key, dir, action, lab) =
  local b = key + 'Button';
  { [b]+: { ['swipe' + dir + 'Action']: action } }
  + (if has(base, b + dir + 'ForegroundStyle') then { [b + dir + 'ForegroundStyle']+: label(lab) } else {})
  + (if has(base, b + 'Swipe' + dir + 'HintForegroundStyle') then { [b + 'Swipe' + dir + 'HintForegroundStyle']+: label(lab) } else {});

local merge(list) = std.foldl(function(acc, o) acc + o, list, {});

// ---------------------------------------------------------------------------
// 1. 竖屏 26 键容器边距 0（RIME-20260926-003，ADR-0005）
local portraitInsets(orientation) =
  if orientation == 'portrait' then { keyboardStyle+: { insets: { top: 0, bottom: 0, left: 0, right: 0 } } } else {};

// 2. q–p 行：上划符号、下划数字（用户决定，2026-09-26）
local qpRow = { q: ['~', '1'], w: ['@', '2'], e: ['#', '3'], r: ['$', '4'], t: ['%', '5'],
                y: ['^', '6'], u: ['&', '7'], i: ['*', '8'], o: ['(', '9'], p: [')', '0'] };
local qpSwipes(base, kind) = merge([
  swipe(base, k, 'Up', { [kind]: qpRow[k][0] }, { text: qpRow[k][0] })
  + swipe(base, k, 'Down', { [kind]: qpRow[k][1] }, { text: qpRow[k][1] })
  for k in std.objectFields(qpRow)
]);

// 3. z–m 下划：`/` 快捷指令（配合 rime_wanxiang_mod）与简繁切换
local zmPinyin = {
  z: [{ sendKeys: '/jt' }, { image: 'arrowshape.up.circle.fill' }],
  x: [{ sendKeys: '/sj' }, { image: 'clock.arrow.circlepath' }],
  c: [{ sendKeys: '/rq' }, { image: 'calendar' }],
  v: [{ sendKeys: '/dt' }, { image: 'clock.circle' }],
  b: [{ sendKeys: '/hb' }, { image: 'chineseyuanrenminbisign.square.fill' }],
  n: [{ sendKeys: '/rq' }, { image: 'calendar.badge.exclamationmark' }],
  m: [{ shortcut: '#简繁切换' }, { text: '繁' }],
};
local zmAlphabetic = {
  x: [{ sendKeys: '/sj' }, { image: 'clock.arrow.circlepath' }],
  c: [{ sendKeys: '/rq' }, { image: 'calendar' }],
  v: [{ sendKeys: '/dt' }, { image: 'clock.circle' }],
  b: [{ sendKeys: '/hb' }, { image: 'chineseyuanrenminbisign.square.fill' }],
};
local zmSwipes(base, table) = merge([swipe(base, k, 'Down', table[k][0], table[k][1]) for k in std.objectFields(table)]);

// 4. shift：上划简繁切换，下划 `\`
local shiftSwipes = { shiftButton+: { swipeUpAction: { shortcut: '#简繁切换' }, swipeDownAction: { character: '\\' } } };

// 5. 删除键上划 #重输（清空 preedit，RIME-20260926-013）
local backspace = { backspaceButton+: { swipeUpAction: { shortcut: '#重输' } } };

// 6. 底行：中英键在空格左侧，"，。"键在空格右侧（用户决定，2026-09-26）
local swapBottomRow(node, cn2en) =
  if std.isArray(node) then std.map(function(n) swapBottomRow(n, cn2en), node)
  else if std.isObject(node) then
    if has(node, 'Cell') then
      if node.Cell == 'spaceLeftButton' then node { Cell: cn2en }
      else if node.Cell == cn2en then node { Cell: 'spaceRightButton' }
      else node
    else { [k]: swapBottomRow(node[k], cn2en) for k in std.objectFields(node) }
  else node;
local bottomRow(base, cn2en, pinyin) =
  { keyboardLayout: swapBottomRow(base.keyboardLayout, cn2en) }
  + {
    spaceRightButton+: {
      swipeUpAction: { character: ',' },
      repeatAction:: null,  // v6：该键不连发
    } + (if pinyin then {
      foregroundStyle: ['spaceRightButtonForegroundStyle', 'spaceRightButtonForegroundStyle2'],
      hintSymbolsStyle: 'spaceLeftButtonHintSymbolsStyle',  // 长按 , .
    } else {}),
  }
  + (if pinyin then {
       spaceRightButtonForegroundStyle+: { text: '，', fontSize: 18, center: { x: 0.62, y: 0.2 } },
       spaceRightButtonForegroundStyle2+: { text: '。', fontSize: 20, center: { x: 0.6, y: 0.45 } },
     } else {});

// 7. 中英键长按菜单：第 4 组对齐 mod 的 Control+q → english；万象 v18 标准版没有 chaifen_switch → 去掉拆分组
local cn2enMenu = {
  cn2enButtonHintSymbolsStyleOf8+: { foregroundStyle: [
    { conditionKey: 'rime$english', conditionValue: 'true', styleName: 'cn2enButtonHintSymbolsForegroundStyleOf8' },
    { conditionKey: 'rime$english', conditionValue: 'false', styleName: 'cn2enButtonHintSymbolsForegroundStyleOf9' },
  ] },
  cn2enButtonHintSymbolsForegroundStyleOf8+: { text: 'rimeOptionLabel$english' },
  cn2enButtonHintSymbolsForegroundStyleOf9+: { text: 'rimeOptionLabel$english' },
  cn2enButtonHintSymbolsStyle+: { symbolStyles: [
    'cn2enButtonHintSymbolsStyleOf0', 'cn2enButtonHintSymbolsStyleOf4', 'cn2enButtonHintSymbolsStyleOf6', 'cn2enButtonHintSymbolsStyleOf8',
  ] },
};

// ---------------------------------------------------------------------------
{
  // 皮肤元信息（config.yaml）
  config: { name: '万象键盘r404r-v7', author: 'BlackCCCat, r404r' },

  apply(prefix, theme, orientation, base)::
    base + (
      if prefix == 'pinyin_26' then
        portraitInsets(orientation) + qpSwipes(base, 'character') + zmSwipes(base, zmPinyin)
        + shiftSwipes + backspace + bottomRow(base, 'cn2enButton', true) + cn2enMenu
      else if prefix == 'alphabetic_26' then
        portraitInsets(orientation) + qpSwipes(base, 'symbol') + zmSwipes(base, zmAlphabetic)
        + shiftSwipes + backspace + bottomRow(base, 'en2cnButton', false)
      else if prefix == 'temp_pinyin' then
        portraitInsets(orientation)
      else {}
    ),
}
