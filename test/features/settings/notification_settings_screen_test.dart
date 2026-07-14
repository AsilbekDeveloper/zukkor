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
import 'package:zukkor/features/settings/presentation/screens/notification_settings_screen.dart';
import 'package:zukkor/features/settings/presentation/screens/settings_screen.dart';

// SettingsScreen is the initial route (mounted underneath) and reads
// themeControllerProvider — needs a real ProviderScope (mocked
// SharedPreferences) rather than a bare MaterialApp.router.
Future<GoRouter> _pumpNotificationSettings(WidgetTester tester, {Size size = const Size(390, 844)}) async {
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
        path: AppRoutes.notificationSettings,
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [appPreferencesProvider.overrideWithValue(AppPreferences(prefs))],
      child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
    ),
  );
  unawaited(router.push(AppRoutes.notificationSettings));
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets('renders the title and all 5 toggles, all on by default, no overflow', (tester) async {
    await _pumpNotificationSettings(tester);

    expect(find.text(AppStrings.notificationsPrefTitle), findsOneWidget);
    expect(find.text(AppStrings.notifPrefDuelInvites), findsOneWidget);
    expect(find.text(AppStrings.notifPrefStreakReminders), findsOneWidget);
    expect(find.text(AppStrings.notifPrefLeaderboardUpdates), findsOneWidget);
    expect(find.text(AppStrings.notifPrefFriendRequests), findsOneWidget);
    expect(find.text(AppStrings.notifPrefProductUpdates), findsOneWidget);

    final Iterable<Switch> switches = tester.widgetList<Switch>(find.byType(Switch));
    expect(switches.length, 5);
    expect(switches.every((s) => s.value), isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits on the smallest supported phone width', (tester) async {
    await _pumpNotificationSettings(tester, size: const Size(360, 780));

    expect(find.text(AppStrings.notificationsPrefTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping a row turns its switch off', (tester) async {
    await _pumpNotificationSettings(tester);

    // Rows render top-to-bottom in declaration order, so the 2nd switch
    // (index 1) belongs to "Streak reminders".
    await tester.tap(find.text(AppStrings.notifPrefStreakReminders));
    await tester.pump();

    final List<Switch> switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
    expect(switches[1].value, isFalse);
    expect(switches.where((s) => s.value).length, 4);
  });

  testWidgets('the back button returns to Settings when pushed on top of it', (tester) async {
    await _pumpNotificationSettings(tester);

    await tester.tap(find.byIcon(TablerIcons.arrowLeft));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.byType(NotificationSettingsScreen), findsNothing);
  });
}
