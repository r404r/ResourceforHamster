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
//    b / n 下划：上屏元书常用语（AI prompt 分隔符，用户决定 2026-10-21，RIME-20261021-001；原为 /hb、/nl）。
//    常用语按标题查找，需在元书 App 中建好「P代码块」「P三花括号」，并开启键盘完全访问
local phraseCode = [{ phrase: 'P代码块' }, { text: '```' }];
local phraseBrace = [{ phrase: 'P三花括号' }, { text: '{{{' }];
local zmPinyin = {
  z: [{ sendKeys: '/jt' }, { image: 'arrowshape.up.circle.fill' }],
  x: [{ sendKeys: '/sj' }, { image: 'clock.arrow.circlepath' }],
  c: [{ sendKeys: '/rq' }, { image: 'calendar' }],
  v: [{ sendKeys: '/dt' }, { image: 'clock.circle' }],
  b: phraseCode,
  n: phraseBrace,
  m: [{ shortcut: '#简繁切换' }, { text: '繁' }],
};
local zmAlphabetic = {
  x: [{ sendKeys: '/sj' }, { image: 'clock.arrow.circlepath' }],
  c: [{ sendKeys: '/rq' }, { image: 'calendar' }],
  v: [{ sendKeys: '/dt' }, { image: 'clock.circle' }],
  b: phraseCode,
  n: phraseBrace,
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

// 13. 浮动面板：4 行（决定 8A 的 3 行 12 键 + 第 4 行靠右键盘）
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
  // 第 4 行：靠右键盘（Split 开关，见 14；用户决定 2026-10-28，RIME-20261028-001）。不足 4 键的行右侧用空白补齐
  [['SplitRightButton', { shortcut: '#toggleSplitState' }, 'rectangle.righthalf.inset.filled', '靠右键盘']],
];
// 以上游的 FinderButton 为模板（背景、字号、位置等外观沿用上游），只替换动作、图标与文字
local panel(base, orientation) =
  {
    keyboardLayout: [
      { HStack: { subviews: [
        { Cell: b[0] }
        for b in row
      ] + (if std.length(row) < 4 then [{}] else []) } }
      for row in panelRows
    ],
  }
  // 面板加宽（用户真机截图，2026-09-26：四字标签占满按键宽度）：左右留白 24 → 8，宽度缩放 0.75 → 0.95（横屏 0.45 → 0.55）
  + { keyboardStyle+: { insets: if orientation == 'portrait' then { top: 12, bottom: 12, left: 8, right: 8 } else { top: 5, bottom: 5, left: 8, right: 8 } } }
  // 面板高度与按键背景边距沿用 v6：上游只有 2 行，把面板高度压到 0.55 / 0.65，3 行时图标与文字会重叠（真机截图，2026-09-26）
  // 加第 4 行后（RIME-20261028-001）：面板高 0.8 → 0.9，上下留白 20 → 12，按键背景上下边距 15 / 10 → 8 / 6，抵消每行变矮（待真机确认）
  + { floatTargetScale: if orientation == 'portrait' then { x: 0.95, y: 0.9 } else { x: 0.55, y: 0.9 } }
  + { ButtonBackgroundStyle+: { insets: { top: 8, bottom: 6, left: 3, right: 3 } } }
  + merge([
    {
      [b[0]]: base.FinderButton { action: b[1], foregroundStyle: [b[0] + 'ForegroundStyle', b[0] + 'ForegroundStyle2'], size: { height: '1/2' } + (if std.length(row) < 4 then { width: '1/4' } else {}) },
      [b[0] + 'ForegroundStyle']: base.FinderButtonForegroundStyle { systemImageName: b[2] },
      [b[0] + 'ForegroundStyle2']: base.FinderButtonForegroundStyle2 { text: b[3] },
    }
    for row in panelRows
    for b in row
  ]);

