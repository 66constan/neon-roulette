# 霓虹轮盘 NEON ROULETTE — PRD v1.0

> **Author:** jiaweisi (AI CTO)
> **Based on:** CEO 游戏文案 v1.0 + 顶级派对游戏特性研究
> **Status:** Draft → Review
> **Target:** Flutter (iOS / Android / Web)

---

## 1. 产品概述

**一句话：** 夜店场景下的9宫格派对惩罚转盘，长按中心松手随机停格，展示惩罚内容。

**目标用户：** 酒吧/KTV/夜店聚会中的年轻人（18-35岁），越南+中文用户群。

**核心价值：** 用游戏机制打破社交尴尬，随机性制造惊喜，霓虹视觉契合夜店氛围。

---

## 2. CEO方案审查结论

### 2.1 通过项 ✅
- 9宫格布局设计合理，FREE PASS对角线分布制造"运气感"
- 8类惩罚内容丰富，覆盖轻度（喝半杯）→重度（KISS）
- 长按松手交互直觉友好
- 音效设计完整（蓄力嗡鸣→清脆叮→哒哒跳格→鼓点重音）
- 等概率12.5%简化开发

### 2.2 需明确项 ⚠️
| # | 问题 | 决策 |
|---|------|------|
| 1 | 格子7"下局加倍"未定义"加倍" | **决策：** 「喝」类惩罚量翻倍（半杯→一杯，一杯→两杯），非「喝」类惩罚时间翻倍（10秒→20秒，30秒→60秒）。用 `nextRoundMultiplier` 状态管理，仅影响紧接的下一局 |
| 2 | H5/PWA vs Flutter | **决策：** CEO指令为 Flutter，覆盖 iOS/Android/Web 三端 |
| 3 | 视觉资产缺失（KISS/ROCK ME/交杯酒插画） | **决策：** MVP用文字+Emoji占位，视觉资产标记为P2迭代 |

### 2.3 补充特性（来自顶级派对游戏研究）

基于 Picolo、Drink Roulette、Party Roulette、Truth or Dare 等 App Store/Google Play 排名前列派对游戏的设计模式：

| 特性 | 来源游戏 | 优先级 |
|------|---------|--------|
| 霓虹粒子背景动画 | NeonMob / 夜店主题游戏 | P0 |
| 触觉反馈（长按震动+停格脉冲） | 所有顶级派对App标配 | P0 |
| 背景BGM（夜店电子循环） | Drink Roulette | P1 |
| 结果弹窗动画（弹入+霓虹闪烁） | Party Roulette | P0 |
| 连胜/连败追踪 | Picolo | P1 |
| 单局历史时间线 | Heads Up! | P2 |
| 多语言（中/越） | 目标市场刚需 | P1 |

---

## 3. 技术架构

```
neon-roulette/
├── lib/
│   ├── main.dart                    # 入口，MaterialApp + 主题
│   ├── app.dart                     # App widget
│   ├── models/
│   │   ├── game_state.dart          # 游戏状态枚举
│   │   ├── penalty.dart             # 8种惩罚数据模型
│   │   ├── grid_item.dart           # 9宫格单元模型
│   │   └── player.dart              # 玩家模型（选人交互用）
│   ├── providers/
│   │   ├── game_provider.dart       # 核心游戏状态管理
│   │   └── audio_provider.dart      # 音效/BGM管理
│   ├── screens/
│   │   └── game_screen.dart         # 唯一主屏
│   ├── widgets/
│   │   ├── neon_grid.dart           # 9宫格组件
│   │   ├── center_button.dart       # 中心长按按钮
│   │   ├── penalty_card.dart        # 惩罚结果卡片
│   │   ├── player_picker.dart       # 挑人弹窗（10s倒计时）
│   │   ├── neon_background.dart     # 霓虹粒子背景
│   │   └── bottom_bar.dart          # 底部操作栏
│   ├── services/
│   │   ├── audio_service.dart       # 音效播放
│   │   ├── haptic_service.dart      # 触觉反馈
│   │   └── random_service.dart      # 随机算法
│   └── theme/
│       └── neon_theme.dart          # 霓虹主题定义
├── assets/
│   ├── audio/                       # 音效文件（MP3/OGG）
│   │   ├── charge_up.mp3            # 蓄力嗡鸣
│   │   ├── trigger_ding.mp3         # 触发叮声
│   │   ├── tick.mp3                 # 跳格哒声
│   │   ├── stop_hit.mp3             # 停格鼓点
│   │   └── bgm_loop.mp3             # 背景循环
│   └── images/                      # 占位/视觉素材
├── pubspec.yaml
└── test/
    ├── models/
    │   └── penalty_test.dart
    ├── providers/
    │   └── game_provider_test.dart
    └── widgets/
        └── neon_grid_test.dart
```

**技术选型：**
| 项 | 选择 | 理由 |
|----|------|------|
| 状态管理 | Provider | 轻量，Flutter官方推荐，够用 |
| 动画 | 内置 AnimationController + Tween | 无需第三方，霓虹发光用ShaderMask |
| 音频 | audioplayers | 最流行的Flutter音频插件 |
| 触觉 | HapticFeedback (内置) | Flutter SDK自带，无额外依赖 |
| 测试 | flutter_test | 内置框架 |

---

## 4. 核心流程

