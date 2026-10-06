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
  n: [{ sendKeys: '/nl' }, { image: 'moon.fill' }],  // 农历（用户决定 2026-09-26，RIME-20260926-015 O3；原为与 c 重复的 /rq）
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

// 5. 删除键：上划 #重输（清空 preedit，RIME-20260926-013）；
//    下划：元书没有 #undo 指令（按"无动作"处理，RIME-20260926-015 O1）→ 输入时发送 Control+BackSpace
//    （万象 v18 editor: back_syllable，删除一个音节）；平时无动作。
//    注意：划动方向没有设置动作时，元书会把这次划动当作点按（真机：下划删掉一个字，RIME-20260926-016）→
//    平时必须显式给一个无效动作。这里用 #重输：没有 preedit 时它什么也不做（真机 RIME-20260926-013 R2）
local backspace(base) = {
  backspaceButton+: {
    swipeUpAction: { shortcut: '#重输' },
    swipeDownAction: { shortcut: '#重输' },
    notification: ['backspaceButtonPreeditNotification'],
  },
  backspaceButtonPreeditNotification: {
    notificationType: 'preeditChanged',
    backgroundStyle: base.backspaceButton.backgroundStyle,
    foregroundStyle: 'backspaceButtonForegroundStyle',
    // 显式写出点按 / 连删 / 上划，避免通知只含下划时其他动作丢失
    action: 'backspace',
    repeatAction: 'backspace',
    swipeUpAction: { shortcut: '#重输' },
    swipeDownAction: { sendKeys: 'Control+BackSpace' },
  },
};
// 英文键盘：无效的 #undo 换成显式的无效动作 #重输（原因同上；上划保持上游 #deleteText）
local backspaceEn = { backspaceButton+: { swipeDownAction: { shortcut: '#重输' } } };

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
// 第二批（用户决定 2026-09-26：3、6、7、8、11 保留 v6，其余采用上游）

// 8. 空格：竖屏显示当前方案名、横屏显示 "Rime"；不要上游新增的空格上划（Shift+space）（决定 3A）
local spaceLabel(base) =
  (if has(base, 'spaceButtonForegroundStyle1') then { spaceButtonForegroundStyle1+: { text: '$rimeSchemaName', center: { x: 0.5, y: 0.75 } } } else {})
  + (if has(base, 'spaceSecondButtonForegroundStyle1') then { spaceSecondButtonForegroundStyle1+: { text: 'Rime', center: { x: 0.85, y: 0.8 } } } else {})
  + merge([{ [b]+: { swipeUpAction:: null } } for b in ['spaceButton', 'spaceFirstButton', 'spaceSecondButton'] if has(base, b)]);

// 9. 回车默认标签 «««（决定 4A）
local enterLabel(base) = if has(base, 'enterButtonForegroundStyle0') then { enterButtonForegroundStyle0+: { text: '«««' } } else {};

// 10. 功能行左右箭头使用实心箭头（决定 5A）
local arrowIcons(base) = merge([
  { [s]+: { systemImageName: std.strReplace(base[s].systemImageName, 'arrowshape.turn.up.', 'arrowshape.') } }
  for s in ['leftButtonForegroundStyle', 'leftButtonUppercasedStateForegroundStyle', 'rightButtonForegroundStyle', 'rightButtonUppercasedStateForegroundStyle']
  if has(base, s) && has(base[s], 'systemImageName')
]);

// 11. 123 键：横向滑动选择由 Custom.button_123_config.enable_slide 打开；上划进入符号键盘（决定 6A）
local button123(base) =
  if has(base, '123Button') then
    { '123Button'+: { swipeUpAction: { keyboardType: 'symbolic' } } }
    // 上游在 enable_slide=true 时，123Button 不再引用 123ButtonHintStyle，但仍输出该样式，且它引用的前景样式并不存在
    // （校验器报"引用了不存在的样式"）。该样式无人引用，隐藏即可，不影响显示
    + (if !has(base['123Button'], 'hintStyle') && has(base, '123ButtonHintStyle') then { '123ButtonHintStyle':: null } else {})
  else {};

