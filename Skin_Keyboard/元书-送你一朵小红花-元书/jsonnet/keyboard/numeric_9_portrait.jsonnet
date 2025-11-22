local animation = import '../lib/animation.libsonnet';
local center = import '../lib/center.libsonnet';
local collectionData = import '../lib/collectionData.libsonnet';
local color = import '../lib/color.libsonnet';
local fontSize = import '../lib/fontSize.libsonnet';
local _hintSymbolsData = import '../lib/hintSymbolsData.libsonnet';
local others = import '../lib/others.libsonnet';
local swipeData = import '../lib/swipeData.libsonnet';
local toolbar = import '../lib/toolbar.libsonnet';
local utils = import '../lib/utils.libsonnet';

local hintSymbolsStyles = import '../lib/hintSymbolsStyles.libsonnet';
local swipeStyles = import '../lib/swipeStyles2.libsonnet';

// 上下和下划的数据
local swipe_up = std.get(swipeData, 'number_swipe_up', {});
local swipe_down = std.get(swipeData, 'number_swipe_down', {});
local hintSymbolsData = std.get(_hintSymbolsData, 'number', {});

local createButton(params={}) =
  local isNumber = std.get(params, 'isNumber', true);
  std.prune({
    size: std.get(params, 'size'),
    bounds: std.get(params, 'bounds'),
    // params中没有isNumber: falsa和背景时，就是数字键背景，非数字键时，设置了背景就用设置的，没设置就默认 key+ButtonBackgroundStyle
    backgroundStyle: if isNumber then 'numberButtonBackgroundStyle' else std.get(params, 'backgroundStyle', params.key + 'ButtonBackgroundStyle'),
    // 和背景是差不多的逻辑
    foregroundStyle:
      if isNumber then
        std.prune([
          if isNumber then 'number' + params.key + 'ButtonForegroundStyle' else params.key + 'ButtonForegroundStyle',
          if std.objectHas(swipe_up, params.key) then 'number' + params.key + 'ButtonUpForegroundStyle' else null,
          if std.objectHas(swipe_down, params.key) then 'number' + params.key + 'ButtonDownForegroundStyle' else null,
        ])
      else
        std.get(params, 'foregroundStyle', params.key + 'ButtonForegroundStyle'),

    action: std.get(params, 'action', { character: params.key }),
    repeatAction: std.get(params, 'repeatAction'),

    [if std.objectHas(swipe_up, params.key) then 'swipeUpAction']: swipe_up[params.key].action,
    [if std.objectHas(swipe_down, params.key) then 'swipeDownAction']: swipe_down[params.key].action,
    // [if isNumber then 'hintSymbolsStyle']: 'number' + params.key + 'ButtonHintSymbolsStyle',
    [if std.objectHas(hintSymbolsData, 'number' + params.key) then 'hintSymbolsStyle']: 'number' + params.key + 'ButtonHintSymbolsStyle',

    // 动画
    animation: [
      'ButtonScaleAnimation',
    ],
  });


