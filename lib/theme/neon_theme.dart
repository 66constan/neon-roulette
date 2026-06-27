import 'package:flutter/material.dart';

/// Neon theme colors and glow utilities.
const Color bgDark = Color(0xFF030712);
const Color surfaceDark = Color(0xFF0c0211);

Color parseHex(String hex) {
  hex = hex.replaceFirst('#', '');
  if (hex.length == 6) hex = 'FF$hex';
  return Color(int.parse(hex, radix: 16));
}

/// Single neon glow box shadow.
List<BoxShadow> neonGlow(Color color, {double blur = 12, double spread = 0}) {
  return [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: blur, spreadRadius: spread)];
}

/// Intense glow for selected cells.
List<BoxShadow> neonGlowIntense(Color color) {
  return [
    BoxShadow(color: color, blurRadius: 30, spreadRadius: 2),
    BoxShadow(color: color.withValues(alpha: 0.6), blurRadius: 60, spreadRadius: 5),
  ];
}

final ThemeData neonTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: bgDark,
  colorScheme: ColorScheme.dark(
    primary: parseHex('#FF2D7A'),
    secondary: parseHex('#E040FB'),
    surface: surfaceDark,
  ),
  fontFamily: 'Inter',
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
  ),
);
