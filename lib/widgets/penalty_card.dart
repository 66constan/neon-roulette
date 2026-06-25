import 'package:flutter/material.dart';

import '../models/penalty.dart';
import '../theme/neon_theme.dart';

/// Emoji mapping keyed by [PenaltyType].
const Map<PenaltyType, String> _penaltyEmojiByType = {
  PenaltyType.freePass: '🎉',
  PenaltyType.freePassNext: '🎉',
  PenaltyType.kiss10s: '💋',
  PenaltyType.crossArm: '🍸',
  PenaltyType.halfDrink: '🥃',
  PenaltyType.rockMe: '💃',
  PenaltyType.fullDrink: '🍺',
  PenaltyType.kissReal: '💋',
};

// =============================================================================
// PenaltyCard — bottom-sliding penalty result overlay
// =============================================================================

/// An animated card that slides up from the bottom to display the current
/// penalty result. Supports a multiplier badge when the penalty is doubled.
class PenaltyCard extends StatelessWidget {
  /// The penalty to display.
  final Penalty penalty;

  /// Multiplier applied to this penalty (default 1.0).
  final double multiplier;

  /// Controls whether the card is visible / animated in.
  final bool isVisible;

  const PenaltyCard({
    super.key,
    required this.penalty,
    this.multiplier = 1.0,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = penaltyColor(penalty.type);
    final String emoji = _penaltyEmojiByType[penalty.type] ?? '❓';

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      left: 16,
      right: 16,
      bottom: isVisible ? 20 : -400,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 400),
        opacity: isVisible ? 1.0 : 0.0,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(
              color: color.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: neonGlow(color, blurRadius: 16.0),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ---- Title with neon glow ----
              Text(
                penalty.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                  letterSpacing: 2.0,
                  shadows: [
                    Shadow(
                      color: color.withValues(alpha: 0.8),
                      blurRadius: 12.0,
                    ),
                    Shadow(
                      color: color.withValues(alpha: 0.4),
                      blurRadius: 24.0,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // ---- Emoji ----
              Text(
                emoji,
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 12),

              // ---- Full description text ----
              Text(
                penalty.fullText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.normal,
                  color: Color(0xB3FFFFFF), // 70% opacity white
                ),
              ),

              // ---- Multiplier warning badge ----
              if (multiplier > 1.0) ...[
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    color: neonOrange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: neonOrange.withValues(alpha: 0.6),
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    '⚡ 加倍惩罚生效中 ×${multiplier.toStringAsFixed(0)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: neonOrange,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