// 14. 靠右键盘（元书分体键盘 Split，#toggleSplitState；用户决定 2026-10-28，RIME-20261028-001）
//    元书单手（右手）模式左侧的「左手模式 / 宽度调节 / 全尺寸」按钮无法隐藏（RIME-20261027-001），改用 Split。
//    exp1 在 keyboardStyle / toolbarStyle / preeditStyle 上写 split 边距，真机无效（Split 下只变成全宽）。
//    exp2 改用文档里的「中缝键」写法：每行最前面加一颗平时零宽、Split 态撑开到 splitGap 的空白键（不绑 action），
//    同一行有宽度的键在 Split 态按 (1 - splitGap) 缩窄，保证一行总宽不变；布局 Cell 上的宽度移到按键样式里，才能被 split 覆盖。
//    数字键盘主体是 3 列 VStack，左侧加一列空白列，3 列样式在 Split 态同样缩窄（列样式能否 split 待真机确认）。
//    范围：竖屏 中文 26（含 temp_pinyin）/ 英文 26 / 数字 9 的按键区、工具栏、候选栏；横屏、iPad、面板、预编辑区不变。
//    splitGap 按用户 iPhone 15 Pro Max 右手模式截图取（430 pt 宽，按键区从约 90 pt 开始 ≈ 0.21）
local splitGap = 0.21;
local splitScale = 1 - splitGap;
local pctOf(w) =
  if std.isObject(w) && has(w, 'percentage') then w.percentage
  else if std.isString(w) && std.length(std.split(w, '/')) == 2 then
    std.parseInt(std.split(w, '/')[0]) / std.parseInt(std.split(w, '/')[1])
  else if std.isNumber(w) then w
  else null;
local isCell(s) = std.isObject(s) && has(s, 'Cell');
// 行：只含 Cell 与空占位 {} 的 HStack；列组：只含 VStack 的 HStack
local isCellRow(sub) =
  std.length([s for s in sub if isCell(s)]) > 0
  && std.length([s for s in sub if !(isCell(s) || (std.isObject(s) && std.length(s) == 0))]) == 0;
local isColRow(sub) = std.length(sub) > 0 && std.length([s for s in sub if !(std.isObject(s) && has(s, 'VStack'))]) == 0;
// 只遍历 keyboardLayout / toolbarLayout / horizontalCandidatesLayout 这几棵小树（不遍历整份渲染结果，见 RIME-20261006-001）
local splitLayout(node) =
  if std.isArray(node) then std.map(splitLayout, node)
  else if std.isObject(node) && has(node, 'HStack') then
    local sub = node.HStack.subviews;
    if isCellRow(sub) then node { HStack+: { subviews: [{ Cell: 'splitGapButton' }] + [if isCell(s) then s { size:: null } else s for s in sub] } }
    else if isColRow(sub) then node { HStack+: { subviews: [{ VStack: { style: 'splitGapColumnStyle', subviews: [{ Cell: 'splitGapFillButton' }] } }] + sub } }
    else node { HStack+: { subviews: splitLayout(sub) } }
  else node;
// 被加了中缝键的行里的 Cell：[名称, 布局 Cell 上的宽度或 null]
local rowCells(node) =
  if std.isArray(node) then std.flattenArrays([rowCells(n) for n in node])
  else if std.isObject(node) && has(node, 'HStack') then
    local sub = node.HStack.subviews;
    if isCellRow(sub) then [[s.Cell, if has(s, 'size') && has(s.size, 'width') then s.size.width else null] for s in sub if isCell(s)]
    else if isColRow(sub) then []
    else rowCells(sub)
  else [];
local colStyles(node) =
  if std.isArray(node) then std.flattenArrays([colStyles(n) for n in node])
  else if std.isObject(node) && has(node, 'HStack') then
    local sub = node.HStack.subviews;
    if isColRow(sub) then [s.VStack.style for s in sub if has(s.VStack, 'style')]
    else if isCellRow(sub) then []
    else colStyles(sub)
  else [];
