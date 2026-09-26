# 介绍
fork 自 [BlackCCCat](https://github.com/BlackCCCat/ResourceforHamster)，定期合并上游。

# r404r 主要内容

## 概要
- 主要维护 **万象键盘皮肤**，发布包见 [release](https://github.com/r404r/ResourceforHamster/releases)。
  - v7 起基于上游 `WanxiangSkin`，个人定制集中在 `WanxiangSkin/jsonnet/overlay.libsonnet`（覆盖层，不改上游源码）。
  - v6 及以前为旧结构 `26键-万象-元书`，已于 v7.0.0.0 退役（历史见 tag `release/v6.0.1.0`）。
- 收集了其它来自网络的 **元书** 键盘皮肤，主要是自己使用，若有侵权请联系我。其它皮肤不作为主要维护对象。

## 元书键盘皮肤
- [万象键盘 r404r（WanxiangSkin + 覆盖层，v7）](Skin_Keyboard/万象-元书/WanxiangSkin)（主要维护）
- [元书-仿仓默认](Skin_Keyboard/元书-仿仓默认)
- [元书-空山素影](Skin_Keyboard/元书-空山素影)
- [元书-送你一朵小红花](Skin_Keyboard/元书-送你一朵小红花-元书)

---

# 说明
1. 高度适配[万象拼音方案](https://github.com/amzxyz/rime_wanxiang)，推荐使用该方案
2. 建议使用全平台（包含iOS）[万象拼音方案下载更新](https://github.com/rimeinn/rime-wanxiang-update-tools)进行方案管理，iOS端也可以使用下面的**万象方案管理**，有可视化的界面操作
3. iOS输入法前端：
    - [仓输入法](https://apps.apple.com/us/app/%E4%BB%93%E8%BE%93%E5%85%A5%E6%B3%95/id6446617683)（该输入法的皮肤不再更新，因此不推荐使用）
    - [元书输入法](https://apps.apple.com/us/app/%E5%85%83%E4%B9%A6%E8%BE%93%E5%85%A5%E6%B3%95/id6744464701)（推荐）
4. iOS端[万象方案管理](https://github.com/BlackCCCat/Scripting-Scripts)，基于[Scripting](https://apps.apple.com/us/app/scripting/id6479691128)

# 目录
- ~~[自定义键盘配置](https://github.com/BlackCCCat/ResourceforHamster/tree/main/Custom_Keyboard)~~ 不推荐使用
- [皮肤配置](https://github.com/BlackCCCat/ResourceforHamster/tree/main/Skin_Keyboard/万象-元书)
- [键盘脚本](https://github.com/BlackCCCat/ResourceforHamster/tree/main/Keyboard_Script)
- [输入法方案自定义部分](https://github.com/BlackCCCat/ResourceforHamster/tree/main/Input_Method)

# 工具
- ~~[皮肤配置修改](https://github.com/BlackCCCat/ResourceforHamster/tree/main/Python_Tools) （仅适用于仓的皮肤修改）~~
- [万象皮肤（元书）皮肤修改skill](https://github.com/BlackCCCat/ResourceforHamster/tree/main/Skin_Keyboard/万象-元书/WanxiangSkin-modifier)：可用于支持skill的app中，通过ai进行皮肤的修改
  - 主要面向 `wanxiang` 目录，适合做 `Custom.libsonnet` 配置调整、toolbar 按钮修改、按键功能调整等功能


# 其他
- 仓皮肤未设置iPad皮肤，需要的可以自行设置
- 元书皮肤可以正常在iPad上使用
