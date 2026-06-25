# 🎰 NEON ROULETTE 霓虹轮盘

> 夜店惩罚转盘游戏 · Nightclub Penalty Roulette Game

A Flutter-based party game featuring a glowing 3×3 penalty grid with neon aesthetics.
Spin the wheel, face your fate, and drink up! 🍻

---

## 📸 Screenshots / 截图

<!-- TODO: Add screenshots here -->
| Idle / 空闲 | Spinning / 旋转中 | Result / 结果 |
|:-----------:|:-----------------:|:-------------:|
| ![idle](docs/screenshots/idle.png) | ![spinning](docs/screenshots/spinning.png) | ![result](docs/screenshots/result.png) |

---

## 🛠 Tech Stack / 技术栈

| Technology | Purpose |
|:-----------|:--------|
| **Flutter** 3.16+ | Cross-platform UI framework |
| **Dart** 3.2+ | Programming language |
| **Provider** ^6.1.1 | State management (ChangeNotifier) |
| **audioplayers** ^5.2.1 | Sound effects & BGM |

---

## 🚀 Getting Started / 如何运行

### Prerequisites / 前置条件

- Flutter SDK >= 3.16.0
- Dart SDK >= 3.2.0
- Android Studio / Xcode (for device/emulator)

### Install & Run / 安装运行

```bash
# Clone the repository
git clone <repo-url>
cd neon-roulette

# Install dependencies
flutter pub get

# Run on connected device
flutter run
```

### Run Tests / 运行测试

```bash
# Run all tests
flutter test

# Run specific test files
flutter test test/providers/game_provider_test.dart
flutter test test/models/penalty_test.dart
flutter test test/widget_test.dart
```

---

## 📁 Project Structure / 项目结构

```
neon-roulette/
├── lib/
│   ├── main.dart                    # App entry point & Provider setup
│   ├── models/
│   │   ├── game_state.dart          # GamePhase enum & GameState model
│   │   ├── penalty.dart             # PenaltyType enum & Penalty model (8 slots)
│   │   └── player.dart              # Player data model
│   ├── providers/
│   │   └── game_provider.dart       # Game state machine (ChangeNotifier)
│   ├── screens/
│   │   └── game_screen.dart         # Main game screen UI
│   ├── services/
│   │   ├── audio_service.dart       # Sound effects & BGM
│   │   ├── haptic_service.dart      # Haptic feedback
│   │   └── random_service.dart      # Spin sequence generation
│   ├── theme/
│   │   └── neon_theme.dart          # Neon color palette & glow effects
│   └── widgets/
│       ├── bottom_bar.dart          # Context-sensitive status bar
│       ├── center_button.dart        # Long-press start / replay button
│       ├── neon_background.dart      # Animated particle background
│       ├── neon_grid.dart            # 3×3 penalty grid
│       ├── penalty_card.dart         # Result display card
│       └── player_picker.dart       # Player selection overlay
├── test/
│   ├── widget_test.dart             # Widget rendering & smoke tests
│   ├── models/
│   │   └── penalty_test.dart        # Penalty model unit tests
│   └── providers/
│       └── game_provider_test.dart  # Game state machine tests
├── assets/
│   └── audio/                       # Sound effect files
├── pubspec.yaml                     # Project dependencies
└── README.md                        # This file
```

---

## 🎮 Game Rules / 游戏规则

### Overview / 概述

NEON ROULETTE is a party drinking game for 4 players. One player holds the center button,
releases to spin, and the wheel lands on a penalty slot. Penalties include drinking,
kissing, dancing, and more!

霓虹轮盘是一款4人夜店派对惩罚游戏。玩家长按中心按钮后松手，转盘随机停在一个惩罚格子上，
惩罚内容包括喝酒、接吻、跳舞等！

### Game Flow / 游戏流程

```
   ┌──────┐   长按     ┌──────────┐   松手     ┌──────────┐
   │ IDLE │ ────────→ │ CHARGING │ ────────→ │ SPINNING │
   └──────┘           └──────────┘           └────┬─────┘
       ↑                                         │
       │                                   动画完成 │
       │              ┌────────┐           ┌──────↓──────┐
       │    再来一局    │ RESULT │ ←─────── │  STOPPING   │
       └──────────────└───┬────┘           └─────────────┘
                          │ ↑
                    挑人完成│ │需要挑人
                    ┌─────↓─┴─────┐
                    │   PICKING    │ (10s countdown)
                    └──────────────┘
```

### Penalty Slots / 惩罚格子 (0-7)

| Index | Type | Title | Description | Needs Picker |
|:-----:|:-----|:------|:------------|:------------:|
| 0 | 🎉 FREE PASS | FREE PASS | 运气真好，直接跳过 | ❌ |
| 1 | 💋 KISS 10s | 舌·吻·十·秒 | 选一个人，十秒不能停 | ✅ |
| 2 | 🍸 CROSS ARM | 交·杯·酒 | 手臂交叉共饮 | ✅ |
| 3 | 🥃 HALF DRINK | 喝·半·杯 | 小惩大诫 | ❌ |
| 4 | 💃 ROCK ME | ROCK ME | 坐上去摇30秒 | ✅ |
| 5 | 🍺 FULL DRINK | 喝·一·杯 | 干了它，不能留一滴 | ❌ |
| 6 | 💋 KISS | K·I·S·S | 真·嘴·对·嘴 | ✅ |
| 7 | 🎉 FREE PASS+ | FREE PASS | 免了，但下局加倍 ⚡ | ❌ |

### Multiplier System / 加倍机制

- Landing on **FREE PASS (下局加倍)** sets the next round's multiplier to **×2**
- Consecutive free-pass-next landings stack: ×2 → ×4 → ×8 ...
- At ×2: "喝半杯" becomes "喝一杯", "喝一杯" becomes "喝两杯"
- Landing on any normal penalty resets the multiplier to ×1

---

## 🎯 3×3 Grid Layout / 9宫格布局

```
┌──────────────┬──────────────┬──────────────┐
│              │              │              │
│  [0] 🎉      │  [1] 💋      │  [2] 🍸      │
│  FREE PASS   │  舌吻十秒     │  交杯酒       │
│              │              │              │
├──────────────┼──────────────┼──────────────┤
│              │              │              │
│  [3] 🥃      │   ⭕ START   │  [4] 💃      │
│  喝半杯       │   长按中心    │  ROCK ME     │
│              │              │              │
├──────────────┼──────────────┼──────────────┤
│              │              │              │
│  [5] 🍺      │  [6] 💋      │  [7] 🎉⚡    │
│  喝一杯       │  KISS        │  FREE PASS   │
│              │              │  下局加倍      │
└──────────────┴──────────────┴──────────────┘
```

---

## 🧪 Testing / 测试

### Unit Tests

- **GameProvider** — Full state machine lifecycle: idle → charging → spinning → result/picking → idle
- **Penalty Model** — All 8 penalty types, copyWith, needsPicker/timerSeconds validation

### Widget Tests

- **NeonGrid** — Smoke tests that the 3×3 grid renders
- **CenterButton** — Verifies correct label text per GamePhase
- **BottomBar** — Verifies contextual status text per GamePhase

---

## 📄 License / 许可证

MIT License

Copyright (c) 2024 NEON ROULETTE

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
