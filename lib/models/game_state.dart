import 'penalty.dart';

/// Game phases matching the React state machine.
enum GamePhase {
  idle,
  charging,   // long-press charging
  spinning,   // grid cycling
  result,     // showing result
}

/// Record of a single spin result.
class RoundRecord {
  final DateTime timestamp;
  final int gridIndex;
  final PenaltyType type;
  final String title;
  final String subtitle;
  final String description;

  const RoundRecord({
    required this.timestamp,
    required this.gridIndex,
    required this.type,
    required this.title,
    required this.subtitle,
    required this.description,
  });
}

/// Snapshot of the full game state.
class GameState {
  final GamePhase phase;
  final int? highlightedIndex;  // index lighting up during spin
  final int? selectedIndex;     // final stop index
  final double chargeProgress;  // 0.0 - 1.0
  final int orbCount;           // 0-3 charged orbs
  final int streakCount;        // consecutive spins
  final bool isFullCharge;      // charge reached 100%
  final bool showStrobe;        // WINNER_A strobe flash
  final List<RoundRecord> history;

  const GameState.initial()
      : phase = GamePhase.idle,
        highlightedIndex = null,
        selectedIndex = null,
        chargeProgress = 0.0,
        orbCount = 0,
        streakCount = 0,
        isFullCharge = false,
        showStrobe = false,
        history = const [];

  const GameState({
    this.phase = GamePhase.idle,
    this.highlightedIndex,
    this.selectedIndex,
    this.chargeProgress = 0.0,
    this.orbCount = 0,
    this.streakCount = 0,
    this.isFullCharge = false,
    this.showStrobe = false,
    this.history = const [],
  });

  GameState copyWith({
    GamePhase? phase,
    int? highlightedIndex,
    bool clearHighlightedIndex = false,
    int? selectedIndex,
    bool clearSelectedIndex = false,
    double? chargeProgress,
    int? orbCount,
    int? streakCount,
    bool? isFullCharge,
    bool? showStrobe,
    List<RoundRecord>? history,
  }) {
    return GameState(
      phase: phase ?? this.phase,
      highlightedIndex: clearHighlightedIndex ? null : (highlightedIndex ?? this.highlightedIndex),
      selectedIndex: clearSelectedIndex ? null : (selectedIndex ?? this.selectedIndex),
      chargeProgress: chargeProgress ?? this.chargeProgress,
      orbCount: orbCount ?? this.orbCount,
      streakCount: streakCount ?? this.streakCount,
      isFullCharge: isFullCharge ?? this.isFullCharge,
      showStrobe: showStrobe ?? this.showStrobe,
      history: history ?? this.history,
    );
  }
}
