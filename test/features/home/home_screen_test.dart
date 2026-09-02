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
import 'package:zukkor/core/storage/token_storage.dart';
import 'package:zukkor/core/theme/app_theme.dart';
import 'package:zukkor/core/utils/formatters.dart';
import 'package:zukkor/features/ai_quiz/data/repositories/ai_quiz_repository_impl.dart';
import 'package:zukkor/features/ai_quiz/domain/entities/ai_quiz.dart';
import 'package:zukkor/features/ai_quiz/domain/entities/discover_quiz.dart';
import 'package:zukkor/features/ai_quiz/domain/entities/manual_question_input.dart';
import 'package:zukkor/features/ai_quiz/domain/repositories/ai_quiz_repository.dart';
import 'package:zukkor/features/ai_quiz/presentation/screens/create_manual_quiz_screen.dart';
import 'package:zukkor/features/ai_quiz/presentation/screens/my_ai_quizzes_screen.dart';
import 'package:zukkor/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:zukkor/features/auth/domain/entities/user.dart';
import 'package:zukkor/features/auth/domain/repositories/auth_repository.dart';
import 'package:zukkor/features/friends/data/repositories/friends_repository_impl.dart';
import 'package:zukkor/features/friends/domain/entities/discovered_user.dart';
import 'package:zukkor/features/friends/domain/entities/friend.dart';
import 'package:zukkor/features/friends/domain/entities/friend_request.dart';
import 'package:zukkor/features/friends/domain/repositories/friends_repository.dart';
import 'package:zukkor/features/friends/presentation/screens/duel_screen.dart';
import 'package:zukkor/features/home/presentation/screens/home_screen.dart';
import 'package:zukkor/features/leaderboard/data/repositories/leaderboard_repository_impl.dart';
import 'package:zukkor/features/leaderboard/domain/entities/leaderboard_data.dart';
import 'package:zukkor/features/leaderboard/domain/entities/leaderboard_scope.dart';
import 'package:zukkor/features/leaderboard/domain/entities/player_stats.dart';
import 'package:zukkor/features/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'package:zukkor/features/lobby/data/repositories/lobby_repository_impl.dart';
import 'package:zukkor/features/lobby/domain/entities/lobby_final_result.dart';
import 'package:zukkor/features/lobby/domain/entities/lobby_game_started_info.dart';
import 'package:zukkor/features/lobby/domain/entities/lobby_join_error.dart';
import 'package:zukkor/features/lobby/domain/entities/lobby_participant.dart';
import 'package:zukkor/features/lobby/domain/entities/lobby_question_event.dart';
import 'package:zukkor/features/lobby/domain/entities/lobby_question_result.dart';
import 'package:zukkor/features/lobby/domain/entities/lobby_room_state.dart';
import 'package:zukkor/features/lobby/domain/repositories/lobby_repository.dart';
import 'package:zukkor/features/lobby/presentation/screens/join_code_screen.dart';
import 'package:zukkor/features/lobby/presentation/screens/lobby_screen.dart';
import 'package:zukkor/features/notifications/data/repositories/notifications_repository_impl.dart';
import 'package:zukkor/features/notifications/domain/entities/notification_record.dart';
import 'package:zukkor/features/notifications/domain/repositories/notifications_repository.dart';
import 'package:zukkor/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:zukkor/features/quiz/data/repositories/quiz_repository_impl.dart';
import 'package:zukkor/features/quiz/domain/entities/answer_result.dart';
import 'package:zukkor/features/quiz/domain/entities/category.dart';
import 'package:zukkor/features/quiz/domain/entities/quiz_start_result.dart';
import 'package:zukkor/features/quiz/domain/repositories/quiz_repository.dart';
import 'package:zukkor/features/quiz/presentation/screens/categories_screen.dart';
import 'package:zukkor/i18n/strings.g.dart';

