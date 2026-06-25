import 'package:flutter/material.dart';
import '../models/penalty.dart';
import '../theme/neon_theme.dart';

/// Emoji + label for each penalty cell.
const Map<int, String> _penaltyEmoji = {
  0: '🎉',  // FREE PASS (纯免罚)
  1: '💋',  // 舌吻十秒
  2: '🍸',  // 交杯酒
  3: '🥃',  // 喝半杯
  4: '💃',  // ROCK ME
  5: '🍺',  // 喝一杯
  6: '💋',  // KISS
  7: '🎉',  // FREE PASS (下局加倍)
};

// =============================================================================
// NeonGrid — the 3×3 penalty grid
// =============================================================================

/// A 3×3 grid of penalty cells with a hole for the center button.
///
/// The grid has 9 positions (3 cols × 3 rows) but only 8 hold penalty cells.
/// The center slot (row 1, col 1 / flat index 4) is intentionally left empty
/// so that [CenterButton] can be overlaid on top.
class NeonGrid extends StatelessWidget {
  /// The penalty index (0-7) currently highlighted during the spin animation.
  final int? highlightedIndex;

  /// The penalty index (0-7) that was selected as the final result.
  /// When set, only this cell glows strongly; all others dim.
  final int? selectedIndex;

  /// Callback when a penalty cell is tapped (reserved for future use).
  final VoidCallback? onCellTap;

  const NeonGrid({
    super.key,
    this.highlightedIndex,
    this.selectedIndex,
    this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8.0),
      // 9 children: 8 penalties + 1 empty center placeholder.
      children: List.generate(9, (flatIndex) {
        // Center slot (flat index 4) is always empty.
        if (flatIndex == 4) {
          return const SizedBox.shrink();
        }

        // Map flat index to penalty index.
        final penaltyIndex = flatIndex < 4 ? flatIndex : flatIndex - 1;
        final penalty = Penalty.fromIndex(penaltyIndex);

        // Highlight logic.
        final isHighlighted = highlightedIndex == penaltyIndex;
        final isSelected = selectedIndex == penaltyIndex;

        // If a result has been selected, only that cell stays bright;
        // all others dim unless they are the selected one.
        final dimmed = selectedIndex != null && !isSelected;

        return _PenaltyCell(
          penalty: penalty,
          penaltyIndex: penaltyIndex,
          isHighlighted: isHighlighted,
          isSelected: isSelected,
          dimmed: dimmed,
          onTap: onCellTap,
        );
      }),
    );
  }
}

// =============================================================================
// _PenaltyCell — single penalty cell inside the grid
// =============================================================================

class _PenaltyCell extends StatelessWidget {
  final Penalty penalty;
  final int penaltyIndex;
  final bool isHighlighted;
  final bool isSelected;
  final bool dimmed;
  final VoidCallback? onTap;

  const _PenaltyCell({
    required this.penalty,
    required this.penaltyIndex,
    required this.isHighlighted,
    required this.isSelected,
    required this.dimmed,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = penaltyColor(penalty.type);
    final emoji = _penaltyEmoji[penaltyIndex] ?? '❓';

    // Determine glow strength.
    double glowAlpha;
    double blurRadius;
    if (isSelected) {
      glowAlpha = 0.9;
      blurRadius = 20.0;
    } else if (isHighlighted) {
      glowAlpha = 0.7;
      blurRadius = 16.0;
    } else {
      glowAlpha = 0.2;
      blurRadius = 6.0;
    }

    final cellOpacity = dimmed ? 0.35 : 1.0;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: cellOpacity,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: surface.withValues(alpha: 0.75),
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: themeColor.withValues(alpha: glowAlpha),
                width: isSelected || isHighlighted ? 2.0 : 1.0,
              ),
              boxShadow: neonGlow(
                themeColor,
                blurRadius: blurRadius,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  emoji,
                  style: TextStyle(
                    fontSize: 24,
                    shadows: [
                      Shadow(
                        color: themeColor.withValues(alpha: glowAlpha),
                        blurRadius: 8.0,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  penalty.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