local keyboard(theme) =
  {
    [if std.objectHas(others, '中文键盘方案') then 'rimeSchema']: others['中文键盘方案'],
    preeditHeight: others['竖屏']['preedit高度'],
    toolbarHeight: others['竖屏']['toolbar高度'],
    keyboardHeight: others['竖屏']['keyboard高度'],

    keyboardLayout: [
      {
        VStack: {
          style: 'VStackStyle1',
          subviews: [
            { Cell: 'collection' },
            { Cell: 'symbolButton' },
          ],
        },
      },
      {
        VStack: {
          style: 'VStackStyle2',
          subviews: [
            { Cell: 'number1Button' },
            { Cell: 'number4Button' },
            { Cell: 'number7Button' },
            { Cell: 'returnButton' },
          ],
        },
      },
      {
        VStack: {
          style: 'VStackStyle2',
          subviews: [
            { Cell: 'number2Button' },
            { Cell: 'number5Button' },
            { Cell: 'number8Button' },
            { Cell: 'number0Button' },
          ],
        },
      },
      {
        VStack: {
          style: 'VStackStyle2',
          subviews: [
            { Cell: 'number3Button' },
            { Cell: 'number6Button' },
            { Cell: 'number9Button' },
            { Cell: 'spaceButton' },
          ],
        },
      },
      {
        VStack: {
          style: 'VStackStyle1',
          subviews: [
            { Cell: 'backspaceButton' },
            { Cell: 'periodButton' },
            { Cell: 'equalButton' },
            { Cell: 'enterButton' },
          ],
        },
      },
    ],

    keyboardStyle: {
      insets: {
        top: 3,
        bottom: 3,
        left: 4,
        right: 4,
      },
      backgroundStyle: 'keyboardBackgroundStyle',
    },
    keyboardBackgroundStyle: {
      buttonStyleType: 'fileImage',
      normalImage: {
        file: 'bj',
        image: 'IMG2',
      },
    },
    VStackStyle1: {
      size: {
        width: '29/183',
      },
    },
    VStackStyle2: {
      size: {
        width: '125/549',
      },
    },
    collection: {
      size: {
        height: '3/4',
      },
      insets: { top: 4, bottom: 4 },
      backgroundStyle: 'collectionBackgroundStyle',
      type: 'symbols',
      dataSource: 'symbols',
      cellStyle: 'collectionCellStyle',
      useRimeEngine: true,
    },
    collectionBackgroundStyle: {
      buttonStyleType: 'fileImage',
      normalImage: {
        file: 'anjian9',
        image: 'IMG1',
      },
    },
    collectionCellStyle: {
      backgroundStyle: 'collectionCellBackgroundStyle',
      foregroundStyle: 'collectionCellForegroundStyle',
    },
    collectionCellBackgroundStyle: {
      buttonStyleType: 'fileImage',
      highlightImage: {
        file: 'anjian26',
        image: 'IMG13',
      },
    },
    collectionCellForegroundStyle: {
      buttonStyleType: 'text',
      insets: { top: 12 },
      normalColor: color[theme]['collection前景颜色'],
      highlightColor: color[theme]['collection前景颜色'],
      fontSize: fontSize['collection前景字体大小'],
      fontWeight: 0,
    },

    number1Button: createButton(
      params={ key: '1' }
    ),
    number4Button: createButton(
      params={ key: '4' }
    ),
    number7Button: createButton(
      params={ key: '7' }
    ),
    number2Button: createButton(
      params={ key: '2' }
    ),
    number5Button: createButton(
      params={ key: '5' }
    ),
    number8Button: createButton(
      params={ key: '8' }
    ),
    number0Button: createButton(
      params={ key: '0' }
    ),
    number3Button: createButton(
      params={ key: '3' }
    ),
    number6Button: createButton(
      params={ key: '6' }
    ),
    number9Button: createButton(
      params={ key: '9' }
    ),

    returnButton: createButton(
      params={
        key: 'return',
        action: 'returnLastKeyboard',
        isNumber: false,
      }
    ),

    returnButtonBackgroundStyle: utils.makeImageStyle({
      normalImage: {
        file: 'anjian123',
        image: 'IMG16',
      },
      highlightImage: {
        file: 'anjian123ax',
        image: 'IMG16',
      },
    }),

    returnButtonForegroundStyle: utils.makeImageStyle({
      contentMode: 'center',
      normalImage: {
        file: 'letter',
        image: 'IMG73',
      },
      highlightImage: {
        file: 'letter2',
        image: 'IMG73',
      },
    }),

    symbolButton: createButton(
      params={
        key: 'symbol',
        action: { keyboardType: 'symbolic' },
        isNumber: false,
      }
    ),

    symbolButtonBackgroundStyle: utils.makeImageStyle({
      normalImage: {
        file: 'anjian9',
        image: 'IMG13',
      },
      highlightImage: {
        file: 'anjian9ax',
        image: 'IMG13',
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

    spaceButton: createButton(
      params={
        key: 'space',
        action: 'space',
        isNumber: false,
      }
    ),

    spaceButtonBackgroundStyle: utils.makeImageStyle({
      normalImage: {
        file: 'anjian123',
        image: 'IMG17',
      },
      highlightImage: {
        file: 'anjian123ax',
        image: 'IMG17',
      },
    }),

    spaceButtonForegroundStyle: utils.makeImageStyle({
      contentMode: 'center',
      normalImage: {
        file: 'more',
        image: 'IMG20',
      },
      highlightImage: {
        file: 'more2',
        image: 'IMG20',
      },
    }),

    backspaceButton: createButton(
      params={
        key: 'backspace',
        action: 'backspace',
        repeatAction: 'backspace',
        isNumber: false,
      }
    ),

    backspaceButtonBackgroundStyle: utils.makeImageStyle({
      normalImage: {
        file: 'anjian123',
        image: 'IMG12',
      },
      highlightImage: {
        file: 'anjian123ax',
        image: 'IMG12',
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

    periodButton: createButton(
      params={
        key: 'period',
        action: { character: '.' },
        isNumber: false,
      }
    ),

    periodButtonBackgroundStyle: utils.makeImageStyle({
      normalImage: {
        file: 'anjian9',
        image: 'IMG12',
      },
      highlightImage: {
        file: 'anjian9ax',
        image: 'IMG12',
      },
    }),
    periodButtonForegroundStyle: utils.makeImageStyle({
      contentMode: 'center',
      normalImage: {
        file: 'letter',
        image: 'IMG72',
      },
      highlightImage: {
        file: 'letter2',
        image: 'IMG72',
      },
    }),

    equalButton: createButton(
      params={
        key: 'equal',
        action: {
          character: '=',
        },
        isNumber: false,
      }
    ),

    equalButtonBackgroundStyle: utils.makeImageStyle({
      normalImage: {
        file: 'anjian123',
        image: 'IMG14',
      },
      highlightImage: {
        file: 'anjian123ax',
        image: 'IMG14',
      },
    }),
    equalButtonForegroundStyle: utils.makeTextStyle({
      text: '=',
      fontSize: fontSize['collection前景字体大小'],
      normalColor: color[theme]['长按非选中字体颜色'],
      highlightColor: color[theme]['长按非选中字体颜色'],
    }),

    enterButton: createButton(
      params={
        key: 'enter',
        action: 'enter',
        isNumber: false,
      }
    ),

    enterButtonBackgroundStyle: utils.makeImageStyle({
      normalImage: {
        file: 'anjian123',
        image: 'IMG18',
      },
      highlightImage: {
        file: 'anjian123ax',
        image: 'IMG18',
      },
    }),
    enterButtonForegroundStyle: utils.makeImageStyle({
      contentMode: 'center',
      normalImage: {
        file: 'more',
        image: 'IMG25',
      },
      highlightImage: {
        file: 'more2',
        image: 'IMG25',
      },
    }),
    numberButtonBackgroundStyle: utils.makeImageStyle({
      normalImage: {
        file: 'anjian9',
        image: 'IMG3',
      },
      highlightImage: {
        file: 'anjian9ax',
        image: 'IMG3',
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
    alphabeticHintSymbolsBackgroundStyle: hintSymbolsStyles['长按背景样式'],
    alphabeticHintSymbolsSelectedStyle: hintSymbolsStyles['长按选中背景样式'],

    // 左侧符号列表数据来源
    symbols: collectionData.numericSymbols,

  };

{
  new(theme):
    keyboard(theme) +
    swipeStyles.makeSwipeStyles(theme, {
      swipe_up: swipe_up,
      swipe_down: swipe_down,
      type: 'number',
    }) +
    hintSymbolsStyles.getStyle(theme, hintSymbolsData) +
    toolbar.getToolBar(theme) +
    utils.genNumberStyles(),
  // 导出keyboard给横屏用
  keyboard: keyboard,
}
