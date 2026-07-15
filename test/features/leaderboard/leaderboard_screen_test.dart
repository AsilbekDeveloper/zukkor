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
import 'package:zukkor/features/home/presentation/screens/home_screen.dart';
import 'package:zukkor/features/leaderboard/presentation/models/leaderboard_entry.dart';
import 'package:zukkor/features/leaderboard/presentation/screens/full_leaderboard_screen.dart';
import 'package:zukkor/features/leaderboard/presentation/screens/leaderboard_screen.dart';
import 'package:zukkor/features/leaderboard/presentation/screens/player_detail_screen.dart';
import 'package:zukkor/features/leaderboard/presentation/screens/rank_filter_screen.dart';
import 'package:zukkor/i18n/strings.g.dart';

Future<GoRouter> _pumpLeaderboard(WidgetTester tester, {Size size = const Size(390, 844)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.leaderboard,
    routes: [
      GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: AppRoutes.leaderboard,
        builder: (context, state) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.fullLeaderboard,
        builder: (context, state) => const FullLeaderboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.playerDetail,
        builder: (context, state) => PlayerDetailScreen(entry: state.extra! as LeaderboardEntry),
      ),
      GoRoute(
        path: AppRoutes.rankFilter,
        builder: (context, state) => RankFilterScreen(currentFilter: state.extra as String?),
      ),
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
  testWidgets('renders header, segments, podium and rank list with no overflow', (tester) async {
    await _pumpLeaderboard(tester);

    // Also appears as the (disabled, active) bottom-nav tab label.
    expect(find.text(AppStrings.leaderboardGreeting), findsWidgets);
    expect(find.text(AppStrings.leaderboardTitle), findsOneWidget);
    expect(find.text(AppStrings.segmentWeekly), findsOneWidget);
    expect(find.text(AppStrings.segmentAllTime), findsOneWidget);
    // "Friends" also appears as the bottom-nav tab label.
    expect(find.text(AppStrings.segmentFriends), findsWidgets);

    // Podium (top 3).
    expect(find.text('Aziz K.'), findsOneWidget);
    expect(find.text('Malika'), findsOneWidget);
    expect(find.text('Shohruh'), findsOneWidget);

    // Rest of the ranked list, including the current user's own row.
    expect(find.text('Dilnoza Rustamova'), findsOneWidget);
    expect(find.text('Bekzod Xolmatov'), findsOneWidget);
    expect(find.text('Nilufar Yoqubova'), findsOneWidget);
    expect(find.text(AppStrings.currentUserName), findsOneWidget);

    expect(find.text(AppStrings.seeFullRanking), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits on the smallest supported phone width', (tester) async {
    await _pumpLeaderboard(tester, size: const Size(360, 780));

    expect(find.text(AppStrings.leaderboardTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('switching segments updates the selected pill', (tester) async {
    await _pumpLeaderboard(tester);

    await tester.tap(find.text(AppStrings.segmentAllTime));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // Sample data is shared across segments for now — the list still renders.
    expect(find.text('Aziz K.'), findsOneWidget);
  });

  testWidgets('tapping the filter button opens Rank Filter, and picking a category relabels the header', (tester) async {
    await _pumpLeaderboard(tester);

    await tester.tap(find.byIcon(TablerIcons.adjustmentsHorizontal));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.rankFilterScreenTitle), findsOneWidget);
    expect(find.text(AppStrings.allCategories), findsOneWidget);
    expect(find.text('Math'), findsOneWidget);

    await tester.tap(find.text('Math'));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.leaderboardGreetingFiltered('Math')), findsOneWidget);
  });

  testWidgets('tapping "See full ranking" opens the Full Leaderboard screen', (tester) async {
    await _pumpLeaderboard(tester);

    await tester.tap(find.text(AppStrings.seeFullRanking));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.fullLeaderboardTitle), findsOneWidget);
    expect(find.text('Javlon Mirzayev'), findsOneWidget);
  });

  testWidgets('tapping a podium entry opens their Player Detail', (tester) async {
    await _pumpLeaderboard(tester);

    await tester.tap(find.text('Aziz K.'));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.playerDetailTitle), findsOneWidget);
    expect(find.text(AppStrings.rankedLabel(1, 4820)), findsOneWidget);
    expect(find.text(AppStrings.addToFriendsButton), findsOneWidget);
  });

  testWidgets('tapping a rank list entry opens their Player Detail', (tester) async {
    await _pumpLeaderboard(tester);

    await tester.tap(find.text('Dilnoza Rustamova'));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.playerDetailTitle), findsOneWidget);
    expect(find.text(AppStrings.rankedLabel(4, 3980)), findsOneWidget);
  });

  testWidgets('tapping your own ("You") row does nothing', (tester) async {
    await _pumpLeaderboard(tester);

    await tester.tap(find.text(AppStrings.currentUserName));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // "Profile" also appears as the bottom-nav tab label, so check by
    // screen type instead of that shared text.
    expect(find.byType(PlayerDetailScreen), findsNothing);
    expect(find.text(AppStrings.leaderboardTitle), findsOneWidget);
  });

  testWidgets('the bottom nav Home tab navigates back to Home', (tester) async {
    await _pumpLeaderboard(tester);

    await tester.tap(find.byIcon(TablerIcons.home));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.duelHeroTitle), findsOneWidget);
    expect(find.text(AppStrings.leaderboardTitle), findsNothing);
  });
}
