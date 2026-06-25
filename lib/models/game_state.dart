import 'penalty.dart';

/// 游戏阶段状态机枚举。
enum GamePhase {
  /// 空闲状态，等待用户开始。
  idle,

  /// 用户长按中心按钮蓄力中。
  charging,

  /// 转盘旋转动画进行中。
  spinning,

  /// 旋转即将停止（减速阶段最后一步）。
  stopping,

  /// 结果显示阶段。
  result,

  /// 需要挑选玩家（倒计时中）。
  picking,
}

/// 不可变的游戏状态快照，通过 [copyWith] 产生新状态。
class GameState {
  final GamePhase phase;
  final int? selectedIndex;
  final Penalty? currentPenalty;
  final double nextRoundMultiplier;
  final int streakCount;

  const GameState({
    required this.phase,
    this.selectedIndex,
    this.currentPenalty,
    this.nextRoundMultiplier = 1.0,
    this.streakCount = 0,
  });

  /// 初始空闲状态。
  factory GameState.initial() => const GameState(
        phase: GamePhase.idle,
        nextRoundMultiplier: 1.0,
        streakCount: 0,
      );

  GameState copyWith({
    GamePhase? phase,
    int? selectedIndex,
    Penalty? currentPenalty,
    double? nextRoundMultiplier,
    int? streakCount,
    bool clearSelectedIndex = false,
    bool clearCurrentPenalty = false,
  }) {
    return GameState(
      phase: phase ?? this.phase,
      selectedIndex:
          clearSelectedIndex ? null : (selectedIndex ?? this.selectedIndex),
      currentPenalty: clearCurrentPenalty
          ? null
          : (currentPenalty ?? this.currentPenalty),
      nextRoundMultiplier: nextRoundMultiplier ?? this.nextRoundMultiplier,
      streakCount: streakCount ?? this.streakCount,
    );
  }
}
