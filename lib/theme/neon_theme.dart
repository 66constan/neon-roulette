import 'package:flutter/material.dart';

import '../models/penalty.dart';

// =============================================================================
// 颜色常量
// =============================================================================

const Color neonPink = Color(0xFFFF2D7A);
const Color neonBlue = Color(0xFF00CFFF);
const Color neonOrange = Color(0xFFFF6B1A);
const Color neonGold = Color(0xFFFFD700);
const Color bgDark = Color(0xFF0A0A0A);
const Color neonDeepPink = Color(0xFFFF1493);
const Color neonSalmon = Color(0xFFFF8C69);
const Color neonAmber = Color(0xFFFFA500);
const Color surface = Color(0xFF1A1A1A);
const Color surfaceLight = Color(0xFF2A2A2A);

// =============================================================================
// 字体定义
// =============================================================================

const TextTheme _neonTextTheme = TextTheme(
  /// 标题用：白色，粗体，字号32
  displayLarge: TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 4.0,
  ),
  /// 惩罚标题用：霓虹色，粗体，字号24
  titleLarge: TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: neonPink,
    letterSpacing: 2.0,
  ),
  /// 文案用：白色70%透明度，字号18
  bodyLarge: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.normal,
    color: Color(0xB3FFFFFF), // 70% opacity
  ),
  /// 副标题用：灰色，字号14
  bodyMedium: TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Color(0xFF888888),
  ),
);

// =============================================================================
// 主题定义
// =============================================================================

/// 霓虹轮盘全局主题 —— 纯黑背景，Material 3 暗色主题。
final ThemeData neonTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: bgDark,
  colorScheme: const ColorScheme.dark(
    primary: neonPink,
    secondary: neonBlue,
    surface: Color(0xFF1A1A1A),
    onPrimary: Colors.white,
    onSecondary: Colors.black,
    onSurface: Colors.white,
  ),
  textTheme: _neonTextTheme,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      letterSpacing: 2.0,
    ),
  ),
);

// =============================================================================
// 辅助函数
// =============================================================================

/// 根据惩罚类型返回对应的霓虹主题色。
Color penaltyColor(PenaltyType type) {
  switch (type) {
    case PenaltyType.freePass:
    case PenaltyType.freePassNext:
      return neonGold;
    case PenaltyType.kiss10s:
      return neonDeepPink;
    case PenaltyType.crossArm:
      return neonBlue;
    case PenaltyType.halfDrink:
      return neonAmber;
    case PenaltyType.rockMe:
      return neonSalmon;
    case PenaltyType.fullDrink:
      return neonOrange;
    case PenaltyType.kissReal:
      return neonPink;
  }
}

/// 生成霓虹发光阴影列表。
List<BoxShadow> neonGlow(Color color, {double blurRadius = 12.0}) {
  return [
    BoxShadow(
      color: color.withValues(alpha: 0.6),
      blurRadius: blurRadius,
      spreadRadius: 1.0,
    ),
    BoxShadow(
      color: color.withValues(alpha: 0.3),
      blurRadius: blurRadius * 2,
      spreadRadius: 2.0,
    ),
  ];
}