// 11b. iPad：上游在 enable_slide=true 时 ipad123 按键引用的前景样式不存在（图标空白）→ 用 123ButtonForegroundStyle 补上
//      （本机无 iPad，仅保证配置引用完整；Unverified）
local ipad123Fix(base) =
  (if has(base, '123ButtonHintStyle') then { '123ButtonHintStyle':: null } else {})
  + merge([
    { [n]: base['123ButtonForegroundStyle'] }
    for n in ['ipad123ButtonForegroundStyle', 'ipad123RightButtonForegroundStyle']
    if !has(base, n) && has(base, '123ButtonForegroundStyle')
  ]);

// 12. 工具栏：左侧滑动区 + 固定 面板 / 符号 / 表情 / 常用语 / 剪贴板 / 收起（决定 7A）
local toolbarSlide = [
  'toolbarButtonOpenAppStyle', 'toolbarButtonScriptStyle', 'toolbarButtonKeyboardSettingsStyle', 'toolbarButtonKeyboardSkinsStyle',
  'toolbarButtonKeyboardPerformanceStyle', 'toolbarButtonRimeSwitcherStyle', 'toolbarButtonEmbeddingToggleStyle',
];
local toolbarFixed = [
  'toolbarButtonPanelStyle', 'toolbarButtonSymbolStyle', 'toolbarButtonEmojiStyle', 'toolbarButtonNoteStyle', 'toolbarButtonClipboardStyle', 'toolbarButtonHideStyle',
];
local toolbarIcons = {
  toolbarButtonOpenAppStyle: 'swirl.circle.righthalf.filled',
  toolbarButtonScriptStyle: 'apple.terminal.fill',
  toolbarButtonKeyboardSkinsStyle: 'paintpalette.fill',
  toolbarButtonPanelStyle: 'gearshape.fill',
  toolbarButtonSymbolStyle: 'command.circle.fill',
};
local toolbar(base) =
  if has(base, 'toolbarLayout') && has(base, 'toolbarSlideButtonsLeft') then {
    toolbarLayout: [{ HStack: { subviews: [{ Cell: 'toolbarSlideButtonsLeft' }] + [{ Cell: c } for c in toolbarFixed] } }],
    toolbarSlideButtonsLeft+: { size: { width: '2/9' } },
    horizontalSymbolsDataSourceLeft: [
      { label: std.toString(i), action: base[toolbarSlide[i]].action, styleName: toolbarSlide[i] }
      for i in std.range(0, std.length(toolbarSlide) - 1)
    ],
  } + merge([
    // v6 图标
    { [base[k].foregroundStyle]+: { systemImageName: toolbarIcons[k] } }
    for k in std.objectFields(toolbarIcons)
    if has(base, k) && std.isString(base[k].foregroundStyle) && has(base, base[k].foregroundStyle)
  ]) else {};

