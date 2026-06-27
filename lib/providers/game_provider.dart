import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';

import '../models/game_state.dart';
import '../models/penalty.dart';
import '../services/audio_synth.dart';
import '../services/haptic_service.dart';
import '../i18n/translations.dart';

/// Central game state machine for Neon Roulette.
///
/// Manages: charging → spinning → result cycle,
/// programmatic audio via [AudioSynth], persistent settings, i18n.
class GameProvider extends ChangeNotifier {
  GameProvider() {
    _loadSettings();
  }

  // ===========================================================================
  // Core state
  // ===========================================================================
  GameState _state = GameState.initial();
  GameState get state => _state;

  final AudioSynth synth = AudioSynth();
  final AudioPlayer _player = AudioPlayer();
  final Random _random = Random();

  // I18n
  I18n _i18n = const I18n('zh');
  I18n get i18n => _i18n;

  // Settings
  bool _soundEnabled = true;
  bool get soundEnabled => _soundEnabled;

  // Custom penalty names (index -> custom name)
  final Map<int, String> _customNames = {};

  // Spin animation control
  bool _isSpinning = false;
  bool get isSpinning => _isSpinning;
  Timer? _chargeTimer;
  DateTime? _chargeStart;

  // BGM
  Timer? _bgmTimer;
  int _bgmBeat = 0;

  // History
  List<RoundRecord> get history => _state.history;

  // ===========================================================================
  // Settings persistence
  // ===========================================================================
  void _loadSettings() {
    // Load settings from local storage would go here.
    // For now, defaults (ZH, sound on).
  }

  void _saveSettings() {
    // Persist settings
  }

  void setLocale(String locale) {
    _i18n = I18n(locale);
    _saveSettings();
    notifyListeners();
  }

  void toggleSound() {
    _soundEnabled = !_soundEnabled;
    synth.setVolume(_soundEnabled ? 0.5 : 0.0);
    _saveSettings();
    notifyListeners();
  }

  void setCustomName(int index, String name) {
    _customNames[index] = name;
    _saveSettings();
  }

  String getCustomName(int index) => _customNames[index] ?? _i18n.penaltyTitle(index);

  // ===========================================================================
  // Charging phase
  // ===========================================================================
  void startCharging() {
    if (_isSpinning) return;
    _state = _state.copyWith(
      phase: GamePhase.charging,
      chargeProgress: 0.0,
      orbCount: 0,
      isFullCharge: false,
      clearSelectedIndex: true,
      clearHighlightedIndex: true,
    );
    _chargeStart = DateTime.now();
    HapticService.light();

    _chargeTimer?.cancel();
    _chargeTimer = Timer.periodic(const Duration(milliseconds: 45), (_) {
      if (_chargeStart == null) return;
      final elapsed = DateTime.now().difference(_chargeStart!).inMilliseconds;
      final progress = (elapsed / 1500).clamp(0.0, 1.0);
      final orbs = progress > 0.99 ? 3 : progress > 0.66 ? 2 : progress > 0.33 ? 1 : 0;
      final full = progress >= 1.0;

      _playChargeClick(progress);

      if (orbs > _state.orbCount) {
        _playDing();
        HapticService.medium();
      }

      // Full charge — auto release
      if (full) {
        _chargeTimer?.cancel();
        _chargeTimer = null;
        _state = _state.copyWith(
          chargeProgress: 1.0,
          orbCount: 3,
          isFullCharge: true,
        );
        notifyListeners();
        HapticService.heavy();
        // Auto-release after a moment
        Future.delayed(const Duration(milliseconds: 200), () {
          if (_state.phase == GamePhase.charging) {
            stopChargingAndSpin();
          }
        });
        return;
      }

      _state = _state.copyWith(
        chargeProgress: progress,
        orbCount: orbs,
      );
      notifyListeners();
    });
  }

  void stopChargingAndSpin() {
    _chargeTimer?.cancel();
    _chargeTimer = null;

    if (_state.phase != GamePhase.charging) return;

    final elapsed = _chargeStart != null
        ? DateTime.now().difference(_chargeStart!).inMilliseconds
        : 500;
    final chargeVal = (elapsed / 1500).clamp(0.18, 1.0);

    _state = _state.copyWith(
      phase: GamePhase.spinning,
      chargeProgress: chargeVal,
      isFullCharge: chargeVal >= 1.0,
    );
    notifyListeners();

    _startSpin(chargeVal);
    _chargeStart = null;
  }

  void cancelCharge() {
    _chargeTimer?.cancel();
    _chargeTimer = null;
    _chargeStart = null;
    if (_state.phase == GamePhase.charging) {
      _state = _state.copyWith(
        phase: GamePhase.idle,
        chargeProgress: 0.0,
        orbCount: 0,
      );
      notifyListeners();
    }
  }

