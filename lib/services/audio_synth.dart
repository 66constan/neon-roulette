import 'dart:math';
import 'dart:typed_data';

/// Pure-Dart WAV audio synthesis engine.
/// Generates all game sounds programmatically — zero audio files needed.
class AudioSynth {
  static const int sampleRate = 44100;
  static const int bitsPerSample = 16;
  static const int numChannels = 1;

  double _volume = 0.5;
  final Random _rng = Random();

  void setVolume(double v) => _volume = v.clamp(0.0, 1.0);
  double get volume => _volume;

  // ===========================================================================
  // Build WAV from float samples (-1.0 to 1.0)
  // ===========================================================================
  Uint8List _buildWav(List<double> samples) {
    final dataLen = samples.length * 2; // 16-bit
    final buf = ByteData(44 + dataLen);

    // RIFF header
    buf.setUint8(0, 0x52); buf.setUint8(1, 0x49); buf.setUint8(2, 0x46); buf.setUint8(3, 0x46); // "RIFF"
    buf.setUint32(4, 36 + dataLen, Endian.little);
    buf.setUint8(8, 0x57); buf.setUint8(9, 0x41); buf.setUint8(10, 0x56); buf.setUint8(11, 0x45); // "WAVE"
    buf.setUint8(12, 0x66); buf.setUint8(13, 0x6D); buf.setUint8(14, 0x74); buf.setUint8(15, 0x20); // "fmt "
    buf.setUint32(16, 16, Endian.little); // chunk size
    buf.setUint16(20, 1, Endian.little);  // PCM
    buf.setUint16(22, numChannels, Endian.little);
    buf.setUint32(24, sampleRate, Endian.little);
    buf.setUint32(28, sampleRate * numChannels * bitsPerSample ~/ 8, Endian.little);
    buf.setUint16(32, numChannels * bitsPerSample ~/ 8, Endian.little);
    buf.setUint16(34, bitsPerSample, Endian.little);
    buf.setUint8(36, 0x64); buf.setUint8(37, 0x61); buf.setUint8(38, 0x74); buf.setUint8(39, 0x61); // "data"
    buf.setUint32(40, dataLen, Endian.little);

    for (int i = 0; i < samples.length; i++) {
      final val = (samples[i] * 32767 * _volume).round().clamp(-32767, 32767);
      buf.setInt16(44 + i * 2, val, Endian.little);
    }
    return buf.buffer.asUint8List();
  }

  // ===========================================================================
  // Oscillator helpers
  // ===========================================================================
  double _sine(double t, double freq) => sin(2 * pi * freq * t);
  double _square(double t, double freq) => _sine(t, freq) >= 0 ? 1.0 : -1.0;
  double _saw(double t, double freq) => 2.0 * (freq * t - (0.5 + freq * t).floor());
  double _triangle(double t, double freq) => 2.0 * _saw(t, freq).abs() - 1.0;

  List<double> _genSamples(double dur, double freq, String type, {double? freqEnd, List<double>? envelope}) {
    final len = (sampleRate * dur).round();
    final samples = List.filled(len, 0.0);
    for (int i = 0; i < len; i++) {
      final t = i / sampleRate;
      final frac = i / len;
      final f = freqEnd != null ? freq + (freqEnd - freq) * frac : freq;
      double val;
      switch (type) {
        case 'sine':     val = _sine(t, f); break;
        case 'square':   val = _square(t, f); break;
        case 'saw':      val = _saw(t, f); break;
        case 'triangle': val = _triangle(t, f); break;
        default:         val = _sine(t, f);
      }
      if (envelope != null && i < envelope.length) val *= envelope[i];
      // Simple ADSR
      final attack = 0.01, release = 0.02;
      double env = 1.0;
      if (i < attack * sampleRate) env = i / (attack * sampleRate);
      else if (i > (dur - release) * sampleRate) env = ((dur - release) * sampleRate - i) / (release * sampleRate) + 1;
      samples[i] = val * env;
    }
    return samples;
  }

  // ===========================================================================
  // SOUNDS
  // ===========================================================================

  /// Tick — short sine sweep (charge tick / spin tick)
  Uint8List tick({double pitch = 1.0}) {
    final s = _genSamples(0.09, 120 * pitch, 'sine', freqEnd: 30 * pitch);
    return _buildWav(s);
  }

  /// Charge click — triangle blip (pitch rises with charge)
  Uint8List chargeClick(double progress) {
    final pitch = 100 + progress * 400;
    final len = (sampleRate * 0.06).round();
    final samples = List.filled(len, 0.0);
    for (int i = 0; i < len; i++) {
      final t = i / sampleRate;
      final f = pitch + (pitch * 0.5) * (i / len);
      final env = 1.0 - i / len;
      samples[i] = _triangle(t, f) * env * 0.3;
    }
    return _buildWav(samples);
  }

