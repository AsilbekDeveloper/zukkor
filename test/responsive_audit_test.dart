import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:zukkor/core/constants/app_strings.dart';
import 'package:zukkor/core/models/avatar_color_option.dart';
import 'package:zukkor/core/notifications/push_notification_service.dart';
import 'package:zukkor/core/storage/app_preferences.dart';
import 'package:zukkor/core/theme/app_theme.dart';
import 'package:zukkor/features/ai_quiz/presentation/screens/create_manual_quiz_screen.dart';
import 'package:zukkor/features/ai_quiz/presentation/screens/generate_ai_quiz_screen.dart';
import 'package:zukkor/features/ai_quiz/presentation/screens/my_ai_quizzes_screen.dart';
import 'package:zukkor/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:zukkor/features/auth/domain/entities/user.dart';
import 'package:zukkor/features/auth/domain/repositories/auth_repository.dart';
import 'package:zukkor/features/auth/presentation/screens/login_screen.dart';
import 'package:zukkor/features/auth/presentation/screens/register_screen.dart';
import 'package:zukkor/features/duel/domain/entities/duel_final_result.dart';
import 'package:zukkor/features/duel/domain/entities/duel_invite.dart';
import 'package:zukkor/features/duel/domain/entities/duel_participant.dart';
import 'package:zukkor/features/duel/domain/entities/duel_player_score.dart';
import 'package:zukkor/features/duel/presentation/models/duel_game_state.dart';
import 'package:zukkor/features/duel/presentation/screens/duel_game_screen.dart';
import 'package:zukkor/features/duel/presentation/screens/duel_result_screen.dart';
import 'package:zukkor/features/friends/data/repositories/friends_repository_impl.dart';
import 'package:zukkor/features/friends/domain/entities/discovered_user.dart';
import 'package:zukkor/features/friends/domain/entities/friend.dart';
import 'package:zukkor/features/friends/domain/entities/friend_request.dart';
import 'package:zukkor/features/friends/domain/repositories/friends_repository.dart';
import 'package:zukkor/features/friends/presentation/models/duel_match.dart';
import 'package:zukkor/features/friends/presentation/models/friend_entry.dart';
import 'package:zukkor/features/friends/presentation/screens/add_friend_screen.dart';
import 'package:zukkor/features/friends/presentation/screens/duel_invite_screen.dart';
import 'package:zukkor/features/friends/presentation/screens/duel_screen.dart';
import 'package:zukkor/features/friends/presentation/screens/duel_waiting_screen.dart';
import 'package:zukkor/features/friends/presentation/screens/friend_requests_screen.dart';
import 'package:zukkor/features/friends/presentation/screens/friends_screen.dart';
import 'package:zukkor/features/history/data/repositories/history_repository_impl.dart';
import 'package:zukkor/features/history/domain/entities/session_history_entry.dart';
import 'package:zukkor/features/history/domain/repositories/history_repository.dart';
import 'package:zukkor/features/history/presentation/screens/history_screen.dart';
import 'package:zukkor/features/home/presentation/screens/home_screen.dart';
import 'package:zukkor/features/introduction/presentation/screens/introduction_screen.dart';
import 'package:zukkor/features/leaderboard/data/repositories/leaderboard_repository_impl.dart';
import 'package:zukkor/features/leaderboard/domain/entities/leaderboard_data.dart';
import 'package:zukkor/features/leaderboard/domain/entities/leaderboard_scope.dart';
import 'package:zukkor/features/leaderboard/domain/entities/player_stats.dart';
import 'package:zukkor/features/leaderboard/domain/entities/rank_entry.dart';
import 'package:zukkor/features/leaderboard/domain/repositories/leaderboard_repository.dart';
import 'package:zukkor/features/leaderboard/presentation/screens/full_leaderboard_screen.dart';
import 'package:zukkor/features/leaderboard/presentation/screens/leaderboard_screen.dart';
import 'package:zukkor/features/lobby/domain/entities/lobby_final_result.dart';
import 'package:zukkor/features/lobby/domain/entities/lobby_participant.dart';
import 'package:zukkor/features/lobby/domain/entities/lobby_player_score.dart';
import 'package:zukkor/features/lobby/domain/entities/lobby_room_state.dart';
import 'package:zukkor/features/lobby/presentation/models/lobby_result_args.dart';
import 'package:zukkor/features/lobby/presentation/screens/join_code_screen.dart';
import 'package:zukkor/features/lobby/presentation/screens/lobby_game_screen.dart';
import 'package:zukkor/features/lobby/presentation/screens/lobby_result_screen.dart';
import 'package:zukkor/features/lobby/presentation/screens/lobby_screen.dart';
import 'package:zukkor/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:zukkor/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:zukkor/features/player_detail/presentation/models/player_detail_args.dart';
import 'package:zukkor/features/player_detail/presentation/screens/player_detail_screen.dart';
import 'package:zukkor/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:zukkor/features/profile/presentation/screens/profile_screen.dart';
import 'package:zukkor/features/quiz/data/repositories/quiz_repository_impl.dart';
import 'package:zukkor/features/quiz/domain/entities/answer_result.dart';
import 'package:zukkor/features/quiz/domain/entities/category.dart';
import 'package:zukkor/features/quiz/domain/entities/quiz_question_data.dart';
import 'package:zukkor/features/quiz/domain/entities/quiz_start_result.dart';
import 'package:zukkor/features/quiz/domain/repositories/quiz_repository.dart';
import 'package:zukkor/features/quiz/presentation/models/quiz_category.dart';
import 'package:zukkor/features/quiz/presentation/models/quiz_launch_args.dart';
import 'package:zukkor/features/quiz/presentation/models/quiz_result.dart';
import 'package:zukkor/features/quiz/presentation/screens/ball_reveal_screen.dart';
import 'package:zukkor/features/quiz/presentation/screens/categories_screen.dart';
import 'package:zukkor/features/quiz/presentation/screens/quiz_intro_screen.dart';
import 'package:zukkor/features/quiz/presentation/screens/quiz_screen.dart';
import 'package:zukkor/features/quiz/presentation/screens/quiz_setup_screen.dart';
import 'package:zukkor/features/quiz/presentation/screens/result_screen.dart';
import 'package:zukkor/features/settings/data/repositories/notification_preferences_repository_impl.dart';
import 'package:zukkor/features/settings/domain/entities/notification_preferences.dart';
import 'package:zukkor/features/settings/domain/repositories/notification_preferences_repository.dart';
import 'package:zukkor/features/settings/presentation/screens/change_password_screen.dart';
import 'package:zukkor/features/settings/presentation/screens/help_center_screen.dart';
import 'package:zukkor/features/settings/presentation/screens/language_screen.dart';
import 'package:zukkor/features/settings/presentation/screens/notification_settings_screen.dart';
import 'package:zukkor/features/settings/presentation/screens/privacy_policy_screen.dart';
import 'package:zukkor/features/settings/presentation/screens/settings_screen.dart';
import 'package:zukkor/features/settings/presentation/screens/terms_of_use_screen.dart';
import 'package:zukkor/features/splash/splash_screen.dart';
import 'package:zukkor/i18n/strings.g.dart';

