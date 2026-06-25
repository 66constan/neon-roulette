import 'dart:math';
import 'package:flutter/material.dart';

/// Full-screen dark background with floating neon particles.
///
/// Renders 40 glowing particles that drift upward with horizontal wobble,
/// cycling through neon pink, cyan, orange, and gold. Particles regenerate
/// from the bottom when they drift off the top edge. Uses a single
/// [CustomPainter] for optimal performance at 60fps.
class NeonBackground extends StatefulWidget {
  const NeonBackground({super.key});

  @override
  State<NeonBackground> createState() => _NeonBackgroundState();
}

class _NeonBackgroundState extends State<NeonBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final List<_Particle> _particles = [];
  final Random _random = Random();

  static const int _particleCount = 40;
  static const Color _backgroundColor = Color(0xFF0A0A0A);

  static const List<Color> _neonColors = [
    Color(0xFFFF2D7A), // neon pink
    Color(0xFF00CFFF), // neon cyan
    Color(0xFFFF6B1A), // neon orange
    Color(0xFFFFD700), // neon gold
  ];

  /// Accumulated time in seconds, incremented each animation frame.
  double _elapsed = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      // Duration is arbitrary; we only use the per-frame listener.
      duration: const Duration(seconds: 10),
    )..repeat();

    // Seed particles at random positions across the full screen.
    for (int i = 0; i < _particleCount; i++) {
      _particles.add(_createParticle(randomY: true));
    }

    _controller.addListener(_onTick);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    _controller.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Particle lifecycle
  // ---------------------------------------------------------------------------

  /// Creates a single particle with randomised properties.
  _Particle _createParticle({required bool randomY}) {
    return _Particle(
      x: _random.nextDouble(),
      y: randomY ? _random.nextDouble() : 1.0 + _random.nextDouble() * 0.05,
      radius: 1.0 + _random.nextDouble() * 3.0,
      color: _neonColors[_random.nextInt(_neonColors.length)],
      speed: 0.003 + _random.nextDouble() * 0.010,
      wobble: 0.001 + _random.nextDouble() * 0.005,
      wobblePhase: _random.nextDouble() * 2 * pi,
      opacityPhase: _random.nextDouble() * 2 * pi,
      opacityFrequency: 0.5 + _random.nextDouble() * 2.0,
    );
  }

  /// Recycles a particle by resetting it to a new spawn point at the bottom.
  void _recycleParticle(_Particle p) {
    final fresh = _createParticle(randomY: false);
    p.x = fresh.x;
    p.y = fresh.y;
    p.radius = fresh.radius;
    p.color = fresh.color;
    p.speed = fresh.speed;
    p.wobble = fresh.wobble;
    p.wobblePhase = fresh.wobblePhase;
    p.opacityPhase = fresh.opacityPhase;
    p.opacityFrequency = fresh.opacityFrequency;
  }

  // ---------------------------------------------------------------------------
  // Per-frame update
  // ---------------------------------------------------------------------------

  void _onTick() {
    _elapsed += 0.016; // ~60 fps

    for (final p in _particles) {
      // Drift upward.
      p.y -= p.speed;

      // Horizontal wobble (sine-based oscillation).
      p.x += sin(_elapsed * 3.0 + p.wobblePhase) * p.wobble;

      // Wrap horizontal position so particles don't drift off-screen.
      if (p.x > 1.0) {
        p.x -= 1.0;
      } else if (p.x < 0.0) {
        p.x += 1.0;
      }

      // Regenerate at the bottom when the particle drifts above the screen.
      if (p.y < -0.05) {
        _recycleParticle(p);
      }
    }

    setState(() {}); // triggers repaint
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _NeonParticlePainter(
        particles: _particles,
        elapsed: _elapsed,
        backgroundColor: _backgroundColor,
      ),
      size: Size.infinite,
    );
  }
}

// =============================================================================
// Particle data model
// =============================================================================

class _Particle {
  /// Normalised horizontal position (0.0 = left edge, 1.0 = right edge).
  double x;

  /// Normalised vertical position (0.0 = top edge, 1.0 = bottom edge).
  double y;

  /// Radius of the particle core in logical pixels (range ~1-4).
  double radius;

  /// Neon colour for this particle.
  Color color;

  /// Upward drift speed in normalised units per frame (range ~0.003-0.013).
  double speed;

  /// Amplitude of the horizontal sine wobble (normalised units).
  double wobble;

  /// Phase offset for the wobble sine wave so particles don't move in sync.
  double wobblePhase;

  /// Phase offset for the opacity pulse sine wave.
  double opacityPhase;

  /// Frequency multiplier for the opacity pulse.
  double opacityFrequency;

  _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.color,
    required this.speed,
    required this.wobble,
    required this.wobblePhase,
    required this.opacityPhase,
    required this.opacityFrequency,
  });

  /// Returns the current opacity (0.3 – 0.8) based on a pulsing sine wave.
  double opacity(double elapsed) {
    final raw = sin(elapsed * opacityFrequency + opacityPhase);
    return 0.55 + raw * 0.25; // map [-1, 1] → [0.3, 0.8]
  }
}

// =============================================================================
// Custom painter — draws every particle in a single pass
// =============================================================================

class _NeonParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double elapsed;
  final Color backgroundColor;

  _NeonParticlePainter({
    required this.particles,
    required this.elapsed,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Solid dark background.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = backgroundColor,
    );

    for (final p in particles) {
      final alpha = p.opacity(elapsed);
      final cx = p.x * size.width;
      final cy = p.y * size.height;

      // ---- outer glow (large, soft) ----
      final outerGlow = Paint()
        ..color = p.color.withValues(alpha: alpha * 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10.0);
      canvas.drawCircle(Offset(cx, cy), p.radius * 3.5, outerGlow);

      // ---- mid glow ----
      final midGlow = Paint()
        ..color = p.color.withValues(alpha: alpha * 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
      canvas.drawCircle(Offset(cx, cy), p.radius * 2.0, midGlow);

      // ---- bright core ----
      final core = Paint()
        ..color = p.color.withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);
      canvas.drawCircle(Offset(cx, cy), p.radius, core);

      // ---- white-hot centre ----
      final center = Paint()
        ..color = Colors.white.withValues(alpha: alpha * 0.7);
      canvas.drawCircle(Offset(cx, cy), p.radius * 0.35, center);
    }
  }

  @override
  bool shouldRepaint(covariant _NeonParticlePainter oldDelegate) => true;
}
