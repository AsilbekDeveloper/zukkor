import '../../i18n/strings.g.dart';
import '../constants/app_strings.dart';

/// Til tanlagichlarda ko'rsatiladigan nom — hozircha [AppStrings]'dan
/// (task #170 Common+Home bo'limini ko'chirgach, bu ham slang'ga o'tadi).
extension AppLocaleDisplayName on AppLocale {
  String get displayName => switch (this) {
        AppLocale.en => AppStrings.languageEnglish,
        AppLocale.uz => AppStrings.languageUzbek,
        AppLocale.ru => AppStrings.languageRussian,
      };
}

/// Til tanlagichlarda ko'rsatish tartibi — generatsiya qilingan
/// `AppLocale.values` (en/ru/uz) o'rniga prototipdagi asl tartib
/// (English/Uzbek/Russian) saqlanadi.
const List<AppLocale> appLocaleDisplayOrder = [AppLocale.en, AppLocale.uz, AppLocale.ru];
