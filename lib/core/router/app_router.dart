import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/duel/domain/entities/duel_invite.dart';
import '../../features/duel/presentation/models/duel_game_state.dart';
import '../../features/duel/presentation/screens/duel_game_screen.dart';
import '../../features/duel/presentation/screens/duel_result_screen.dart';
import '../../features/friends/presentation/models/duel_match.dart';
import '../../features/friends/presentation/models/friend_entry.dart';
import '../../features/friends/presentation/screens/add_friend_screen.dart';
import '../../features/friends/presentation/screens/duel_invite_screen.dart';
import '../../features/friends/presentation/screens/duel_screen.dart';
import '../../features/friends/presentation/screens/duel_waiting_screen.dart';
import '../../features/friends/presentation/screens/friend_requests_screen.dart';
import '../../features/friends/presentation/screens/friends_screen.dart';
import '../../features/history/presentation/screens/history_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/introduction/presentation/screens/introduction_screen.dart';
import '../../features/leaderboard/presentation/models/leaderboard_entry.dart';
import '../../features/leaderboard/presentation/screens/full_leaderboard_screen.dart';
import '../../features/leaderboard/presentation/screens/leaderboard_screen.dart';
import '../../features/leaderboard/presentation/screens/player_detail_screen.dart';
import '../../features/lobby/presentation/models/lobby_result_args.dart';
import '../../features/lobby/presentation/screens/join_code_screen.dart';
import '../../features/lobby/presentation/screens/lobby_game_screen.dart';
import '../../features/lobby/presentation/screens/lobby_result_screen.dart';
import '../../features/lobby/presentation/screens/lobby_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/quiz/presentation/models/quiz_category.dart';
import '../../features/quiz/presentation/models/quiz_launch_args.dart';
import '../../features/quiz/presentation/models/quiz_result.dart';
import '../../features/quiz/presentation/screens/ball_reveal_screen.dart';
import '../../features/quiz/presentation/screens/categories_screen.dart';
import '../../features/quiz/presentation/screens/quiz_intro_screen.dart';
import '../../features/quiz/presentation/screens/quiz_screen.dart';
import '../../features/quiz/presentation/screens/quiz_setup_screen.dart';
import '../../features/quiz/presentation/screens/result_screen.dart';
import '../../features/settings/presentation/screens/change_password_screen.dart';
import '../../features/settings/presentation/screens/help_center_screen.dart';
import '../../features/settings/presentation/screens/language_screen.dart';
import '../../features/settings/presentation/screens/notification_settings_screen.dart';
import '../../features/settings/presentation/screens/privacy_policy_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/terms_of_use_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../storage/app_preferences.dart';
import 'app_routes.dart';

