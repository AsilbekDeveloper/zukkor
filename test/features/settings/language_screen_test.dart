import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:zukkor/core/constants/app_strings.dart';
import 'package:zukkor/core/locale/locale_controller.dart';
import 'package:zukkor/core/router/app_routes.dart';
import 'package:zukkor/core/storage/app_preferences.dart';
import 'package:zukkor/core/theme/app_theme.dart';
import 'package:zukkor/features/settings/presentation/screens/language_screen.dart';
import 'package:zukkor/features/settings/presentation/screens/settings_screen.dart';
import 'package:zukkor/i18n/strings.g.dart';

/// SettingsScreen is the initial route (mounted underneath), and both
/// screens read localeControllerProvider (and SettingsScreen also reads
/// themeControllerProvider) — needs a real ProviderScope (mocked
/// SharedPreferences) rather than a bare MaterialApp.router.
Future<GoRouter> _pumpLanguage(WidgetTester tester, {Size size = const Size(390, 844)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.settings,
    routes: [
      GoRoute(path: AppRoutes.settings, builder: (context, state) => const SettingsScreen()),
      GoRoute(path: AppRoutes.languageSettings, builder: (context, state) => const LanguageScreen()),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: TranslationProvider(
        child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
      ),
    ),
  );
  unawaited(router.push(AppRoutes.languageSettings));
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets('renders all 3 languages with the current one checked, no overflow', (tester) async {
    await _pumpLanguage(tester);

    expect(find.text(AppStrings.settingsLanguage), findsOneWidget);
    expect(find.text(AppStrings.languageEnglish), findsOneWidget);
    expect(find.text(AppStrings.languageUzbek), findsOneWidget);
    expect(find.text(AppStrings.languageRussian), findsOneWidget);
    expect(find.byIcon(TablerIcons.check), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits on the smallest supported phone width', (tester) async {
    await _pumpLanguage(tester, size: const Size(360, 780));

    expect(find.text(AppStrings.settingsLanguage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping a language sets the locale and pops back', (tester) async {
    await _pumpLanguage(tester);

    await tester.tap(find.text(AppStrings.languageRussian));
    await tester.pumpAndSettle();

    expect(find.byType(LanguageScreen), findsNothing);
    expect(find.byType(SettingsScreen), findsOneWidget);
    final ProviderContainer container =
        ProviderScope.containerOf(tester.element(find.byType(SettingsScreen)));
    expect(container.read(localeControllerProvider), AppLocale.ru);
  });

  testWidgets('the back button pops without changing the locale', (tester) async {
    final GoRouter router = await _pumpLanguage(tester);

    await tester.tap(find.byIcon(TablerIcons.arrowLeft));
    await tester.pumpAndSettle();

    expect(find.byType(LanguageScreen), findsNothing);
    final ProviderContainer container = ProviderScope.containerOf(
      router.routerDelegate.navigatorKey.currentContext!,
    );
    expect(container.read(localeControllerProvider), AppLocale.en);
  });
}
