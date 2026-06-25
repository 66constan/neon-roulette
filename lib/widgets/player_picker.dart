import 'dart:async';

import 'package:flutter/material.dart';

import '../models/player.dart';
import '../theme/neon_theme.dart';

// =============================================================================
// PlayerPicker — countdown player-selection overlay
// =============================================================================

/// A modal overlay that appears during the [GamePhase.picking] phase.
///
/// Shows a list of player buttons with neon borders and a 10-second
/// countdown. When the countdown expires onPickTimeout is called
/// automatically.
class PlayerPicker extends StatefulWidget {
  /// List of players to choose from.
  final List<Player> players;

  /// Whether this overlay is currently visible.
  final bool isVisible;

  /// Called when a player button is tapped.
  final void Function(Player) onPlayerSelected;

  /// Called when the 10-second countdown expires.
  final VoidCallback onTimeout;

  const PlayerPicker({
    super.key,
    required this.players,
    required this.isVisible,
    required this.onPlayerSelected,
    required this.onTimeout,
  });

  @override
  State<PlayerPicker> createState() => _PlayerPickerState();
}

class _PlayerPickerState extends State<PlayerPicker>
    with SingleTickerProviderStateMixin {
  /// Seconds remaining on the countdown.
  int _secondsLeft = 10;

  /// Periodic timer driving the countdown.
  Timer? _timer;

  /// Controls the pulsating glow on the countdown text during the final 3 s.
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant PlayerPicker oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Start / stop the countdown when visibility changes.
    if (widget.isVisible && !oldWidget.isVisible) {
      _startCountdown();
    } else if (!widget.isVisible && oldWidget.isVisible) {
      _cancelCountdown();
    }
  }

  @override
  void dispose() {
    _cancelCountdown();
    _pulseController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Countdown
  // ---------------------------------------------------------------------------

  void _startCountdown() {
    _cancelCountdown();
    _secondsLeft = 10;
    _pulseController.stop();
    _pulseController.reset();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;

      setState(() {
        _secondsLeft--;
      });

      if (_secondsLeft <= 3 && !_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }

      if (_secondsLeft <= 0) {
        _cancelCountdown();
        widget.onTimeout();
      }
    });
  }

  void _cancelCountdown() {
    _timer?.cancel();
    _timer = null;
    _pulseController.stop();
    _pulseController.reset();
  }

  void _onPlayerTap(Player player) {
    _cancelCountdown();
    widget.onPlayerSelected(player);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return Stack(
      children: [
        // ---- Semi-transparent backdrop ----
        GestureDetector(
          onTap: () {}, // absorb taps so they don't pass through
          child: Container(
            color: Colors.black.withValues(alpha: 0.75),
          ),
        ),

        // ---- Centered modal ----
        Center(
          child: Container(
            width: 300,
            margin: const EdgeInsets.symmetric(horizontal: 32.0),
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 30.0,
                  spreadRadius: 2.0,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ---- Title ----
                const Text(
                  '👆 快选！',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 2.0,
                  ),
                ),
                const SizedBox(height: 8),

                // ---- Countdown ----
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    final isUrgent = _secondsLeft <= 3;
                    final scale = isUrgent ? 1.0 + _pulseAnimation.value * 0.15 : 1.0;
                    return Transform.scale(
                      scale: scale,
                      child: Text(
                        '⏱ ${_secondsLeft}s',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isUrgent
                              ? neonPink.withValues(alpha: _pulseAnimation.value)
                              : const Color(0xFFFF4444),
                          letterSpacing: 2.0,
                          shadows: [
                            Shadow(
                              color: (isUrgent ? neonPink : const Color(0xFFFF4444))
                                  .withValues(alpha: 0.5),
                              blurRadius: 8.0,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // ---- Player buttons ----
                ...widget.players.map((player) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: () => _onPlayerTap(player),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(vertical: 14.0),
                          decoration: BoxDecoration(
                            color: surfaceLight,
                            borderRadius: BorderRadius.circular(12.0),
                            border: Border.all(
                              color: neonBlue.withValues(alpha: 0.6),
                              width: 1.5,
                            ),
                            boxShadow: neonGlow(neonBlue, blurRadius: 8.0),
                          ),
                          child: Center(
                            child: Text(
                              player.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
