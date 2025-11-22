local center = import '../lib/center.libsonnet';
local color = import '../lib/color.libsonnet';
local fontSize = import '../lib/fontSize.libsonnet';
local utils = import '../lib/utils.libsonnet';

// key: 按键名称
local createButton(key, action, sf_symbol, text, theme) = {
  [key + 'Button']: {
    size: {
      height: '1/4',
    },
    backgroundStyle: 'ButtonBackgroundStyle',
    foregroundStyle: [
      key + 'ButtonForegroundStyle',
      key + 'ButtonForegroundStyle2',
    ],
    action: action,
  },
  [key + 'ButtonForegroundStyle']: utils.makeSystemImageStyle({
    systemImageName: sf_symbol,
    center: center['panel键盘按键sf符号前景偏移'],
    fontSize: fontSize['按键前景sf符号大小'],
    normalColor: color[theme]['按键前景颜色'],
    highlightColor: color[theme]['按键前景颜色'],
  }),

  [key + 'ButtonForegroundStyle2']: utils.makeTextStyle({
    text: text,
    fontSize: fontSize['按键前景文字大小'],
    normalColor: color[theme]['按键前景颜色'],
    highlightColor: color[theme]['按键前景颜色'],
    center: center['panel键盘按键文字前景偏移'],
  }),
};

local keyboard(theme, orientation) =
  createButton(
    'Hamster',
    { openURL: 'hamster3://com.ihsiao.apps.hamster3/' },
    'keyboard',
    '元书',
    theme
  ) +

  createButton(
    'Switcher',
    { shortcut: '#RimeSwitcher' },
    'switch.2',
    'Switcher',
    theme
  ) +
  createButton(
    'Phrase',
    { shortcut: '#showPhraseView' },
    'clipboard',
    '常用语',
    theme
  ) +
  createButton(
    'HamsterSkin',
    { openURL: 'hamster3://com.ihsiao.apps.hamster3/keyboardSkins' },
    'tshirt',
    '皮肤设置',
    theme
  ) +
  createButton(
    'Upload',
    { openURL: 'hamster3://com.ihsiao.apps.hamster3/wifi' },
    'square.and.arrow.up',
    '方案上传',
    theme
  ) +
  createButton(
    'Deploy',
    { openURL: 'hamster3://com.ihsiao.apps.hamster3/rime?action=deploy' },
    'command.circle',
    '部署',
    theme
  ) +
  createButton(
    'Finder',
    { openURL: 'hamster3://com.ihsiao.apps.hamster3/finder' },
    'folder',
    '文件',
    theme
  ) +
  createButton(
    'toogleEmbedded',
    { shortcut: '#toggleEmbeddedInputMode' },
    'square.and.pencil',
    '内嵌开关',
    theme
  ) +
  {
    keyboardLayout: [
      {
        HStack: {
          subviews: [
            { Cell: 'HamsterButton' },
            { Cell: 'SwitcherButton' },
            { Cell: 'PhraseButton' },
            { Cell: 'FinderButton' },
          ],
        },
      },
      {
        HStack: {
          subviews: [
            { Cell: 'HamsterSkinButton' },
            { Cell: 'UploadButton' },
            { Cell: 'DeployButton' },
            { Cell: 'toogleEmbeddedButton' },
          ],
        },
      },
    ],
    floatTargetScale:
      if orientation == 'portrait' then
        { x: 0.7, y: 0.55 }
      else
        { x: 0.45, y: 0.8 }
    ,
    keyboardStyle: {
      insets: {
        top: 12,
        left: 12,
        bottom: 10,
        right: 12,
      },
      backgroundStyle: 'keyboardBackgroundStyle',
    },
    keyboardBackgroundStyle: {
      buttonStyleType: 'geometry',
      normalColor: color[theme]['键盘背景颜色'],
      cornerRadius: 15,
    },

    ButtonBackgroundStyle: utils.makeImageStyle({
      normalImage: {
        file: 'anjian',
        image: 'IMG5',
      },
      highlightImage: {
        file: 'anjian123',
        image: 'IMG16',
      },
    }),
  };

{
  new(theme, orientation):
    keyboard(theme, orientation),
}
