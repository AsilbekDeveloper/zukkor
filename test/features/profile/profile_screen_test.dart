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
import 'package:zukkor/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:zukkor/features/auth/domain/entities/user.dart';
import 'package:zukkor/features/auth/domain/repositories/auth_repository.dart';
import 'package:zukkor/features/friends/data/repositories/friends_repository_impl.dart';
import 'package:zukkor/features/friends/domain/entities/discovered_user.dart';
import 'package:zukkor/features/friends/domain/entities/friend.dart';
import 'package:zukkor/features/friends/domain/entities/friend_request.dart';
import 'package:zukkor/features/friends/domain/repositories/friends_repository.dart';
import 'package:zukkor/features/friends/presentation/screens/friends_screen.dart';
import 'package:zukkor/features/history/data/repositories/history_repository_impl.dart';
import 'package:zukkor/features/history/domain/entities/session_history_entry.dart';
import 'package:zukkor/features/history/domain/repositories/history_repository.dart';
import 'package:zukkor/features/history/presentation/screens/history_screen.dart';
import 'package:zukkor/features/home/presentation/screens/home_screen.dart';
import 'package:zukkor/features/leaderboard/data/repositories/leaderboard_repository_impl.dart';
import 'package:zukkor/features/leaderboard/domain/entities/leaderboard_data.dart';
import 'package:zukkor/features/leaderboard/domain/entities/leaderboard_scope.dart';
import 'package:zukkor/features/leaderboard/domain/entities/player_stats.dart';
import 'package:zukkor/features/leaderboard/domain/entities/rank_entry.dart';
import 'package:zukkor/features/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'package:zukkor/features/leaderboard/presentation/screens/leaderboard_screen.dart';
import 'package:zukkor/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:zukkor/features/profile/presentation/screens/profile_screen.dart';
import 'package:zukkor/features/settings/presentation/screens/settings_screen.dart';
import 'package:zukkor/i18n/strings.g.dart';

/// Backendga murojaat qilmaydigan soxta auth repository — Profile ekrani
/// ochilganda `GET /auth/me`ni chaqiradi, haqiqiy tarmoqqa bog'liq
/// bo'lmasligi kerak.
class _FakeAuthRepository implements AuthRepository {
  @override
  Future<void> register({required String email, required String password}) async {}

  @override
  Future<void> login({required String email, required String password}) async {}

  @override
  Future<User?> signInWithGoogle() => throw UnimplementedError();

  @override
  Future<User> getCurrentUser() async => User(
        id: '1',
        email: 'aziz@example.com',
        username: 'aziz_karimov',
        firstName: 'Aziz',
        lastName: 'Karimov',
        isActive: true,
        createdAt: DateTime(2026),
        onboardingCompleted: true,
        authProvider: 'email',
      );

  @override
  Future<User> updateProfile({
    required String username,
    required String firstName,
    required String lastName,
    String? avatarColor,
    required String direction,
    List<String>? interests,
    String? studyPlace,
    String? quizLiking,
  }) async =>
      getCurrentUser();

  @override
  Future<bool> isUsernameAvailable(String username) async => true;

  @override
  Future<void> logout() async {}

  @override
  Future<void> registerPushToken(String token) async {}

  @override
  Future<User> uploadAvatarImage(String filePath) => throw UnimplementedError();

  @override
  Future<void> changePassword({required String currentPassword, required String newPassword}) =>
      throw UnimplementedError();

  @override
  Future<void> deleteAccount(String? password) => throw UnimplementedError();
}

/// Backendga murojaat qilmaydigan soxta leaderboard repository —
/// Leaderboard tab'i `GET /leaderboard`ni chaqiradi, haqiqiy tarmoqqa
/// bog'liq bo'lmasligi kerak.
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
  Future<PlayerStats> getPlayerStats(String userId) async => const PlayerStats(
        userId: '1',
        rank: 42,
        username: 'aziz_karimov',
        firstName: 'Aziz',
        lastName: 'Karimov',
        avatarColor: 'a-coral',
        avatarImagePath: null,
        totalXp: 2140,
        level: 12,
        levelTitle: 'Scholar',
        nextLevelXp: 3000,
        currentLevelXp: 2750,
        currentStreak: 8,
        longestStreak: 12,
        gamesPlayed: 184,
        winRatePercent: 68,
      );
}

/// Backendga murojaat qilmaydigan soxta history repository — History
/// ekrani `GET /history`ni chaqiradi, haqiqiy tarmoqqa bog'liq
/// bo'lmasligi kerak.
class _FakeHistoryRepository implements HistoryRepository {
  @override
  Future<({List<SessionHistoryEntry> entries, bool hasMore})> getHistory({int limit = 50, int offset = 0}) async =>
      (hasMore: false, entries: [
        SessionHistoryEntry(
          sessionId: '1',
          categoryId: 1,
          categoryName: 'Math',
          categoryIconName: 'math-symbols',
          categoryColorKey: 'coral',
          finishedAt: DateTime.now(),
          correctCount: 8,
          totalQuestions: 10,
          totalBall: 7200,
          totalXpEarned: 72,
          mode: HistorySessionMode.solo,
        ),
      ]);
}

/// Backendga murojaat qilmaydigan soxta friends repository — Friends tab'i
/// `GET /friends`ni chaqiradi, haqiqiy tarmoqqa bog'liq bo'lmasligi kerak.
class _FakeFriendsRepository implements FriendsRepository {
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
      ];

  @override
  Future<List<DiscoveredUser>> searchUsers(String query) => throw UnimplementedError();

  @override
  Future<void> sendFriendRequest(String userId) => throw UnimplementedError();

  @override
  Future<List<FriendRequest>> getIncomingRequests() async => const [];

  @override
  Future<void> acceptFriendRequest(String requestId) => throw UnimplementedError();

  @override
  Future<void> declineFriendRequest(String requestId) => throw UnimplementedError();
}

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
      overrides: [
        appPreferencesProvider.overrideWithValue(AppPreferences(prefs)),
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        leaderboardRepositoryProvider.overrideWithValue(_FakeLeaderboardRepository()),
        historyRepositoryProvider.overrideWithValue(_FakeHistoryRepository()),
        friendsRepositoryProvider.overrideWithValue(_FakeFriendsRepository()),
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