/// RESPONSIVE AUDIT — the project's overflow safety net.
///
/// Every screen is laid out at every size in [_sizes] (real device
/// dimensions: small/large phones, portrait/landscape tablets, and a
/// landscape phone as the harshest height) and additionally at the app's
/// maximum clamped text scale (1.3) on the narrowest and widest devices.
/// Any RenderFlex overflow or other layout exception fails the matching
/// test case by name, e.g. `Leaderboard @ 320x568`.
///
/// RULE FOR NEW SCREENS: add the screen to [_screens] in the same change
/// that creates it — this file is what keeps "no overflow anywhere" true
/// as the app grows.
const List<Size> _sizes = [
  // Phones (portrait).
  Size(320, 568), // iPhone SE 1 / smallest realistic device
  Size(360, 640), // small Android
  Size(375, 667), // iPhone SE 2/3
  Size(390, 844), // iPhone 14
  Size(412, 915), // Pixel 7
  Size(480, 800), // large/wide phone
  // Phone (landscape) — the harshest height any screen must survive.
  Size(844, 390),
  // Tablets (portrait).
  Size(600, 960), // exactly at the tablet breakpoint
  Size(768, 1024), // iPad
  Size(834, 1194), // iPad Air
  Size(1024, 1366), // iPad Pro 12.9"
  // Tablets (landscape).
  Size(1024, 768),
  Size(1280, 800),
];

