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
import 'package:zukkor/features/home/presentation/screens/home_screen.dart';
import 'package:zukkor/features/leaderboard/data/repositories/leaderboard_repository_impl.dart';
import 'package:zukkor/features/leaderboard/domain/entities/leaderboard_data.dart';
import 'package:zukkor/features/leaderboard/domain/entities/leaderboard_scope.dart';
import 'package:zukkor/features/leaderboard/domain/entities/player_stats.dart';
import 'package:zukkor/features/leaderboard/domain/entities/rank_entry.dart';
import 'package:zukkor/features/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'package:zukkor/features/leaderboard/presentation/screens/full_leaderboard_screen.dart';
import 'package:zukkor/features/player_detail/presentation/models/player_detail_args.dart';
import 'package:zukkor/features/player_detail/presentation/screens/player_detail_screen.dart';
import 'package:zukkor/i18n/strings.g.dart';

const List<({String name, int xp})> _topTen = [
  (name: 'Aziz K.', xp: 4820),
  (name: 'Malika Yusupova', xp: 4510),
  (name: 'Shohruh Toshpulatov', xp: 4290),
  (name: 'Dilnoza Rustamova', xp: 3980),
  (name: 'Bekzod Xolmatov', xp: 3840),
  (name: 'Nilufar Yoqubova', xp: 3710),
  (name: 'Javlon Mirzayev', xp: 3540),
  (name: 'Kamola Tursunova', xp: 3410),
  (name: 'Otabek Rahimov', xp: 3260),
  (name: 'Sevinch Aliyeva', xp: 3105),
];

/// Backendga murojaat qilmaydigan soxta leaderboard repository — top 10 +
/// o'zining (uzoqroq) rangi, real `GET /leaderboard` javobiga mos.
class _FakeLeaderboardRepository implements LeaderboardRepository {
  @override
  Future<LeaderboardData> getLeaderboard({
    int limit = 50,
    LeaderboardScope scope = LeaderboardScope.allTime,
    int offset = 0,
  }) async =>
      LeaderboardData(
        entries: [
          for (int i = 0; i < _topTen.length; i++)
            RankEntry(
              userId: '${i + 1}',
              rank: i + 1,
              username: 'user${i + 1}',
              firstName: _topTen[i].name,
              lastName: null,
              avatarColor: 'a-coral',
              avatarImagePath: null,
              totalXp: _topTen[i].xp,
              level: 10,
              isMe: false,
            ),
        ],
        me: const RankEntry(
          userId: 'me',
          rank: 312,
          username: 'aziz2',
          firstName: null,
          lastName: null,
          avatarColor: 'a-coral',
          avatarImagePath: null,
          totalXp: 2140,
          level: 5,
          isMe: true,
        ),
      );

  @override
  Future<PlayerStats> getPlayerStats(String userId) async => PlayerStats(
        userId: userId,
        rank: 8,
        username: 'user8',
        firstName: 'Kamola Tursunova',
        lastName: null,
        avatarColor: 'a-coral',
        avatarImagePath: null,
        totalXp: 3410,
        level: 10,
        levelTitle: 'Scholar',
        nextLevelXp: 4000,
        currentLevelXp: 3750,
        currentStreak: 4,
        longestStreak: 11,
        gamesPlayed: 27,
        winRatePercent: 68,
      );
}

Future<GoRouter> _pumpFullLeaderboard(WidgetTester tester, {Size size = const Size(390, 844)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: AppRoutes.fullLeaderboard,
        builder: (context, state) => const FullLeaderboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.playerDetail,
        builder: (context, state) {
          final Map<dynamic, dynamic> extra = state.extra! as Map;
          return PlayerDetailScreen(
            args: PlayerDetailArgs(
              userId: extra['userId'] as String,
              relation: PlayerDetailRelation.values.firstWhere(
                (r) => r.name == extra['relation'],
                orElse: () => PlayerDetailRelation.unknown,
              ),
              incomingRequestId: extra['requestId'] as String?,
              initialRequestSent: extra['requestSent'] == true,
            ),
          );
        },
      ),
    ],
  );

  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appPreferencesProvider.overrideWithValue(AppPreferences(prefs)),
        leaderboardRepositoryProvider.overrideWithValue(_FakeLeaderboardRepository()),
      ],
      child: TranslationProvider(
        child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
      ),
    ),
  );
  unawaited(router.push(AppRoutes.fullLeaderboard));
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets('renders the title and all 11 ranked rows, no overflow', (tester) async {
    await _pumpFullLeaderboard(tester);

    expect(find.text(AppStrings.fullLeaderboardTitle), findsOneWidget);
    for (final ({String name, int xp}) entry in _topTen) {
      expect(find.text(entry.name), findsOneWidget, reason: '${entry.name} should be listed');
    }
    expect(find.text(AppStrings.currentUserName), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits on the smallest supported phone width', (tester) async {
    await _pumpFullLeaderboard(tester, size: const Size(360, 780));

    expect(find.text(AppStrings.fullLeaderboardTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping someone opens their Player Detail', (tester) async {
    await _pumpFullLeaderboard(tester);

    await tester.tap(find.text('Kamola Tursunova'));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.playerDetailTitle), findsOneWidget);
    expect(find.text(AppStrings.rankedLabel(8, 3410)), findsOneWidget);
  });

  testWidgets('tapping your own ("You") row does nothing', (tester) async {
    await _pumpFullLeaderboard(tester);

    await tester.tap(find.text(AppStrings.currentUserName));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byType(PlayerDetailScreen), findsNothing);
  });

  testWidgets('the back button returns to Home when pushed on top of it', (tester) async {
    final GoRouter router = await _pumpFullLeaderboard(tester);
    router.go(AppRoutes.home);
    unawaited(router.push(AppRoutes.fullLeaderboard));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.fullLeaderboardTitle), findsOneWidget);

    await tester.tap(find.byIcon(TablerIcons.arrowLeft));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.duelHeroTitle), findsOneWidget);
    expect(find.text(AppStrings.fullLeaderboardTitle), findsNothing);
  });
}
