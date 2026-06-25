import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/game_state.dart';
import '../models/penalty.dart';
import '../models/player.dart';

/// 霓虹轮盘游戏状态机，基于 [ChangeNotifier]。
///
/// 生命周期:
///   idle → charging → spinning → stopping → result → (picking → result) → idle
///
/// API 契约（供 Phase 1B 和 Phase 2 使用）:
///   - provider.state.phase: GamePhase
///   - provider.state.currentPenalty: Penalty?
///   - provider.state.selectedIndex: int?
///   - provider.state.nextRoundMultiplier: double
///   - provider.players: List<Player>
///   - provider.startCharging()
///   - provider.stopChargingAndSpin()
///   - provider.selectPlayer(Player)
///   - provider.nextRound()
///   - provider.getEffectivePenalty(Penalty): Penalty
class GameProvider extends ChangeNotifier {
  final Random _random = Random();

  // ===========================================================================
  // State
  // ===========================================================================

  GameState _state = GameState.initial();

  /// 当前游戏状态快照。
  GameState get state => _state;

  // ===========================================================================
  // Players
  // ===========================================================================

  List<Player> _players = Player.defaultPlayers();

  /// 当前玩家列表。
  List<Player> get players => List.unmodifiable(_players);

  // ===========================================================================
  // Transition: idle → charging
  // ===========================================================================

  /// 用户开始长按中心按钮，进入蓄力阶段。
  void startCharging() {
    _state = _state.copyWith(
      phase: GamePhase.charging,
      clearSelectedIndex: true,
      clearCurrentPenalty: true,
    );
    notifyListeners();
  }

  // ===========================================================================
  // Transition: charging → spinning
  // ===========================================================================

  /// 用户松手，随机选 0-7 索引，进入旋转阶段。
  ///
  /// 旋转动画的实际延迟和跳格由 widget 层管理。widget 应在约 2 秒后调用
  /// [onSpinComplete]。
  ///
  /// 如果提供 [targetIndex]，则使用该索引（用于测试）。
  void stopChargingAndSpin({int? targetIndex}) {
    final index = targetIndex ?? _random.nextInt(8);
    _state = _state.copyWith(
      phase: GamePhase.spinning,
      selectedIndex: index, // 临时记录目标索引（widget 可用它做动画）
    );
    notifyListeners();
  }

  // ===========================================================================
  // Transition: spinning → stopping → result
  // ===========================================================================

  /// Widget 层在旋转动画完成后调用此方法。
  ///
  /// 设置最终停格位置、当前惩罚，并根据 [Penalty.needsPicker] 决定是否进入
  /// picking 阶段。
  void _onSpinComplete(int index) {
    final penalty = Penalty.fromIndex(index);

    _state = _state.copyWith(
      phase: GamePhase.stopping,
      selectedIndex: index,
      currentPenalty: penalty,
    );

    // 短暂延迟后进入 result（widget 层管理延迟）
    _state = _state.copyWith(
      phase: GamePhase.result,
      streakCount: _state.streakCount + 1,
    );

    // 如果需要挑人则进入 picking
    if (penalty.needsPicker) {
      _state = _state.copyWith(phase: GamePhase.picking);
    }

    notifyListeners();
  }

  /// Widget 层调用的公开入口 —— 等同于 _onSpinComplete。
  void onSpinComplete(int index) {
    _onSpinComplete(index);
  }

  // ===========================================================================
  // Picking phase
  // ===========================================================================

  /// 用户在 picking 阶段选中某个玩家，返回 result 阶段。
  void selectPlayer(Player player) {
    if (_state.phase != GamePhase.picking) return;
    _state = _state.copyWith(phase: GamePhase.result);
    notifyListeners();
  }

  /// 挑人倒计时超时，自动随机选人。
  void onPickTimeout() {
    if (_state.phase != GamePhase.picking) return;
    if (_players.isEmpty) return;
    final randomPlayer = _players[_random.nextInt(_players.length)];
    _state = _state.copyWith(phase: GamePhase.result);
    notifyListeners();
  }

  // ===========================================================================
  // Transition: result → idle (再来一局)
  // ===========================================================================

  /// 进入下一局。
  ///
  /// - 如果上一局的 [Penalty] 是 [PenaltyType.freePassNext]，设置
  ///   [nextRoundMultiplier] = 2.0。
  /// - 否则重置 [nextRoundMultiplier] 为 1.0。
  /// - 清除 selectedIndex 和 currentPenalty。
  void nextRound() {
    final wasFreePassNext =
        _state.currentPenalty?.type == PenaltyType.freePassNext;

    _state = _state.copyWith(
      phase: GamePhase.idle,
      clearSelectedIndex: true,
      clearCurrentPenalty: true,
      nextRoundMultiplier: wasFreePassNext ? 2.0 : 1.0,
    );
    notifyListeners();
  }

  // ===========================================================================
  // Full reset
  // ===========================================================================

  /// 完全重置游戏状态（清空连击、重置玩家列表等）。
  void resetGame() {
    _state = GameState.initial();
    _players = Player.defaultPlayers();
    notifyListeners();
  }

  // ===========================================================================
  // Multiplier helpers
  // ===========================================================================

  /// 根据当前 [nextRoundMultiplier] 返回调整后文案的 [Penalty]。
  ///
  /// 当 multiplier > 1.0 时，title 和 fullText 会调整以反映加倍效果
  /// （如 "喝半杯" → "喝一杯"、"喝一杯" → "喝两杯"）。
  Penalty getEffectivePenalty(Penalty p) {
    if (_state.nextRoundMultiplier <= 1.0) return p;

    // 构建加倍后的文案
    String adjustedTitle = p.title;
    String adjustedFullText = p.fullText;

    if (_state.nextRoundMultiplier == 2.0) {
      // 半杯 → 一杯
      if (p.type == PenaltyType.halfDrink) {
        adjustedTitle = '喝·一·杯';
        adjustedFullText = '干了它，不能留一滴！';
      }
      // 一杯 → 两杯
      if (p.type == PenaltyType.fullDrink) {
        adjustedTitle = '喝·两·杯';
        adjustedFullText = '双倍命运 — 两杯干了！';
      }
    } else if (_state.nextRoundMultiplier >= 4.0) {
      adjustedTitle = '${p.title} ×${_state.nextRoundMultiplier.toInt()}';
      adjustedFullText = '加倍惩罚！${p.fullText}';
    }

    return p.copyWith(
      title: adjustedTitle,
      fullText: adjustedFullText,
    );
  }
}
