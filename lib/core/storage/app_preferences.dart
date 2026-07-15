import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Oddiy (maxfiy bo'lmagan) sozlamalar ombori: tema rejimi va h.k.
/// Token kabi maxfiy ma'lumotlar bu yerda EMAS — ular [TokenStorage]da.
class AppPreferences {
  AppPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const String _themeModeKey = 'zukkor.theme_mode';
  static const String _hasSeenIntroductionKey = 'zukkor.has_seen_introduction';
  static const String _soundEffectsEnabledKey = 'zukkor.sound_effects_enabled';
  static const String _localeCodeKey = 'zukkor.locale_code';

  ThemeMode get themeMode {
    return switch (_prefs.getString(_themeModeKey)) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.light,
    };
  }

  Future<void> saveThemeMode(ThemeMode mode) =>
      _prefs.setString(_themeModeKey, mode.name);

  bool get hasSeenIntroduction => _prefs.getBool(_hasSeenIntroductionKey) ?? false;

  Future<void> saveHasSeenIntroduction(bool value) =>
      _prefs.setBool(_hasSeenIntroductionKey, value);

  // Defaults to off — the current sound set is a placeholder (synthesized
  // tones) and coverage across the app isn't finished yet. Flip this back
  // to `true` once real SFX are dropped into assets/sounds/ and coverage
  // is complete; the Settings toggle already works either way.
  bool get soundEffectsEnabled => _prefs.getBool(_soundEffectsEnabledKey) ?? false;

  Future<void> saveSoundEffectsEnabled(bool value) =>
      _prefs.setBool(_soundEffectsEnabledKey, value);

  /// Saqlangan til kodi ('en'/'uz'/'ru'). `null` bo'lsa hali tanlanmagan —
  /// bu holda qurilma tiliga tayaniladi.
  String? get localeCode => _prefs.getString(_localeCodeKey);

  Future<void> saveLocaleCode(String code) =>
      _prefs.setString(_localeCodeKey, code);
}

/// main() da SharedPreferences yuklangach override qilinadi —
/// shu tufayli sinxron, null-siz ishlaydi.
final Provider<AppPreferences> appPreferencesProvider =
    Provider<AppPreferences>((ref) {
  throw UnimplementedError(
    'appPreferencesProvider main() ichida override qilinishi shart',
  );
});