/// Narrowest + widest devices re-run at the max clamped font scale.
const List<Size> _textScaleSizes = [Size(320, 568), Size(360, 640), Size(1024, 1366)];

typedef _ScreenCase = ({String name, WidgetBuilder builder});

const QuizCategory _math = QuizCategory(
  id: 1,
  name: 'Math',
  questionCount: 120,
  icon: TablerIcons.mathSymbols,
  colorKey: CategoryColorKey.coral,
);

final List<_ScreenCase> _screens = [
  (name: 'Splash', builder: (_) => const SplashScreen()),
  (name: 'Introduction', builder: (_) => const IntroductionScreen()),
  (name: 'Login', builder: (_) => const LoginScreen()),
  (name: 'Register', builder: (_) => const RegisterScreen()),
  (name: 'Onboarding', builder: (_) => const OnboardingScreen()),
  (name: 'Home', builder: (_) => const HomeScreen()),
  (name: 'Categories', builder: (_) => const CategoriesScreen()),
  (name: 'QuizSetup', builder: (_) => QuizSetupScreen(category: _math, onStart: (context, ref, count) {})),
  (
    name: 'QuizIntro',
    builder: (_) => const QuizIntroScreen(args: QuizLaunchArgs(category: _math)),
  ),
  (name: 'Quiz', builder: (_) => const QuizScreen(category: _math)),
  (
    name: 'BallReveal',
    builder: (_) => const BallRevealScreen(
      result: QuizResult(
        category: _math,
        correctCount: 4,
        totalCount: 5,
        xpEarned: 60,
        totalBall: 4200,
        breakdown: [],
      ),
    ),
  ),
  (
    name: 'Result',
    builder: (_) => const ResultScreen(
      result: QuizResult(
        category: _math,
        correctCount: 4,
        totalCount: 5,
        xpEarned: 60,
        totalBall: 4200,
        breakdown: [],
      ),
    ),
  ),
  (name: 'Leaderboard', builder: (_) => const LeaderboardScreen()),
  (name: 'Friends', builder: (_) => const FriendsScreen()),
  (name: 'AddFriend', builder: (_) => const AddFriendScreen()),
  (name: 'FriendRequests', builder: (_) => const FriendRequestsScreen()),
  (name: 'Duel', builder: (_) => const DuelScreen()),
  (name: 'Profile', builder: (_) => const ProfileScreen()),
  (name: 'JoinCode', builder: (_) => const JoinCodeScreen()),
  (name: 'LobbyHost', builder: (_) => const LobbyScreen(role: LobbyRole.host)),
  (name: 'LobbyGuest', builder: (_) => const LobbyScreen(role: LobbyRole.guest)),
  (name: 'LobbyGame', builder: (_) => const LobbyGameScreen()),
  (
    name: 'LobbyResult',
    builder: (_) => const LobbyResultScreen(
      args: LobbyResultArgs(
        room: LobbyRoomState(
          roomId: 'room-1',
          roomCode: '482913',
          youParticipantId: 'you',
          participants: [
            LobbyParticipant(
              id: 'you',
              username: null,
              firstName: null,
              lastName: null,
              avatarColor: null,
              avatarImagePath: null,
              isHost: true,
            ),
            LobbyParticipant(
              id: 'u2',
              username: 'malika',
              firstName: 'Malika',
              lastName: null,
              avatarColor: 'a-teal',
              avatarImagePath: null,
              isHost: false,
            ),
            LobbyParticipant(
              id: 'u3',
              username: 'shohruh',
              firstName: 'Shohruh',
              lastName: null,
              avatarColor: 'a-terra',
              avatarImagePath: null,
              isHost: false,
            ),
            LobbyParticipant(
              id: 'u4',
              username: 'dilnoza',
              firstName: 'Dilnoza',
              lastName: null,
              avatarColor: 'a-pink',
              avatarImagePath: null,
              isHost: false,
            ),
          ],
        ),
        result: LobbyFinalResult(
          roomId: 'room-1',
          standings: [
            LobbyPlayerScore(participantId: 'you', correct: 4, total: 5, totalTimeMs: 42000),
            LobbyPlayerScore(participantId: 'u2', correct: 3, total: 5, totalTimeMs: 40000),
            LobbyPlayerScore(participantId: 'u3', correct: 2, total: 5, totalTimeMs: 45000),
            LobbyPlayerScore(participantId: 'u4', correct: 1, total: 5, totalTimeMs: 48000),
          ],
          xpEarned: 58,
          ballEarned: 4000,
          breakdown: [],
        ),
      ),
    ),
  ),
  (name: 'FullLeaderboard', builder: (_) => const FullLeaderboardScreen()),
  (
    name: 'PlayerDetail',
    builder: (_) => const PlayerDetailScreen(
      args: PlayerDetailArgs(userId: '1'),
    ),
  ),
  (name: 'Settings', builder: (_) => const SettingsScreen()),
  (name: 'History', builder: (_) => const HistoryScreen()),
  (
    name: 'DuelWaiting',
    builder: (_) => const DuelWaitingScreen(
      match: DuelMatch(
        opponent: FriendEntry(
          name: 'Malika Yusupova',
          username: 'malika_yusupova',
          initials: 'MR',
          avatarColor: AvatarColorOption.teal,
        ),
        category: _math,
      ),
    ),
  ),
  (
    name: 'DuelInvite',
    builder: (_) => DuelInviteScreen(
      invite: DuelInvite(
        id: 'invite-1',
        fromUser: const DuelParticipant(
          id: 'u1',
          username: 'malika_yusupova',
          firstName: 'Malika',
          lastName: 'Yusupova',
          avatarColor: 'a-teal',
          avatarImagePath: null,
        ),
        category: const Category(id: 2, name: 'History', iconName: 'book', colorKey: 'terra', questionCount: 98),
        expiresAt: DateTime(2026, 7, 19),
      ),
    ),
  ),
  (name: 'DuelGame', builder: (_) => const DuelGameScreen()),
  (
    name: 'DuelResult',
    builder: (_) => const DuelResultScreen(
      game: DuelGameState(
        duelId: 'd1',
        category: Category(id: 2, name: 'History', iconName: 'book', colorKey: 'terra', questionCount: 98),
        opponent: DuelParticipant(
          id: 'u1',
          username: 'malika_yusupova',
          firstName: 'Malika',
          lastName: 'Yusupova',
          avatarColor: 'a-teal',
          avatarImagePath: null,
        ),
        totalQuestions: 5,
        finalResult: DuelFinalResult(
          duelId: 'd1',
          outcome: DuelOutcome.won,
          yourScore: DuelPlayerScore(correct: 4, total: 5, totalTimeMs: 42000),
          opponentScore: DuelPlayerScore(correct: 3, total: 5, totalTimeMs: 45000),
          xpEarned: 60,
          ballEarned: 4200,
          breakdown: [],
        ),
      ),
    ),
  ),
  (name: 'Notifications', builder: (_) => const NotificationsScreen()),
  (name: 'EditProfile', builder: (_) => const EditProfileScreen()),
  (name: 'Language', builder: (_) => const LanguageScreen()),
  (name: 'NotificationSettings', builder: (_) => const NotificationSettingsScreen()),
  (name: 'PrivacyPolicy', builder: (_) => const PrivacyPolicyScreen()),
  (name: 'HelpCenter', builder: (_) => const HelpCenterScreen()),
  (name: 'TermsOfUse', builder: (_) => const TermsOfUseScreen()),
  (name: 'ChangePassword', builder: (_) => const ChangePasswordScreen()),
  (name: 'MyAiQuizzes', builder: (_) => const MyAiQuizzesScreen()),
  (name: 'GenerateAiQuiz', builder: (_) => const GenerateAiQuizScreen()),
  (name: 'CreateManualQuiz', builder: (_) => const CreateManualQuizScreen()),
];

