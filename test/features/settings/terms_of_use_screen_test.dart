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
import 'package:zukkor/features/settings/presentation/screens/settings_screen.dart';
import 'package:zukkor/features/settings/presentation/screens/terms_of_use_screen.dart';

// SettingsScreen is the initial route (mounted underneath) and reads
// themeControllerProvider — needs a real ProviderScope (mocked
// SharedPreferences) rather than a bare MaterialApp.router.
Future<GoRouter> _pumpTermsOfUse(WidgetTester tester, {Size size = const Size(390, 844)}) async {
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
      GoRoute(path: AppRoutes.termsOfUse, builder: (context, state) => const TermsOfUseScreen()),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [appPreferencesProvider.overrideWithValue(AppPreferences(prefs))],
      child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
    ),
  );
  unawaited(router.push(AppRoutes.termsOfUse));
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets('renders the title and all 4 sections, no overflow', (tester) async {
    await _pumpTermsOfUse(tester);

    expect(find.text(AppStrings.termsOfUseTitle), findsOneWidget);
    expect(find.text(AppStrings.termsSectionAccountTitle), findsOneWidget);
    expect(find.text(AppStrings.termsSectionConductTitle), findsOneWidget);
    expect(find.text(AppStrings.termsSectionContentTitle), findsOneWidget);
    expect(find.text(AppStrings.termsSectionChangesTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits on the smallest supported phone width', (tester) async {
    await _pumpTermsOfUse(tester, size: const Size(360, 780));

    expect(find.text(AppStrings.termsOfUseTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the back button returns to Settings when pushed on top of it', (tester) async {
    await _pumpTermsOfUse(tester);

    await tester.tap(find.byIcon(TablerIcons.arrowLeft));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.byType(TermsOfUseScreen), findsNothing);
  });
}
