/// 8 penalties with weighted probability matching React source.
enum PenaltyType {
  allCheers,     // 0: 全场干杯 (FREE_PASS_1)
  teaseSip,      // 1: 养鱼半杯 (HALF_DRINK_1)
  bottomsUp,     // 2: 深水炸弹 (FULL_SHOT_1)
  lapDance,      // 3: 贴身热舞 (LAP_DANCE_1) — needs partner
  freePass,      // 4: 免死金牌 (FREE_PASS_2)
  frenchKiss,    // 5: 法式湿吻 (KISS_1) — needs partner
  dominator,     // 6: 绝对支配 (FREE_PASS_3)
  bodySway,      // 7: 欲擒故纵 (ROCK_ME) — needs partner
}

class Penalty {
  final PenaltyType type;
  final String emoji;        // emoji for grid display
  final String colorHex;     // hex color for neon theme
  final int weight;          // probability weight (out of 100)
  final bool needsPartner;   // requires partner selection

  const Penalty({
    required this.type,
    required this.emoji,
    required this.colorHex,
    required this.weight,
    this.needsPartner = false,
  });

  static const List<Penalty> all = [
    // 0: 全场干杯 — everyone drinks together (weight 14)
    Penalty(type: PenaltyType.allCheers,   emoji: '🥂', colorHex: '#FFD700', weight: 14),
    // 1: 养鱼半杯 — tease sip (weight 14)
    Penalty(type: PenaltyType.teaseSip,    emoji: '🍹', colorHex: '#FF9100', weight: 14),
    // 2: 深水炸弹 — bottoms up (weight 12)
    Penalty(type: PenaltyType.bottomsUp,   emoji: '🍺', colorHex: '#FF4500', weight: 12),
    // 3: 贴身热舞 — lap dance (weight 12)
    Penalty(type: PenaltyType.lapDance,    emoji: '💃', colorHex: '#E040FB', weight: 12, needsPartner: true),
    // 4: 免死金牌 — free pass (weight 12)
    Penalty(type: PenaltyType.freePass,    emoji: '🛡️', colorHex: '#FFD700', weight: 12),
    // 5: 法式湿吻 — french kiss (weight 14)
    Penalty(type: PenaltyType.frenchKiss,  emoji: '💋', colorHex: '#FF2D7A', weight: 14, needsPartner: true),
    // 6: 绝对支配 — dominator (weight 10)
    Penalty(type: PenaltyType.dominator,   emoji: '👑', colorHex: '#FFD700', weight: 10),
    // 7: 欲擒故纵 — body sway (weight 12)
    Penalty(type: PenaltyType.bodySway,    emoji: '🔄', colorHex: '#00CFFF', weight: 12, needsPartner: true),
  ];

  static Penalty fromIndex(int index) => all[index];

  /// Weighted random index matching the React distribution.
  static int rollIndex() {
    final roll = _random.nextInt(100);
    if (roll < 12) return 0;   // ALL_CHEERS (12%)
    if (roll < 26) return 1;   // TEASE_SIP (14%)
    if (roll < 38) return 2;   // BOTTOMS_UP (12%)
    if (roll < 50) return 3;   // LAP_DANCE (12%)
    if (roll < 62) return 4;   // FREE_PASS (12%)
    if (roll < 76) return 5;   // KISS (14%)
    if (roll < 88) return 6;   // DOMINATOR (12%)
    return 7;                   // BODY_SWAY (12%)
  }
}

final _random = _SimpleRandom();

/// Minimal Deterministic-compatible random.
class _SimpleRandom {
  int _seed = DateTime.now().microsecondsSinceEpoch;
  int nextInt(int max) {
    _seed = (_seed * 1103515245 + 12345) & 0x7fffffff;
    return _seed % max;
  }
}
