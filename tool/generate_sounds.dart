// Generates the app's UI sound effects as tiny synthesized WAV files —
// no external assets, no licensing concerns. Re-run with:
//   dart run tool/generate_sounds.dart
// Swap the generated files under assets/sounds/ for produced SFX later
// without changing any app code (filenames stay the same).
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

const int _sampleRate = 44100;

void main() {
  final Directory dir = Directory('assets/sounds')..createSync(recursive: true);

  _writeWav('${dir.path}/tap.wav', _tone(frequency: 1100, durationMs: 55, amplitude: 0.5, fadeOutMs: 30));

  _writeWav(
    '${dir.path}/correct.wav',
    _sequence([
      _tone(frequency: 523.25, durationMs: 110, amplitude: 0.55, fadeOutMs: 20), // C5
      _tone(frequency: 659.25, durationMs: 150, amplitude: 0.55, fadeOutMs: 60), // E5
    ]),
  );

  _writeWav('${dir.path}/wrong.wav', _buzz(frequency: 180, durationMs: 260, amplitude: 0.5));

  _writeWav(
    '${dir.path}/success.wav',
    _sequence([
      _tone(frequency: 523.25, durationMs: 90, amplitude: 0.5, fadeOutMs: 15), // C5
      _tone(frequency: 659.25, durationMs: 90, amplitude: 0.5, fadeOutMs: 15), // E5
      _tone(frequency: 784, durationMs: 90, amplitude: 0.5, fadeOutMs: 15), // G5
      _tone(frequency: 1046.5, durationMs: 220, amplitude: 0.55, fadeOutMs: 80), // C6
    ]),
  );

  stdout.writeln('Generated 4 sound assets in ${dir.path}');
}

/// A single sine tone with a linear fade-in/out envelope (avoids clicks
/// at the sample boundaries).
Int16List _tone({
  required double frequency,
  required int durationMs,
  required double amplitude,
  int fadeInMs = 5,
  int fadeOutMs = 20,
}) {
  final int n = (_sampleRate * durationMs / 1000).round();
  final int fadeInSamples = (_sampleRate * fadeInMs / 1000).round();
  final int fadeOutSamples = (_sampleRate * fadeOutMs / 1000).round();
  final Int16List samples = Int16List(n);

  for (int i = 0; i < n; i++) {
    double envelope = 1;
    if (i < fadeInSamples) envelope = i / fadeInSamples;
    if (i > n - fadeOutSamples) envelope = (n - i) / fadeOutSamples;
    envelope = envelope.clamp(0, 1);

    final double t = i / _sampleRate;
    final double sample = math.sin(2 * math.pi * frequency * t) * amplitude * envelope;
    samples[i] = (sample * 32767).round().clamp(-32768, 32767);
  }
  return samples;
}

/// A slightly harsher tone (fundamental + a soft 2nd harmonic) for the
/// "wrong answer" cue — distinct from the plain [_tone] used elsewhere.
Int16List _buzz({required double frequency, required int durationMs, required double amplitude}) {
  final int n = (_sampleRate * durationMs / 1000).round();
  final int fadeOutSamples = (_sampleRate * 60 / 1000).round();
  final Int16List samples = Int16List(n);

  for (int i = 0; i < n; i++) {
    double envelope = 1;
    if (i > n - fadeOutSamples) envelope = (n - i) / fadeOutSamples;
    envelope = envelope.clamp(0, 1);

    final double t = i / _sampleRate;
    final double fundamental = math.sin(2 * math.pi * frequency * t);
    final double harmonic = math.sin(2 * math.pi * frequency * 2 * t) * 0.35;
    final double sample = (fundamental + harmonic) * amplitude * envelope * 0.8;
    samples[i] = (sample * 32767).round().clamp(-32768, 32767);
  }
  return samples;
}

/// Concatenates tones back-to-back into one multi-note effect.
Int16List _sequence(List<Int16List> parts) {
  final int total = parts.fold(0, (sum, p) => sum + p.length);
  final Int16List out = Int16List(total);
  int offset = 0;
  for (final Int16List part in parts) {
    out.setRange(offset, offset + part.length, part);
    offset += part.length;
  }
  return out;
}

void _writeWav(String path, Int16List samples) {
  const int bitsPerSample = 16;
  const int channels = 1;
  const int byteRate = _sampleRate * channels * bitsPerSample ~/ 8;
  const int blockAlign = channels * bitsPerSample ~/ 8;
  final int dataSize = samples.length * 2;

  final BytesBuilder builder = BytesBuilder();

  void writeString(String s) => builder.add(s.codeUnits);
  void writeUint32(int v) => builder.add((ByteData(4)..setUint32(0, v, Endian.little)).buffer.asUint8List());
  void writeUint16(int v) => builder.add((ByteData(2)..setUint16(0, v, Endian.little)).buffer.asUint8List());

  writeString('RIFF');
  writeUint32(36 + dataSize);
  writeString('WAVE');
  writeString('fmt ');
  writeUint32(16); // PCM fmt chunk size
  writeUint16(1); // PCM format
  writeUint16(channels);
  writeUint32(_sampleRate);
  writeUint32(byteRate);
  writeUint16(blockAlign);
  writeUint16(bitsPerSample);
  writeString('data');
  writeUint32(dataSize);

  final ByteData sampleBytes = ByteData(dataSize);
  for (int i = 0; i < samples.length; i++) {
    sampleBytes.setInt16(i * 2, samples[i], Endian.little);
  }
  builder.add(sampleBytes.buffer.asUint8List());

  File(path).writeAsBytesSync(builder.toBytes());
}
