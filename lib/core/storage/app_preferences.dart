import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Oddiy (maxfiy bo'lmagan) sozlamalar ombori: tema rejimi va h.k.
/// Token kabi maxfiy ma'lumotlar bu yerda EMAS — ular [TokenStorage]da.
class AppPreferences {
  AppPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const String _themeModeKey = 'zukkor.theme_mode';

  ThemeMode get themeMode {
    return switch (_prefs.getString(_themeModeKey)) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.light,
    };
  }

  Future<void> saveThemeMode(ThemeMode mode) =>
      _prefs.setString(_themeModeKey, mode.name);
}

/// main() da SharedPreferences yuklangach override qilinadi —
/// shu tufayli sinxron, null-siz ishlaydi.
final Provider<AppPreferences> appPreferencesProvider =
    Provider<AppPreferences>((ref) {
  throw UnimplementedError(
    'appPreferencesProvider main() ichida override qilinishi shart',
  );
});
