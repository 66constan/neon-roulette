import 'package:flutter/material.dart';
import '../models/penalty.dart';
import '../theme/neon_theme.dart';
import '../providers/game_provider.dart';
import '../i18n/translations.dart';

/// 3×3 penalty grid with center spin button.
class NeonGrid extends StatelessWidget {
  final GameProvider provider;

  const NeonGrid({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final state = provider.state;
    final i18n = provider.i18n;

    // React grid layout (index mapping):
    // Top:    0(ALL_CHEERS)  1(TEASE_SIP)  2(BOTTOMS_UP)
    // Mid:    7(BODY_SWAY)   [CENTER]      3(LAP_DANCE)
    // Bot:    6(DOMINATOR)   5(FRENCH_KISS) 4(FREE_PASS)
    const gridOrder = [0, 1, 2, 7, -1, 3, 6, 5, 4];

    return AspectRatio(
      aspectRatio: 1.0,
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(6),
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        children: List.generate(9, (flat) {
          final idx = gridOrder[flat];
          if (idx == -1) return const SizedBox.shrink(); // center slot

          final penalty = Penalty.fromIndex(idx);
          final color = parseHex(penalty.colorHex);
          final isHighlighted = state.highlightedIndex == idx;
          final isSelected = state.selectedIndex == idx;
          final dimmed = state.selectedIndex != null && !isSelected;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: surfaceDark.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? color
                    : isHighlighted
                        ? color.withValues(alpha: 0.7)
                        : color.withValues(alpha: 0.15),
                width: isSelected ? 2.5 : isHighlighted ? 2.0 : 1.0,
              ),
              boxShadow: isSelected
                  ? neonGlowIntense(color)
                  : isHighlighted
                      ? neonGlow(color, blur: 18)
                      : null,
            ),
            child: _buildCellContent(penalty, idx, isHighlighted, isSelected, dimmed, i18n),
          );
        }),
      ),
    );
  }

  Widget _buildCellContent(Penalty penalty, int idx, bool isHighlighted, bool isSelected, bool dimmed, I18n i18n) {
    final color = parseHex(penalty.colorHex);
    final opacity = dimmed ? 0.3 : 1.0;
    final title = penalty.type == PenaltyType.dominator
        ? '👑'
        : penalty.type == PenaltyType.freePass
            ? '🛡️'
            : penalty.type == PenaltyType.bodySway
                ? '🔄'
                : penalty.emoji;

    return Opacity(
      opacity: opacity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isSelected ? 34 : isHighlighted ? 30 : 26,
              shadows: isSelected || isHighlighted
                  ? [Shadow(color: color, blurRadius: 12)]
                  : null,
            ),
          ),
          const SizedBox(height: 2),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Text(
              i18n.penaltyTitle(idx),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSelected ? 13 : 11,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                shadows: isSelected ? [Shadow(color: color, blurRadius: 8)] : null,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
