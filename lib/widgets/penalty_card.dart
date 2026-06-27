import 'package:flutter/material.dart';
import '../models/penalty.dart';
import '../theme/neon_theme.dart';

/// Result card showing penalty details.
class PenaltyCard extends StatelessWidget {
  final int penaltyIndex;
  final String title;
  final String subtitle;
  final String description;
  final String colorHex;
  final bool showPlayAgain;
  final VoidCallback? onPlayAgain;

  const PenaltyCard({
    super.key,
    required this.penaltyIndex,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.colorHex,
    this.showPlayAgain = false,
    this.onPlayAgain,
  });

  @override
  Widget build(BuildContext context) {
    final color = parseHex(colorHex);
    final penalty = Penalty.fromIndex(penaltyIndex);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: surfaceDark.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 25, spreadRadius: 2),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            penalty.emoji,
            style: TextStyle(fontSize: 40, shadows: [Shadow(color: color, blurRadius: 15)]),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 2,
              shadows: [Shadow(color: color, blurRadius: 10)],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 13, color: color.withValues(alpha: 0.85)),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.white.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 12),
          if (showPlayAgain && onPlayAgain != null)
            GestureDetector(
              onTap: onPlayAgain,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: color, width: 1.5),
                  boxShadow: [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 12)],
                ),
                child: Text(
                  '再来一局 🎰',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
