# GATE 状态文件 — 霓虹轮盘 NEON ROULETTE v2.0

> **最后更新:** 2026-06-27
> **项目状态:** ✅ REBUILT FROM REACT SOURCE — 待云构建
> **负责人:** jiaweisi (AI CTO)

## 阶段状态

| Gate | 状态 | 备注 |
|------|------|------|
| G1: React源码评估 | ✅ DONE | Google AI Studio生成，React 19+TypeScript+Tailwind |
| G2: 数据模型翻译 | ✅ DONE | 加权概率、8惩罚项、4语翻译 |
| G3: 音频合成引擎 | ✅ DONE | 纯Dart WAV合成，零音频文件 |
| G4: UI组件 | ✅ DONE | 9宫格+充电条+能量球+指纹触控+设置面板+频闪 |
| G5: 主屏整合 | ✅ DONE | GameScreen串联所有组件 |
| G6: Web构建验证 | ✅ DONE | `flutter build web --release` 通过 |
| G7: GitHub Push | ✅ DONE | https://github.com/66constan/neon-roulette |
| G8: Magic云构建 | ⏳ PENDING | 准备触发 |

## React→Flutter移植保留特性

| # | 特性 | 来源 |
|---|------|------|
| ✅ | 加权概率(14/14/12/12/12/14/10/12) | React rollTargetIndex |
| ✅ | 8种惩罚：全场干杯/养鱼半杯/深水炸弹/贴身热舞/免死金牌/法式湿吻/绝对支配/欲擒故纵 | React translations |
| ✅ | 纯程序化音效(WAV合成) | React AudioEngine (Web Audio → Dart WAV) |
| ✅ | VinaHouse Drop 145BPM | React playVinaHouseDrop |
| ✅ | 四语完整翻译(ZH/EN/VI/JA) | React translations.ts |
| ✅ | 充电强度条(PWR) + 3枚能量球 | React charging bar + orbs |
| ✅ | 中心长按旋转按钮 | React center trigger button |
| ✅ | 底部指纹触摸区 | React fingerprint touch area |
| ✅ | 动态环境光 | React ambientGlow |
| ✅ | Settings面板(音效/语言/自定义) | React SettingsPanel |
| ✅ | BGM背景节拍 | React toggleAmbientClubBGM |
| ✅ | 胜利频闪(VinaDrop strobe) | React isDzoFlash |
| ✅ | 屏幕抖动+触觉反馈 | React shake+vibrate |

## 决策记录

- **平台:** Flutter (非H5/PWA)，覆盖iOS/Android/Web
- **状态管理:** Provider (轻量，够用)
- **音效:** 纯Dart WAV合成 (替代React的Web Audio API)，使用audioplayers BytesSource播放
- **网格布局:** 跟随React排列 (0-7重排：0全场干杯 1养鱼半杯 2深水炸弹 7欲擒故纵 3贴身热舞 6绝对支配 5法式湿吻 4免死金牌)
- **选人方式:** React使用自动方向+序号(保留)，Flutter弹窗选人(原先)未移植 — 保持React风格
