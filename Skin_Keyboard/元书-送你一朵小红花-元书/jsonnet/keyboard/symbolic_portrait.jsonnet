local animation = import '../lib/animation.libsonnet';
local collectionData = import '../lib/collectionData.libsonnet';
local color = import '../lib/color.libsonnet';
local fontSize = import '../lib/fontSize.libsonnet';
local others = import '../lib/others.libsonnet';
local utils = import '../lib/utils.libsonnet';

local createButton(params={}) =
  std.prune({
    size: std.get(params, 'size'),
    bounds: std.get(params, 'bounds'),
    backgroundStyle: std.get(params, 'backgroundStyle', params.key + 'ButtonBackgroundStyle'),
    foregroundStyle: std.get(params, 'foregroundStyle', params.key + 'ButtonForegroundStyle'),

    action: std.get(params, 'action', { character: params.key }),
    repeatAction: std.get(params, 'repeatAction'),

    // 动画
    animation: [
      'ButtonScaleAnimation',
    ],
  });

local keyboard(theme) =
  {
    keyboardHeight: others['竖屏']['键盘总高度'],
    keyboardLayout: [
      {
        HStack: {
          style: 'HStackStyle1',
          subviews: [
            { Cell: 'categoryCollection' },
            { Cell: 'descriptionCollection' },
          ],
        },
      },
      {
        HStack: {
          style: 'HStackStyle2',
          subviews: [
            { Cell: 'symbolreturnButton' },
            { Cell: 'pageUpButton' },
            { Cell: 'pageDownButton' },
            { Cell: 'lockButton' },
            { Cell: 'symbolbackspaceButton' },
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
    HStackStyle1: {
      size: {
        height: '227/281',
      },
    },
    HStackStyle2: {
      size: {
        height: '54/281',
      },
    },
    categoryCollection: {
      size: {
        width: '56/375',
      },
      insets: { top: 4, bottom: 4 },
      backgroundStyle: 'categoryCollectionBackgroundStyle',
      type: 'classifiedSymbols',
      dataSource: 'category',
      cellStyle: 'categoryCollectionCellStyle',
    },
    categoryCollectionBackgroundStyle: {
      buttonStyleType: 'fileImage',
      normalImage: {
        file: 'anjian',
        image: 'IMG15',
      },
    },
    categoryCollectionCellStyle: {
      backgroundStyle: 'categoryCollectionCellBackgroundStyle',
      foregroundStyle: 'categoryCollectionCellForegroundStyle',
    },
    categoryCollectionCellBackgroundStyle: {
      buttonStyleType: 'fileImage',
      highlightImage: {
        file: 'sym2',
        image: 'IMG11',
      },
    },
    categoryCollectionCellForegroundStyle: {
      buttonStyleType: 'text',
      normalColor: color[theme]['列表未选中字体颜色'],
      highlightColor: color[theme]['列表选中字体颜色'],
      fontSize: fontSize['符号键盘左侧collection前景字体大小'],
      fontWeight: 0,
    },
    descriptionCollection: {
      size: {
        width: '319/375',
      },
      insets: { top: 4, bottom: 4, left: 4, right: 4 },
      backgroundStyle: 'descriptionCollectionBackgroundStyle',
      type: 'subClassifiedSymbols',
      cellStyle: 'descriptionCollectionCellStyle',

    },
    descriptionCollectionBackgroundStyle: {
      buttonStyleType: 'fileImage',
      normalImage: {
        file: 'anjian',
        image: 'IMG13',
      },
    },
    descriptionCollectionCellStyle: {
      backgroundStyle: 'categoryCollectionCellBackgroundStyle',
      foregroundStyle: 'descriptionCollectionCellForegroundStyle',
    },
    descriptionCollectionCellForegroundStyle: {
      buttonStyleType: 'text',
      normalColor: color[theme]['列表未选中字体颜色'],
      highlightColor: color[theme]['列表选中字体颜色'],
      fontSize: fontSize['符号键盘右侧collection前景字体大小'],
      fontWeight: 0,
    },
    symbolreturnButton: createButton(
      params={
        key: 'symbolreturn',
        size: { width: '56/375' },
        action: 'returnLastKeyboard',
        isNumber: false
      }
    ),

    symbolreturnButtonBackgroundStyle: utils.makeImageStyle({
      normalImage: {
        file: 'anjian26',
        image: 'IMG29',
      },
      highlightImage: {
        file: 'anjian26ax',
        image: 'IMG29',
      },
    }),

    symbolreturnButtonForegroundStyle: utils.makeImageStyle({
      contentMode: 'center',
      normalImage: {
        file: 'sym',
        image: 'IMG1',
      },
      highlightImage: {
        file: 'sym2',
        image: 'IMG1',
      },
    }),
    pageUpButton: createButton(
      params={
        key: 'pageUp',
        size: { width: '87/375' },
        backgroundStyle: 'systemButtonBackgroundStyle',
        action: { shortcut: '#subCollectionPageUp' },
        isNumber: false,
      }
    ),

    pageUpButtonForegroundStyle: utils.makeImageStyle({
      contentMode: 'center',
      normalImage: {
        file: 'sym',
        image: 'IMG2',
      },
      highlightImage: {
        file: 'sym2',
        image: 'IMG2',
      },
    }),

    pageDownButton: createButton(
      params={
        key: 'pageDown',
        size: { width: '87/375' },
        backgroundStyle: 'systemButtonBackgroundStyle',
        action: { shortcut: '#subCollectionPageDown' },
        isNumber: false,
      }
    ),

    pageDownButtonForegroundStyle: utils.makeImageStyle({
      contentMode: 'center',
      normalImage: {
        file: 'sym',
        image: 'IMG3',
      },
      highlightImage: {
        file: 'sym2',
        image: 'IMG3',
      },
    }),
    lockButton: createButton(
      params={
        key: 'lock',
        size: { width: '87/375' },
        isNumber: false,
        backgroundStyle: 'systemButtonBackgroundStyle',
        foregroundStyle: [
          {
            styleName: 'unlockButtonForegroundStyle',
            conditionKey: '$symbolicKeyboardLockState',
            conditionValue: false,
          },
          {
            styleName: 'lockButtonForegroundStyle',
            conditionKey: '$symbolicKeyboardLockState',
            conditionValue: true,
          },
        ],
        action: 'symbolicKeyboardLockStateToggle',
      }
    ),

    lockButtonForegroundStyle: utils.makeImageStyle({
      contentMode: 'center',
      normalImage: {
        file: 'sym',
        image: 'IMG9',
      },
      highlightImage: {
        file: 'sym2',
        image: 'IMG9',
      },
    }),
    unlockButtonForegroundStyle: utils.makeImageStyle({
      contentMode: 'center',
      normalImage: {
        file: 'sym',
        image: 'IMG8',
      },
      highlightImage: {
        file: 'sym2',
        image: 'IMG8',
      },
    }),

    symbolbackspaceButton: createButton(
      params={
        key: 'symbolbackspace',
        size: { width: '60/375' },
        action: 'backspace',
        repeatAction: 'backspace',
        isNumber: false,
      }
    ),

    symbolbackspaceButtonBackgroundStyle: utils.makeImageStyle({
      normalImage: {
        file: 'anjian9',
        image: 'IMG11',
      },
      highlightImage: {
        file: 'anjian9ax',
        image: 'IMG11',
      },
    }),
    symbolbackspaceButtonForegroundStyle: utils.makeImageStyle({
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
  };
{
  new(theme): keyboard(theme) + collectionData.symbolicDataSource,   // 符号数据源
  getKeyboard(theme): keyboard(theme), // 给emoji键盘使用，提供无符号数据源的键盘配置
}