```
[启动] → [空闲态:9宫格全亮,中心显示"长按松手随机"]
    ↓ 长按
[蓄力态:中心按钮收缩,嗡鸣渐强,触觉反馈连续]
    ↓ 松手
[旋转态:格子依次高亮跳变,哒声由快→慢,约2秒]
    ↓ 停止
[结果态:目标格放大霓虹闪烁,鼓点重音,展示惩罚卡片]
    ↓
    ├─ 单人惩罚(喝半杯/喝一杯/FREE PASS) → 直接展示,无选人
    └─ 双人惩罚(舌吻/交杯酒/ROCK ME/KISS) → 弹出选人界面,10s倒计时
          ↓
          ├─ 手动选人 → 展示结果:A 🤝 B
          └─ 超时 → 随机指定 → 展示结果
    ↓
[点击"再来一局"] → 回到空闲态
```

---

## 5. 状态机

```
States:
  IDLE        → 9宫格静止，中心显示"长按中心·松手随机"
  CHARGING    → 长按中，嗡鸣音效，按钮缩放动画
  SPINNING    → 格子跳变高亮，哒声由快→慢
  STOPPING    → 停格瞬间，鼓点重音
  RESULT      → 惩罚卡片展示
  PICKING     → 挑人弹窗，10s倒计时（仅双人惩罚时触发）
```

**转换规则：**
```
IDLE ──[长按>300ms]──→ CHARGING
CHARGING ──[松手]──→ SPINNING
SPINNING ──[2s后]──→ STOPPING
STOPPING ──[动画结束]──→ RESULT
RESULT ──[需要选人]──→ PICKING
PICKING ──[人选确定/超时]──→ RESULT
RESULT ──[点"再来一局"]──→ IDLE
```

---

## 6. 数据模型

```dart
enum PenaltyType {
  freePass,      // 格子0: 纯免罚
  freePassNext,  // 格子7: 免罚但下局加倍
  kiss10s,       // 格子1: 舌吻十秒
  crossArm,      // 格子2: 交杯酒
  halfDrink,     // 格子3: 喝半杯
  rockMe,        // 格子4: ROCK ME
  fullDrink,     // 格子5: 喝一杯
  kissReal,      // 格子6: KISS
}

class Penalty {
  final PenaltyType type;
  final String title;
  final String subtitle;
  final String fullText;
  final Color themeColor;
  final bool needsPicker;  // 是否需要挑人
  final int timerSeconds;  // 选人倒计时秒数
}

class GameState {
  GamePhase phase;           // IDLE | CHARGING | SPINNING | STOPPING | RESULT | PICKING
  int? selectedGridIndex;    // 最终停格位置 0-7
  Penalty? currentPenalty;
  double nextRoundMultiplier; // 1.0 或 2.0（格子7触发后）
  int streakCount;           // 连续惩罚次数
  List<RoundResult> history; // 历史记录
}
```

---

## 7. 格子→惩罚映射

| Index | 位置 | Type | 需要选人 | 颜色 | 持续/量 |
|-------|------|------|---------|------|--------|
| 0 | 左上 | freePass | ❌ | #FFD700 | - |
| 1 | 右上 | kiss10s | ✅ | #FF1493 | 10s |
| 2 | 左中 | halfDrink | ❌ | #FFA500 | 半杯 |
| 3 | 中左 | halfDrink(同2) | ❌ | #FFA500 | 半杯 |
| Start | 中心 | - | - | - | - |
| 4 | 中右 | rockMe | ✅ | #FF8C69 | 30s |
| 5 | 左下 | fullDrink | ❌ | #FF6B1A | 一杯 |
| 6 | 右下 | kissReal | ✅ | #FF2D7A | - |
| 7 | 下中 | freePassNext | ❌ | #FFD700 | - |

> ⚠️ **注意：** CEO文档9宫格布局中只有8个惩罚格（格子0-7）+1个中心按钮。格子索引与文档图一致。

---

## 8. "下局加倍"机制

触发格子7（右下FREE PASS）后：
- `nextRoundMultiplier = 2.0`
- 「喝」类惩罚（halfDrink/fullDrink）：量翻倍显示
- 「非喝」类惩罚（kiss10s/rockMe）：时间翻倍
- 该倍率仅影响紧接的 **下一局**，用后重置为1.0
- 如果下一局又是格子7，倍率叠加到4.0（极小概率，但逻辑支持）

---

## 9. 音效时序

| 阶段 | 音频文件 | 时长 | 备注 |
|------|---------|------|------|
| 长按蓄力 | charge_up.mp3 | 无限循环 | pitch随蓄力时间升高 |
| 松手触发 | trigger_ding.mp3 | 0.3s | 清脆金属"叮" |
| 跳格旋转 | tick.mp3 | 每跳一次 | 间隔从50ms→300ms逐渐变慢 |
| 最终停止 | stop_hit.mp3 | 0.5s | 鼓点重音 |
| 背景循环 | bgm_loop.mp3 | 30s | 低音量夜店电子循环 |

---

## 10. 验收标准

| # | 标准 | 验证方式 |
|---|------|---------|
| AC1 | 长按中心>300ms触发CHARGING状态，松手即开始旋转 | 手动测试 |
| AC2 | 旋转动画约2秒，跳变速度由快→慢 | 肉眼+秒表 |
| AC3 | 停格后正确展示对应惩罚卡片 | 遍历8格各触发3次 |
| AC4 | 双人惩罚弹出选人界面，10秒倒计时 | 触发舌吻/交杯酒/ROCK ME/KISS |
| AC5 | 倒计时超时自动随机选人 | 等待10秒 |
| AC6 | 格子7触发后下局加倍生效 | 触发格子7→再玩一局验证文案 |
| AC7 | 音效在正确时机播放 | 耳朵听 |
| AC8 | 触觉反馈在长按/停格时触发 | 真机测试 |
| AC9 | 霓虹粒子背景持续运行 | 肉眼 |
| AC10 | "再来一局"重置状态，进入新局 | 点击"再来一局"→回到IDLE |

---

*PRD v1.0 — 待CEO确认后进入Kanban拆解阶段*
