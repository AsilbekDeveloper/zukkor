import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/app_preferences.dart';
import 'app_sound.dart';
import 'sound_service.dart';

/// Whether UI sound effects are on — Settings' "Sound effects" toggle
/// drives this. Persisted via [AppPreferences], same pattern as
/// `ThemeController`.
class SoundController extends Notifier<bool> {
  @override
  bool build() => ref.watch(appPreferencesProvider).soundEffectsEnabled;

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await ref.read(appPreferencesProvider).saveSoundEffectsEnabled(enabled);
  }
}

final NotifierProvider<SoundController, bool> soundControllerProvider =
    NotifierProvider<SoundController, bool>(SoundController.new);

/// One-line call site for playing a UI sound — checks the mute toggle so
/// callers don't have to.
extension SoundRefX on WidgetRef {
  void playSound(AppSound sound) {
    if (!read(soundControllerProvider)) return;
    unawaited(read(soundServiceProvider).play(sound));
  }
}
