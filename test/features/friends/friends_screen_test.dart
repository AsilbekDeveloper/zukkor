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
import 'package:zukkor/features/friends/presentation/models/friend_entry.dart';
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
import 'package:zukkor/features/quiz/data/repositories/quiz_repository_impl.dart';
import 'package:zukkor/features/quiz/domain/entities/answer_result.dart';
import 'package:zukkor/features/quiz/domain/entities/category.dart';
import 'package:zukkor/features/quiz/domain/entities/quiz_start_result.dart';
import 'package:zukkor/features/quiz/domain/repositories/quiz_repository.dart';
import 'package:zukkor/features/quiz/presentation/screens/categories_screen.dart';
import 'package:zukkor/i18n/strings.g.dart';

/// Backendga murojaat qilmaydigan soxta quiz repository — Categories
/// ekrani (Duel'ning kategoriya tanlagichi) `GET /categories`ni chaqiradi,
/// haqiqiy tarmoqqa bog'liq bo'lmasligi kerak.
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

/// Backendga murojaat qilmaydigan soxta leaderboard repository —
/// Leaderboard tab'i `GET /leaderboard`ni chaqiradi, haqiqiy tarmoqqa
/// bog'liq bo'lmasligi kerak.
class _FakeLeaderboardRepository implements LeaderboardRepository {
  @override
  Future<LeaderboardData> getLeaderboard({int limit = 50, LeaderboardScope scope = LeaderboardScope.allTime}) async =>
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
  Future<PlayerStats> getPlayerStats(String userId) => throw UnimplementedError();
}

/// Backendga murojaat qilmaydigan soxta friends repository — real
/// `GET /friends` javobiga mos. [incomingRequests] Friends header'dagi
/// so'rovlar nishonini sinash uchun ishlatiladi.
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
  Future<List<DiscoveredUser>> searchUsers(String query) => throw UnimplementedError();

  @override
  Future<void> sendFriendRequest(String userId) => throw UnimplementedError();

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
        builder: (context, state) => CategoriesScreen(duelOpponent: state.extra as FriendEntry?),
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

    // "Friends" also appears as the (disabled, active) bottom-nav tab label.
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

  testWidgets('tapping the add-friend button navigates to the Add Friend screen', (tester) async {
    await _pumpFriends(tester);

    await tester.tap(find.byIcon(TablerIcons.userPlus));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.orViaInviteLink), findsOneWidget);
  });

  testWidgets('typing in the search bar filters by name or username', (tester) async {
    await _pumpFriends(tester);

    await tester.enterText(find.byType(TextField), 'mal');
    await tester.pump();

    expect(find.text('Malika Yusupova'), findsOneWidget);
    expect(find.text('Shohruh Toshpulatov'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a search with no matches shows the empty state', (tester) async {
    await _pumpFriends(tester);

    await tester.enterText(find.byType(TextField), 'zzz-no-such-friend');
    await tester.pump();

    expect(find.text(AppStrings.noFriendsFound), findsOneWidget);
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
