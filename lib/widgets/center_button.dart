import 'package:flutter/material.dart';
import '../models/game_state.dart';

// =============================================================================
// CenterButton — the long-press start / replay button at the center of the grid
// =============================================================================

/// A circular neon button that occupies the center slot of the [NeonGrid].
///
/// Behaviour per [GamePhase]:
/// - **idle**       : Pulsating glow, shows "长按中心 · 松手随机".
/// - **charging**   : Shrinks slightly, glow intensifies, shows "松手!".
/// - **spinning**   : Disabled and greyed out.
/// - **stopping**   : Disabled and greyed out.
/// - **result**     : Shows "再来一局"; tapping fires [onTap].
/// - **picking**    : Disabled.
///
/// Long-press detection uses a 300 ms threshold via [GestureDetector].
class CenterButton extends StatefulWidget {
  final GamePhase phase;
  final VoidCallback onLongPressStart;
  final VoidCallback onLongPressEnd;
  final VoidCallback onTap;

  const CenterButton({
    super.key,
    required this.phase,
    required this.onLongPressStart,
    required this.onLongPressEnd,
    required this.onTap,
  });

  @override
  State<CenterButton> createState() => _CenterButtonState();
}

class _CenterButtonState extends State<CenterButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  // ---------------------------------------------------------------------------
  // Gradient colours
  // ---------------------------------------------------------------------------

  static const _gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF1493), // neon pink
      Color(0xFFFF6B1A), // neon orange
    ],
  );

  static const _disabledGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF555555),
      Color(0xFF444444),
    ],
  );

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(covariant CenterButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.phase == GamePhase.idle && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (widget.phase != GamePhase.idle &&
        _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  bool get _isDisabled =>
      widget.phase == GamePhase.spinning ||
      widget.phase == GamePhase.stopping ||
      widget.phase == GamePhase.picking;

  double _diameter(GamePhase phase) {
    return phase == GamePhase.charging ? 70.0 : 80.0;
  }

  String _label(GamePhase phase) {
    switch (phase) {
      case GamePhase.idle:
        return '长按中心\n松手随机';
      case GamePhase.charging:
        return '松手!';
      case GamePhase.result:
        return '再来一局';
      default:
        return '';
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final diameter = _diameter(widget.phase);
    final disabled = _isDisabled;
    final showPulse = widget.phase == GamePhase.idle;

    Widget button = GestureDetector(
      onLongPressStart:
          widget.phase == GamePhase.idle
              ? (_) => widget.onLongPressStart()
              : null,
      onLongPressEnd:
          widget.phase == GamePhase.charging
              ? (_) => widget.onLongPressEnd()
              : null,
      onTap: widget.phase == GamePhase.result ? () => widget.onTap() : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: disabled ? _disabledGradient : _gradient,
          boxShadow: disabled
              ? []
              : [
                  BoxShadow(
                    color: _gradient.colors[1].withValues(alpha: 0.5),
                    blurRadius: 12.0,
                    spreadRadius: 1.0,
                  ),
                ],
        ),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: widget.phase == GamePhase.result ? 18.0 : 14.0,
              fontWeight: FontWeight.bold,
              color: disabled ? Colors.white30 : Colors.white,
              height: 1.3,
              letterSpacing: 1.0,
              shadows: disabled
                  ? []
                  : [
                      Shadow(
                        color: Colors.white.withValues(alpha: 0.5),
                        blurRadius: 6.0,
                      ),
                    ],
            ),
            textAlign: TextAlign.center,
            child: Text(_label(widget.phase)),
          ),
        ),
      ),
    );

    // Wrap in AnimatedBuilder to add the pulsing outer glow during idle.
    if (showPulse) {
      button = AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Container(
            width: diameter + 24,
            height: diameter + 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _gradient.colors[0]
                      .withValues(alpha: _pulseAnimation.value),
                  blurRadius: 24.0,
                  spreadRadius: 4.0,
                ),
              ],
            ),
            child: child,
          );
        },
        child: button,
      );
    }

    return button;
  }
}
