import 'dart:math';

import '../models/player.dart';

/// Service for generating random values used by the game state machine.
class RandomService {
  static final Random _random = Random();

  /// Returns a random grid index 0-7 (excluding center which is position 4
  /// in the 3x3 grid). All 8 indices have equal probability (12.5%).
  static int randomStop() {
    return _random.nextInt(8); // 0-7 uniformly
  }

  /// Alias for [randomStop]. Returns a random grid index 0-7 with equal
  /// probability (12.5% each).
  static int randomStopIndex() => randomStop();

  /// Returns a list of indices simulating the spin sequence before stopping.
  ///
  /// The sequence starts fast (~50ms between ticks), gradually slows (to
  /// ~300ms), with a total duration of approximately 2 seconds. Returns
  /// ~20-25 tick positions.
  ///
  /// The last element is guaranteed to be [finalStop].
  static List<int> spinSequence(int finalStop) {
    const targetTicks = 23; // 22 intermediate + 1 final = 23

    final List<int> sequence = [];

    // Start the wheel at a random position, then spin it forward
    int position = _random.nextInt(8);
    for (int i = 0; i < targetTicks - 1; i++) {
      sequence.add(position);
      // Move forward 1-3 steps around the wheel (cycling 0-7)
      position = (position + 1 + _random.nextInt(3)) % 8;
    }

    // The last element is the final stop position
    sequence.add(finalStop);

    return sequence;
  }

  /// Pick a random player index from the list (for timeout auto-pick).
  ///
  /// Returns an index in the range `[0, playerCount)`.
  static int randomPlayerIndex(int playerCount) {
    if (playerCount <= 0) {
      throw ArgumentError.value(
        playerCount,
        'playerCount',
        'Must be greater than 0',
      );
    }
    return _random.nextInt(playerCount);
  }

  /// Pick a random player from the list, excluding the specified player.
  ///
  /// Returns a randomly chosen [Player] from [players] that is not
  /// [excludePlayer]. If the list contains only the excluded player,
  /// returns that player. Returns `null` if the list is empty.
  static Player? randomPlayer(List<Player> players, Player excludePlayer) {
    if (players.isEmpty) return null;

    final candidates = players
        .where((p) => p.id != excludePlayer.id)
        .toList();

    if (candidates.isEmpty) {
      // Only the excluded player exists — return them anyway
      return excludePlayer;
    }

    return candidates[_random.nextInt(candidates.length)];
  }
}