  /// Ding — ascending sine (energy orb fill)
  Uint8List ding() {
    final s = _genSamples(0.5, 880, 'sine', freqEnd: 1760);
    return _buildWav(s.map((v) => v * 0.6).toList());
  }

  /// Success arpeggio — C4-E4-G4-C5 triangle
  Uint8List success() {
    final notes = [261.63, 329.63, 392.00, 523.25];
    List<double> all = [];
    for (int i = 0; i < notes.length; i++) {
      final n = _genSamples(0.15, notes[i], 'triangle');
      all.addAll(n);
      // gap
      all.addAll(List.filled((0.05 * sampleRate).round(), 0.0));
    }
    return _buildWav(all);
  }

  /// Winner fanfare — G4-C5-E5-G5-C6 sawtooth+triangle detuned
  Uint8List winnerCheer() {
    final notes = [392.00, 523.25, 659.25, 783.99, 1046.50];
    List<double> all = [];
    for (int i = 0; i < notes.length; i++) {
      final n1 = _genSamples(0.15, notes[i], 'saw');
      final n2 = _genSamples(0.15, notes[i] * 1.008, 'triangle');
      for (int j = 0; j < n1.length; j++) {
        all.add((n1[j] + n2[j]) * 0.5);
      }
      all.addAll(List.filled((0.02 * sampleRate).round(), 0.0));
    }
    // Whistles
    for (int i = 0; i < 4; i++) {
      final startFreq = 1000.0 + i * 200 + _rng.nextDouble() * 150;
      final w = _genSamples(0.2, startFreq, 'sine', freqEnd: startFreq * 1.5);
      all.addAll(w.map((v) => v * 0.3));
    }
    return _buildWav(all);
  }

  /// VinaHouse Drop — 145 BPM hardstyle kicks + square donks (16 beats)
  Uint8List vinaHouseDrop() {
    const bpm = 145.0;
    final beatLen = 60.0 / bpm;
    List<double> all = [];
    for (int i = 0; i < 16; i++) {
      final offset = i * beatLen;
      final kickSamples = (beatLen * sampleRate).round();
      final beat = List.filled(kickSamples, 0.0);

      // Kick
      for (int j = 0; j < (0.12 * sampleRate).round() && j < beat.length; j++) {
        final t = j / sampleRate;
        final freq = 150.0 * exp(-t * 20);
        beat[j] += _sine(t, freq) * exp(-t * 15) * 0.6;
      }

      // Synth donk on even beats
      if (i % 2 != 0) {
        final notes = [440.0, 493.0, 523.0, 587.0, 659.0];
        final freq = notes[i % notes.length];
        for (int j = 0; j < (0.1 * sampleRate).round() && j < beat.length; j++) {
          final t = offset + j / sampleRate;
          beat[j] += _square(t - offset, freq) * exp(-(t - offset) * 15.0) * 0.2;
        }
      }

      all.addAll(beat);
    }
    return _buildWav(all);
  }

  /// Double penalty alarm — 8Hz LFO modulated saw
  Uint8List doubleAlarm() {
    final dur = 0.8;
    final len = (sampleRate * dur).round();
    final samples = List.filled(len, 0.0);
    for (int i = 0; i < len; i++) {
      final t = i / sampleRate;
      final mod = 1.0 + sin(2 * pi * 8 * t) * 0.5;
      final f = 150 * mod;
      final env = 1.0 - i / len;
      samples[i] = _saw(t, f) * env * 0.35;
    }
    return _buildWav(samples);
  }

  /// Slot machine spin sound — continuous filtered sweep + rhythmic pulse
  Uint8List slotMachineSpin({double duration = 0.35}) {
    final len = (sampleRate * duration).round();
    final samples = List.filled(len, 0.0);
    const baseFreq = 880.0;
    for (int i = 0; i < len; i++) {
      final t = i / sampleRate;
      final frac = i / len;
      final f = baseFreq + frac * 200;
      samples[i] = _sine(t, f) * 0.08 + _square(t, f * 1.5) * 0.03;
    }
    return _buildWav(samples);
  }

  /// BGM kick — single kick drum hit
  Uint8List bgmKick() {
    final len = (0.16 * sampleRate).round();
    final samples = List.filled(len, 0.0);
    for (int i = 0; i < len; i++) {
      final t = i / sampleRate;
      final f = 130.0 * exp(-t * 12);
      samples[i] = _sine(t, f) * exp(-t * 10) * 0.35;
    }
    return _buildWav(samples);
  }

  /// BGM bass — triangle low note
  Uint8List bgmBass(double freq) {
    final s = _genSamples(0.35, freq, 'triangle');
    return _buildWav(s.map((v) => v * 0.25).toList());
  }
}
