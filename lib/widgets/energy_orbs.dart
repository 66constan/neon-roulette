import 'package:flutter/material.dart';
import '../theme/neon_theme.dart';

/// Three energy orbs at top — charge level indicator.
class EnergyOrbs extends StatelessWidget {
  final int count; // 0–3

  const EnergyOrbs({super.key, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (i) {
        final filled = i < count;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 24,
          height: 24,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? parseHex('#FF1493') : Colors.transparent,
            border: Border.all(
              color: filled ? parseHex('#FF1493') : parseHex('#E040FB').withValues(alpha: 0.3),
              width: 2.5,
            ),
            boxShadow: filled
                ? [BoxShadow(color: parseHex('#FF1493').withValues(alpha: 0.6), blurRadius: 20)]
                : null,
          ),
        );
      }),
    );
  }
}
