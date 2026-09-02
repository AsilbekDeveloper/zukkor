import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:zukkor/core/constants/app_strings.dart';
import 'package:zukkor/core/error/failures.dart';
import 'package:zukkor/core/router/app_routes.dart';
import 'package:zukkor/core/storage/app_preferences.dart';
import 'package:zukkor/core/theme/app_theme.dart';
import 'package:zukkor/features/settings/data/repositories/notification_preferences_repository_impl.dart';
import 'package:zukkor/features/settings/domain/entities/notification_preferences.dart';
import 'package:zukkor/features/settings/domain/repositories/notification_preferences_repository.dart';
import 'package:zukkor/features/settings/presentation/screens/notification_settings_screen.dart';
import 'package:zukkor/features/settings/presentation/screens/settings_screen.dart';
import 'package:zukkor/i18n/strings.g.dart';

const NotificationPreferences _allOn = NotificationPreferences(
  duelInvites: true,
  streakReminders: true,
  leaderboardUpdates: true,
  friendRequests: true,
  productUpdates: true,
);

/// Backendga murojaat qilmaydigan soxta repository — real
/// `GET|PATCH /users/me/notification-preferences` javobiga mos.
class _FakeNotificationPreferencesRepository implements NotificationPreferencesRepository {
  _FakeNotificationPreferencesRepository({this.updateFails = false});

  final bool updateFails;
  NotificationPreferences? lastUpdated;

  @override
  Future<NotificationPreferences> getPreferences() async => _allOn;

  @override
  Future<NotificationPreferences> updatePreferences(NotificationPreferences preferences) async {
    if (updateFails) throw ServerFailure('Saqlab bo\'lmadi');
    lastUpdated = preferences;
    return preferences;
  }
}

// SettingsScreen is the initial route (mounted underneath) and reads
// themeControllerProvider — needs a real ProviderScope (mocked
// SharedPreferences) rather than a bare MaterialApp.router.
Future<GoRouter> _pumpNotificationSettings(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  NotificationPreferencesRepository? repository,
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
        path: AppRoutes.notificationSettings,
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        notificationPreferencesRepositoryProvider
            .overrideWithValue(repository ?? _FakeNotificationPreferencesRepository()),
      ],
      child: TranslationProvider(
        child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
      ),
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

  testWidgets('tapping a row turns its switch off and saves the change', (tester) async {
    final _FakeNotificationPreferencesRepository repository = _FakeNotificationPreferencesRepository();
    await _pumpNotificationSettings(tester, repository: repository);

    // Rows render top-to-bottom in declaration order, so the 2nd switch
    // (index 1) belongs to "Streak reminders".
    await tester.tap(find.text(AppStrings.notifPrefStreakReminders));
    await tester.pumpAndSettle();

    final List<Switch> switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
    expect(switches[1].value, isFalse);
    expect(switches.where((s) => s.value).length, 4);
    expect(repository.lastUpdated?.streakReminders, isFalse);
  });

  testWidgets('a failed save reverts the switch and shows an error', (tester) async {
    final _FakeNotificationPreferencesRepository repository =
        _FakeNotificationPreferencesRepository(updateFails: true);
    await _pumpNotificationSettings(tester, repository: repository);

    await tester.tap(find.text(AppStrings.notifPrefStreakReminders));
    await tester.pumpAndSettle();

    final List<Switch> switches = tester.widgetList<Switch>(find.byType(Switch)).toList();
    expect(switches[1].value, isTrue);
    expect(find.text('Saqlab bo\'lmadi'), findsOneWidget);
    expect(repository.lastUpdated, isNull);
  });

  testWidgets('the back button returns to Settings when pushed on top of it', (tester) async {
    await _pumpNotificationSettings(tester);

    await tester.tap(find.byIcon(TablerIcons.arrowLeft));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(find.byType(NotificationSettingsScreen), findsNothing);
  });
}
