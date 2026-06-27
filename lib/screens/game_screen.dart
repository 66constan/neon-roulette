import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/game_state.dart';
import '../models/player.dart';
import '../providers/game_provider.dart';
import '../services/audio_service.dart';
import '../services/haptic_service.dart';
import '../services/random_service.dart';
import '../widgets/bottom_bar.dart';
import '../widgets/center_button.dart';
import '../widgets/neon_background.dart';
import '../widgets/neon_grid.dart';
import '../widgets/penalty_card.dart';
import '../widgets/player_picker.dart';

// =============================================================================
// GameScreen — main game screen integrating all components
// =============================================================================

/// The single-screen game UI for Neon Roulette.
///
/// Composes [NeonBackground], [NeonGrid], [CenterButton], [PenaltyCard],
/// [PlayerPicker], and [BottomBar] into the full gameplay experience.
///
/// Manages spin animation sequencing and lifecycle for audio/haptics via
/// [AudioService] and [HapticService].
class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // =========================================================================
  // Local animation state
  // =========================================================================

  /// The penalty index (0-7) currently lit up during the spin sequence.
  int? _highlightedIndex;

  /// Semaphore to prevent overlapping spin animations.
  bool _isSpinning = false;

  // =========================================================================
  // Lifecycle
  // =========================================================================

  @override
  void initState() {
    super.initState();
    AudioService.init();
    AudioService.playBgm();
  }

  @override
  void dispose() {
    AudioService.stopBgm();
    AudioService.dispose();
    super.dispose();
  }

  // =========================================================================
  // Callbacks: CenterButton
  // =========================================================================

  /// User starts long-pressing the center button → charging phase.
  void _onLongPressStart() {
    final provider = context.read<GameProvider>();
    provider.startCharging();
    AudioService.playChargeUp();
    HapticService.chargingPulse();
  }

  /// User releases the center button → trigger spin.
  void _onLongPressEnd() {
    final provider = context.read<GameProvider>();
    provider.stopChargingAndSpin();
    AudioService.stopChargeUp();
    AudioService.playTrigger();
    HapticService.mediumImpact();

    // Start the spin animation sequence.
    final targetIndex = provider.state.selectedIndex;
    if (targetIndex != null) {
      _executeSpinSequence(targetIndex);
    }
  }

  /// User taps the center button in result phase → next round.
  void _onTap() {
    final provider = context.read<GameProvider>();
    provider.nextRound();
    setState(() {
      _highlightedIndex = null;
    });
  }

  // =========================================================================
  // Spin animation
  // =========================================================================

  /// Runs the tick-by-tick spin animation, ending at [finalStop].
  ///
  /// Tick delays progress from ~50 ms (fast) to ~300 ms (slow) over the
  /// course of the sequence, creating a deceleration effect.
  Future<void> _executeSpinSequence(int finalStop) async {
    if (_isSpinning) return;
    _isSpinning = true;

    try {
      final sequence = RandomService.spinSequence(finalStop);

      for (int i = 0; i < sequence.length; i++) {
        if (!mounted) break;

        setState(() {
          _highlightedIndex = sequence[i];
        });

        // Play tick sound and haptic for each step.
        AudioService.playTick();
        HapticService.mediumImpact();

        // Progressive delay: 50 ms → 300 ms.
        final progress = i / (sequence.length - 1).clamp(1, sequence.length);
        final delayMs = (50 + progress * 250).round();

        await Future.delayed(Duration(milliseconds: delayMs));
      }

      if (!mounted) return;

      // Spin complete — notify provider, play stop sound, heavy haptic.
      final provider = context.read<GameProvider>();
      provider.onSpinComplete(finalStop);
      AudioService.playStop();
      HapticService.heavyImpact();

      setState(() {
        _highlightedIndex = null;
      });
    } finally {
      _isSpinning = false;
    }
  }

  // =========================================================================
  // Player picker callbacks
  // =========================================================================

  void _onPlayerSelected(Player player) {
    context.read<GameProvider>().selectPlayer(player);
  }

  void _onPickTimeout() {
    context.read<GameProvider>().onPickTimeout();
  }

  // =========================================================================
  // Build
  // =========================================================================

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final phase = provider.state.phase;
    final selectedIndex = provider.state.selectedIndex;
    final currentPenalty = provider.state.currentPenalty;
    final multiplier = provider.state.nextRoundMultiplier;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          children: [
            Text(
              'NEON ROULETTE',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2.0,
              ),
            ),
            Text(
              '夜店惩罚转盘',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: Color(0xFF888888),
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // ---- Background particles ----
          const NeonBackground(),

          // ---- Main content ----
          SafeArea(
            child: Column(
              children: [
                // ---- 9-grid area fills remaining space ----
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0),
                      child: AspectRatio(
                        aspectRatio: 1.0,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            NeonGrid(
                              highlightedIndex: _highlightedIndex,
                              selectedIndex: selectedIndex,
                            ),
                            CenterButton(
                              phase: phase,
                              onLongPressStart: _onLongPressStart,
                              onLongPressEnd: _onLongPressEnd,
                              onTap: _onTap,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // ---- Result area ----
                if (currentPenalty != null) ...[
                  PenaltyCard(
                    penalty: provider.getEffectivePenalty(currentPenalty),
                    multiplier: multiplier,
                    isVisible: phase == GamePhase.result ||
                        phase == GamePhase.picking,
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),

          // ---- Player picker overlay ----
          PlayerPicker(
            players: provider.players,
            isVisible: phase == GamePhase.picking,
            onPlayerSelected: _onPlayerSelected,
            onTimeout: _onPickTimeout,
          ),
        ],
      ),
      bottomNavigationBar: BottomBar(phase: phase),
    );
  }
}
