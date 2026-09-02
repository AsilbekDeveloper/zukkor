import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/presentation/controllers/current_user_controller.dart';

/// Oddiy (maxfiy bo'lmagan) sozlamalar ombori: tema rejimi va h.k.
/// Token kabi maxfiy ma'lumotlar bu yerda EMAS — ular [TokenStorage]da.
class AppPreferences {
  AppPreferences(this._prefs, {this.activeUserId});

  final SharedPreferences _prefs;
  final String? activeUserId;

  String _key(String base) => activeUserId != null ? 'zukkor.${activeUserId!}.$base' : base;

  static const String _themeModeKey = 'zukkor.theme_mode';
  static const String _hasSeenIntroductionKey = 'zukkor.has_seen_introduction';
  static const String _soundEffectsEnabledKey = 'zukkor.sound_effects_enabled';
  static const String _localeCodeKey = 'zukkor.locale_code';
  static const String _introInterestsKey = 'zukkor.intro_interests';
  static const String _introStudyPlaceKey = 'zukkor.intro_study_place';
  static const String _introQuizLikingKey = 'zukkor.intro_quiz_liking';

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
  bool get hasSeenIntroduction => _prefs.getBool(_hasSeenIntroductionKey) ?? false;

  Future<void> saveHasSeenIntroduction(bool value) =>
      _prefs.setBool(_hasSeenIntroductionKey, value);

  bool get soundEffectsEnabled => _prefs.getBool(_key(_soundEffectsEnabledKey)) ?? false;

  Future<void> saveSoundEffectsEnabled(bool value) =>
      _prefs.setBool(_key(_soundEffectsEnabledKey), value);

  /// Saqlangan til kodi ('en'/'uz'/'ru').
  String? get localeCode => _prefs.getString(_key(_localeCodeKey));

  Future<void> saveLocaleCode(String code) =>
      _prefs.setString(_key(_localeCodeKey), code);

  // Introduction so'rovnomasi javoblari — ro'yxatdan o'tishdan OLDIN
  // to'planadi (hali foydalanuvchi hisobi yo'q), shuning uchun bu yerda
  // vaqtincha saqlanadi va Onboarding'ni yakunlash so'rovi bilan birga
  // yuboriladi (keyin [clearIntroSurvey] bilan tozalanadi).
  List<String>? get introInterests => _prefs.getStringList(_introInterestsKey);
  String? get introStudyPlace => _prefs.getString(_introStudyPlaceKey);
  String? get introQuizLiking => _prefs.getString(_introQuizLikingKey);

  Future<void> saveIntroSurvey({
    required List<String> interests,
    required String studyPlace,
    required String quizLiking,
  }) async {
    await _prefs.setStringList(_introInterestsKey, interests);
    await _prefs.setString(_introStudyPlaceKey, studyPlace);
    await _prefs.setString(_introQuizLikingKey, quizLiking);
  }

  Future<void> clearIntroSurvey() async {
    await _prefs.remove(_introInterestsKey);
    await _prefs.remove(_introStudyPlaceKey);
    await _prefs.remove(_introQuizLikingKey);
  }

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
final Provider<SharedPreferences> sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider override qilinishi shart');
});

/// Faol akkauntga bog'langan holda sozlamalarni qaytaradi.
final Provider<AppPreferences> appPreferencesProvider = Provider<AppPreferences>((ref) {
  final SharedPreferences prefs = ref.watch(sharedPreferencesProvider);
  final String? activeId = ref.watch(currentUserControllerProvider).data?.id;
  return AppPreferences(prefs, activeUserId: activeId);
});
