import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../i18n/strings.g.dart';
import '../storage/app_preferences.dart';

/// Til holati — Sozlamalar va Introduction'dagi til tanlagichlar shu bilan
/// ishlaydi. Haqiqiy manba [LocaleSettings] (slang) hisoblanadi; bu
/// controller uni Riverpod orqali kuzatish mumkin qiladi va tanlovni
/// [AppPreferences] orqali diskda saqlaydi.
class LocaleController extends Notifier<AppLocale> {
  @override
  AppLocale build() => LocaleSettings.currentLocale;

  Future<void> setLocale(AppLocale locale) async {
    state = await LocaleSettings.setLocale(locale);
    await ref.read(appPreferencesProvider).saveLocaleCode(locale.languageCode);
  }
}

final NotifierProvider<LocaleController, AppLocale> localeControllerProvider =
    NotifierProvider<LocaleController, AppLocale>(LocaleController.new);
