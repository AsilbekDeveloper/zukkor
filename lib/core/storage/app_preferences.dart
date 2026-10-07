import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Oddiy (maxfiy bo'lmagan) sozlamalar ombori: tema rejimi va h.k.
/// Token kabi maxfiy ma'lumotlar bu yerda EMAS — ular [TokenStorage]da.
///
/// Hammasi GLOBAL (qurilma darajasida), akkauntga bog'lanmagan — avval
/// tema/til har bir akkaunt uchun alohida (`zukkor.<userId>.*` kaliti
/// bilan) saqlanardi, bu multi-account funksiyasi uchun qilingan edi
/// (keyinchalik 2026-09-12'da butunlay olib tashlangan). Shu
/// qoldiq alohida-saqlash mantig'i jiddiy xatoga sabab bo'lgan edi
/// (2026-10-07, foydalanuvchi topdi): `main.dart` ilova ochilishining
/// eng boshida, foydalanuvchi hali yuklanmasdan (`activeUserId == null`)
/// tilni sinxron o'qiydi — prefikssiz kalitdan. Lekin Sozlamalar
/// ekranida til o'zgartirilganda foydalanuvchi allaqachon yuklangan
/// bo'lardi — saqlash boshqa (prefikslangan) kalitga yozilardi. Natijada
/// tanlov hech qachon o'qiladigan joyga yozilmas, ilova qayta
/// ochilganda doim standart tilga/temaga qaytardi.
class AppPreferences {
  AppPreferences(this._prefs);

  final SharedPreferences _prefs;

  static const String _themeModeKey = 'zukkor.theme_mode';
  static const String _hasSeenIntroductionKey = 'zukkor.has_seen_introduction';
  static const String _hasSeenHomeTourKey = 'zukkor.has_seen_home_tour';
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

  bool get hasSeenIntroduction =>
      _prefs.getBool(_hasSeenIntroductionKey) ?? false;

  Future<void> saveHasSeenIntroduction(bool value) =>
      _prefs.setBool(_hasSeenIntroductionKey, value);

  // Home ekranidagi asosiy tugmalarni tushuntiruvchi coachmark tur faqat
  // bir marta ko'rsatiladi.
  bool get hasSeenHomeTour => _prefs.getBool(_hasSeenHomeTourKey) ?? false;

  Future<void> saveHasSeenHomeTour(bool value) =>
      _prefs.setBool(_hasSeenHomeTourKey, value);

  /// Saqlangan til kodi ('en'/'uz'/'ru').
  String? get localeCode => _prefs.getString(_localeCodeKey);

  Future<void> saveLocaleCode(String code) =>
      _prefs.setString(_localeCodeKey, code);
}

/// main() da yuklangach override qilinadi.
final Provider<SharedPreferences> sharedPreferencesProvider =
    Provider<SharedPreferences>((ref) {
      throw UnimplementedError(
        'sharedPreferencesProvider override qilinishi shart',
      );
    });

final Provider<AppPreferences> appPreferencesProvider =
    Provider<AppPreferences>((ref) {
      final SharedPreferences prefs = ref.watch(sharedPreferencesProvider);
      return AppPreferences(prefs);
    });