/// Backendga murojaat qilmaydigan soxta quiz repository — Home o'zining
/// kategoriyalar to'rini `GET /categories`dan yuklaydi, haqiqiy tarmoqqa
/// bog'liq bo'lmasligi kerak.
class _FakeQuizRepository implements QuizRepository {
  @override
  Future<List<Category>> getCategories() async => const [
        Category(id: 1, name: 'Math', iconName: 'math-symbols', colorKey: 'coral', questionCount: 120),
        Category(id: 2, name: 'History', iconName: 'book', colorKey: 'terra', questionCount: 98),
        Category(id: 3, name: 'English', iconName: 'language', colorKey: 'teal', questionCount: 150),
        Category(id: 4, name: 'Movies', iconName: 'movie', colorKey: 'pink', questionCount: 76),
        Category(
          id: 5,
          name: 'Football',
          iconName: 'ball-football',
          colorKey: 'green',
          questionCount: 64,
        ),
        Category(id: 6, name: 'Memes', iconName: 'mood-smile', colorKey: 'blue', questionCount: 50),
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

  @override
  Future<void> reportQuestion({required int questionId, required String reason, String? comment}) =>
      throw UnimplementedError();
}

/// Backendga murojaat qilmaydigan soxta AI quiz repository — markazdagi
/// tugma bosilganda ochiladigan "Mening AI quizlarim" ekrani ro'yxatni
/// avtomatik yuklaydi, haqiqiy tarmoqqa bog'liq bo'lmasligi kerak.
class _FakeAiQuizRepository implements AiQuizRepository {
  @override
  Future<AiQuiz> generate({
    String? filePath,
    String? fileName,
    String? instruction,
    String? topic,
    required int questionCount,
    int? topicCategoryId,
  }) =>
      throw UnimplementedError();

  @override
  Future<List<AiQuiz>> list() async => const [];

  @override
  Future<void> delete(int id) => throw UnimplementedError();

  @override
  Future<AiQuiz> updateVisibility(int id, String visibility) => throw UnimplementedError();

  @override
  Future<AiQuiz> updateTopic(int id, int? topicCategoryId) => throw UnimplementedError();

  @override
  Future<AiQuiz> createManual({
    required String name,
    required List<ManualQuestionInput> questions,
    int? topicCategoryId,
  }) =>
      throw UnimplementedError();

  @override
  Future<List<AiQuiz>> listForUser(String userId) => throw UnimplementedError();

  @override
  Future<List<DiscoverQuiz>> discover({int? categoryId}) async => const [];

  @override
  Future<List<DiscoverQuiz>> searchDiscover(String query, {int? categoryId}) async => const [];

  @override
  Future<String> generateAsync({
    String? filePath,
    String? fileName,
    String? instruction,
    String? topic,
    required int questionCount,
    int? topicCategoryId,
  }) =>
      throw UnimplementedError();

  @override
  Future<({String status, AiQuiz? quiz, String? error})> getAsyncJobStatus(String jobId) =>
      throw UnimplementedError();
}

/// Backendga murojaat qilmaydigan soxta friends repository — Home
/// o'zining do'stlar sonini `GET /friends`dan yuklaydi, haqiqiy tarmoqqa
/// bog'liq bo'lmasligi kerak.
class _FakeFriendsRepository implements FriendsRepository {
  @override
  Future<List<Friend>> getFriends() async => const [
        Friend(
          id: '1',
          username: 'malika',
          firstName: 'Malika',
          lastName: 'Yusupova',
          avatarColor: 'a-teal',
          avatarImagePath: null,
        ),
        Friend(
          id: '2',
          username: 'shohruh',
          firstName: 'Shohruh',
          lastName: 'Toshpulatov',
          avatarColor: 'a-terra',
          avatarImagePath: null,
        ),
        Friend(
          id: '3',
          username: 'dilnoza',
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
  Future<List<FriendRequest>> getIncomingRequests() async => const [];

  @override
  Future<void> acceptFriendRequest(String requestId) => throw UnimplementedError();

  @override
  Future<void> declineFriendRequest(String requestId) => throw UnimplementedError();
}

/// Backendga murojaat qilmaydigan soxta auth repository — Home ekrani
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

  @override
  Future<void> forgotPassword(String email) async {}

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {}

  @override
  Future<List<StoredAccountInfo>> listAccounts() async => const [];

  @override
  Future<String?> activeAccountId() async => null;

  @override
  Future<void> switchAccount(String userId) async {}

  @override
  Future<void> removeAccount(String userId) async {}

  @override
  Future<User> addAccount({required String email, required String password}) => throw UnimplementedError();

  @override
  Future<User> addAccountViaRegister({required String email, required String password}) =>
      throw UnimplementedError();

  @override
  Future<User?> addAccountWithGoogle() => throw UnimplementedError();
}

/// Backendga murojaat qilmaydigan soxta leaderboard repository — Home
/// o'zining statistikasini (`GET /leaderboard/{my_user_id}`) shundan
/// yuklaydi, haqiqiy tarmoqqa bog'liq bo'lmasligi kerak.
class _FakeLeaderboardRepository implements LeaderboardRepository {
  @override
  Future<LeaderboardData> getLeaderboard({
    int limit = 50,
    LeaderboardScope scope = LeaderboardScope.allTime,
    int offset = 0,
  }) =>
      throw UnimplementedError();

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
      );
}

/// Backendga murojaat qilmaydigan soxta lobby repository — "Create a
/// room" tugmasi bosilganda darhol xost sifatida bitta o'yinchili xona
/// qaytaradi, real WebSocket'ga bog'lanmasdan.
class _FakeLobbyRepository implements LobbyRepository {
  final StreamController<LobbyRoomState> _roomController = StreamController<LobbyRoomState>.broadcast();

