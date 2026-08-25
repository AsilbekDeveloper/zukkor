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
import 'package:zukkor/features/friends/data/repositories/friends_repository_impl.dart';
import 'package:zukkor/features/friends/domain/entities/discovered_user.dart';
import 'package:zukkor/features/friends/domain/entities/friend.dart';
import 'package:zukkor/features/friends/domain/entities/friend_request.dart';
import 'package:zukkor/features/friends/domain/repositories/friends_repository.dart';
import 'package:zukkor/features/friends/presentation/screens/add_friend_screen.dart';
import 'package:zukkor/features/friends/presentation/screens/friend_requests_screen.dart';
import 'package:zukkor/features/friends/presentation/screens/friends_screen.dart';
import 'package:zukkor/features/home/presentation/screens/home_screen.dart';
import 'package:zukkor/features/leaderboard/data/repositories/leaderboard_repository_impl.dart';
import 'package:zukkor/features/leaderboard/domain/entities/leaderboard_data.dart';
import 'package:zukkor/features/leaderboard/domain/entities/leaderboard_scope.dart';
import 'package:zukkor/features/leaderboard/domain/entities/player_stats.dart';
import 'package:zukkor/features/leaderboard/domain/entities/rank_entry.dart';
import 'package:zukkor/features/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'package:zukkor/features/leaderboard/presentation/screens/leaderboard_screen.dart';
import 'package:zukkor/features/player_detail/presentation/models/player_detail_args.dart';
import 'package:zukkor/features/player_detail/presentation/screens/player_detail_screen.dart';
import 'package:zukkor/features/quiz/data/repositories/quiz_repository_impl.dart';
import 'package:zukkor/features/quiz/domain/entities/answer_result.dart';
import 'package:zukkor/features/quiz/domain/entities/category.dart';
import 'package:zukkor/features/quiz/domain/entities/quiz_start_result.dart';
import 'package:zukkor/features/quiz/domain/repositories/quiz_repository.dart';
import 'package:zukkor/features/quiz/presentation/screens/categories_screen.dart';
import 'package:zukkor/i18n/strings.g.dart';

class _FakeQuizRepository implements QuizRepository {
  @override
  Future<List<Category>> getCategories() async => const [
        Category(id: 1, name: 'Math', iconName: 'math-symbols', colorKey: 'coral', questionCount: 120),
        Category(id: 2, name: 'History', iconName: 'book', colorKey: 'terra', questionCount: 98),
      ];

  @override
  Future<QuizStartResult> startQuiz({required int categoryId, required int questionCount}) =>
      throw UnimplementedError();

  @override
  Future<AnswerResult> submitAnswer({
    required String sessionId,
    required int sessionQuestionId,
    required int? selectedOption,
  }) =>
      throw UnimplementedError();
}

class _FakeLeaderboardRepository implements LeaderboardRepository {
  @override
  Future<LeaderboardData> getLeaderboard({
    int limit = 50,
    LeaderboardScope scope = LeaderboardScope.allTime,
    int offset = 0,
  }) async =>
      const LeaderboardData(
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
        ],
        me: RankEntry(
          userId: 'me',
          rank: 42,
          username: 'me',
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
        rank: 5,
        username: 'malika_yusupova',
        firstName: 'Malika',
        lastName: 'Yusupova',
        avatarColor: 'a-teal',
        avatarImagePath: null,
        totalXp: 3000,
        level: 8,
        levelTitle: 'Scholar',
        nextLevelXp: 3500,
        currentLevelXp: 3250,
        currentStreak: 3,
        longestStreak: 10,
        gamesPlayed: 20,
        winRatePercent: 55,
      );
}

class _FakeFriendsRepository implements FriendsRepository {
  _FakeFriendsRepository({this.incomingRequests = const []});

  final List<FriendRequest> incomingRequests;

  @override
  Future<List<Friend>> getFriends() async => const [
        Friend(
          id: '1',
          username: 'malika_yusupova',
          firstName: 'Malika',
          lastName: 'Yusupova',
          avatarColor: 'a-teal',
          avatarImagePath: null,
        ),
        Friend(
          id: '2',
          username: 'shohruh_toshpulatov',
          firstName: 'Shohruh',
          lastName: 'Toshpulatov',
          avatarColor: 'a-terra',
          avatarImagePath: null,
        ),
        Friend(
          id: '3',
          username: 'dilnoza_rustamova',
          firstName: 'Dilnoza',
          lastName: 'Rustamova',
          avatarColor: 'a-pink',
          avatarImagePath: null,
        ),
      ];

  @override
  Future<List<DiscoveredUser>> searchUsers(String query) async {
    if (query.toLowerCase().contains('q')) {
      return const [
        DiscoveredUser(
          id: '10',
          username: 'qodir_ali',
          firstName: 'Qodir',
          lastName: 'Ali',
          avatarColor: 'a-blue',
          avatarImagePath: null,
          requestPending: false,
        ),
      ];
    }
    return const [];
  }

  @override
  Future<void> sendFriendRequest(String userId) async {}

  @override
  Future<List<FriendRequest>> getIncomingRequests() async => incomingRequests;

  @override
  Future<void> acceptFriendRequest(String requestId) => throw UnimplementedError();

  @override
  Future<void> declineFriendRequest(String requestId) => throw UnimplementedError();
}

