/// 玩家数据模型。
class Player {
  /// 唯一标识符（UUID 格式）。
  final String id;

  /// 玩家名称。
  final String name;

  const Player({
    required this.id,
    required this.name,
  });

  /// 返回4个默认玩家。
  static List<Player> defaultPlayers() => const [
        Player(id: '550e8400-e29b-41d4-a716-446655440001', name: '玩家1'),
        Player(id: '550e8400-e29b-41d4-a716-446655440002', name: '玩家2'),
        Player(id: '550e8400-e29b-41d4-a716-446655440003', name: '玩家3'),
        Player(id: '550e8400-e29b-41d4-a716-446655440004', name: '玩家4'),
      ];
}