  @override
  Stream<bool> get connectionStatus => const Stream.empty();

  @override
  Stream<LobbyRoomState> get roomUpdates => _roomController.stream;

  @override
  Stream<LobbyJoinErrorReason> get joinErrors => const Stream.empty();

  @override
  Stream<String> get roomClosed => const Stream.empty();

  @override
  Stream<LobbyGameStartedInfo> get gameStarted => const Stream.empty();

  @override
  Stream<LobbyQuestionEvent> get gameQuestion => const Stream.empty();

  @override
  Stream<String> get waitingForOthers => const Stream.empty();

  @override
  Stream<LobbyQuestionResult> get gameQuestionResult => const Stream.empty();

  @override
  Stream<LobbyFinalResult> get gameFinished => const Stream.empty();

  @override
  void startGame({required String roomId, required int categoryId, int? questionCount}) {}

  @override
  void submitAnswer({required String roomId, required int questionIndex, required int? selectedOption}) {}

  @override
  Future<void> connect() async {}

  @override
  void disconnect() {}

  @override
  void createRoom() => _roomController.add(
        const LobbyRoomState(
          roomId: 'room-1',
          roomCode: '482913',
          youParticipantId: 'host-1',
          participants: [
            LobbyParticipant(
              id: 'host-1',
              username: null,
              firstName: null,
              lastName: null,
              avatarColor: null,
              avatarImagePath: null,
              isHost: true,
            ),
          ],
        ),
      );

  @override
  void joinRoom(String roomCode) {}

  @override
  void leaveRoom(String roomId) {}
}

/// Backendga murojaat qilmaydigan soxta notifications repository — bo'sh
/// ro'yxat qaytaradi, real WebSocket'ga bog'lanmasdan.
class _FakeNotificationsRepository implements NotificationsRepository {
  @override
  Future<List<NotificationRecord>> getNotifications() async => const [];