/// Hozircha statik marshrutlar — auth holatiga bog'liq yo'naltirish
/// (redirect) auth qatlami qayta qurilganda qaytariladi. Ekranlar orasida
/// hozircha to'g'ridan-to'g'ri `context.go(...)` bilan o'tiladi.
///
/// `initialLocation` faqat bittasi bundan mustasno: birinchi marta
/// kirganda (hali [AppPreferences.hasSeenIntroduction] false bo'lganda)
/// ilova Login/Register'dan OLDIN Introduction oqimini ko'rsatadi.
final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((ref) {
  final AppPreferences prefs = ref.watch(appPreferencesProvider);

  return GoRouter(
    initialLocation: prefs.hasSeenIntroduction ? AppRoutes.home : AppRoutes.introduction,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.introduction,
        builder: (context, state) => const IntroductionScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      // `extra` carries the pending duel opponent when reached from the
      // Duel screen; absent (or a deep link) means the plain solo picker.
      GoRoute(
        path: AppRoutes.categories,
        builder: (context, state) => CategoriesScreen(
          duelOpponent: state.extra is FriendEntry ? state.extra as FriendEntry : null,
          lobbyRoomId: state.extra is String ? state.extra as String : null,
        ),
      ),
      GoRoute(
        path: AppRoutes.leaderboard,
        builder: (context, state) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.friends,
        builder: (context, state) => const FriendsScreen(),
      ),
      GoRoute(
        path: AppRoutes.addFriend,
        builder: (context, state) => const AddFriendScreen(),
      ),
      GoRoute(
        path: AppRoutes.friendRequests,
        builder: (context, state) => const FriendRequestsScreen(),
      ),
      GoRoute(
        path: AppRoutes.duel,
        builder: (context, state) => const DuelScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      // The quiz-flow routes carry non-serializable data via `extra` —
      // if it's missing or the wrong type (e.g. a deep link, or state
      // lost on a hot restart), redirect to Home instead of crashing.
      GoRoute(
        path: AppRoutes.quizSetup,
        redirect: (context, state) => state.extra is QuizCategory ? null : AppRoutes.home,
        builder: (context, state) => QuizSetupScreen(category: state.extra! as QuizCategory),
      ),
      GoRoute(
        path: AppRoutes.quizIntro,
        redirect: (context, state) => state.extra is QuizLaunchArgs ? null : AppRoutes.home,
        builder: (context, state) => QuizIntroScreen(args: state.extra! as QuizLaunchArgs),
      ),
      GoRoute(
        path: AppRoutes.quiz,
        redirect: (context, state) => state.extra is QuizLaunchArgs ? null : AppRoutes.home,
        builder: (context, state) {
          final QuizLaunchArgs args = state.extra! as QuizLaunchArgs;
          return QuizScreen(
            category: args.category,
            questionCount: args.questionCount,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.ballReveal,
        redirect: (context, state) => state.extra is QuizResult ? null : AppRoutes.home,
        builder: (context, state) => BallRevealScreen(result: state.extra! as QuizResult),
      ),
      GoRoute(
        path: AppRoutes.result,
        redirect: (context, state) => state.extra is QuizResult ? null : AppRoutes.home,
        builder: (context, state) => ResultScreen(result: state.extra! as QuizResult),
      ),
      GoRoute(
        path: AppRoutes.lobbyResult,
        redirect: (context, state) => state.extra is LobbyResultArgs ? null : AppRoutes.home,
        builder: (context, state) => LobbyResultScreen(args: state.extra! as LobbyResultArgs),
      ),
      GoRoute(
        path: AppRoutes.joinCode,
        builder: (context, state) => const JoinCodeScreen(),
      ),
      // Defaults to `host` when arriving without `extra` (e.g. a deep
      // link) — the safer of the two roles to fall back to, since it
      // doesn't misrepresent the device as having joined someone else's
      // real room.
      GoRoute(
        path: AppRoutes.lobby,
        builder: (context, state) => LobbyScreen(role: (state.extra as LobbyRole?) ?? LobbyRole.host),
      ),
      GoRoute(
        path: AppRoutes.lobbyGame,
        builder: (context, state) => const LobbyGameScreen(),
      ),
      GoRoute(
        path: AppRoutes.fullLeaderboard,
        builder: (context, state) => const FullLeaderboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.playerDetail,
        redirect: (context, state) => state.extra is LeaderboardEntry ? null : AppRoutes.leaderboard,
        builder: (context, state) => PlayerDetailScreen(entry: state.extra! as LeaderboardEntry),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.history,
        builder: (context, state) => const HistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.duelWaiting,
        redirect: (context, state) => state.extra is DuelMatch ? null : AppRoutes.home,
        builder: (context, state) => DuelWaitingScreen(match: state.extra! as DuelMatch),
      ),
      GoRoute(
        path: AppRoutes.duelInvite,
        redirect: (context, state) => state.extra is DuelInvite ? null : AppRoutes.home,
        builder: (context, state) => DuelInviteScreen(invite: state.extra! as DuelInvite),
      ),
      GoRoute(
        path: AppRoutes.duelGame,
        builder: (context, state) => const DuelGameScreen(),
      ),
      GoRoute(
        path: AppRoutes.duelResult,
        redirect: (context, state) => state.extra is DuelGameState ? null : AppRoutes.home,
        builder: (context, state) => DuelResultScreen(game: state.extra! as DuelGameState),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.languageSettings,
        builder: (context, state) => const LanguageScreen(),
      ),
      GoRoute(
        path: AppRoutes.notificationSettings,
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacyPolicy,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: AppRoutes.helpCenter,
        builder: (context, state) => const HelpCenterScreen(),
      ),
      GoRoute(
        path: AppRoutes.termsOfUse,
        builder: (context, state) => const TermsOfUseScreen(),
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        builder: (context, state) => const ChangePasswordScreen(),
      ),
    ],
  );
});
