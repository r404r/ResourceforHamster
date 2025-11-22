local center = import 'center.libsonnet';
local color = import 'color.libsonnet';
local fontSize = import 'fontSize.libsonnet';

// key: 按键名, a-z, shift, space....
// contentMode: center, scaleAspectFill 更多类型见文档
// normalFile、highlightFile

// 单个生成函数
local makeImageStyle(params={}) =
  std.prune({
    buttonStyleType: 'fileImage',
    center: std.get(params, 'center'),
    insets: std.get(params, 'insets'),
    contentMode: std.get(params, 'contentMode'),
    normalImage: std.get(params, 'normalImage'),
    highlightImage: std.get(params, 'highlightImage'),
  });

local makeTextStyle(params={}) =
  std.prune({
    buttonStyleType: 'text',
    text: std.get(params, 'text'),
    fontSize: std.get(params, 'fontSize'),
    normalColor: std.get(params, 'normalColor'),
    highlightColor: std.get(params, 'highlightColor'),
    center: std.get(params, 'center'),
    fontWeight: std.get(params, 'fontWeight'),
  });

local makeSystemImageStyle(params={}) =
  std.prune({
    buttonStyleType: 'systemImage',
    insets: std.get(params, 'insets'),
    center: std.get(params, 'center'),
    systemImageName: std.get(params, 'systemImageName'),
    contentMode: std.get(params, 'contentMode'),
    fontSize: std.get(params, 'fontSize'),
    fontWeight: std.get(params, 'fontWeight'),
    normalColor: std.get(params, 'normalColor'),
    highlightColor: std.get(params, 'highlightColor'),
  });

local HintBackgroundStyle = {
  insets: { left: -10, right: -10, top: -10, bottom: -10 },
  buttonStyleType: 'fileImage',
  contentMode: 'scaleAspectFit',
  normalImage: {
    file: 'hint',
    image: 'IMG3',
  },
};

// 按键前景批量生成
local keyMap = {
  q: 1,
  w: 2,
  e: 3,
  r: 4,
  t: 5,
  y: 6,
  u: 7,
  i: 8,
  o: 9,
  p: 10,
  a: 11,
  s: 12,
  d: 13,
  f: 14,
  g: 15,
  h: 16,
  j: 17,
  k: 18,
  l: 19,
  z: 20,
  x: 21,
  c: 22,
  v: 23,
  b: 24,
  n: 25,
  m: 26,
};

// 生成26字母键前景
local genPinyinStyles() =
  {
    [key + 'ButtonForegroundStyle']: makeImageStyle({
      insets: { top: 6, left: 6, right: 6, bottom: 6 },
      center: center['26键中文前景偏移'],
      contentMode: 'scaleAspectFit',
      normalImage: {
        file: 'letter',
        image: 'IMG' + keyMap[key],
      },
      highlightImage: {
        file: 'letter2',
        image: 'IMG' + keyMap[key],
      },
    })
    for key in std.objectFields(keyMap)
  } + {
    [key + 'ButtonUppercasedStateForegroundStyle']: makeImageStyle({
      insets: { top: 6, left: 6, right: 6, bottom: 6 },
      center: center['26键中文前景偏移'],
      contentMode: 'scaleAspectFit',
      normalImage: {
        file: 'letter',
        image: 'IMG' + keyMap[key],
      },
      highlightImage: {
        file: 'letter2',
        image: 'IMG' + keyMap[key],
      },
    })
    for key in std.objectFields(keyMap)
  };

// 生成英文26键前景 - 确保使用正确的图片索引
local genAlphabeticStyles() =
  {
    [key + 'ButtonForegroundStyle']: makeImageStyle({
      insets: { top: 6, left: 6, right: 6, bottom: 6 },
      center: center['26键中文前景偏移'],
      contentMode: 'scaleAspectFit',
      normalImage: {
        file: 'letter',
        image: 'IMG' + std.toString(keyMap[key] + 26),  // 小写字母：27-52
      },
      highlightImage: {
        file: 'letter2',
        image: 'IMG' + std.toString(keyMap[key] + 26),  // 小写字母：27-52
      },
    })
    for key in std.objectFields(keyMap)

  } + {
    [key + 'ButtonUppercasedStateForegroundStyle']: makeImageStyle({
      insets: { top: 6, left: 6, right: 6, bottom: 6 },
      center: center['26键中文前景偏移'],
      contentMode: 'scaleAspectFit',
      normalImage: {
        file: 'letter',
        image: 'IMG' + keyMap[key],  // 大写字母：1-26
      },
      highlightImage: {
        file: 'letter2',
        image: 'IMG' + keyMap[key],  // 大写字母：1-26
      },
    })
    for key in std.objectFields(keyMap)
  };

// 生成数字9键前景
local genNumberStyles() = {
  ['number' + std.toString((num - 61) % 10) + 'ButtonForegroundStyle']: makeImageStyle({
    insets: { top: 6, left: 6, right: 6, bottom: 6 },
    center: center['数字键盘数字前景偏移'],
    contentMode: 'scaleAspectFit',
    normalImage: {
      file: 'letter',
      image: 'IMG' + num,
    },
    highlightImage: {
      file: 'letter2',
      image: 'IMG' + num,
    },
  })
  for num in std.range(62, 71)
};

// 生成按下气泡前景
local genHintStyles(theme) =
  {
    [key + 'ButtonHintForegroundStyle']: makeTextStyle({
      center: center['按下气泡文字偏移'],
      text: std.asciiUpper(key),
      fontSize: fontSize['划动气泡前景文字大小'],
      normalColor: color[theme]['气泡前景颜色'],
    })
    for key in std.stringChars('qwertyuiopasdfghjklzxcvbnm')
  };

{
  makeImageStyle: makeImageStyle,
  makeTextStyle: makeTextStyle,
  makeSystemImageStyle: makeSystemImageStyle,

  genPinyinStyles: genPinyinStyles,
  genAlphabeticStyles: genAlphabeticStyles,
  genNumberStyles: genNumberStyles,
  genHintStyles: genHintStyles,
  HintBackgroundStyle: HintBackgroundStyle,
}