  @override
  Future<void> markAllRead() async {}
}

/// "See all" and the center Play tab use go_router, so a real (if
/// minimal) router is still required — and the shared bottom-nav/button
/// widgets play a tap sound via Riverpod, so a `ProviderScope` is too.
Future<void> _pumpHome(WidgetTester tester, {Size size = const Size(390, 844)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: AppRoutes.categories,
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: AppRoutes.myAiQuizzes,
        builder: (context, state) => const MyAiQuizzesScreen(),
      ),
      GoRoute(path: AppRoutes.duel, builder: (context, state) => const DuelScreen()),
      GoRoute(path: AppRoutes.joinCode, builder: (context, state) => const JoinCodeScreen()),
      GoRoute(
        path: AppRoutes.lobby,
        builder: (context, state) => LobbyScreen(role: state.extra! as LobbyRole),
      ),
      GoRoute(path: AppRoutes.notifications, builder: (context, state) => const NotificationsScreen()),
      GoRoute(
        path: AppRoutes.createManualQuiz,
        builder: (context, state) => const CreateManualQuizScreen(),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
        leaderboardRepositoryProvider.overrideWithValue(_FakeLeaderboardRepository()),
        quizRepositoryProvider.overrideWithValue(_FakeQuizRepository()),
        aiQuizRepositoryProvider.overrideWithValue(_FakeAiQuizRepository()),
        friendsRepositoryProvider.overrideWithValue(_FakeFriendsRepository()),
        lobbyRepositoryProvider.overrideWithValue(_FakeLobbyRepository()),
        notificationsRepositoryProvider.overrideWithValue(_FakeNotificationsRepository()),
      ],
      child: TranslationProvider(
        child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
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
    expect(find.text(AppStrings.createQuizTitle), findsOneWidget);

    // One card per sample category.
    expect(find.text('Math'), findsOneWidget);
    expect(find.text('Movies'), findsOneWidget);
    expect(find.text('Memes'), findsNothing);

    // No RenderFlex overflow (or any other) errors were thrown mid-layout.
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows real XP/rank/streak from GET /leaderboard/{my_user_id}', (tester) async {
    await _pumpHome(tester);

    expect(find.text(formatThousands(2140)), findsOneWidget);
    expect(find.text('#312'), findsOneWidget);
    expect(find.text('5'), findsOneWidget); // the duel-hero streak chip
  });

  testWidgets('renders correctly on a wide (tablet) viewport, no overflow', (tester) async {
    // Standard mobile layout everywhere — on a wide viewport the single
    // column just stretches full-width, no special tablet treatment.
    await _pumpHome(tester, size: const Size(1024, 1366));

    expect(find.text(AppStrings.duelHeroTitle), findsOneWidget);
    expect(find.text(AppStrings.categoriesTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping the notification bell opens Notifications', (tester) async {
    await _pumpHome(tester);

    await tester.tap(find.byIcon(TablerIcons.bell));
    await tester.pumpAndSettle();

    expect(find.byType(NotificationsScreen), findsOneWidget);
  });

  testWidgets('"Create a room" navigates to the Lobby screen as host', (tester) async {
    await _pumpHome(tester);

    await tester.tap(find.text(AppStrings.createRoom));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.lobbyScreenTitle), findsOneWidget);
    expect(find.text(AppStrings.startGameButton), findsOneWidget);
  });

  testWidgets('"Join with a code" navigates to the Join Code screen', (tester) async {
    await _pumpHome(tester);

    await tester.tap(find.text(AppStrings.joinWithCode));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.joinCodeHint), findsOneWidget);
  });

  testWidgets('the Start Duel pill keeps its natural width instead of stretching', (tester) async {
    await _pumpHome(tester);

    // Regression test: the button used to sit inside an Expanded, which
    // stretched it into a wide bar with the icon/label squashed to the
    // left instead of the intended compact pill shape.
    final double cardWidth = tester.getSize(
      find.text(AppStrings.duelHeroTitle),
    ).width;
    final double buttonWidth = tester.getSize(
      find.ancestor(
        of: find.text(AppStrings.startDuel),
        matching: find.byType(Material),
      ).first,
    ).width;

    expect(
      buttonWidth,
      lessThan(cardWidth),
      reason: 'Start Duel button should be a compact pill, not stretch to the card width',
    );

    // Tapping should still work correctly (both button and card render,
    // no interaction was accidentally broken by fixing the layout) and
    // now pushes the real Duel (choose a friend) screen.
    await tester.tap(find.text(AppStrings.startDuel));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.duelScreenTitle), findsOneWidget);
  });

  testWidgets('the create-quiz card navigates to manual quiz creation', (tester) async {
    // Tall viewport so the last list item isn't near the bottom nav bar's
    // raised center Play button, whose hit area extends above its own
    // bounding box and can otherwise steal the tap.
    await _pumpHome(tester, size: const Size(390, 1400));

    await tester.tap(find.text(AppStrings.createQuizTitle));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.manualQuizScreenTitle), findsOneWidget);
  });

  testWidgets('"See all" navigates to the Categories screen', (tester) async {
    await _pumpHome(tester);

    await tester.tap(find.text(AppStrings.seeAll));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.categoriesScreenTitle), findsOneWidget);
    expect(find.text(AppStrings.duelHeroTitle), findsNothing);
  });
}
