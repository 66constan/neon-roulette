import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/game_state.dart';
import '../models/penalty.dart';
import '../providers/game_provider.dart';
import '../theme/neon_theme.dart';
import '../services/haptic_service.dart';
import '../widgets/neon_grid.dart';
import '../widgets/center_button.dart';
import '../widgets/charge_bar.dart';
import '../widgets/energy_orbs.dart';
import '../widgets/penalty_card.dart';
import '../widgets/fingerprint_touch.dart';
import '../widgets/settings_panel.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _showSettings = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().startBgm();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GameProvider>();
    final state = provider.state;
    final i18n = provider.i18n;

    return Scaffold(
      backgroundColor: bgDark,
      body: Stack(
        children: [
          // ---- Background gradient ----
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 180,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    parseHex('#FF1493').withValues(
                      alpha: state.phase == GamePhase.spinning ? 0.2 + (0.5) * 0.3 : 0.12,
                    ),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // ---- Grid background pattern ----
          Positioned.fill(
            child: CustomPaint(
              painter: _GridPatternPainter(),
            ),
          ),

          // ---- Strobe overlay ----
          if (state.showStrobe)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  color: DateTime.now().millisecondsSinceEpoch % 200 < 100
                      ? Colors.white.withValues(alpha: 0.9)
                      : Colors.transparent,
                ),
              ),
            ),

          // ---- Main content ----
          SafeArea(
            child: Column(
              children: [
                // ---- Header ----
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      // Logo
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: surfaceDark,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: parseHex('#FF2D7A').withValues(alpha: 0.4)),
                          boxShadow: [BoxShadow(color: parseHex('#FF2D7A').withValues(alpha: 0.2), blurRadius: 12)],
                        ),
                        child: const Icon(Icons.whatshot, color: Color(0xFFFF2D7A), size: 16),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                i18n.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 2,
                                  foreground: Paint()
                                    ..shader = const LinearGradient(
                                      colors: [Color(0xFFFF1493), Color(0xFFE040FB), Color(0xFFFFD700)],
                                    ).createShader(const Rect.fromLTWH(0, 0, 150, 20)),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(3),
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFFFF1493), Color(0xFFFFD700)],
                                  ),
                                ),
                                child: const Text(
                                  'VIP',
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            i18n.subtitle,
                            style: const TextStyle(
                              fontSize: 9,
                              color: Color(0x80FF1493),
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Sound toggle
                      _IconBtn(
                        icon: provider.soundEnabled ? Icons.volume_up : Icons.volume_off,
                        color: provider.soundEnabled ? const Color(0xFFFF1493) : Colors.white24,
                        onTap: () => provider.toggleSound(),
                      ),
                      const SizedBox(width: 4),
                      // Language switch
                      _IconBtn(
                        icon: Icons.language,
                        color: const Color(0xFF00CFFF),
                        label: i18n.locale.toUpperCase(),
                        onTap: () {
                          provider.setLocale(i18n.nextLocale());
                        },
                      ),
                      const SizedBox(width: 4),
                      // Settings
                      _IconBtn(
                        icon: Icons.settings,
                        color: Colors.white38,
                        onTap: () => setState(() => _showSettings = true),
                      ),
                    ],
                  ),
                ),

                // ---- Energy orbs ----
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: EnergyOrbs(count: state.orbCount),
                ),

                // ---- Main board area ----
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        // Charge bar
                        if (state.phase == GamePhase.charging || state.orbCount > 0)
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChargeBar(
                              progress: state.chargeProgress,
                              isFull: state.isFullCharge,
                            ),
                          ),
                        // 3x3 grid
                        Expanded(
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              NeonGrid(provider: provider),
                              // Center button
                              CenterButton(
                                phase: state.phase,
                                label: state.phase == GamePhase.idle
                                    ? '长按\n旋转'
                                    : state.phase == GamePhase.charging
                                        ? '松手!'
                                        : state.phase == GamePhase.result
                                            ? '再来\n一局'
                                            : i18n.spinning,
                                onLongPressStart: () => provider.startCharging(),
                                onLongPressEnd: () => provider.stopChargingAndSpin(),
                                onTap: () => provider.nextRound(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ---- Result card ----
                if (state.selectedIndex != null) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: PenaltyCard(
                      penaltyIndex: state.selectedIndex!,
                      title: provider.getCustomName(state.selectedIndex!),
                      subtitle: i18n.penaltySubtitle(state.selectedIndex!),
                      description: i18n.penaltyDescription(state.selectedIndex!),
                      colorHex: Penalty.colorHex(state.selectedIndex!),
                      showPlayAgain: state.phase == GamePhase.result,
                      onPlayAgain: () {
                        provider.nextRound();
                      },
                    ),
                  ),
                ],

                // ---- Rules text ----
                if (state.phase == GamePhase.idle)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                    child: Text(
                      i18n.rules,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.35),
                        letterSpacing: 1,
                      ),
                    ),
                  ),

                // ---- Fingerprint touch ----
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: FingerprintTouch(
                    isCharging: state.phase == GamePhase.charging,
                    onLongPressStart: state.phase == GamePhase.idle
                        ? () => provider.startCharging()
                        : null,
                    onLongPressEnd: state.phase == GamePhase.charging
                        ? () => provider.stopChargingAndSpin()
                        : null,
                  ),
                ),

                // ---- Footer ----
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '© 2026 NEON ROULETTE',
                        style: TextStyle(
                          fontSize: 8,
                          color: parseHex('#FF1493').withValues(alpha: 0.5),
                          letterSpacing: 1,
                        ),
                      ),
                      Text(
                        'CABARET VERIFIED',
                        style: TextStyle(
                          fontSize: 8,
                          color: parseHex('#E040FB').withValues(alpha: 0.6),
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ---- Settings overlay ----
          if (_showSettings)
            SettingsPanel(
              provider: provider,
              onClose: () => setState(() => _showSettings = false),
            ),
        ],
      ),
    );
  }
}

// =============================================================================
// Helper widgets
// =============================================================================

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String? label;
  final VoidCallback onTap;

  const _IconBtn({required this.icon, required this.color, this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bgDark,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            if (label != null) ...[
              const SizedBox(width: 4),
              Text(label!, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: color)),
            ],
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// Grid pattern painter
// =============================================================================

class _GridPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = parseHex('#FF1493').withValues(alpha: 0.03)
      ..strokeWidth = 0.5;

    const cellSize = 56.0;
    for (double x = 0; x < size.width; x += cellSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += cellSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
