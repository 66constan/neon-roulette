import 'package:flutter/services.dart';

/// Haptic feedback service for the Neon Roulette game.
///
/// Provides light, medium, and heavy impact feedback as well as a charging
/// pulse effect. All methods are static for easy access from anywhere.
class HapticService {
  HapticService._(); // prevent instantiation

  // ---------------------------------------------------------------------------
  // Impact strengths
  // ---------------------------------------------------------------------------

  /// Light haptic — used for subtle UI feedback and charging pulse.
  static void lightImpact() {
    HapticFeedback.lightImpact();
  }

  /// Medium haptic — used for tick/step events during spinning.
  static void mediumImpact() {
    HapticFeedback.mediumImpact();
  }

  /// Heavy haptic — used when the wheel stops on a penalty cell.
  static void heavyImpact() {
    HapticFeedback.heavyImpact();
  }

  // ---------------------------------------------------------------------------
  // Compound patterns
  // ---------------------------------------------------------------------------

  /// Charging pulse — a quick light impact suitable for the long-press
  /// wind-up phase.
  static void chargingPulse() {
    HapticFeedback.lightImpact();
  }
}
