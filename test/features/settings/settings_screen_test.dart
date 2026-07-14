import 'dart:async';

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
import 'package:zukkor/features/auth/presentation/screens/login_screen.dart';
import 'package:zukkor/features/home/presentation/screens/home_screen.dart';
import 'package:zukkor/features/settings/presentation/screens/help_center_screen.dart';
import 'package:zukkor/features/settings/presentation/screens/language_screen.dart';
import 'package:zukkor/features/settings/presentation/screens/notification_settings_screen.dart';
import 'package:zukkor/features/settings/presentation/screens/privacy_policy_screen.dart';
import 'package:zukkor/features/settings/presentation/screens/settings_screen.dart';
import 'package:zukkor/features/settings/presentation/screens/terms_of_use_screen.dart';

// SettingsScreen's theme switch reads/writes themeControllerProvider,
// which depends on appPreferencesProvider — needs a real ProviderScope
// (with a mocked SharedPreferences override) rather than a bare
// MaterialApp.router.
Future<GoRouter> _pumpSettings(WidgetTester tester, {Size size = const Size(390, 844)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen()),
      GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginScreen()),
      GoRoute(path: AppRoutes.settings, builder: (context, state) => const SettingsScreen()),
      GoRoute(
        path: AppRoutes.languageSettings,
        builder: (context, state) =>
            LanguageScreen(currentLanguage: (state.extra as String?) ?? AppStrings.languageEnglish),
      ),
      GoRoute(
        path: AppRoutes.notificationSettings,
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(path: AppRoutes.privacyPolicy, builder: (context, state) => const PrivacyPolicyScreen()),
      GoRoute(path: AppRoutes.helpCenter, builder: (context, state) => const HelpCenterScreen()),
      GoRoute(path: AppRoutes.termsOfUse, builder: (context, state) => const TermsOfUseScreen()),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [appPreferencesProvider.overrideWithValue(AppPreferences(prefs))],
      child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
    ),
  );
  unawaited(router.push(AppRoutes.settings));
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets('renders both groups, all rows, and Log out, no overflow', (tester) async {
    await _pumpSettings(tester);

    expect(find.text(AppStrings.settings), findsOneWidget);
    expect(find.text(AppStrings.settingsLanguage), findsOneWidget);
    expect(find.text(AppStrings.settingsLanguageValue), findsOneWidget);
    expect(find.text(AppStrings.settingsNotifications), findsOneWidget);
    expect(find.text(AppStrings.settingsTheme), findsOneWidget);
    expect(find.text(AppStrings.settingsThemeLight), findsOneWidget);
    expect(find.text(AppStrings.settingsPrivacy), findsOneWidget);
    expect(find.text(AppStrings.settingsHelpCenter), findsOneWidget);
    expect(find.text(AppStrings.settingsTermsOfUse), findsOneWidget);
    expect(find.text(AppStrings.settingsLogOut), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits on the smallest supported phone width', (tester) async {
    await _pumpSettings(tester, size: const Size(360, 780));

    expect(find.text(AppStrings.settingsLogOut), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping the theme row toggles the label from Light to Dark', (tester) async {
    await _pumpSettings(tester);

    expect(find.text(AppStrings.settingsThemeLight), findsOneWidget);

    await tester.tap(find.text(AppStrings.settingsTheme));
    await tester.pump();

    expect(find.text(AppStrings.settingsThemeDark), findsOneWidget);
    expect(find.text(AppStrings.settingsThemeLight), findsNothing);
  });

  testWidgets('tapping Language opens the Language picker, and picking one updates the row', (tester) async {
    await _pumpSettings(tester);

    await tester.tap(find.text(AppStrings.settingsLanguage));
    await tester.pumpAndSettle();

    expect(find.byType(LanguageScreen), findsOneWidget);
    expect(find.text(AppStrings.languageUzbek), findsOneWidget);

    await tester.tap(find.text(AppStrings.languageUzbek));
    await tester.pumpAndSettle();

    expect(find.byType(LanguageScreen), findsNothing);
    expect(find.text(AppStrings.languageUzbek), findsOneWidget);
  });

  testWidgets('tapping Notifications opens Notification preferences', (tester) async {
    await _pumpSettings(tester);

    await tester.tap(find.text(AppStrings.settingsNotifications));
    await tester.pumpAndSettle();

    expect(find.byType(NotificationSettingsScreen), findsOneWidget);
  });

  testWidgets('tapping Privacy opens the Privacy Policy', (tester) async {
    await _pumpSettings(tester);

    await tester.tap(find.text(AppStrings.settingsPrivacy));
    await tester.pumpAndSettle();

    expect(find.byType(PrivacyPolicyScreen), findsOneWidget);
  });

  testWidgets('tapping Help center opens the Help Center', (tester) async {
    await _pumpSettings(tester);

    await tester.tap(find.text(AppStrings.settingsHelpCenter));
    await tester.pumpAndSettle();

    expect(find.byType(HelpCenterScreen), findsOneWidget);
  });

  testWidgets('tapping Terms of use opens the Terms of Use', (tester) async {
    await _pumpSettings(tester);

    await tester.tap(find.text(AppStrings.settingsTermsOfUse));
    await tester.pumpAndSettle();

    expect(find.byType(TermsOfUseScreen), findsOneWidget);
  });

  testWidgets('tapping Log out navigates to Login', (tester) async {
    await _pumpSettings(tester);

    await tester.tap(find.text(AppStrings.settingsLogOut));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(SettingsScreen), findsNothing);
  });

  testWidgets('the back button returns to Home when pushed on top of it', (tester) async {
    await _pumpSettings(tester);

    await tester.tap(find.byIcon(TablerIcons.arrowLeft));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.duelHeroTitle), findsOneWidget);
    expect(find.byType(SettingsScreen), findsNothing);
  });
}
