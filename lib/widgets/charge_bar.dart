import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/neon_theme.dart';

/// Vertical neon charge bar — left side PWR indicator.
class ChargeBar extends StatelessWidget {
  final double progress; // 0.0–1.0
  final bool isFull;

  const ChargeBar({super.key, required this.progress, this.isFull = false});

  @override
  Widget build(BuildContext context) {
    final p = progress.clamp(0.0, 1.0);

    return Container(
      width: 22,
      decoration: BoxDecoration(
        color: surfaceDark.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFull ? Colors.yellow : parseHex('#FF1493').withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: isFull
            ? [BoxShadow(color: Colors.yellow.withValues(alpha: 0.6), blurRadius: 30)]
            : null,
      ),
      child: Column(
        children: [
          const SizedBox(height: 4),
          // MAX label
          Text(
            'MAX',
            style: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.w900,
              color: isFull ? Colors.yellow : parseHex('#FF1493'),
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 4),
          // Bar
          Expanded(
            child: Container(
              width: 12,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.black38, width: 0.5),
              ),
              child: Column(
                children: [
                  const Spacer(),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    height: max(2, p * 200),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      gradient: isFull
                          ? const LinearGradient(
                              colors: [Color(0xFFFF5252), Color(0xFFFFEB3B), Colors.white],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            )
                          : LinearGradient(
                              colors: [
                                parseHex('#FF1493'),
                                parseHex('#E040FB'),
                                parseHex('#FF5252'),
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                      boxShadow: [
                        BoxShadow(
                          color: isFull
                              ? Colors.yellow.withValues(alpha: 0.6)
                              : parseHex('#FF1493').withValues(alpha: 0.3 + p * 0.5),
                          blurRadius: isFull ? 25 : 5 + p * 20,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 2),
          // PWR label
          Text(
            'PWR',
            style: TextStyle(
              fontSize: 7,
              fontWeight: FontWeight.w800,
              color: isFull ? Colors.yellow : parseHex('#FF1493'),
            ),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
