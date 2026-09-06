import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:zukkor/core/constants/app_strings.dart';
import 'package:zukkor/core/router/app_routes.dart';
import 'package:zukkor/core/state/load_state.dart';
import 'package:zukkor/core/storage/app_preferences.dart';
import 'package:zukkor/core/theme/app_theme.dart';
import 'package:zukkor/features/auth/domain/entities/user.dart';
import 'package:zukkor/features/auth/presentation/controllers/current_user_controller.dart';
import 'package:zukkor/features/duel/data/repositories/duel_repository_impl.dart';
import 'package:zukkor/features/duel/domain/entities/duel_final_result.dart';
import 'package:zukkor/features/duel/domain/entities/duel_invite.dart';
import 'package:zukkor/features/duel/domain/entities/duel_invite_outcome.dart';
import 'package:zukkor/features/duel/domain/entities/duel_opponent_progress_event.dart';
import 'package:zukkor/features/duel/domain/entities/duel_question_event.dart';
import 'package:zukkor/features/duel/domain/entities/duel_question_result.dart';
import 'package:zukkor/features/duel/domain/entities/duel_started_info.dart';
import 'package:zukkor/features/duel/domain/repositories/duel_repository.dart';
import 'package:zukkor/features/history/data/repositories/history_repository_impl.dart';
import 'package:zukkor/features/history/domain/entities/session_history_entry.dart';
import 'package:zukkor/features/history/domain/entities/weekly_activity.dart';
import 'package:zukkor/features/history/domain/repositories/history_repository.dart';
import 'package:zukkor/features/home/presentation/screens/home_screen.dart';
import 'package:zukkor/features/leaderboard/data/repositories/leaderboard_repository_impl.dart';
import 'package:zukkor/features/leaderboard/domain/entities/leaderboard_data.dart';
import 'package:zukkor/features/leaderboard/domain/entities/leaderboard_scope.dart';
import 'package:zukkor/features/leaderboard/domain/entities/player_stats.dart';
import 'package:zukkor/features/leaderboard/domain/entities/rank_entry.dart';
import 'package:zukkor/features/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'package:zukkor/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:zukkor/features/notifications/domain/entities/notification_record.dart';
import 'package:zukkor/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:zukkor/features/quiz/data/repositories/quiz_repository_impl.dart';
import 'package:zukkor/features/quiz/domain/entities/category.dart';
import 'package:zukkor/features/quiz/domain/repositories/quiz_repository.dart';
import 'package:zukkor/i18n/strings.g.dart';

class _FakeDuelRepository extends Fake implements DuelRepository {
  final StreamController<bool> _conn = StreamController<bool>.broadcast();
  final StreamController<DuelInvite> _invites = StreamController<DuelInvite>.broadcast();

  @override
  Stream<bool> get connectionStatus => _conn.stream;
  @override
  Stream<DuelInvite> get incomingInvites => _invites.stream;
  @override
  Stream<DuelInviteOutcome> get outgoingInviteOutcomes => const Stream.empty();
  @override
  Stream<DuelStartedInfo> get duelStarted => const Stream.empty();
  @override
  Stream<DuelQuestionEvent> get duelQuestion => const Stream.empty();
  @override
  Stream<DuelOpponentProgressEvent> get opponentProgress => const Stream.empty();
  @override
  Stream<DuelQuestionResult> get duelQuestionResult => const Stream.empty();
  @override
  Stream<String> get waitingForOpponent => const Stream.empty();
  @override
  Stream<DuelFinalResult> get duelFinished => const Stream.empty();
  @override
  Stream<String> get duelCancelled => const Stream.empty();

  @override
  Future<void> connect() async => _conn.add(true);
}

class _FakeNotificationsRepository extends Fake implements NotificationsRepository {
  @override
  Future<List<NotificationRecord>> getNotifications() async => [];
  @override
  Future<void> markAllRead() async {}
}

class _FakeQuizRepository extends Fake implements QuizRepository {
  @override
  Future<List<Category>> getCategories() async => [
        const Category(id: 1, name: 'Math', iconName: 'math', colorKey: 'coral', questionCount: 10),
        const Category(id: 2, name: 'Movies', iconName: 'movie', colorKey: 'pink', questionCount: 15),
        const Category(id: 3, name: 'History', iconName: 'book', colorKey: 'terra', questionCount: 12),
      ];
}

class _FakeHistoryRepository extends Fake implements HistoryRepository {
  @override
  Future<({List<SessionHistoryEntry> entries, bool hasMore})> getHistory({int limit = 50, int offset = 0}) async =>
      (entries: <SessionHistoryEntry>[], hasMore: false);

  @override
  Future<WeeklyActivity> getWeeklyActivity() async => const WeeklyActivity(days: [false, false, false, false, false, false, false]);
}

class _FakeLeaderboardRepository implements LeaderboardRepository {
  @override
  Future<LeaderboardData> getLeaderboard({
    int limit = 50,
    LeaderboardScope scope = LeaderboardScope.allTime,
    int offset = 0,
  }) async =>
      const LeaderboardData(
        entries: [],
        me: RankEntry(
          userId: '1',
          rank: 312,
          username: 'aziz_karimov',
          firstName: 'Aziz',
          lastName: 'Karimov',
          avatarColor: 'a-coral',
          avatarImagePath: null,
          totalXp: 2140,
          isMe: true,
        ),
      );