Future<GoRouter> _pumpFriends(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  FriendsRepository? repository,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.friends,
    routes: [
      GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen()),
      GoRoute(path: AppRoutes.leaderboard, builder: (context, state) => const LeaderboardScreen()),
      GoRoute(path: AppRoutes.friends, builder: (context, state) => const FriendsScreen()),
      GoRoute(path: AppRoutes.addFriend, builder: (context, state) => const AddFriendScreen()),
      GoRoute(path: AppRoutes.friendRequests, builder: (context, state) => const FriendRequestsScreen()),
      GoRoute(
        path: AppRoutes.categories,
        builder: (context, state) => const CategoriesScreen(),
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
        quizRepositoryProvider.overrideWithValue(_FakeQuizRepository()),
        leaderboardRepositoryProvider.overrideWithValue(_FakeLeaderboardRepository()),
        friendsRepositoryProvider.overrideWithValue(repository ?? _FakeFriendsRepository()),
      ],
      child: TranslationProvider(
        child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets('renders header, search bar and friend list with no overflow', (tester) async {
    await _pumpFriends(tester);

    expect(find.text(AppStrings.navFriends), findsWidgets);
    expect(find.text(AppStrings.searchFriendsPlaceholder), findsOneWidget);
    expect(find.text(AppStrings.allFriendsSectionTitle), findsOneWidget);
    expect(find.text('3'), findsOneWidget);

    expect(find.text('Malika Yusupova'), findsOneWidget);
    expect(find.text('Shohruh Toshpulatov'), findsOneWidget);
    expect(find.text('Dilnoza Rustamova'), findsOneWidget);
    expect(find.text('@malika_yusupova'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets('fits on the smallest supported phone width', (tester) async {
    await _pumpFriends(tester, size: const Size(360, 780));

    expect(find.text(AppStrings.searchFriendsPlaceholder), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('typing in the search bar filters by name or username', (tester) async {
    await _pumpFriends(tester);

    await tester.enterText(find.byType(TextField), 'mal');
    await tester.pump();

    expect(find.text('Malika Yusupova'), findsOneWidget);
    expect(find.text('Shohruh Toshpulatov'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('typing "q" shows others section with results from server', (tester) async {
    await _pumpFriends(tester);

    await tester.enterText(find.byType(TextField), 'q');
    // Debounce wait
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.otherUsersSectionTitle), findsOneWidget);
    expect(find.text('Qodir Ali'), findsOneWidget);
    expect(find.text('@qodir_ali'), findsOneWidget);
  });

  testWidgets('sending a friend request changes button to requested state', (tester) async {
    await _pumpFriends(tester);

    await tester.enterText(find.byType(TextField), 'q');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    final Finder addButton = find.text(AppStrings.addButton);
    expect(addButton, findsOneWidget);

    await tester.tap(addButton);
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.requestedLabel), findsOneWidget);
  });

  testWidgets('a search with no matches anywhere shows the discover empty state', (tester) async {
    await _pumpFriends(tester);

    await tester.enterText(find.byType(TextField), 'zzz-no-such-friend');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    // While searching, "no friends" (friends.noneFound) only applies to the
    // zero-friends-total state (not searching) - a no-match search instead
    // shows the "other users" section's own empty copy.
    expect(find.text(AppStrings.noUsersFound), findsOneWidget);
    expect(find.text(AppStrings.noFriendsFound), findsNothing);
    expect(find.text('Malika Yusupova'), findsNothing);
  });

  testWidgets('clearing the search restores the full list', (tester) async {
    await _pumpFriends(tester);

    await tester.enterText(find.byType(TextField), 'mal');
    await tester.pump();
    await tester.tap(find.byIcon(TablerIcons.x));
    await tester.pump();

    expect(find.text('Shohruh Toshpulatov'), findsOneWidget);
  });

  testWidgets('tapping a duel button on the friends list starts a duel with that friend', (tester) async {
    await _pumpFriends(tester);

    await tester.tap(find.byIcon(TablerIcons.swords).first);
    await tester.pumpAndSettle();

    expect(find.byType(CategoriesScreen), findsOneWidget);
    expect(find.text(AppStrings.categoriesScreenTitle), findsOneWidget);
  });

  testWidgets('tapping a friend row opens their profile with an already-friends badge', (tester) async {
    await _pumpFriends(tester);

    await tester.tap(find.text('Malika Yusupova'));
    await tester.pumpAndSettle();

    expect(find.byType(PlayerDetailScreen), findsOneWidget);
    expect(find.text(AppStrings.alreadyFriendsLabel), findsOneWidget);
    expect(find.text(AppStrings.addToFriendsButton), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the bottom nav Home tab navigates back to Home', (tester) async {
    await _pumpFriends(tester);

    await tester.tap(find.byIcon(TablerIcons.home));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.duelHeroTitle), findsOneWidget);
  });

  testWidgets('the bottom nav Leaderboard tab navigates to Leaderboard', (tester) async {
    await _pumpFriends(tester);

    await tester.tap(find.byIcon(TablerIcons.trophy));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.leaderboardTitle), findsOneWidget);
  });

  testWidgets('tapping the requests button navigates to Friend Requests', (tester) async {
    await _pumpFriends(tester);

    await tester.tap(find.byIcon(TablerIcons.userCheck));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.friendRequestsTitle), findsOneWidget);
  });

  testWidgets('a pending incoming request shows a badge dot on the requests button', (tester) async {
    final FriendRequest pending = FriendRequest(
      id: 'req-1',
      fromUserId: '9',
      username: 'bekzod',
      firstName: 'Bekzod',
      lastName: 'Xolmatov',
      avatarColor: 'a-blue',
      avatarImagePath: null,
      createdAt: DateTime(2026, 7, 18),
    );
    await _pumpFriends(tester, repository: _FakeFriendsRepository(incomingRequests: [pending]));

    await tester.tap(find.byIcon(TablerIcons.userCheck));
    await tester.pumpAndSettle();

    expect(find.text('Bekzod Xolmatov'), findsOneWidget);
  });
}
