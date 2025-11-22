local swipeStyles = import '../jsonnet/lib/swipeStyles2.libsonnet';
local mySwipe = import '../jsonnet/lib/swipeData.libsonnet';

swipeStyles.makeSwipeStyles(
  'light',
  {
    swipe_up: mySwipe.swipe_up,
    swipe_down: mySwipe.swipe_down,
    type: "pinyin"
    // cn9_swipe_up: mySwipe.cn9_swipe_up,  // 可选
  }
)
