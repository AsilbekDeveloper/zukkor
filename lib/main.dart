import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zukkor/app.dart';
import 'core/storage/app_preferences.dart';
import 'firebase_options.dart';
import 'i18n/strings.g.dart';

Future<void> main() async {
  // `runZonedGuarded` — beta paytida xatolarni ushlab olish uchun: Flutter
  // frameworkning o'zi ko'targan xatolar (widget build/layout) va shu zonadan
  // tashqariga chiqib ketgan har qanday boshqa (masalan async) xato ikkalasi
  // ham shu yerda Crashlytics'ga yetkaziladi - debug rejimida esa konsolga
  // ham chiqib turadi, xuddi standart xatti-harakat kabi.
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

      FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      // Tema tanlovi kabi sozlamalar sinxron o'qilishi uchun oldindan
      // yuklanadi — ilova birinchi kadrdan to'g'ri temada ochiladi ("yarq
      // etish" bo'lmaydi).
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      // Til ham xuddi shunday — birinchi kadrdan to'g'ri tilda ochilishi
      // uchun runApp'dan oldin sinxron o'rnatiladi.
      final String? savedLocaleCode = AppPreferences(prefs).localeCode;
      if (savedLocaleCode != null) {
        LocaleSettings.setLocaleRawSync(savedLocaleCode);
      } else {
        LocaleSettings.useDeviceLocaleSync();
      }

      // slang paketida "uz" uchun standart ko'plik (plural) qoidasi yo'q —
      // sozlanmasa har safar "Resolver for <lang = uz> not specified!"
      // ogohlantirishi bilan zaxira (fallback) ishlatiladi. O'zbek tilida
      // (turkiy tillarning aksariyati kabi) otlar songa qarab grammatik
      // shaklini o'zgartirmaydi — faqat "other" toifasi kifoya.
      LocaleSettings.setPluralResolverSync(
        language: 'uz',
        cardinalResolver: (n, {zero, one, two, few, many, other}) => other ?? '',
        ordinalResolver: (n, {zero, one, two, few, many, other}) => other ?? '',
      );

      runApp(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const ZukkorApp(),
        ),
      );
    },
    (error, stack) => FirebaseCrashlytics.instance.recordError(error, stack, fatal: true),
  );
}
