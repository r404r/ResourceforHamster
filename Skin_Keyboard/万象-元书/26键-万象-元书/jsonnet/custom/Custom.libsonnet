{
  with_functions_row: true,  // true为有功能按键，false为无功能按键
  is_letter_capital: false,  // 26个字母按键大小写显示，false为显示小写
  fix_sf_symbol: false,  // 是否修复部分sf_symbol不显示的情况，false为不修复
  show_swipe: true,  // 是否显示上下划前景
  tips_button_action: { sendKeys: 'Break' },  // 根据自己方案中tips上屏的按键进行调整，万象方案默认为 { character: ',' }
  show_wanxiang: true,  // 空格按键上是否显示“万象”标识
  ios26_style: false,  // 是否启用iOS26风格（统一按键颜色，Light模式下调整高亮）
  button_insets: {
    portrait: { top: 3.8, left: 2.5, right: 2.5, bottom: 3.8 },  // 若需要间隔大稍大，可使用：{ top: 5, left: 3, bottom: 5, right: 3 }
    landscape: { top: 2.2, left: 1.8, bottom: 2.2, right: 1.8 },  // 若需要间隔大稍大，可按需调整:{top: 3, left: 2, bottom: 3, right: 2}
  },
  // 竖屏 26 键键盘区（字母区容器）的边距，单位 pt。改为 0 时按键占满整个键盘区：边缘按键的触摸区贴到屏幕边缘，按键间距略增。
  // 原值 { top: 3, bottom: 3, left: 4, right: 4 }；RIME-20260926-003 实验值为全 0。
  keyboard_insets: {
    portrait: { top: 0, bottom: 0, left: 0, right: 0 },
  },
  cornerRadius: 8, // 圆角大小，建议7或者8或者8.5即可
}
