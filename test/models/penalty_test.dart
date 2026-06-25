import 'package:flutter_test/flutter_test.dart';

import 'package:neon_roulette/models/penalty.dart';

void main() {
  group('Penalty.all()', () {
    test('returns 8 elements', () {
      final all = Penalty.all();
      expect(all.length, 8);
    });

    test('each penalty has a non-empty title', () {
      for (final p in Penalty.all()) {
        expect(p.title, isNotEmpty,
            reason: 'Penalty ${p.type} has empty title');
      }
    });

    test('each penalty has a non-empty subtitle', () {
      for (final p in Penalty.all()) {
        expect(p.subtitle, isNotEmpty,
            reason: 'Penalty ${p.type} has empty subtitle');
      }
    });

    test('each penalty has a non-empty fullText', () {
      for (final p in Penalty.all()) {
        expect(p.fullText, isNotEmpty,
            reason: 'Penalty ${p.type} has empty fullText');
      }
    });
  });

  group('Penalty.fromIndex', () {
    test('fromIndex(0) type == PenaltyType.freePass', () {
      final p = Penalty.fromIndex(0);
      expect(p.type, PenaltyType.freePass);
      expect(p.needsPicker, false);
    });

    test('fromIndex(7) type == PenaltyType.freePassNext', () {
      final p = Penalty.fromIndex(7);
      expect(p.type, PenaltyType.freePassNext);
      expect(p.needsPicker, false);
    });

    test('all 8 indices return valid penalties', () {
      for (int i = 0; i < 8; i++) {
        final p = Penalty.fromIndex(i);
        expect(p, isA<Penalty>());
        expect(p.title, isNotEmpty);
      }
    });

    test('correct types for all indices', () {
      expect(Penalty.fromIndex(0).type, PenaltyType.freePass);
      expect(Penalty.fromIndex(1).type, PenaltyType.kiss10s);
      expect(Penalty.fromIndex(2).type, PenaltyType.crossArm);
      expect(Penalty.fromIndex(3).type, PenaltyType.halfDrink);
      expect(Penalty.fromIndex(4).type, PenaltyType.rockMe);
      expect(Penalty.fromIndex(5).type, PenaltyType.fullDrink);
      expect(Penalty.fromIndex(6).type, PenaltyType.kissReal);
      expect(Penalty.fromIndex(7).type, PenaltyType.freePassNext);
    });
  });

  group('Penalty.needsPicker and timerSeconds', () {
    test('needsPicker=true penalties have timerSeconds == 10', () {
      final pickerPenalties = Penalty.all().where((p) => p.needsPicker);
      expect(pickerPenalties, isNotEmpty);

      for (final p in pickerPenalties) {
        expect(p.timerSeconds, 10,
            reason: '${p.type} needsPicker but timerSeconds != 10');
      }
    });

    test('needsPicker=false penalties have timerSeconds == 0', () {
      final nonPickerPenalties = Penalty.all().where((p) => !p.needsPicker);
      expect(nonPickerPenalties, isNotEmpty);

      for (final p in nonPickerPenalties) {
        expect(p.timerSeconds, 0,
            reason: '${p.type} !needsPicker but timerSeconds != 0');
      }
    });

    test('picker penalties: kiss10s, crossArm, rockMe, kissReal', () {
      final pickerTypes = Penalty.all()
          .where((p) => p.needsPicker)
          .map((p) => p.type)
          .toSet();

      expect(pickerTypes, {
        PenaltyType.kiss10s,
        PenaltyType.crossArm,
        PenaltyType.rockMe,
        PenaltyType.kissReal,
      });
    });

    test('non-picker penalties: freePass, halfDrink, fullDrink, freePassNext',
        () {
      final nonPickerTypes = Penalty.all()
          .where((p) => !p.needsPicker)
          .map((p) => p.type)
          .toSet();

      expect(nonPickerTypes, {
        PenaltyType.freePass,
        PenaltyType.halfDrink,
        PenaltyType.fullDrink,
        PenaltyType.freePassNext,
      });
    });
  });

  group('Penalty.copyWith', () {
    test('copyWith with no arguments returns identical penalty', () {
      final original = Penalty.fromIndex(3); // halfDrink
      final copy = original.copyWith();

      expect(copy.type, original.type);
      expect(copy.title, original.title);
      expect(copy.subtitle, original.subtitle);
      expect(copy.fullText, original.fullText);
      expect(copy.themeColor, original.themeColor);
      expect(copy.needsPicker, original.needsPicker);
      expect(copy.timerSeconds, original.timerSeconds);
    });

    test('copyWith overrides title correctly', () {
      final original = Penalty.fromIndex(3);
      final copy = original.copyWith(title: '喝·一·杯');

      expect(copy.title, '喝·一·杯');
      // Other fields unchanged
      expect(copy.type, original.type);
      expect(copy.subtitle, original.subtitle);
      expect(copy.fullText, original.fullText);
    });

    test('copyWith overrides title and fullText', () {
      final original = Penalty.fromIndex(3);
      final copy = original.copyWith(
        title: '喝·一·杯',
        fullText: '干了它，不能留一滴！',
      );

      expect(copy.title, '喝·一·杯');
      expect(copy.fullText, '干了它，不能留一滴！');
      expect(copy.type, original.type);
      expect(copy.needsPicker, original.needsPicker);
    });

    test('copyWith overrides type', () {
      final original = Penalty.fromIndex(3); // halfDrink
      final copy = original.copyWith(type: PenaltyType.fullDrink);

      expect(copy.type, PenaltyType.fullDrink);
      // Title stays from original (copyWith only overrides what you give)
      expect(copy.title, original.title);
    });

    test('copyWith overrides needsPicker and timerSeconds', () {
      final original = Penalty.fromIndex(1); // kiss10s, needsPicker=true
      final copy = original.copyWith(needsPicker: false, timerSeconds: 0);

      expect(copy.needsPicker, false);
      expect(copy.timerSeconds, 0);
      expect(copy.type, original.type);
    });
  });

  group('PenaltyEnum values', () {
    test('PenaltyType has 8 values', () {
      expect(PenaltyType.values.length, 8);
    });
  });
}
