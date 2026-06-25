import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../theme/neon_theme.dart';

// =============================================================================
// BottomBar — status / instruction bar at the foot of the screen
// =============================================================================

/// A compact bar (60 px tall) that shows context-sensitive instructions
/// based on the current [GamePhase].
///
/// If [statusText] is provided it overrides the default phase text,
/// allowing the parent to inject dynamic content (e.g. penalty details).
class BottomBar extends StatelessWidget {
  final GamePhase phase;
  final String? statusText;

  const BottomBar({
    super.key,
    required this.phase,
    this.statusText,
  });

  // ---------------------------------------------------------------------------
  // Phase → default text
  // ---------------------------------------------------------------------------

  String _defaultText(GamePhase phase) {
    switch (phase) {
      case GamePhase.idle:
        return '🔊 长按中心 · 松手随机';
      case GamePhase.charging:
        return '🔊 蓄力中...';
      case GamePhase.spinning:
        return '🔊 旋转中...';
      case GamePhase.stopping:
        return '🔊 ...';
      case GamePhase.result:
        return ''; // main button handles "再来一局"
      case GamePhase.picking:
        return '👆 请选择一位玩家';
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final text = statusText ?? _defaultText(phase);

    // Result phase: show the replay button inline.
    if (phase == GamePhase.result && statusText == null) {
      return Container(
        height: 60,
        decoration: BoxDecoration(
          color: surface,
          border: Border(
            top: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1.0,
            ),
          ),
        ),
        child: const Center(
          child: Text(
            '',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white60,
            ),
          ),
        ),
      );
    }

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: surface,
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
            width: 1.0,
          ),
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white60,
            ),
          ),
        ),
      ),
    );
  }
}