  @override
  Future<PlayerStats> getPlayerStats(String userId) async => const PlayerStats(
        userId: '1',
        rank: 312,
        username: 'aziz_karimov',
        firstName: 'Aziz',
        lastName: 'Karimov',
        avatarColor: 'a-coral',
        avatarImagePath: null,
        totalXp: 2140,
        currentStreak: 5,
        longestStreak: 15,
        gamesPlayed: 40,
        winRatePercent: 68,
        totalWins: 27,
        bestRankAchieved: 1,
      );
}

class _MockCurrentUserController extends CurrentUserController {
  @override
  LoadState<User> build() => LoadState(
        data: User(
          id: '1',
          email: 'aziz@example.com',
          username: 'aziz_karimov',
          firstName: 'Aziz',
          lastName: 'Karimov',
          isActive: true,
          createdAt: DateTime(2026),
          onboardingCompleted: true,
          authProvider: 'email',
        ),
      );

  // Home's _reloadEssentialData() calls this unconditionally (no fake
  // authRepositoryProvider is wired here) - without this override, the
  // real load() hits an unmocked network call, fails, and overwrites the
  // mock's data above with a null/error state, so later stats/streak
  // reads see no user id and never load at all.
  @override
  Future<void> load() async {}
}

Future<void> _pumpHome(WidgetTester tester, {Size size = const Size(390, 844)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues({});
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen()),
      GoRoute(path: AppRoutes.notifications, builder: (context, state) => const Scaffold(body: Text('NOTIFICATIONS'))),
      GoRoute(path: AppRoutes.duel, builder: (context, state) => const Scaffold(body: Text('DUEL_PICK'))),
      GoRoute(path: AppRoutes.lobby, builder: (context, state) => const Scaffold(body: Text('LOBBY'))),
      GoRoute(path: AppRoutes.joinCode, builder: (context, state) => const Scaffold(body: Text('JOIN_CODE'))),
      GoRoute(path: AppRoutes.categories, builder: (context, state) => const Scaffold(body: Text('CATEGORIES'))),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        duelRepositoryProvider.overrideWithValue(_FakeDuelRepository()),
        notificationsRepositoryProvider.overrideWithValue(_FakeNotificationsRepository()),
        quizRepositoryProvider.overrideWithValue(_FakeQuizRepository()),
        historyRepositoryProvider.overrideWithValue(_FakeHistoryRepository()),
        leaderboardRepositoryProvider.overrideWithValue(_FakeLeaderboardRepository()),
        currentUserControllerProvider.overrideWith(() => _MockCurrentUserController()),
      ],
      child: TranslationProvider(
        child: MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: router,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('renders every section with no layout overflow', (tester) async {
    await _pumpHome(tester);

    expect(find.text(AppStrings.duelHeroTitle), findsOneWidget);
    expect(find.text(AppStrings.startDuel), findsOneWidget);
    expect(find.text(AppStrings.totalXpLabel), findsOneWidget);
    expect(find.text(AppStrings.rankLabel), findsOneWidget);
    expect(find.text(AppStrings.createRoom), findsOneWidget);
    expect(find.text(AppStrings.joinWithCode), findsOneWidget);
    expect(find.text(AppStrings.categoriesTitle), findsOneWidget);

    // One tile per sample category (all 3 should be visible now).
    expect(find.text('Math'), findsOneWidget);
    expect(find.text('Movies'), findsOneWidget);
    expect(find.text('History'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets('shows real XP/rank/streak from GET /leaderboard/{my_user_id}', (tester) async {
    await _pumpHome(tester);

    // Stats are rendered.
    expect(find.text(AppStrings.totalXpLabel), findsOneWidget);
    expect(find.text(AppStrings.rankLabel), findsOneWidget);

    // Streak chip value.
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('tapping the notification bell opens Notifications', (tester) async {
    await _pumpHome(tester);

    await tester.tap(find.byIcon(TablerIcons.bell));
    await tester.pumpAndSettle();

    expect(find.text('NOTIFICATIONS'), findsOneWidget);
  });

  testWidgets('"Create a room" navigates to the Lobby screen', (tester) async {
    await _pumpHome(tester);

    await tester.tap(find.text(AppStrings.createRoom));
    await tester.pumpAndSettle();

    expect(find.text('LOBBY'), findsOneWidget);
  });

  testWidgets('"Join with a code" navigates to the Join Code screen', (tester) async {
    await _pumpHome(tester);

    await tester.tap(find.text(AppStrings.joinWithCode));
    await tester.pumpAndSettle();

    expect(find.text('JOIN_CODE'), findsOneWidget);
  });

  testWidgets('"See all" navigates to the Categories screen', (tester) async {
    await _pumpHome(tester);

    await tester.tap(find.text(AppStrings.seeAll));
    await tester.pumpAndSettle();

    expect(find.text('CATEGORIES'), findsOneWidget);
  });
}
