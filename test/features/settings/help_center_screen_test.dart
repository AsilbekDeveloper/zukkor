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
import 'package:zukkor/features/settings/presentation/screens/help_center_screen.dart';
import 'package:zukkor/features/settings/presentation/screens/settings_screen.dart';

// SettingsScreen is the initial route (mounted underneath) and reads
// themeControllerProvider — needs a real ProviderScope (mocked
// SharedPreferences) rather than a bare MaterialApp.router.
Future<GoRouter> _pumpHelpCenter(WidgetTester tester, {Size size = const Size(390, 844)}) async {
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
      GoRoute(path: AppRoutes.helpCenter, builder: (context, state) => const HelpCenterScreen()),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [appPreferencesProvider.overrideWithValue(AppPreferences(prefs))],
      child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
    ),
  );
  unawaited(router.push(AppRoutes.helpCenter));
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets('renders the title and all 5 questions collapsed, no overflow', (tester) async {
    await _pumpHelpCenter(tester);

    expect(find.text(AppStrings.settingsHelpCenter), findsOneWidget);
    expect(find.text(AppStrings.faqDuelQuestion), findsOneWidget);
    expect(find.text(AppStrings.faqXpQuestion), findsOneWidget);
    expect(find.text(AppStrings.faqStreakQuestion), findsOneWidget);
    expect(find.text(AppStrings.faqLobbyQuestion), findsOneWidget);
    expect(find.text(AppStrings.faqReportQuestion), findsOneWidget);
    // Collapsed by default: answers aren't built yet.
    expect(find.text(AppStrings.faqDuelAnswer), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits on the smallest supported phone width', (tester) async {
    await _pumpHelpCenter(tester, size: const Size(360, 780));

    expect(find.text(AppStrings.settingsHelpCenter), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping a question reveals its answer', (tester) async {
    await _pumpHelpCenter(tester);

    await tester.tap(find.text(AppStrings.faqXpQuestion));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.faqXpAnswer), findsOneWidget);
  });

  testWidgets('the back button returns to Settings when pushed on top of it', (tester) async {
    await _pumpHelpCenter(tester);

    await tester.tap(find.byIcon(TablerIcons.arrowLeft));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.byType(HelpCenterScreen), findsNothing);
  });
}
