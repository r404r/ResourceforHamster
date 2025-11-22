local animation = import '../lib/animation.libsonnet';
// local center = import '../lib/center.libsonnet';
// local color = import '../lib/color.libsonnet';
// local fontSize = import '../lib/fontSize.libsonnet';
local _hintSymbolsData = import '../lib/hintSymbolsData.libsonnet';
local keyboardLayout = import '../lib/keyboardLayout.libsonnet';
local others = import '../lib/others.libsonnet';
local swipeData = import '../lib/swipeData-en.libsonnet';
local toolbar = import '../lib/toolbar-en.libsonnet';
local utils = import '../lib/utils.libsonnet';

local hintSymbolsStyles = import '../lib/hintSymbolsStyles.libsonnet';
local swipeStyles = import '../lib/swipeStyles2.libsonnet';

// 划动以及长按数据
local swipe_up = std.get(swipeData, 'swipe_up', {});
local swipe_down = std.get(swipeData, 'swipe_down', {});
local hintSymbolsData = std.get(_hintSymbolsData, "pinyin", {});

local isBindSchema = std.objectHas(others, '英文键盘方案');

local createButton(params={}) =
  local isLetter = std.get(params, 'isLetter', true);
  std.prune({
    size: std.get(params, 'size'),
    bounds: std.get(params, 'bounds'),
    backgroundStyle: if isLetter then 'alphabeticBackgroundStyle' else std.get(params, 'backgroundStyle', params.key + 'ButtonBackgroundStyle'),
    foregroundStyle:
      if isLetter then
        std.prune([
          params.key + 'ButtonForegroundStyle',
          if std.objectHas(swipe_up, params.key) then params.key + 'ButtonUpForegroundStyle' else null,
          if std.objectHas(swipe_down, params.key) then params.key + 'ButtonDownForegroundStyle' else null,
        ])
      else
        std.get(params, 'foregroundStyle', params.key + 'ButtonForegroundStyle'),

    [if isLetter then 'uppercasedStateForegroundStyle']: std.prune([
      params.key + 'ButtonUppercasedStateForegroundStyle',
      if std.objectHas(swipe_up, params.key) then params.key + 'ButtonUpForegroundStyle' else null,
      if std.objectHas(swipe_down, params.key) then params.key + 'ButtonDownForegroundStyle' else null,
    ]),
    [if isLetter then 'capsLockedStateForegroundStyle']: self.uppercasedStateForegroundStyle,  // 同uppercaseStateForegroundStyle
    hintStyle: params.key + 'ButtonHintStyle',
    action: std.get(params, 'action', { [if isBindSchema then 'character' else 'symbol']: params.key }),
    [if isLetter then 'uppercasedStateAction']: {
      [if isBindSchema then 'character' else 'symbol']: std.asciiUpper(params.key),
    },
    repeatAction: std.get(params, 'repeatAction'),
    [if std.objectHas(swipe_up, params.key) then 'swipeUpAction']: swipe_up[params.key].action,
    [if std.objectHas(swipe_down, params.key) then 'swipeDownAction']: swipe_down[params.key].action,
    [if std.objectHas(hintSymbolsData, params.key) then 'hintSymbolsStyle']: params.key + 'ButtonHintSymbolsStyle',

    // 动画
    animation: [
      'ButtonScaleAnimation',
      // 'CartoonAniamtion',
    ],
  });

