import 'dart:math';

/// 8 penalty types.
enum PenaltyType {
  allCheers,    // 0: 全场干杯 (10%)
  teaseSip,     // 1: 养鱼半杯 (30%)
  bottomsUp,    // 2: 深水炸弹 (4%)
  lapDance,     // 3: 贴身热舞 (4%)
  freePass,     // 4: 免死金牌 (40%)
  frenchKiss,   // 5: 法式湿吻 (4%)
  dominator,    // 6: 绝对支配 (4%)
  bodySway,     // 7: 欲擒故纵 (4%)
}

class Penalty {
  final PenaltyType type;
  final String emoji;

  const Penalty({
    required this.type,
    required this.emoji,
  });

  static const List<String> colors = [
    '#FFD700',   // 0: 全场干杯 (金)
    '#FF9100',   // 1: 养鱼半杯 (橙)
    '#FF4500',   // 2: 深水炸弹 (红橙)
    '#E040FB',   // 3: 贴身热舞 (紫)
    '#FFD700',   // 4: 免死金牌 (金)
    '#FF2D7A',   // 5: 法式湿吻 (粉)
    '#FFD700',   // 6: 绝对支配 (金)
    '#00CFFF',   // 7: 欲擒故纵 (青)
  ];

  static String colorHex(int index) => colors[index];

  static const List<Penalty> all = [
    Penalty(type: PenaltyType.allCheers,  emoji: '🥂'),
    Penalty(type: PenaltyType.teaseSip,   emoji: '🍹'),
    Penalty(type: PenaltyType.bottomsUp,  emoji: '🍺'),
    Penalty(type: PenaltyType.lapDance,   emoji: '💃'),
    Penalty(type: PenaltyType.freePass,   emoji: '🛡️'),
    Penalty(type: PenaltyType.frenchKiss, emoji: '💋'),
    Penalty(type: PenaltyType.dominator,  emoji: '👑'),
    Penalty(type: PenaltyType.bodySway,   emoji: '🔄'),
  ];

  static Penalty fromIndex(int index) => all[index];

  /// Weighted random: 全场干杯10%, 养鱼半杯30%, 免死金牌40%, 其余各4%.
  static int rollIndex() {
    final roll = Random().nextInt(100);
    if (roll < 10) return 0;   // ALL_CHEERS (10%)
    if (roll < 40) return 1;   // TEASE_SIP (30%)
    if (roll < 44) return 2;   // BOTTOMS_UP (4%)
    if (roll < 48) return 3;   // LAP_DANCE (4%)
    if (roll < 88) return 4;   // FREE_PASS (40%)
    if (roll < 92) return 5;   // FRENCH_KISS (4%)
    if (roll < 96) return 6;   // DOMINATOR (4%)
    return 7;                   // BODY_SWAY (4%)
  }
}
