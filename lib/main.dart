import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zukkor/app.dart';
import 'core/storage/app_preferences.dart';
import 'firebase_options.dart';
import 'i18n/strings.g.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Tema tanlovi kabi sozlamalar sinxron o'qilishi uchun oldindan yuklanadi —
  // ilova birinchi kadrdan to'g'ri temada ochiladi ("yarq etish" bo'lmaydi).
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  // Til ham xuddi shunday — birinchi kadrdan to'g'ri tilda ochilishi uchun
  // runApp'dan oldin sinxron o'rnatiladi.
  final String? savedLocaleCode = AppPreferences(prefs).localeCode;
  if (savedLocaleCode != null) {
    LocaleSettings.setLocaleRawSync(savedLocaleCode);
  } else {
    LocaleSettings.useDeviceLocaleSync();
  }

  runApp(
    ProviderScope(
      overrides: [
        appPreferencesProvider.overrideWithValue(AppPreferences(prefs)),
      ],
      child: const ZukkorApp(),
    ),
  );
}