local keyboard(theme, orientation) =
  local ButtonSize = if orientation == 'portrait' then keyboardLayout['竖屏按键尺寸'] else keyboardLayout['横屏按键尺寸'];
  {
    [if isBindSchema then 'rimeSchema']: others['英文键盘方案'],
    preeditHeight: others[if orientation == 'portrait' then '竖屏' else '横屏']['preedit高度'],
    toolbarHeight: others[if orientation == 'portrait' then '竖屏' else '横屏']['toolbar高度'],
    keyboardHeight: others[if orientation == 'portrait' then '竖屏' else '横屏']['keyboard高度'],

    qButton: createButton(
      params={
        key: 'q',
        size: std.get(ButtonSize, '普通键size'),
      }
    ),
    qButtonHintStyle: {
      backgroundStyle: 'alphabeticHintBackgroundStyle',
      foregroundStyle: 'qButtonHintForegroundStyle',
      swipeUpForegroundStyle: 'qButtonSwipeUpHintForegroundStyle',
    },

    wButton: createButton(
      params={
        key: 'w',
        size: std.get(ButtonSize, '普通键size'),
      }
    ),

    wButtonHintStyle: {
      backgroundStyle: 'alphabeticHintBackgroundStyle',
      foregroundStyle: 'wButtonHintForegroundStyle',
      swipeUpForegroundStyle: 'wButtonSwipeUpHintForegroundStyle',
    },
    eButton: createButton(
      params={
        key: 'e',
        size: std.get(ButtonSize, '普通键size'),
      }
    ),


    eButtonHintStyle: {
      backgroundStyle: 'alphabeticHintBackgroundStyle',
      foregroundStyle: 'eButtonHintForegroundStyle',
      swipeUpForegroundStyle: 'eButtonSwipeUpHintForegroundStyle',
    },

    rButton: createButton(
      params={
        key: 'r',
        size: std.get(ButtonSize, '普通键size'),
      }
    ),


    rButtonHintStyle: {
      backgroundStyle: 'alphabeticHintBackgroundStyle',
      foregroundStyle: 'rButtonHintForegroundStyle',
      swipeUpForegroundStyle: 'rButtonSwipeUpHintForegroundStyle',
    },

    tButton: createButton(
      params={
        key: 't',
        size: std.get(ButtonSize, '普通键size'),
        bounds: std.get(ButtonSize, 't键bounds'),
      }
    ),


    tButtonHintStyle: {
      backgroundStyle: 'alphabeticHintBackgroundStyle',
      foregroundStyle: 'tButtonHintForegroundStyle',
      swipeUpForegroundStyle: 'tButtonSwipeUpHintForegroundStyle',
    },

    yButton: createButton(
      params={
        key: 'y',
        size: std.get(ButtonSize, '普通键size'),
        bounds: std.get(ButtonSize, 'y键bounds'),
      }
    ),


    yButtonHintStyle: {
      backgroundStyle: 'alphabeticHintBackgroundStyle',
      foregroundStyle: 'yButtonHintForegroundStyle',
      swipeUpForegroundStyle: 'yButtonSwipeUpHintForegroundStyle',
    },

    uButton: createButton(
      params={
        key: 'u',
        size: std.get(ButtonSize, '普通键size'),
      }
    ),


    uButtonHintStyle: {
      backgroundStyle: 'alphabeticHintBackgroundStyle',
      foregroundStyle: 'uButtonHintForegroundStyle',
      swipeUpForegroundStyle: 'uButtonSwipeUpHintForegroundStyle',
    },

    iButton: createButton(
      params={
        key: 'i',
        size: std.get(ButtonSize, '普通键size'),
      }
    ),


    iButtonHintStyle: {
      backgroundStyle: 'alphabeticHintBackgroundStyle',
      foregroundStyle: 'iButtonHintForegroundStyle',
      swipeUpForegroundStyle: 'iButtonSwipeUpHintForegroundStyle',
    },


    oButton: createButton(
      params={
        key: 'o',
        size: std.get(ButtonSize, '普通键size'),
      }
    ),


    oButtonHintStyle: {
      backgroundStyle: 'alphabeticHintBackgroundStyle',
      foregroundStyle: 'oButtonHintForegroundStyle',
      swipeUpForegroundStyle: 'oButtonSwipeUpHintForegroundStyle',
    },

    pButton: createButton(
      params={
        key: 'p',
        size: std.get(ButtonSize, '普通键size'),
      }
    ),


    pButtonHintStyle: {
      backgroundStyle: 'alphabeticHintBackgroundStyle',
      foregroundStyle: 'pButtonHintForegroundStyle',
      swipeUpForegroundStyle: 'pButtonSwipeUpHintForegroundStyle',
    },

    aButton: createButton(
      params={
        key: 'a',
        size: std.get(ButtonSize, 'a键size'),
        bounds: std.get(ButtonSize, 'a键bounds'),
      }
    ),

    aButtonHintStyle: {
      backgroundStyle: 'alphabeticHintBackgroundStyle',
      foregroundStyle: 'aButtonHintForegroundStyle',
      swipeUpForegroundStyle: 'aButtonSwipeUpHintForegroundStyle',
    },

    sButton: createButton(
      params={
        key: 's',
        size: std.get(ButtonSize, '普通键size'),
      }
    ),


    sButtonHintStyle: {
      backgroundStyle: 'alphabeticHintBackgroundStyle',
      foregroundStyle: 'sButtonHintForegroundStyle',
      swipeUpForegroundStyle: 'sButtonSwipeUpHintForegroundStyle',
    },

    dButton: createButton(
      params={
        key: 'd',
        size: std.get(ButtonSize, '普通键size'),
      }
    ),


    dButtonHintStyle: {
      backgroundStyle: 'alphabeticHintBackgroundStyle',
      foregroundStyle: 'dButtonHintForegroundStyle',
      swipeUpForegroundStyle: 'dButtonSwipeUpHintForegroundStyle',
    },

    fButton: createButton(
      params={
        key: 'f',
        size: std.get(ButtonSize, '普通键size'),
      }
    ),


    fButtonHintStyle: {
      backgroundStyle: 'alphabeticHintBackgroundStyle',
      foregroundStyle: 'fButtonHintForegroundStyle',
      swipeUpForegroundStyle: 'fButtonSwipeUpHintForegroundStyle',
    },

    gButton: createButton(
      params={
        key: 'g',
        size: std.get(ButtonSize, '普通键size'),
      }
    ),


    gButtonHintStyle: {
      backgroundStyle: 'alphabeticHintBackgroundStyle',
      foregroundStyle: 'gButtonHintForegroundStyle',
      swipeUpForegroundStyle: 'gButtonSwipeUpHintForegroundStyle',
    },

    hButton: createButton(
      params={
        key: 'h',
        size: std.get(ButtonSize, '普通键size'),
      }
    ),


    hButtonHintStyle: {
      backgroundStyle: 'alphabeticHintBackgroundStyle',
      foregroundStyle: 'hButtonHintForegroundStyle',
      swipeUpForegroundStyle: 'hButtonSwipeUpHintForegroundStyle',
    },

    jButton: createButton(
      params={
        key: 'j',
        size: std.get(ButtonSize, '普通键size'),
      }
    ),


    jButtonHintStyle: {
      backgroundStyle: 'alphabeticHintBackgroundStyle',
      foregroundStyle: 'jButtonHintForegroundStyle',
      swipeUpForegroundStyle: 'jButtonSwipeUpHintForegroundStyle',
    },

    kButton: createButton(
      params={
        key: 'k',
        size: std.get(ButtonSize, '普通键size'),
      }
    ),


    kButtonHintStyle: {
      backgroundStyle: 'alphabeticHintBackgroundStyle',
      foregroundStyle: 'kButtonHintForegroundStyle',
      swipeUpForegroundStyle: 'kButtonSwipeUpHintForegroundStyle',
    },
    lButton: createButton(
      params={
        key: 'l',
        size: std.get(ButtonSize, 'l键size'),
        bounds: std.get(ButtonSize, 'l键bounds'),
      }
    ),


    lButtonHintStyle: {
      backgroundStyle: 'alphabeticHintBackgroundStyle',
      foregroundStyle: 'lButtonHintForegroundStyle',
      swipeUpForegroundStyle: 'lButtonSwipeUpHintForegroundStyle',
    },

    shiftButton: createButton(
      params={
        key: 'shift',
        action: 'shift',
        backgroundStyle: 'shiftButtonBackgroundStyle',
        size: std.get(ButtonSize, 'shift键size'),
        isLetter: false,
      },
    ) + {
      // uppercasedStateAction: 'shift',
      capsLockedStateForegroundStyle: 'shiftButtonCapsLockedForegroundStyle',
      uppercasedStateForegroundStyle: 'shiftButtonUppercasedForegroundStyle',
    },

    shiftButtonBackgroundStyle: utils.makeImageStyle({
      normalImage: {
        file: 'anjian26',
        image: 'IMG27',
      },
      highlightImage: {
        file: 'anjian26ax',
        image: 'IMG27',
      },
    }),

    shiftButtonForegroundStyle: utils.makeImageStyle({
      contentMode: 'center',
      normalImage: {
        file: 'more',
        image: 'IMG1',
      },
      highlightImage: {
        file: 'more2',
        image: 'IMG1',
      },
    }),
    shiftButtonUppercasedForegroundStyle: utils.makeImageStyle({
      contentMode: 'center',
      normalImage: {
        file: 'more',
        image: 'IMG7',
      },
      highlightImage: {
        file: 'more2',
        image: 'IMG7',
      },
    }),
    shiftButtonCapsLockedForegroundStyle: utils.makeImageStyle({
      contentMode: 'center',
      normalImage: {
        file: 'more',
        image: 'IMG8',
      },
      highlightImage: {
        file: 'more2',
        image: 'IMG8',
      },
    }),

    zButton: createButton(
      params={
        key: 'z',
        size: std.get(ButtonSize, '普通键size'),
      }
    ),

    zButtonHintStyle: {
      backgroundStyle: 'alphabeticHintBackgroundStyle',
      foregroundStyle: 'zButtonHintForegroundStyle',
      swipeUpForegroundStyle: 'zButtonSwipeUpHintForegroundStyle',
    },

    xButton: createButton(
      params={
        key: 'x',
        size: std.get(ButtonSize, '普通键size'),
      }
    ),

    xButtonHintStyle: {
      backgroundStyle: 'alphabeticHintBackgroundStyle',
      foregroundStyle: 'xButtonHintForegroundStyle',
      swipeUpForegroundStyle: 'xButtonSwipeUpHintForegroundStyle',
    },

    cButton: createButton(
      params={
        key: 'c',
        size: std.get(ButtonSize, '普通键size'),
      }
    ),

    cButtonHintStyle: {
      backgroundStyle: 'alphabeticHintBackgroundStyle',
      foregroundStyle: 'cButtonHintForegroundStyle',
      swipeUpForegroundStyle: 'cButtonSwipeUpHintForegroundStyle',
    },

    vButton: createButton(
      params={
        key: 'v',
        size: std.get(ButtonSize, '普通键size'),
      }
    ),

    vButtonHintStyle: {
      backgroundStyle: 'alphabeticHintBackgroundStyle',
      foregroundStyle: 'vButtonHintForegroundStyle',
      swipeUpForegroundStyle: 'vButtonSwipeUpHintForegroundStyle',
    },

    bButton: createButton(
      params={
        key: 'b',
        size: std.get(ButtonSize, '普通键size'),
      }
    ),

    bButtonHintStyle: {
      backgroundStyle: 'alphabeticHintBackgroundStyle',
      foregroundStyle: 'bButtonHintForegroundStyle',
      swipeUpForegroundStyle: 'bButtonSwipeUpHintForegroundStyle',
    },

    nButton: createButton(
      params={
        key: 'n',
        size: std.get(ButtonSize, '普通键size'),
      }
    ),

    nButtonHintStyle: {
      backgroundStyle: 'alphabeticHintBackgroundStyle',
      foregroundStyle: 'nButtonHintForegroundStyle',
      swipeUpForegroundStyle: 'nButtonSwipeUpHintForegroundStyle',
    },

    mButton: createButton(
      params={
        key: 'm',
        size: std.get(ButtonSize, '普通键size'),
      }
    ),

    mButtonHintStyle: {
      backgroundStyle: 'alphabeticHintBackgroundStyle',
      foregroundStyle: 'mButtonHintForegroundStyle',
      swipeUpForegroundStyle: 'mButtonSwipeUpHintForegroundStyle',
    },

    backspaceButton: createButton(
      params={
        key: 'backspace',
        size: ButtonSize['backspace键size'],
        backgroundStyle: 'backspaceButtonBackgroundStyle',
        action: 'backspace',
        repeatAction: 'backspace',
        isLetter: false,
      },
    ),


    backspaceButtonBackgroundStyle: utils.makeImageStyle({
      normalImage: {
        file: 'anjian26',
        image: 'IMG28',
      },
      highlightImage: {
        file: 'anjian26ax',
        image: 'IMG28',
      },
    }),

    backspaceButtonForegroundStyle: utils.makeImageStyle({
      contentMode: 'center',
      normalImage: {
        file: 'more',
        image: 'IMG2',
      },
      highlightImage: {
        file: 'more2',
        image: 'IMG2',
      },
    }),

    symbolButton: createButton(
      params={
        key: 'symbol',
        size: ButtonSize['symbol键size'],
        backgroundStyle: 'symbolButtonBackgroundStyle',
        action: { keyboardType: 'symbolic' },
        isLetter: false,
      },
    ),

    symbolButtonBackgroundStyle: utils.makeImageStyle({
      normalImage: {
        file: 'anjian26',
        image: 'IMG29',
      },
      highlightImage: {
        file: 'anjian26ax',
        image: 'IMG29',
      },
    }),
    symbolButtonForegroundStyle: utils.makeImageStyle({
      contentMode: 'center',
      normalImage: {
        file: 'more',
        image: 'IMG3',
      },
      highlightImage: {
        file: 'more2',
        image: 'IMG3',
      },
    }),

    '123Button': createButton(
      params={
        key: '123',
        size: ButtonSize['123键size'],
        backgroundStyle: '123ButtonBackgroundStyle',
        action: { keyboardType: if orientation == 'portrait' then 'numeric' else 'symbolic' },
        isLetter: false,
      },
    ),

    '123ButtonBackgroundStyle': utils.makeImageStyle({
      normalImage: {
        file: 'anjian26',
        image: 'IMG30',
      },
      highlightImage: {
        file: 'anjian26ax',
        image: 'IMG30',
      },
    }),
    '123ButtonForegroundStyle': utils.makeImageStyle({
      contentMode: 'center',
      normalImage: {
        file: 'more',
        image: 'IMG9',
      },
      highlightImage: {
        file: 'more2',
        image: 'IMG9',
      },
    }),

    spaceButton: createButton(
      params={
        key: 'space',
        size: ButtonSize['space键size'],
        backgroundStyle: 'spaceButtonBackgroundStyle',
        action: 'space',
        isLetter: false,
      },
    ),
    spaceButtonBackgroundStyle: utils.makeImageStyle({
      normalImage: {
        file: 'anjian26',
        image: 'IMG32',
      },
      highlightImage: {
        file: 'anjian26ax',
        image: 'IMG32',
      },
    }),
    spaceButtonForegroundStyle: utils.makeImageStyle({
      contentMode: 'scaleAspectFit',
      center: { x: 0.7 },
      insets: { left: 10, right: 10, top: 10, bottom: 10 },
      normalImage: {
        file: 'more',
        image: 'IMG20',
      },
      highlightImage: {
        file: 'more2',
        image: 'IMG20',
      },
    }),

    // 添加 👌 按钮
    okHandButton: createButton(
      params={
        key: 'okHand',
        size: std.get(ButtonSize, '普通键size'),
        backgroundStyle: 'okHandButtonBackgroundStyle',
        foregroundStyle: 'okHandButtonForegroundStyle',
        action: { symbol: '👌' },
        isLetter: false,
      }
    ),

    okHandButtonBackgroundStyle: utils.makeImageStyle({
      normalImage: {
        file: 'anjian26',
        image: 'IMG1',
      },
      highlightImage: {
        file: 'anjian26ax',
        image: 'IMG1',
      },
    }),

    okHandButtonForegroundStyle: {
      buttonStyleType: 'text',
      normalColor: '#000000',
      highlightColor: '#FFFFFF',
      text: '👌',
      fontSize: 16,
    },

    spaceRightButton: createButton(
      params={
        key: 'spaceRight',
        size: ButtonSize['spaceRight键size'],
        action: { symbol: '.' },
        backgroundStyle: 'alphabeticBackgroundStyle',
        foregroundStyle: [
          'spaceRightButtonForegroundStyle',
        ],
        isLetter: false,
      },
    ),

    spaceRightButtonForegroundStyle: utils.makeImageStyle({
      contentMode: 'center',
      center: { y: 0.53 },
      normalImage: {
        file: 'more',
        image: 'IMG17',
      },
      highlightImage: {
        file: 'more2',
        image: 'IMG17',
      },
    }),

    enterButton: createButton(
      params={
        key: 'enter',
        size: ButtonSize['enter键size'],
        backgroundStyle: 'enterButtonBackgroundStyle',
        action: 'enter',
        isLetter: false,
      },
    ),

    enterButtonBackgroundStyle: utils.makeImageStyle({
      normalImage: {
        file: 'anjian26',
        image: 'IMG35',
      },
      highlightImage: {
        file: 'anjian26ax',
        image: 'IMG35',
      },
    }),
    enterButtonForegroundStyle: utils.makeImageStyle({
      contentMode: 'scaleAspectFit',
      insets: { left: 10, right: 10, top: 10, bottom: 10 },
      normalImage: {
        file: 'more',
        image: 'IMG25',
      },
      highlightImage: {
        file: 'more2',
        image: 'IMG25',
      },
    }),

    alphabeticBackgroundStyle: utils.makeImageStyle({
      normalImage: {
        file: 'anjian26',
        image: 'IMG1',
      },
      highlightImage: {
        file: 'anjian26ax',
        image: 'IMG1',
      },
    }),
    systemButtonBackgroundStyle: utils.makeImageStyle({
      normalImage: {
        file: 'anjian123',
        image: 'IMG16',
      },
      highlightImage: {
        file: 'anjian123ax',
        image: 'IMG16',
      },
    }),

    ButtonScaleAnimation: animation['26键按键动画'],
    alphabeticHintBackgroundStyle: utils.HintBackgroundStyle,
    alphabeticHintSymbolsBackgroundStyle: hintSymbolsStyles['长按背景样式'],
    alphabeticHintSymbolsSelectedStyle: hintSymbolsStyles['长按选中背景样式'],
  };

{
  new(theme, orientation):
    keyboard(theme, orientation) +
    keyboardLayout[if orientation == 'portrait' then '竖屏英文26键' else '横屏英文26键'] +
    swipeStyles.makeSwipeStyles(theme, {
      swipe_up: swipe_up,
      swipe_down: swipe_down,
      type: 'pinyin',
    }) +
    hintSymbolsStyles.getStyle(theme, hintSymbolsData) +
    toolbar.getToolBar(theme) +
    utils.genAlphabeticStyles() +
    utils.genHintStyles(theme),
}