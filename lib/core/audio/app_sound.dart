/// Every UI sound effect the app can play — each maps to a tiny
/// synthesized WAV under `assets/sounds/` (see `tool/generate_sounds.dart`
/// for how they were generated; swap the files for produced SFX later
/// without touching any app code).
enum AppSound {
  /// General tap/selection — buttons, chips, segments, nav tabs.
  tap('sounds/tap.wav'),

  /// A correct quiz answer.
  correct('sounds/correct.wav'),

  /// A wrong (or timed-out) quiz answer.
  wrong('sounds/wrong.wav'),

  /// A celebratory moment — finishing the Introduction walkthrough, a
  /// quiz result reveal.
  success('sounds/success.wav');

  const AppSound(this.assetPath);

  /// Relative to the `assets/` folder declared in pubspec.yaml — matches
  /// what [AssetSource] expects.
  final String assetPath;
}
