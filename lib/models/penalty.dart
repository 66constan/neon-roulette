import 'package:flutter/material.dart';

/// 霓虹轮盘8种惩罚类型，按格子索引0-7排列。
enum PenaltyType {
  freePass,      // 格子0: 纯免罚
  freePassNext,  // 格子1: 免罚但下局加倍
  kiss10s,       // 格子2: 舌吻十秒
  crossArm,      // 格子3: 交杯酒
  halfDrink,     // 格子4: 喝半杯
  rockMe,        // 格子5: ROCK ME
  fullDrink,     // 格子6: 喝一杯
  kissReal,      // 格子7: KISS
}

/// 单个惩罚格子的完整数据模型。
class Penalty {
  final PenaltyType type;
  final String title;
  final String subtitle;
  final String fullText;
  final Color themeColor;
  final bool needsPicker;
  final int timerSeconds;

  const Penalty({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.fullText,
    required this.themeColor,
    this.needsPicker = false,
    this.timerSeconds = 0,
  });

  /// 返回8个格子的惩罚列表，按格子索引0-7排列（与PRD第7节映射一致）。
  ///
  /// 3×3 网格映射（跳过中心按钮位置）：
  ///   [0]  [1]  [2]
  ///   [3]   X   [4]
  ///   [5]  [6]  [7]
  /// 按 CEO 文档 9 宫格布局排列（0-7，跳过中心位置4）：
  /// ```
  /// [0:FREE PASS] [1:舌吻十秒] [2:交杯酒]
  /// [3:喝半杯]    [  开始  ]  [4:ROCK ME]
  /// [5:喝一杯]    [6:KISS]    [7:FREE PASS(下局加倍)]
  /// ```
  static List<Penalty> all() => const [
        // 格子0: 纯免罚（左上）
        Penalty(
          type: PenaltyType.freePass,
          title: 'FREE PASS',
          subtitle: '运气真好，直接跳过',
          fullText: '这一轮你直接跳过！',
          themeColor: Color(0xFFFFD700),
          needsPicker: false,
          timerSeconds: 0,
        ),
        // 格子1: 舌吻十秒
        Penalty(
          type: PenaltyType.kiss10s,
          title: '舌·吻·十·秒',
          subtitle: '选一个人，开始',
          fullText: '选一个人 — 十秒不能停',
          themeColor: Color(0xFFFF1493),
          needsPicker: true,
          timerSeconds: 10,
        ),
        // 格子2: 交杯酒
        Penalty(
          type: PenaltyType.crossArm,
          title: '交·杯·酒',
          subtitle: '手臂交叉共饮',
          fullText: '手臂交叉，选一人一起干',
          themeColor: Color(0xFF00CFFF),
          needsPicker: true,
          timerSeconds: 10,
        ),
        // 格子3: 喝半杯
        Penalty(
          type: PenaltyType.halfDrink,
          title: '喝·半·杯',
          subtitle: '小惩大诫',
          fullText: '来一口，小意思而已',
          themeColor: Color(0xFFFFA500),
          needsPicker: false,
          timerSeconds: 0,
        ),
        // 格子4: ROCK ME（中右）
        Penalty(
          type: PenaltyType.rockMe,
          title: 'ROCK ME',
          subtitle: 'Lắc Lư · 坐上来',
          fullText: '坐上去 — 摇啊摇，30秒',
          themeColor: Color(0xFFFF8C69),
          needsPicker: true,
          timerSeconds: 10,
        ),
        // 格子5: 喝一杯（左下）
        Penalty(
          type: PenaltyType.fullDrink,
          title: '喝·一·杯',
          subtitle: '命运选中了你',
          fullText: '干了它，不能留一滴！',
          themeColor: Color(0xFFFF6B1A),
          needsPicker: false,
          timerSeconds: 0,
        ),
        // 格子6: KISS（下中）
        Penalty(
          type: PenaltyType.kissReal,
          title: 'K · I · S · S',
          subtitle: '选一人，嘴对嘴',
          fullText: '选一个人 — 真·嘴·对·嘴',
          themeColor: Color(0xFFFF2D7A),
          needsPicker: true,
          timerSeconds: 10,
        ),
        // 格子7: FREE PASS 下局加倍（右下）
        Penalty(
          type: PenaltyType.freePassNext,
          title: 'FREE PASS',
          subtitle: '下局加倍 ⚡',
          fullText: '免了，但下一局惩罚加倍',
          themeColor: Color(0xFFFFD700),
          needsPicker: false,
          timerSeconds: 0,
        ),
      ];

  /// 按格子索引获取惩罚（0-7）。
  static Penalty fromIndex(int index) => all()[index];

  /// 创建一个副本，可覆盖 title/fullText（用于加倍文案）。
  Penalty copyWith({
    PenaltyType? type,
    String? title,
    String? subtitle,
    String? fullText,
    Color? themeColor,
    bool? needsPicker,
    int? timerSeconds,
  }) {
    return Penalty(
      type: type ?? this.type,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      fullText: fullText ?? this.fullText,
      themeColor: themeColor ?? this.themeColor,
      needsPicker: needsPicker ?? this.needsPicker,
      timerSeconds: timerSeconds ?? this.timerSeconds,
    );
  }
}
