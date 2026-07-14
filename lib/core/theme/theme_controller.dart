import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/app_preferences.dart';

/// Tema rejimi holati — Sozlamalar ekranidagi dark mode toggle shu bilan
/// ishlaydi. Tanlov [AppPreferences] orqali diskda saqlanadi va ilova
/// qayta ochilganda tiklanadi (prototipdagi localStorage xatti-harakati).
class ThemeController extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ref.watch(appPreferencesProvider).themeMode;

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    await ref.read(appPreferencesProvider).saveThemeMode(mode);
  }

  Future<void> toggleDark(bool isDark) =>
      setMode(isDark ? ThemeMode.dark : ThemeMode.light);
}

final NotifierProvider<ThemeController, ThemeMode> themeControllerProvider =
    NotifierProvider<ThemeController, ThemeMode>(ThemeController.new);
