{
  // 缩放动画
  '26键按键动画': {
    animationType: 'scale',
    isAutoReverse: true,
    scale: 0.87,
    pressDuration: 60,
    releaseDuration: 80,
  },
  'cartoon动画': {
    animationType: 'cartoon',
    fps: 28,
    images: [
      std.format("ax_%02d.png", i)
      for i in std.range(1, 28)
    ],
    zPosition: "below",
  }
}
