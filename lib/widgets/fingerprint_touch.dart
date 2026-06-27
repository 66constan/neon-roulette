import 'package:flutter/material.dart';
import '../theme/neon_theme.dart';

/// Bottom large touch area with fingerprint icons.
class FingerprintTouch extends StatelessWidget {
  final bool isCharging;
  final VoidCallback? onLongPressStart;
  final VoidCallback? onLongPressEnd;

  const FingerprintTouch({
    super.key,
    this.isCharging = false,
    this.onLongPressStart,
    this.onLongPressEnd,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: onLongPressStart != null
          ? (_) => onLongPressStart!()
          : null,
      onLongPressEnd: onLongPressEnd != null
          ? (_) => onLongPressEnd!()
          : null,
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: surfaceDark.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isCharging
                ? parseHex('#FF1493').withValues(alpha: 0.5)
                : parseHex('#FF1493').withValues(alpha: 0.15),
          ),
          boxShadow: isCharging
              ? [BoxShadow(color: parseHex('#FF1493').withValues(alpha: 0.15), blurRadius: 20)]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Icon(
                Icons.fingerprint,
                size: 48,
                color: isCharging
                    ? parseHex('#FF1493').withValues(alpha: 0.6)
                    : Colors.white.withValues(alpha: 0.15),
              ),
            );
          }),
        ),
      ),
    );
  }
}
