import 'package:flutter/material.dart';
import '../models/penalty.dart';
import '../providers/game_provider.dart';
import '../theme/neon_theme.dart';
import '../i18n/translations.dart';

/// Settings panel — customize penalty names, language, sound.
class SettingsPanel extends StatefulWidget {
  final GameProvider provider;
  final VoidCallback onClose;

  const SettingsPanel({super.key, required this.provider, required this.onClose});

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  late Map<int, String> _names;
  late I18n _i18n;
  late bool _sound;

  @override
  void initState() {
    super.initState();
    _names = {};
    for (int i = 0; i < 8; i++) {
      _names[i] = widget.provider.getCustomName(i);
    }
    _i18n = widget.provider.i18n;
    _sound = widget.provider.soundEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Container(
          width: 360,
          constraints: const BoxConstraints(maxHeight: 500),
          decoration: BoxDecoration(
            color: surfaceDark,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: parseHex('#FF1493').withValues(alpha: 0.3)),
            boxShadow: [BoxShadow(color: parseHex('#FF1493').withValues(alpha: 0.2), blurRadius: 40)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _i18n.settingsTitle,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onClose,
                      child: const Icon(Icons.close, color: Colors.white54),
                    ),
                  ],
                ),
              ),
              const Divider(color: Color(0x29FF1493)),

              // Sound
              _buildToggle(
                icon: Icons.volume_up,
                label: _i18n.soundLabel,
                value: _sound,
                onChanged: (v) {
                  setState(() => _sound = v);
                  widget.provider.toggleSound();
                },
              ),

              // Language
              _buildRow(
                child: Row(
                  children: [
                    const Icon(Icons.language, color: Color(0xFF00CFFF), size: 20),
                    const SizedBox(width: 8),
                    Text(_i18n.langLabel, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        final next = _i18n.nextLocale();
                        widget.provider.setLocale(next);
                        setState(() => _i18n = widget.provider.i18n);
                      },
                      child: Text(
                        _i18n.locale.toUpperCase(),
                        style: const TextStyle(
                          color: Color(0xFF00CFFF),
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(color: Color(0x29FF1493)),

              // Custom names
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: 8,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (_, i) {
                    final p = Penalty.fromIndex(i);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 28,
                            decoration: BoxDecoration(
                              color: parseHex(Penalty.colorHex(i)),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${p.emoji} ${_i18n.penaltyTitle(i)}',
                              style: const TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Close button
              Padding(
                padding: const EdgeInsets.all(12),
                child: GestureDetector(
                  onTap: widget.onClose,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white24),
                    ),
                    child: Text(
                      'CLOSE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.6),
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggle({required IconData icon, required String label, required bool value, required ValueChanged<bool> onChanged}) {
    return _buildRow(
      child: Row(
        children: [
          Icon(icon, color: parseHex('#FF1493'), size: 20),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const Spacer(),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: parseHex('#FF1493'),
          ),
        ],
      ),
    );
  }

  Widget _buildRow({required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: child,
    );
  }
}
