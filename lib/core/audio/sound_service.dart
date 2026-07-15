import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_sound.dart';

/// Plays short UI sound effects — one [AudioPlayer] per [AppSound],
/// reused across calls (cheaper than creating a new player per tap).
///
/// Every call is best-effort: a missing/broken audio backend (widget
/// tests, an unsupported target, a device with no audio output) never
/// throws back into the UI interaction that triggered the sound.
class SoundService {
  final Map<AppSound, AudioPlayer> _players = {};

  AudioPlayer _playerFor(AppSound sound) =>
      _players.putIfAbsent(sound, AudioPlayer.new);

  Future<void> play(AppSound sound) async {
    try {
      final AudioPlayer player = _playerFor(sound);
      await player.stop();
      await player.play(AssetSource(sound.assetPath));
    } catch (_) {
      // Best-effort — see class doc.
    }
  }

  Future<void> dispose() async {
    for (final AudioPlayer player in _players.values) {
      await player.dispose();
    }
    _players.clear();
  }
}

final Provider<SoundService> soundServiceProvider = Provider<SoundService>((ref) {
  final SoundService service = SoundService();
  ref.onDispose(service.dispose);
  return service;
});
