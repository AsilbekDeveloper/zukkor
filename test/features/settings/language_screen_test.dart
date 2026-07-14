import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:zukkor/core/constants/app_strings.dart';
import 'package:zukkor/core/router/app_routes.dart';
import 'package:zukkor/core/storage/app_preferences.dart';
import 'package:zukkor/core/theme/app_theme.dart';
import 'package:zukkor/features/settings/presentation/screens/language_screen.dart';
import 'package:zukkor/features/settings/presentation/screens/settings_screen.dart';

/// Returns the router plus the `Future` the screen's own `push` resolves
/// with — mirrors the pattern used by `rank_filter_screen_test.dart`.
/// SettingsScreen is the initial route (mounted underneath), and it reads
/// themeControllerProvider — needs a real ProviderScope (mocked
/// SharedPreferences) rather than a bare MaterialApp.router.
Future<(GoRouter, Future<String?>)> _pumpLanguage(
  WidgetTester tester, {
  required String currentLanguage,
  Size size = const Size(390, 844),
}) async {
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
      GoRoute(
        path: AppRoutes.languageSettings,
        builder: (context, state) => LanguageScreen(currentLanguage: state.extra! as String),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [appPreferencesProvider.overrideWithValue(AppPreferences(prefs))],
      child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
    ),
  );
  final Future<String?> resultFuture =
      router.push<String?>(AppRoutes.languageSettings, extra: currentLanguage);
  await tester.pumpAndSettle();
  return (router, resultFuture);
}

void main() {
  testWidgets('renders all 3 languages with the current one checked, no overflow', (tester) async {
    await _pumpLanguage(tester, currentLanguage: AppStrings.languageEnglish);

    expect(find.text(AppStrings.settingsLanguage), findsOneWidget);
    expect(find.text(AppStrings.languageEnglish), findsOneWidget);
    expect(find.text(AppStrings.languageUzbek), findsOneWidget);
    expect(find.text(AppStrings.languageRussian), findsOneWidget);
    expect(find.byIcon(TablerIcons.check), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits on the smallest supported phone width', (tester) async {
    await _pumpLanguage(tester, currentLanguage: AppStrings.languageEnglish, size: const Size(360, 780));

    expect(find.text(AppStrings.settingsLanguage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping a language pops with that language name', (tester) async {
    final (_, Future<String?> resultFuture) =
        await _pumpLanguage(tester, currentLanguage: AppStrings.languageEnglish);

    await tester.tap(find.text(AppStrings.languageRussian));
    await tester.pumpAndSettle();

    expect(await resultFuture, AppStrings.languageRussian);
  });

  testWidgets('the back button pops with the previously active language unchanged', (tester) async {
    final (_, Future<String?> resultFuture) =
        await _pumpLanguage(tester, currentLanguage: AppStrings.languageUzbek);

    await tester.tap(find.byIcon(TablerIcons.arrowLeft));
    await tester.pumpAndSettle();

    expect(await resultFuture, AppStrings.languageUzbek);
  });
}
