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
import 'package:zukkor/features/leaderboard/presentation/screens/leaderboard_screen.dart';
import 'package:zukkor/features/leaderboard/presentation/widgets/leaderboard_segment_control.dart';
import 'package:zukkor/features/player_detail/presentation/models/player_detail_args.dart';
import 'package:zukkor/features/player_detail/presentation/screens/player_detail_screen.dart';
import 'package:zukkor/i18n/strings.g.dart';

/// Backendga murojaat qilmaydigan soxta leaderboard repository — real
/// `GET /leaderboard?scope=...` javobiga mos, har bir kesim uchun turli
/// ma'lumot (kesimlar haqiqatan alohida so'rov ekanini tekshirish uchun).
class _FakeLeaderboardRepository implements LeaderboardRepository {
  final List<LeaderboardScope> requestedScopes = [];

  @override
  Future<LeaderboardData> getLeaderboard({
    int limit = 50,
    LeaderboardScope scope = LeaderboardScope.allTime,
    int offset = 0,
  }) async {
    requestedScopes.add(scope);
    return switch (scope) {
      LeaderboardScope.weekly => _weekly,
      LeaderboardScope.allTime => _allTime,
      LeaderboardScope.friends => _friends,
    };
  }

  static const LeaderboardData _weekly = LeaderboardData(
    entries: [
      RankEntry(
        userId: '7',
        rank: 1,
        username: 'kamola',
        firstName: 'Kamola',
        lastName: 'Tursunova',
        avatarColor: 'a-green',
        avatarImagePath: null,
        totalXp: 640,
        level: 3,
        isMe: false,
      ),
    ],
    me: RankEntry(
      userId: 'me',
      rank: 9,
      username: 'aziz2',
      firstName: null,
      lastName: null,
      avatarColor: 'a-coral',
      avatarImagePath: null,
      totalXp: 210,
      level: 1,
      isMe: true,
    ),
  );

  static const LeaderboardData _friends = LeaderboardData(
    entries: [
      RankEntry(
        userId: '8',
        rank: 1,
        username: 'sardor',
        firstName: 'Sardor',
        lastName: 'Aliyev',
        avatarColor: 'a-blue',
        avatarImagePath: null,
        totalXp: 1500,
        level: 6,
        isMe: false,
      ),
    ],
    me: RankEntry(
      userId: 'me',
      rank: 2,
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

  static const LeaderboardData _allTime = LeaderboardData(
        entries: [
          RankEntry(
            userId: '1',
            rank: 1,
            username: 'aziz',
            firstName: 'Aziz',
            lastName: 'K.',
            avatarColor: 'a-coral',
            avatarImagePath: null,
            totalXp: 4820,
            level: 12,
            isMe: false,
          ),
          RankEntry(
            userId: '2',
            rank: 2,
            username: 'malika',
            firstName: 'Malika',
            lastName: null,
            avatarColor: 'a-teal',
            avatarImagePath: null,
            totalXp: 4510,
            level: 11,
            isMe: false,
          ),
          RankEntry(
            userId: '3',
            rank: 3,
            username: 'shohruh',
            firstName: 'Shohruh',
            lastName: null,
            avatarColor: 'a-terra',
            avatarImagePath: null,
            totalXp: 4290,
            level: 10,
            isMe: false,
          ),
          RankEntry(
            userId: '4',
            rank: 4,
            username: 'dilnoza',
            firstName: 'Dilnoza',
            lastName: 'Rustamova',
            avatarColor: 'a-teal',
            avatarImagePath: null,
            totalXp: 3980,
            level: 9,
            isMe: false,
          ),
          RankEntry(
            userId: '5',
            rank: 5,
            username: 'bekzod',
            firstName: 'Bekzod',
            lastName: 'Xolmatov',
            avatarColor: 'a-terra',
            avatarImagePath: null,
            totalXp: 3840,
            level: 9,
            isMe: false,
          ),
          RankEntry(
            userId: '6',
            rank: 6,
            username: 'nilufar',
            firstName: 'Nilufar',
            lastName: 'Yoqubova',
            avatarColor: 'a-pink',
            avatarImagePath: null,
            totalXp: 3710,
            level: 8,
            isMe: false,
          ),
        ],
        me: RankEntry(
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
  Future<PlayerStats> getPlayerStats(String userId) async {
    final RankEntry entry = _allTime.entries.firstWhere((e) => e.userId == userId);
    return PlayerStats(
      userId: userId,
      rank: entry.rank,
      username: entry.username,
      firstName: entry.firstName,
      lastName: entry.lastName,
      avatarColor: entry.avatarColor,
      avatarImagePath: entry.avatarImagePath,
      totalXp: entry.totalXp,
      level: entry.level,
      levelTitle: 'Scholar',
      nextLevelXp: entry.totalXp + 500,
      currentLevelXp: entry.totalXp + 250,
      currentStreak: 8,
      longestStreak: 15,
      gamesPlayed: 40,
      winRatePercent: 62,
    );
  }
}

Future<({GoRouter router, _FakeLeaderboardRepository repository})> _pumpLeaderboard(
  WidgetTester tester, {
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final _FakeLeaderboardRepository repository = _FakeLeaderboardRepository();

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

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appPreferencesProvider.overrideWithValue(AppPreferences(prefs)),
        leaderboardRepositoryProvider.overrideWithValue(repository),
      ],
      child: TranslationProvider(
        child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (router: router, repository: repository);
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

  testWidgets('switching to Weekly re-fetches and shows that scope\'s real data', (tester) async {
    final result = await _pumpLeaderboard(tester);

    await tester.tap(find.text(AppStrings.segmentWeekly));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(result.repository.requestedScopes, [LeaderboardScope.allTime, LeaderboardScope.weekly]);
    // Weekly's fake data is a single (non-podium) entry, not All-time's list.
    expect(find.text('Aziz K.'), findsNothing);
    expect(find.text('Kamola Tursunova'), findsOneWidget);
  });

  testWidgets('switching to Friends re-fetches and shows that scope\'s real data', (tester) async {
    final result = await _pumpLeaderboard(tester);

    await tester.tap(
      find.descendant(of: find.byType(LeaderboardSegmentControl), matching: find.text(AppStrings.segmentFriends)),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(result.repository.requestedScopes, [LeaderboardScope.allTime, LeaderboardScope.friends]);
    expect(find.text('Aziz K.'), findsNothing);
    expect(find.text('Sardor Aliyev'), findsOneWidget);
  });

  testWidgets('tapping "See full ranking" opens the Full Leaderboard screen', (tester) async {
    await _pumpLeaderboard(tester);

    await tester.tap(find.text(AppStrings.seeFullRanking));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.fullLeaderboardTitle), findsOneWidget);
    expect(find.text('Nilufar Yoqubova'), findsOneWidget);
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
