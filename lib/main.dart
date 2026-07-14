import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zukkor/app.dart';
import 'core/storage/app_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Tema tanlovi kabi sozlamalar sinxron o'qilishi uchun oldindan yuklanadi —
  // ilova birinchi kadrdan to'g'ri temada ochiladi ("yarq etish" bo'lmaydi).
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        appPreferencesProvider.overrideWithValue(AppPreferences(prefs)),
      ],
      child: const ZukkorApp(),
    ),
  );
}
