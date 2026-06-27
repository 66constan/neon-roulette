import 'package:flutter/material.dart';
import '../models/game_state.dart';
import '../theme/neon_theme.dart';

/// Center spin button with long-press to charge.
class CenterButton extends StatelessWidget {
  final GamePhase phase;
  final String label;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;
  final VoidCallback? onTap;

  const CenterButton({
    super.key,
    required this.phase,
    required this.label,
    this.onLongPressStart,
    this.onLongPressEnd,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isIdle = phase == GamePhase.idle;
    final isCharging = phase == GamePhase.charging;
    final isSpinning = phase == GamePhase.spinning;
    final isResult = phase == GamePhase.result;

    return GestureDetector(
      onLongPressStart: isIdle ? (_) => onLongPressStart?.call() : null,
      onLongPressEnd: isCharging ? (_) => onLongPressEnd?.call() : null,
      onLongPressCancel: isCharging ? onLongPressEnd : null,
      onTap: isResult ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFFFF1493), Color(0xFFFF6B1A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: parseHex('#FF1493').withValues(alpha: isCharging ? 0.8 : 0.4),
              blurRadius: isCharging ? 40 : 20,
              spreadRadius: isCharging ? 8 : 2,
            ),
          ],
        ),
        child: Center(
          child: isSpinning
              ? const SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
        ),
      ),
    );
  }
}