/// Backendga murojaat qilmaydigan soxta auth repository — Onboarding
/// wizard'ini to'liq bosib o'tadigan audit testlar haqiqiy tarmoqqa
/// bog'liq bo'lmasligi kerak.
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
        isActive: true,
        createdAt: DateTime(2026),
        onboardingCompleted: false,
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
      User(
        id: '1',
        email: 'aziz@example.com',
        username: username,
        firstName: firstName,
        lastName: lastName,
        avatarColor: avatarColor,
        direction: direction,
        isActive: true,
        createdAt: DateTime(2026),
        onboardingCompleted: true,
        authProvider: 'email',
      );

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
}

class _FakePushNotificationService implements PushNotificationService {
  @override
  Future<String?> requestTokenOrNull() async => 'fake-token';

  @override
  void listenTokenRefresh(void Function(String token) onToken) {}

  @override
  void listenForeground() {}
}

/// Backendga murojaat qilmaydigan soxta leaderboard repository —
/// Leaderboard/FullLeaderboard/PlayerDetail audit testlari haqiqiy
/// tarmoqqa bog'liq bo'lmasligi, va PlayerDetail'ning xato bo'lganda
/// GoRouter'siz muhitda navigatsiya qilishga urinib qulashining oldini
/// olish uchun.
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
            isMe: false,
          ),
          RankEntry(
            userId: '2',
            rank: 2,
            username: 'malika',
            firstName: 'Malika',
            lastName: 'Yusupova',
            avatarColor: 'a-teal',
            avatarImagePath: null,
            totalXp: 4510,
            isMe: false,
          ),
          RankEntry(
            userId: '3',
            rank: 3,
            username: 'shohruh',
            firstName: 'Shohruh',
            lastName: 'Toshpulatov',
            avatarColor: 'a-terra',
            avatarImagePath: null,
            totalXp: 4290,
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
          isMe: true,
        ),
      );

  @override
  Future<PlayerStats> getPlayerStats(String userId) async => const PlayerStats(
        userId: '1',
        rank: 1,
        username: 'aziz',
        firstName: 'Aziz',
        lastName: 'K.',
        avatarColor: 'a-coral',
        avatarImagePath: null,
        totalXp: 4820,
        currentStreak: 5,
        longestStreak: 15,
        gamesPlayed: 40,
        winRatePercent: 68,
      );
}