  // ===========================================================================
  // Spin phase
  // ===========================================================================
  int? _spinTarget;
  int _spinStep = 0;
  int _totalSteps = 0;
  Timer? _spinTimer;

  void _startSpin(double chargeVal) {
    if (_isSpinning) return;
    _isSpinning = true;
    _spinTarget = Penalty.rollIndex();
    _spinStep = 0;
    _totalSteps = 8 + (chargeVal * 25).round() + _spinTarget!;
    int idx = _random.nextInt(8);

    int delayMs = (80 - chargeVal * 60).round().clamp(10, 80);

    _playSlotMachineSound();
    HapticService.medium();

    void tickLoop() {
      idx = (idx + 1) % 8;
      _spinStep++;

      _state = _state.copyWith(highlightedIndex: idx);
      notifyListeners();

      _playTick();
      HapticService.selection();

      final remaining = _totalSteps - _spinStep;

      if (remaining <= 0 && idx == _spinTarget) {
        // Done
        _stopSlotMachineSound();
        _isSpinning = false;
        _spinTimer = null;

        _state = _state.copyWith(
          phase: GamePhase.result,
          selectedIndex: idx,
          highlightedIndex: null,
          streakCount: _state.streakCount + 1,
        );

        // Determine sound effect
        final penType = Penalty.fromIndex(idx).type;
        if (penType == PenaltyType.allCheers) {
          _playVinaDrop();
          _state = _state.copyWith(showStrobe: true);
        } else if (penType == PenaltyType.dominator || penType == PenaltyType.freePass) {
          _playWinnerCheer();
        } else {
          _playSuccess();
        }

        HapticService.heavy();
        notifyListeners();

        // Auto clear strobe
        if (_state.showStrobe) {
          Future.delayed(const Duration(seconds: 8), () {
            _state = _state.copyWith(showStrobe: false);
            notifyListeners();
          });
        }
      } else {
        // Deceleration
        if (remaining < 2) {
          delayMs += 120;
        } else if (remaining < 4) {
          delayMs += 50;
        } else if (remaining < 9) {
          delayMs += 15;
        } else if (_spinStep < 5) {
          delayMs = (delayMs - 5).clamp(10, delayMs);
        }
        _spinTimer = Timer(Duration(milliseconds: delayMs), tickLoop);
      }
    }

    _spinTimer = Timer(Duration(milliseconds: delayMs), tickLoop);
  }

  // ===========================================================================
  // Reset
  // ===========================================================================
  void nextRound() {
    _spinTarget = null;
    _spinStep = 0;
    _state = _state.copyWith(
      phase: GamePhase.idle,
      chargeProgress: 0.0,
      orbCount: 0,
      isFullCharge: false,
      clearSelectedIndex: true,
      clearHighlightedIndex: true,
    );
    notifyListeners();
  }

  void addToHistory(RoundRecord record) {
    _state = _state.copyWith(history: [..._state.history, record]);
    notifyListeners();
  }

  // ===========================================================================
  // Audio helpers
  // ===========================================================================
  void _playBytes(Uint8List bytes) async {
    if (!_soundEnabled) return;
    try {
      await _player.play(BytesSource(bytes));
    } catch (_) {}
  }

  void _playTick() => _playBytes(synth.tick());
  void _playDing() => _playBytes(synth.ding());
  void _playSuccess() => _playBytes(synth.success());
  void _playWinnerCheer() => _playBytes(synth.winnerCheer());
  void _playVinaDrop() => _playBytes(synth.vinaHouseDrop());
  void _playSlotMachineSound() => _playBytes(synth.slotMachineSpin());
  void _stopSlotMachineSound() {}
  void _playChargeClick(double p) => _playBytes(synth.chargeClick(p));

  // ===========================================================================
  // BGM
  // ===========================================================================
  void startBgm() {
    _bgmTimer?.cancel();
    _bgmBeat = 0;
    final bassNotes = [55.0, 48.99, 65.41, 58.27];

    _bgmTimer = Timer.periodic(const Duration(milliseconds: 450), (_) {
      _playBytes(synth.bgmKick());
      if (_bgmBeat % 2 == 0) {
        _playBytes(synth.bgmBass(bassNotes[(_bgmBeat ~/ 2) % bassNotes.length]));
      }
      _bgmBeat = (_bgmBeat + 1) % 8;
    });
  }

  void stopBgm() {
    _bgmTimer?.cancel();
    _bgmTimer = null;
  }

  @override
  void dispose() {
    _chargeTimer?.cancel();
    _spinTimer?.cancel();
    _bgmTimer?.cancel();
    _player.dispose();
    super.dispose();
  }
}
