import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Audio service for the Neon Roulette game.
///
/// All audio files live under assets/audio/. Since actual audio files may not
/// exist yet, every playback method is wrapped in a try-catch that silently
/// handles failures and prints a log marker for debugging purposes.
class AudioService {
  static final AudioPlayer _player = AudioPlayer();
  static final AudioPlayer _bgmPlayer = AudioPlayer();

  static bool _initialized = false;

  // ---------------------------------------------------------------------------
  // Asset paths
  // ---------------------------------------------------------------------------

  static const String _chargeUp = 'assets/audio/charge_up.mp3';
  static const String _triggerDing = 'assets/audio/trigger_ding.mp3';
  static const String _tick = 'assets/audio/tick.mp3';
  static const String _stopHit = 'assets/audio/stop_hit.mp3';
  static const String _bgmLoop = 'assets/audio/bgm_loop.mp3';

  // ---------------------------------------------------------------------------
  // Initialization
  // ---------------------------------------------------------------------------

  /// Initialize audio players. Safe to call multiple times.
  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;
    debugPrint('[AudioService] Initialized.');
  }

  // ---------------------------------------------------------------------------
  // Sound effects
  // ---------------------------------------------------------------------------

  /// Play the charging hum loop (long-press wind-up).
  static Future<void> playChargeUp() async {
    try {
      await _player.stop();
      await _player.play(AssetSource(_chargeUp));
      await _player.setReleaseMode(ReleaseMode.loop);
      debugPrint('[AudioService] ▶ charge_up.mp3 (loop)');
    } catch (e) {
      debugPrint('[AudioService] ⚠ playChargeUp failed: $e');
    }
  }

  /// Stop the charging hum.
  static Future<void> stopChargeUp() async {
    try {
      await _player.stop();
      debugPrint('[AudioService] ■ charge_up stopped');
    } catch (e) {
      debugPrint('[AudioService] ⚠ stopChargeUp failed: $e');
    }
  }

  /// Play the trigger ding sound.
  static Future<void> playTrigger() async {
    try {
      await AudioPlayer().play(AssetSource(_triggerDing));
      debugPrint('[AudioService] ▶ trigger_ding.mp3');
    } catch (e) {
      debugPrint('[AudioService] ⚠ playTrigger failed: $e');
    }
  }

  /// Play the tick sound (each step during spinning).
  static Future<void> playTick() async {
    try {
      await AudioPlayer().play(AssetSource(_tick));
      debugPrint('[AudioService] ▶ tick.mp3');
    } catch (e) {
      debugPrint('[AudioService] ⚠ playTick failed: $e');
    }
  }

  /// Play the stop drum hit sound.
  static Future<void> playStop() async {
    try {
      await AudioPlayer().play(AssetSource(_stopHit));
      debugPrint('[AudioService] ▶ stop_hit.mp3');
    } catch (e) {
      debugPrint('[AudioService] ⚠ playStop failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Background music
  // ---------------------------------------------------------------------------

  /// Start background music loop at low volume.
  static Future<void> playBgm() async {
    try {
      await _bgmPlayer.stop();
      await _bgmPlayer.play(AssetSource(_bgmLoop));
      await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
      await _bgmPlayer.setVolume(0.3);
      debugPrint('[AudioService] ▶ bgm_loop.mp3 (loop, vol=0.3)');
    } catch (e) {
      debugPrint('[AudioService] ⚠ playBgm failed: $e');
    }
  }

  /// Stop background music.
  static Future<void> stopBgm() async {
    try {
      await _bgmPlayer.stop();
      debugPrint('[AudioService] ■ bgm stopped');
    } catch (e) {
      debugPrint('[AudioService] ⚠ stopBgm failed: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  /// Release all audio players.
  static void dispose() {
    _player.dispose();
    _bgmPlayer.dispose();
    _initialized = false;
    debugPrint('[AudioService] Disposed.');
  }
}