local splitWidth(w) = { split: { size: { width: { percentage: pctOf(w) * splitScale } } } };
local splitRight(prefix, orientation, r) =
  local layouts = [k for k in ['keyboardLayout', 'toolbarLayout', 'horizontalCandidatesLayout'] if has(r, k)];
  if orientation == 'portrait' && std.member(['pinyin_26', 'temp_pinyin', 'alphabetic_26', 'numeric_9'], prefix) then
    { [k]: splitLayout(r[k]) for k in layouts }
    + { splitGapButton: { size: { width: { percentage: 0 } }, split: { size: { width: { percentage: splitGap } } } } }
    + (if std.length([1 for k in layouts for st in colStyles(r[k])]) > 0 then {
         splitGapColumnStyle: { size: { width: { percentage: 0 } }, split: { size: { width: { percentage: splitGap } } } },
         splitGapFillButton: { size: { height: { percentage: 1 } } },
       } else {})
    + merge([
      local c = cw[0];
      // 布局里引用的样式一定存在，直接取 r[c]；不对整份 r 调 has()（每次都要枚举上千个字段，渲染慢约 5%）
      local w = if cw[1] != null then cw[1] else if has(r[c], 'size') && has(r[c].size, 'width') then r[c].size.width else null;
      if w == null || pctOf(w) == null then {}
      else { [c]+: { size+: { width: w } } + splitWidth(w) }
      for k in layouts
      for cw in rowCells(r[k])
    ])
    + merge([
      if has(r[st], 'size') && has(r[st].size, 'width') && pctOf(r[st].size.width) != null
      then { [st]+: splitWidth(r[st].size.width) } else {}
      for k in layouts
      for st in colStyles(r[k])
    ])
  else {};

// 万象 v18.1.0 把"翻译"开关 chinese_english 改名为 english_chinese（只剩英译中）。上游皮肤仍引用旧名，
// 只出现在中英键长按菜单的 4 个样式节点（pinyin_26 / temp_pinyin / ipad_pinyin_26）。这里只改这 4 处。
// v7.1.0.0 曾用递归遍历整份配置统一替换，渲染慢约 30 倍，元书中一直 loading → v7.1.0.1 改为精确覆盖。RIME-20261006-001
// 上游日后自行改名后不再命中（字符串中无旧名时原样保留），可删除。
local OLD_OPT = '$chinese_english';
local NEW_OPT = '$english_chinese';
local ren(s) = if std.isString(s) then std.strReplace(s, OLD_OPT, NEW_OPT) else s;
local renameOption(base) =
  local textFix(k) = if has(base, k) && has(base[k], 'text') then { [k]+: { text: ren(base[k].text) } } else {};
  local condFix(k) =
    if has(base, k) && has(base[k], 'foregroundStyle') && std.isArray(base[k].foregroundStyle) then
      { [k]+: { foregroundStyle: [
        if std.isObject(e) && has(e, 'conditionKey') then e { conditionKey: ren(e.conditionKey) } else e
        for e in base[k].foregroundStyle
      ] } }
    else {};
  textFix('cn2enButtonHintSymbolsForegroundStyleOf4') + textFix('cn2enButtonHintSymbolsForegroundStyleOf5')
  + condFix('cn2enButtonHintSymbolsStyleOf4');

// ---------------------------------------------------------------------------
{
  // 皮肤元信息（config.yaml）
  config: { name: '万象键盘r404r-v7', author: 'BlackCCCat, r404r' },

  apply(prefix, theme, orientation, base)::
    local r = $.applyBase(prefix, theme, orientation, base);
    r + splitRight(prefix, orientation, r),

  applyBase(prefix, theme, orientation, base)::
    local common = spaceLabel(base) + enterLabel(base) + arrowIcons(base) + button123(base) + toolbar(base);
    base + (
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
    ) + renameOption(base),
}
