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
import 'package:zukkor/features/friends/presentation/screens/friends_screen.dart';
import 'package:zukkor/features/history/presentation/screens/history_screen.dart';
import 'package:zukkor/features/home/presentation/screens/home_screen.dart';
import 'package:zukkor/features/leaderboard/presentation/screens/leaderboard_screen.dart';
import 'package:zukkor/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:zukkor/features/profile/presentation/screens/profile_screen.dart';
import 'package:zukkor/features/settings/presentation/screens/settings_screen.dart';
import 'package:zukkor/i18n/strings.g.dart';

// Profile pushes to SettingsScreen, which reads themeControllerProvider —
// needs a real ProviderScope (mocked SharedPreferences) rather than a
// bare MaterialApp.router. setMockInitialValues must run before any
// SharedPreferences.getInstance() call, or it hits a real platform
// channel with no test handler and hangs instead of failing.
Future<GoRouter> _pumpProfile(WidgetTester tester, {Size size = const Size(390, 844)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.profile,
    routes: [
      GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen()),
      GoRoute(path: AppRoutes.leaderboard, builder: (context, state) => const LeaderboardScreen()),
      GoRoute(path: AppRoutes.friends, builder: (context, state) => const FriendsScreen()),
      GoRoute(path: AppRoutes.profile, builder: (context, state) => const ProfileScreen()),
      GoRoute(path: AppRoutes.settings, builder: (context, state) => const SettingsScreen()),
      GoRoute(path: AppRoutes.history, builder: (context, state) => const HistoryScreen()),
      GoRoute(path: AppRoutes.editProfile, builder: (context, state) => const EditProfileScreen()),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [appPreferencesProvider.overrideWithValue(AppPreferences(prefs))],
      child: TranslationProvider(
        child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets('renders banner, name, level card, stats and settings with no overflow', (tester) async {
    await _pumpProfile(tester);

    // "Profile" also appears as the (disabled, active) bottom-nav tab label.
    expect(find.text(AppStrings.navProfile), findsWidgets);
    expect(find.text('Aziz Karimov'), findsOneWidget);
    expect(find.text('@aziz_karimov'), findsOneWidget);
    expect(find.text(AppStrings.levelWithTitle(12, 'Scholar')), findsOneWidget);
    expect(find.text(AppStrings.xpProgressLabel(2140, 3000, 860)), findsOneWidget);
    expect(find.text(AppStrings.statTotalGames), findsOneWidget);
    expect(find.text(AppStrings.statWinRate), findsOneWidget);
    expect(find.text(AppStrings.statLongestStreak), findsOneWidget);
    expect(find.text('184'), findsOneWidget);
    expect(find.text('68%'), findsOneWidget);
    // "12" appears both as the level-ring label and the longest-streak value.
    expect(find.text('12'), findsWidgets);
    expect(find.text(AppStrings.gameHistory), findsOneWidget);
    expect(find.text(AppStrings.settingsAndHelp), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets('fits on the smallest supported phone width', (tester) async {
    await _pumpProfile(tester, size: const Size(360, 780));

    expect(find.text('Aziz Karimov'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping the header settings button opens Settings', (tester) async {
    await _pumpProfile(tester);

    await tester.tap(find.byIcon(TablerIcons.settings).first);
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  testWidgets('tapping the edit-profile button opens Edit Profile', (tester) async {
    await _pumpProfile(tester);

    await tester.tap(find.byIcon(TablerIcons.pencil));
    await tester.pumpAndSettle();

    expect(find.byType(EditProfileScreen), findsOneWidget);
  });

  testWidgets('tapping "Game history" opens History', (tester) async {
    await _pumpProfile(tester);

    await tester.tap(find.text(AppStrings.gameHistory));
    await tester.pumpAndSettle();

    expect(find.byType(HistoryScreen), findsOneWidget);
  });

  testWidgets('tapping "Settings & help" opens Settings', (tester) async {
    await _pumpProfile(tester);

    await tester.tap(find.text(AppStrings.settingsAndHelp));
    await tester.pumpAndSettle();

    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  testWidgets('the bottom nav Home tab navigates back to Home', (tester) async {
    await _pumpProfile(tester);

    await tester.tap(find.byIcon(TablerIcons.home));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.duelHeroTitle), findsOneWidget);
  });

  testWidgets('the bottom nav Leaderboard tab navigates to Leaderboard', (tester) async {
    await _pumpProfile(tester);

    await tester.tap(find.byIcon(TablerIcons.trophy));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.leaderboardTitle), findsOneWidget);
  });

  testWidgets('the bottom nav Friends tab navigates to Friends', (tester) async {
    await _pumpProfile(tester);

    await tester.tap(find.byIcon(TablerIcons.users));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.searchFriendsPlaceholder), findsOneWidget);
  });
}