// 13. 浮动面板：3 行 12 键（决定 8A）
local panelRows = [
  [['KeyboardSettingsButton', { openURL: 'hamster3://com.ihsiao.apps.hamster3/keyboardSettings' }, 'gearshape.fill', '键盘设置'],
   ['SwitcherButton', { shortcutCommand: '#RimeSwitcher' }, 'filemenu.and.selection', '方案开关'],
   ['FinderButton', { openURL: 'hamster3://com.ihsiao.apps.hamster3/finder' }, 'folder', '文件管理'],
   ['PerformanceButton', { shortcut: '#keyboardPerformance' }, 'gauge.with.dots.needle.bottom.50percent', '内存占用']],
  [['DeployButton', { openURL: 'hamster3://com.ihsiao.apps.hamster3/rime?action=deploy' }, 'command.circle', '重新部署'],
   ['SyncButton', { openURL: 'hamster3://com.ihsiao.apps.hamster3/rime?action=sync' }, 'arrow.trianglehead.2.clockwise.rotate.90', '同步方案'],
   ['ScriptButton', { openURL: 'hamster3://com.ihsiao.apps.hamster3/script' }, 'apple.terminal.fill', '脚本管理'],
   ['InputSchemaButton', { openURL: 'hamster3://com.ihsiao.apps.hamster3/inputSchema' }, 'filemenu.and.selection', '方案管理']],
  [['TraditionalChineseButton', { shortcut: '#简繁切换' }, 'character.square.fill.zh', '繁简切换'],
   ['LeftHandModeButton', { shortcut: '#左手模式' }, 'keyboard.onehanded.left.fill', '左手键盘'],
   ['RightHandModeButton', { shortcut: '#右手模式' }, 'keyboard.onehanded.right.fill', '右手键盘'],
   ['KeyboardThemeButton', { openURL: 'hamster3://com.ihsiao.apps.hamster3/keyboardSkins' }, 'paintpalette.fill', '键盘皮肤']],
];
// 以上游的 FinderButton 为模板（背景、字号、位置等外观沿用上游），只替换动作、图标与文字
local panel(base, orientation) =
  { keyboardLayout: [{ HStack: { subviews: [{ Cell: b[0] } for b in row] } } for row in panelRows] }
  // 面板加宽（用户真机截图，2026-09-26：四字标签占满按键宽度）：左右留白 24 → 8，宽度缩放 0.75 → 0.95（横屏 0.45 → 0.55）
  + { keyboardStyle+: { insets: if orientation == 'portrait' then { top: 20, bottom: 20, left: 8, right: 8 } else { top: 5, bottom: 5, left: 8, right: 8 } } }
  // 面板高度与按键背景边距沿用 v6：上游只有 2 行，把面板高度压到 0.55 / 0.65，3 行时图标与文字会重叠（真机截图，2026-09-26）
  + { floatTargetScale: if orientation == 'portrait' then { x: 0.95, y: 0.8 } else { x: 0.55, y: 0.8 } }
  + { ButtonBackgroundStyle+: { insets: { top: 15, bottom: 10, left: 3, right: 3 } } }
  + merge([
    {
      [b[0]]: base.FinderButton { action: b[1], foregroundStyle: [b[0] + 'ForegroundStyle', b[0] + 'ForegroundStyle2'], size: { height: '1/2' } },
      [b[0] + 'ForegroundStyle']: base.FinderButtonForegroundStyle { systemImageName: b[2] },
      [b[0] + 'ForegroundStyle2']: base.FinderButtonForegroundStyle2 { text: b[3] },
    }
    for row in panelRows
    for b in row
  ]);

// 万象 v18.1.0 把"翻译"开关 chinese_english 改名为 english_chinese（只剩英译中）。上游皮肤仍引用旧名
// （rimeOptionLabel$chinese_english / rime$chinese_english），在此对渲染结果统一改名。
// 只替换含 "$chinese_english" 的字符串；上游日后自行改名后本函数不再命中，可删除。RIME-20261006-001
local OLD_OPT = '$chinese_english';
local NEW_OPT = '$english_chinese';
local renameOption(node) =
  if std.isString(node) then
    (if std.length(std.findSubstr(OLD_OPT, node)) > 0 then std.strReplace(node, OLD_OPT, NEW_OPT) else node)
  else if std.isArray(node) then std.map(renameOption, node)
  else if std.isObject(node) then { [k]: renameOption(node[k]) for k in std.objectFields(node) }
  else node;

// ---------------------------------------------------------------------------
{
  // 皮肤元信息（config.yaml）
  config: { name: '万象键盘r404r-v7', author: 'BlackCCCat, r404r' },

  apply(prefix, theme, orientation, base)::
    local common = spaceLabel(base) + enterLabel(base) + arrowIcons(base) + button123(base) + toolbar(base);
    renameOption(base + (
      if prefix == 'pinyin_26' then
        portraitInsets(orientation) + qpSwipes(base, 'character') + zmSwipes(base, zmPinyin)
        + shiftSwipes + backspace(base) + bottomRow(base, 'cn2enButton', true) + cn2enMenu + common
      else if prefix == 'alphabetic_26' then
        // 英文键盘删除键上划保持上游 #deleteText（决定 12B）
        portraitInsets(orientation) + qpSwipes(base, 'symbol') + zmSwipes(base, zmAlphabetic)
        + shiftSwipes + backspaceEn + bottomRow(base, 'en2cnButton', false) + arrowIcons(base) + button123(base) + toolbar(base)
      else if prefix == 'temp_pinyin' then
        portraitInsets(orientation) + button123(base)
      else if prefix == 'ipad_pinyin_26' || prefix == 'ipad_alphabetic_26' then
        ipad123Fix(base)
      else if prefix == 'numeric_9' then
        arrowIcons(base) + toolbar(base)
      else if prefix == 'panel' then
        panel(base, orientation)
      else {}
    )),
}