/// Backendga murojaat qilmaydigan soxta quiz repository — `Quiz` audit
/// testi haqiqiy tarmoqqa bog'liq bo'lmasligi, va sessiya boshlanishi
/// muvaffaqiyatsiz bo'lganda GoRouter'siz muhitda navigatsiya qilishga
/// urinib qulashining oldini olish uchun.
class _FakeQuizRepository implements QuizRepository {
  @override
  Future<List<Category>> getCategories() => throw UnimplementedError();

  @override
  Future<QuizStartResult> startQuiz({required int categoryId, required int questionCount}) async =>
      const QuizStartResult(
        sessionId: 'session-1',
        question: QuizQuestionData(
          sessionQuestionId: 1,
          questionText: 'What is 2 + 2?',
          options: ['3', '4', '5', '6'],
          correctOptionIndex: 1,
          order: 1,
          total: 5,
          timeLimitMs: 15000,
        ),
      );

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

/// Backendga murojaat qilmaydigan soxta history repository — History
/// audit testi haqiqiy tarmoqqa bog'liq bo'lmasligi kerak.
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

/// Backendga murojaat qilmaydigan soxta repository —
/// NotificationSettings audit testi haqiqiy tarmoqqa bog'liq bo'lmasligi
/// kerak.
class _FakeNotificationPreferencesRepository implements NotificationPreferencesRepository {
  @override
  Future<NotificationPreferences> getPreferences() async => const NotificationPreferences(
        duelInvites: true,
        streakReminders: true,
        leaderboardUpdates: true,
        friendRequests: true,
        productUpdates: true,
      );

