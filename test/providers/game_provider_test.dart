import 'package:flutter_test/flutter_test.dart';

import 'package:neon_roulette/models/game_state.dart';
import 'package:neon_roulette/models/penalty.dart';
import 'package:neon_roulette/models/player.dart';
import 'package:neon_roulette/providers/game_provider.dart';

void main() {
  late GameProvider provider;

  setUp(() {
    provider = GameProvider();
  });

  // ===========================================================================
  // 初始状态
  // ===========================================================================
  group('Initial state', () {
    test('phase == idle, selectedIndex == null, streakCount == 0', () {
      expect(provider.state.phase, GamePhase.idle);
      expect(provider.state.selectedIndex, isNull);
      expect(provider.state.currentPenalty, isNull);
      expect(provider.state.nextRoundMultiplier, 1.0);
      expect(provider.state.streakCount, 0);
    });

    test('players defaults to 4', () {
      expect(provider.players.length, 4);
      expect(provider.players[0].name, '玩家1');
      expect(provider.players[3].name, '玩家4');
    });
  });

  // ===========================================================================
  // Phase transitions: idle → charging → spinning → result / picking
  // ===========================================================================
  group('Phase transitions', () {
    test('startCharging(): idle → charging', () {
      provider.startCharging();
      expect(provider.state.phase, GamePhase.charging);
      expect(provider.state.selectedIndex, isNull);
      expect(provider.state.currentPenalty, isNull);
    });

    test('stopChargingAndSpin(): charging → spinning, selectedIndex in 0-7', () {
      provider.startCharging();
      expect(provider.state.phase, GamePhase.charging);

      provider.stopChargingAndSpin(targetIndex: 5);
      expect(provider.state.phase, GamePhase.spinning);
      expect(provider.state.selectedIndex, 5);
      expect(provider.state.selectedIndex, inInclusiveRange(0, 7));
    });

    test(
        'onSpinComplete(index) with non-picker penalty: '
        'spinning → result (not picking)', () {
      provider.startCharging();
      provider.stopChargingAndSpin(targetIndex: 0); // freePass — needsPicker=false
      provider.onSpinComplete(0);

      expect(provider.state.phase, GamePhase.result);
      expect(provider.state.selectedIndex, 0);
      expect(provider.state.currentPenalty, isNotNull);
      expect(provider.state.currentPenalty!.type, PenaltyType.freePass);
      expect(provider.state.currentPenalty!.needsPicker, false);
      expect(provider.state.streakCount, 1);
    });

    test(
        'onSpinComplete(index) with picker penalty: '
        'spinning → picking', () {
      provider.startCharging();
      // Index 2 = crossArm — needsPicker = true
      provider.stopChargingAndSpin(targetIndex: 2);
      provider.onSpinComplete(2);

      expect(provider.state.phase, GamePhase.picking);
      expect(provider.state.selectedIndex, 2);
      expect(provider.state.currentPenalty, isNotNull);
      expect(provider.state.currentPenalty!.type, PenaltyType.crossArm);
      expect(provider.state.currentPenalty!.needsPicker, true);
      expect(provider.state.streakCount, 1);
    });

    test('halfDrink (index 3) goes directly to result (needsPicker=false)', () {
      provider.startCharging();
      provider.stopChargingAndSpin(targetIndex: 3); // halfDrink
      provider.onSpinComplete(3);

      expect(provider.state.phase, GamePhase.result);
      expect(provider.state.currentPenalty!.type, PenaltyType.halfDrink);
      expect(provider.state.currentPenalty!.needsPicker, false);
    });

    test('fullDrink (index 5) goes directly to result (needsPicker=false)', () {
      provider.startCharging();
      provider.stopChargingAndSpin(targetIndex: 5); // fullDrink
      provider.onSpinComplete(5);

      expect(provider.state.phase, GamePhase.result);
      expect(provider.state.currentPenalty!.type, PenaltyType.fullDrink);
      expect(provider.state.currentPenalty!.needsPicker, false);
    });

    test('freePassNext (index 7) goes directly to result (needsPicker=false)', () {
      provider.startCharging();
      provider.stopChargingAndSpin(targetIndex: 7);
      provider.onSpinComplete(7);

      expect(provider.state.phase, GamePhase.result);
      expect(provider.state.currentPenalty!.type, PenaltyType.freePassNext);
      expect(provider.state.currentPenalty!.needsPicker, false);
    });
  });

  // ===========================================================================
  // Picking phase
  // ===========================================================================
  group('Picking phase', () {
    setUp(() {
      // Navigate to picking state via a picker penalty (index 1 = kiss10s)
      provider.startCharging();
      provider.stopChargingAndSpin(targetIndex: 1);
      provider.onSpinComplete(1);
    });

    test('selectPlayer(Player): picking → result', () {
      expect(provider.state.phase, GamePhase.picking);

      provider.selectPlayer(provider.players[0]);
      expect(provider.state.phase, GamePhase.result);
    });

    test('onPickTimeout(): picking → result', () {
      expect(provider.state.phase, GamePhase.picking);

      provider.onPickTimeout();
      expect(provider.state.phase, GamePhase.result);
    });

    test('selectPlayer is no-op when not in picking', () {
      provider.selectPlayer(provider.players[0]); // back to result
      expect(provider.state.phase, GamePhase.result);

      // Calling again should not change phase
      provider.selectPlayer(provider.players[1]);
      expect(provider.state.phase, GamePhase.result);
    });

    test('onPickTimeout is no-op when not in picking', () {
      provider.selectPlayer(provider.players[0]);
      expect(provider.state.phase, GamePhase.result);

      provider.onPickTimeout();
      expect(provider.state.phase, GamePhase.result);
    });
  });

  // ===========================================================================
  // nextRound: result → idle
  // ===========================================================================
  group('nextRound', () {
    test('nextRound(): result → idle', () {
      provider.startCharging();
      provider.stopChargingAndSpin(targetIndex: 0);
      provider.onSpinComplete(0);
      expect(provider.state.phase, GamePhase.result);

      provider.nextRound();
      expect(provider.state.phase, GamePhase.idle);
      expect(provider.state.selectedIndex, isNull);
      expect(provider.state.currentPenalty, isNull);
    });

    test('nextRound from picking also goes to idle', () {
      provider.startCharging();
      provider.stopChargingAndSpin(targetIndex: 1); // kiss10s → picking
      provider.onSpinComplete(1);
      expect(provider.state.phase, GamePhase.picking);

      provider.nextRound();
      expect(provider.state.phase, GamePhase.idle);
    });

    test('nextRound multiplier: freePassNext sets multiplier to 2.0', () {
      provider.startCharging();
      provider.stopChargingAndSpin(targetIndex: 7); // freePassNext
      provider.onSpinComplete(7);
      expect(provider.state.currentPenalty!.type, PenaltyType.freePassNext);
      expect(provider.state.nextRoundMultiplier, 1.0); // not yet applied

      provider.nextRound();
      expect(provider.state.nextRoundMultiplier, 2.0);
    });

    test('nextRound after normal penalty resets multiplier to 1.0', () {
      // First round: freePassNext to set multiplier
      provider.startCharging();
      provider.stopChargingAndSpin(targetIndex: 7);
      provider.onSpinComplete(7);
      provider.nextRound();
      expect(provider.state.nextRoundMultiplier, 2.0);

      // Second round: normal penalty
      provider.startCharging();
      provider.stopChargingAndSpin(targetIndex: 3); // halfDrink
      provider.onSpinComplete(3);

      provider.nextRound();
      expect(provider.state.nextRoundMultiplier, 1.0);
    });

    test('consecutive freePassNext stacks multiplier (1.0 → 2.0 → 4.0)', () {
      provider.startCharging();
      provider.stopChargingAndSpin(targetIndex: 7);
      provider.onSpinComplete(7);
      provider.nextRound();
      expect(provider.state.nextRoundMultiplier, 2.0);

      provider.startCharging();
      provider.stopChargingAndSpin(targetIndex: 7);
      provider.onSpinComplete(7);
      provider.nextRound();
      expect(provider.state.nextRoundMultiplier, 4.0);
    });

    test('streakCount persists across nextRound (not reset)', () {
      provider.startCharging();
      provider.stopChargingAndSpin(targetIndex: 0);
      provider.onSpinComplete(0);
      expect(provider.state.streakCount, 1);

      provider.nextRound();
      expect(provider.state.streakCount, 1);
    });
  });

  // ===========================================================================
  // getEffectivePenalty
  // ===========================================================================
  group('getEffectivePenalty', () {
    test('returns original penalty when multiplier is 1.0', () {
      final penalty = Penalty.fromIndex(3); // halfDrink
      final effective = provider.getEffectivePenalty(penalty);
      expect(effective.title, '喝·半·杯');
      expect(effective.fullText, '来一口，小意思而已');
    });

    test('halfDrink at multiplier=2.0: title becomes "喝·一·杯"', () {
      // Setup multiplier = 2.0 via freePassNext
      provider.startCharging();
      provider.stopChargingAndSpin(targetIndex: 7);
      provider.onSpinComplete(7);
      provider.nextRound();
      expect(provider.state.nextRoundMultiplier, 2.0);

      final penalty = Penalty.fromIndex(3); // halfDrink
      final effective = provider.getEffectivePenalty(penalty);
      expect(effective.title, '喝·一·杯');
      expect(effective.fullText, '干了它，不能留一滴！');
    });

    test('fullDrink at multiplier=2.0: title becomes "喝·两·杯"', () {
      provider.startCharging();
      provider.stopChargingAndSpin(targetIndex: 7);
      provider.onSpinComplete(7);
      provider.nextRound();
      expect(provider.state.nextRoundMultiplier, 2.0);

      final penalty = Penalty.fromIndex(5); // fullDrink
      final effective = provider.getEffectivePenalty(penalty);
      expect(effective.title, '喝·两·杯');
      expect(effective.fullText, '双倍命运 — 两杯干了！');
    });

    test('penalty at multiplier >= 4.0 appends "×N" suffix', () {
      // Get to 4.0 multiplier
      provider.startCharging();
      provider.stopChargingAndSpin(targetIndex: 7);
      provider.onSpinComplete(7);
      provider.nextRound();
      provider.startCharging();
      provider.stopChargingAndSpin(targetIndex: 7);
      provider.onSpinComplete(7);
      provider.nextRound();
      expect(provider.state.nextRoundMultiplier, 4.0);

      final penalty = Penalty.fromIndex(3); // halfDrink
      final effective = provider.getEffectivePenalty(penalty);
      expect(effective.title, contains('×4'));
      expect(effective.fullText, contains('加倍惩罚'));
    });
  });

  // ===========================================================================
  // streakCount
  // ===========================================================================
  group('streakCount', () {
    test('increments on each onSpinComplete', () {
      expect(provider.state.streakCount, 0);

      for (int i = 1; i <= 3; i++) {
        provider.startCharging();
        provider.stopChargingAndSpin(targetIndex: 0);
        provider.onSpinComplete(0);
        expect(provider.state.streakCount, i);
        provider.nextRound();
      }
    });
  });

  // ===========================================================================
  // resetGame
  // ===========================================================================
  group('resetGame', () {
    test('resetGame() returns to full initial state', () {
      // Drive the state machine through several rounds
      provider.startCharging();
      provider.stopChargingAndSpin(targetIndex: 7); // freePassNext
      provider.onSpinComplete(7);
      provider.nextRound(); // multiplier = 2.0
      provider.startCharging();
      provider.stopChargingAndSpin(targetIndex: 1); // kiss10s → picking
      provider.onSpinComplete(1);

      // State should be non-initial
      expect(provider.state.phase, GamePhase.picking);
      expect(provider.state.selectedIndex, isNotNull);
      expect(provider.state.currentPenalty, isNotNull);
      expect(provider.state.nextRoundMultiplier, 2.0);
      expect(provider.state.streakCount, greaterThan(0));

      // Reset!
      provider.resetGame();

      // Verify full reset
      expect(provider.state.phase, GamePhase.idle);
      expect(provider.state.selectedIndex, isNull);
      expect(provider.state.currentPenalty, isNull);
      expect(provider.state.nextRoundMultiplier, 1.0);
      expect(provider.state.streakCount, 0);
      expect(provider.players.length, 4);
    });

    test('resetGame restores default players', () {
      provider.resetGame();
      expect(provider.players.length, 4);
      expect(provider.players[0].name, '玩家1');
      expect(provider.players[3].name, '玩家4');
    });
  });

  // ===========================================================================
  // Current penalty for each index
  // ===========================================================================
  group('currentPenalty per index', () {
    test('returns correct penalty for each index 0-7', () {
      for (int i = 0; i < 8; i++) {
        provider.startCharging();
        provider.stopChargingAndSpin(targetIndex: i);
        provider.onSpinComplete(i);

        expect(provider.state.currentPenalty, isNotNull);
        expect(provider.state.currentPenalty!.type, Penalty.fromIndex(i).type);
        expect(provider.state.selectedIndex, i);

        provider.nextRound();
      }
    });
  });
}
