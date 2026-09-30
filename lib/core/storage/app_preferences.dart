import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/presentation/controllers/current_user_controller.dart'
    show activeUserIdSignalProvider;

/// Oddiy (maxfiy bo'lmagan) sozlamalar ombori: tema rejimi va h.k.
/// Token kabi maxfiy ma'lumotlar bu yerda EMAS — ular [TokenStorage]da.
class AppPreferences {
  AppPreferences(this._prefs, {this.activeUserId});

  final SharedPreferences _prefs;
  final String? activeUserId;

  String _key(String base) =>
      activeUserId != null ? 'zukkor.${activeUserId!}.$base' : base;

  static const String _themeModeKey = 'zukkor.theme_mode';
  static const String _hasSeenIntroductionKey = 'zukkor.has_seen_introduction';
  static const String _hasSeenHomeTourKey = 'zukkor.has_seen_home_tour';
  static const String _localeCodeKey = 'zukkor.locale_code';

  ThemeMode get themeMode {
    // Theme and Locale are per-account.
    return switch (_prefs.getString(_key(_themeModeKey))) {
      'dark' => ThemeMode.dark,
      'light' => ThemeMode.light,
      _ => ThemeMode.light,
    };
  }

  Future<void> saveThemeMode(ThemeMode mode) =>
      _prefs.setString(_key(_themeModeKey), mode.name);

  // Global (device-level) setting.
  bool get hasSeenIntroduction =>
      _prefs.getBool(_hasSeenIntroductionKey) ?? false;

  Future<void> saveHasSeenIntroduction(bool value) =>
      _prefs.setBool(_hasSeenIntroductionKey, value);

  // Global (device-level) setting — Home ekranidagi asosiy tugmalarni
  // tushuntiruvchi coachmark tur faqat bir marta ko'rsatiladi.
  bool get hasSeenHomeTour => _prefs.getBool(_hasSeenHomeTourKey) ?? false;

  Future<void> saveHasSeenHomeTour(bool value) =>
      _prefs.setBool(_hasSeenHomeTourKey, value);

  /// Saqlangan til kodi ('en'/'uz'/'ru').
  String? get localeCode => _prefs.getString(_key(_localeCodeKey));

  Future<void> saveLocaleCode(String code) =>
      _prefs.setString(_key(_localeCodeKey), code);

  /// Berilgan foydalanuvchiga tegishli barcha sozlamalarni o'chiradi.
  Future<void> clearUserData(String userId) async {
    final String prefix = 'zukkor.$userId.';
    final Set<String> keys = _prefs.getKeys();
    for (final String key in keys) {
      if (key.startsWith(prefix)) {
        await _prefs.remove(key);
      }
    }
  }
}

/// main() da yuklangach override qilinadi.
final Provider<SharedPreferences> sharedPreferencesProvider =
    Provider<SharedPreferences>((ref) {
      throw UnimplementedError(
        'sharedPreferencesProvider override qilinishi shart',
      );
    });

/// Faol akkauntga bog'langan holda sozlamalarni qaytaradi.
///
/// MUHIM: bu yerda `currentUserControllerProvider`ni TO'G'RIDAN-TO'G'RI
/// o'qimang — bu provider `authRepositoryProvider` orqali
/// `getCurrentUserUseCaseProvider`ga bog'liq, `currentUserControllerProvider`
/// esa AYNAN shu use-case'ni chaqirib o'zini yuklaydi. To'g'ridan-to'g'ri
/// bog'lansa `currentUserControllerProvider` → `appPreferencesProvider` →
/// `currentUserControllerProvider` aylanma hosil bo'lib, HAR SAFAR profil
/// yuklashda `CircularDependencyError` berardi (2026-09-06, production'ni
/// butunlay buzgan xato). O'rniga hech narsaga bog'liq bo'lmagan
/// [activeUserIdSignalProvider]ni o'qiymiz — uni faqat
/// `CurrentUserController` yangilaydi.
final Provider<AppPreferences> appPreferencesProvider =
    Provider<AppPreferences>((ref) {
      final SharedPreferences prefs = ref.watch(sharedPreferencesProvider);
      final String? activeId = ref.watch(activeUserIdSignalProvider);
      return AppPreferences(prefs, activeUserId: activeId);
    });