  @override
  Future<NotificationPreferences> updatePreferences(NotificationPreferences preferences) async => preferences;
}

/// Backendga murojaat qilmaydigan soxta friends repository — Friends,
/// AddFriend va Duel audit testlari haqiqiy tarmoqqa bog'liq bo'lmasligi
/// kerak. Uzun ism qo'shildi — matn to'lib-toshishini tekshirish uchun.
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
        Friend(
          id: '2',
          username: 'shohruhbek_toshpulatov_dev',
          firstName: 'Shohruhbek',
          lastName: 'Toshpulatov-Dilshodov',
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
  Future<List<DiscoveredUser>> searchUsers(String query) async => const [];

  @override
  Future<void> sendFriendRequest(String userId) async {}

  @override
  Future<List<FriendRequest>> getIncomingRequests() async => [
        FriendRequest(
          id: 'req-1',
          fromUserId: '9',
          username: 'bekzod_xolmatov',
          firstName: 'Bekzod',
          lastName: 'Xolmatov',
          avatarColor: 'a-blue',
          avatarImagePath: null,
          createdAt: DateTime(2026, 7, 18),
        ),
      ];

  @override
  Future<void> acceptFriendRequest(String requestId) async {}

  @override
  Future<void> declineFriendRequest(String requestId) async {}
}

Future<void> _pumpAt(
  WidgetTester tester,
  Size size,
  WidgetBuilder builder, {
  double textScale = 1.0,
  bool useFakeAuthRepository = false,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  // Settings reads themeControllerProvider (dark-mode toggle), which
  // depends on appPreferencesProvider — every screen needs a
  // ProviderScope even though most don't touch it themselves.
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appPreferencesProvider.overrideWithValue(AppPreferences(prefs)),
        leaderboardRepositoryProvider.overrideWithValue(_FakeLeaderboardRepository()),
        quizRepositoryProvider.overrideWithValue(_FakeQuizRepository()),
        historyRepositoryProvider.overrideWithValue(_FakeHistoryRepository()),
        friendsRepositoryProvider.overrideWithValue(_FakeFriendsRepository()),
        pushNotificationServiceProvider.overrideWithValue(_FakePushNotificationService()),
        notificationPreferencesRepositoryProvider.overrideWithValue(_FakeNotificationPreferencesRepository()),
        if (useFakeAuthRepository)
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
      ],
      child: TranslationProvider(
        child: MaterialApp(
          theme: AppTheme.light(),
          // Mirrors production: `clampTextScaling` caps the system scale at
          // 1.3, so 1.3 here is exactly the worst case a user can produce.
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: Builder(builder: builder),
        ),
      ),
    ),
  );
  // Bounded pumps (not pumpAndSettle — Splash has an indefinite spinner).
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  // Backs appPreferencesProvider (see _pumpAt) — must be set before any
  // SharedPreferences.getInstance() call or it hits a real platform
  // channel with no test handler and hangs forever instead of failing.
  SharedPreferences.setMockInitialValues(<String, Object>{});

  for (final _ScreenCase screen in _screens) {
    group(screen.name, () {
      for (final Size size in _sizes) {
        testWidgets('${screen.name} @ ${size.width.toInt()}x${size.height.toInt()}', (tester) async {
          await _pumpAt(tester, size, screen.builder);
          expect(tester.takeException(), isNull);
        });
      }

      for (final Size size in _textScaleSizes) {
        testWidgets(
            '${screen.name} @ ${size.width.toInt()}x${size.height.toInt()} (text scale 1.3)',
            (tester) async {
          await _pumpAt(tester, size, screen.builder, textScale: 1.3);
          expect(tester.takeException(), isNull);
        });
      }
    });
  }

  // The onboarding wizard's later steps only exist after interaction, so
  // walk the full flow at representative extremes of the size matrix.
  group('Onboarding wizard walk', () {
    const List<Size> walkSizes = [Size(320, 568), Size(390, 844), Size(844, 390), Size(1024, 768)];

    for (final Size size in walkSizes) {
      testWidgets('all 3 steps @ ${size.width.toInt()}x${size.height.toInt()}', (tester) async {
        await _pumpAt(
          tester,
          size,
          (_) => const OnboardingScreen(),
          useFakeAuthRepository: true,
        );
        expect(tester.takeException(), isNull, reason: 'step 1 overflowed');

        // Step 1 → 2.
        await tester.tap(find.text(AppStrings.onboardingContinue));
        await tester.pump(const Duration(milliseconds: 400));
        expect(tester.takeException(), isNull, reason: 'step 2 overflowed');

        // Fill the profile form so step 2 can advance.
        await tester.enterText(find.byType(TextFormField).at(0), 'Aziz');
        await tester.enterText(find.byType(TextFormField).at(1), 'Karimov');
        await tester.enterText(find.byType(TextFormField).at(2), 'aziz_karimov');
        await tester.pump();

        // Step 2 → 3.
        await tester.tap(find.text(AppStrings.onboardingContinue));
        await tester.pump(const Duration(milliseconds: 400));
        expect(tester.takeException(), isNull, reason: 'step 3 overflowed');

        expect(find.text(AppStrings.directionStepTitle), findsOneWidget);
      });
    }
  });

  // Same idea for the Introduction walkthrough's 6 pages — walk to the
  // last page (survey inputs included) without tapping the final button,
  // since that calls `context.go` and this harness has no GoRouter.
  group('Introduction walkthrough', () {
    const List<Size> walkSizes = [Size(320, 568), Size(390, 844), Size(844, 390), Size(1024, 768)];

    for (final Size size in walkSizes) {
      testWidgets('all 6 pages @ ${size.width.toInt()}x${size.height.toInt()}', (tester) async {
        await _pumpAt(tester, size, (_) => const IntroductionScreen());
        expect(tester.takeException(), isNull, reason: 'page 1 overflowed');

        // Pages 1 → 5: plain explainer pages, just advance through them.
        for (int page = 2; page <= 5; page++) {
          await tester.tap(find.text(AppStrings.onboardingContinue));
          await tester.pump(const Duration(milliseconds: 400));
          expect(tester.takeException(), isNull, reason: 'page $page overflowed');
        }

        // Page 5: interests survey — select a couple of chips including
        // "Other", which reveals a text field. The chip grid can overflow
        // the shortest test viewports, so scroll each chip into view
        // before tapping it.
        await tester.ensureVisible(find.text('Math'));
        await tester.tap(find.text('Math'));
        await tester.ensureVisible(find.text(AppStrings.introOtherOption));
        await tester.tap(find.text(AppStrings.introOtherOption));
        await tester.pump();
        expect(tester.takeException(), isNull, reason: 'page 5 (interests) overflowed');

        await tester.enterText(find.byType(TextFormField), 'Chess');
        await tester.pump();

        await tester.tap(find.text(AppStrings.onboardingContinue));
        await tester.pump(const Duration(milliseconds: 400));

        // Page 6: study place + quiz liking — switch both segments to
        // their non-default option to exercise the wider labels.
        expect(tester.takeException(), isNull, reason: 'page 6 overflowed');
        await tester.ensureVisible(find.text(AppStrings.introStudyPlaceExamPrep));
        await tester.tap(find.text(AppStrings.introStudyPlaceExamPrep));
        await tester.ensureVisible(find.text(AppStrings.introQuizLikingNotReally));
        await tester.tap(find.text(AppStrings.introQuizLikingNotReally));
        await tester.pump();
        expect(tester.takeException(), isNull, reason: 'page 6 after selection overflowed');

        expect(find.text(AppStrings.introQuizLikingLabel), findsOneWidget);
      });
    }
  });
}
