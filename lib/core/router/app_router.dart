import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/friends/presentation/models/duel_match.dart';
import '../../features/friends/presentation/models/friend_entry.dart';
import '../../features/friends/presentation/screens/add_friend_screen.dart';
import '../../features/friends/presentation/screens/duel_invite_screen.dart';
import '../../features/friends/presentation/screens/duel_screen.dart';
import '../../features/friends/presentation/screens/duel_waiting_screen.dart';
import '../../features/friends/presentation/screens/friends_screen.dart';
import '../../features/history/presentation/screens/history_screen.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/leaderboard/presentation/models/leaderboard_entry.dart';
import '../../features/leaderboard/presentation/screens/full_leaderboard_screen.dart';
import '../../features/leaderboard/presentation/screens/leaderboard_screen.dart';
import '../../features/leaderboard/presentation/screens/player_detail_screen.dart';
import '../../features/leaderboard/presentation/screens/rank_filter_screen.dart';
import '../../features/lobby/presentation/screens/join_code_screen.dart';
import '../../features/lobby/presentation/screens/lobby_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/quiz/presentation/models/quiz_category.dart';
import '../../features/quiz/presentation/models/quiz_result.dart';
import '../../features/quiz/presentation/screens/categories_screen.dart';
import '../../features/quiz/presentation/screens/quiz_intro_screen.dart';
import '../../features/quiz/presentation/screens/quiz_screen.dart';
import '../../features/quiz/presentation/screens/result_screen.dart';
import '../../features/settings/presentation/screens/help_center_screen.dart';
import '../../features/settings/presentation/screens/language_screen.dart';
import '../../features/settings/presentation/screens/notification_settings_screen.dart';
import '../../features/settings/presentation/screens/privacy_policy_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/terms_of_use_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../constants/app_strings.dart';
import 'app_routes.dart';

/// Hozircha statik marshrutlar — auth holatiga bog'liq yo'naltirish
/// (redirect) auth qatlami qayta qurilganda qaytariladi. Ekranlar orasida
/// hozircha to'g'ridan-to'g'ri `context.go(...)` bilan o'tiladi.
final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
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
        builder: (context, state) => CategoriesScreen(duelOpponent: state.extra as FriendEntry?),
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
        path: AppRoutes.duel,
        builder: (context, state) => const DuelScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      // The 3 quiz-flow routes carry non-serializable data via `extra` —
      // if it's missing or the wrong type (e.g. a deep link, or state
      // lost on a hot restart), redirect to Home instead of crashing.
      GoRoute(
        path: AppRoutes.quizIntro,
        redirect: (context, state) => state.extra is QuizCategory ? null : AppRoutes.home,
        builder: (context, state) => QuizIntroScreen(category: state.extra! as QuizCategory),
      ),
      GoRoute(
        path: AppRoutes.quiz,
        redirect: (context, state) => state.extra is QuizCategory ? null : AppRoutes.home,
        builder: (context, state) => QuizScreen(category: state.extra! as QuizCategory),
      ),
      GoRoute(
        path: AppRoutes.result,
        redirect: (context, state) => state.extra is QuizResult ? null : AppRoutes.home,
        builder: (context, state) => ResultScreen(result: state.extra! as QuizResult),
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
        path: AppRoutes.fullLeaderboard,
        builder: (context, state) => const FullLeaderboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.playerDetail,
        redirect: (context, state) => state.extra is LeaderboardEntry ? null : AppRoutes.leaderboard,
        builder: (context, state) => PlayerDetailScreen(entry: state.extra! as LeaderboardEntry),
      ),
      GoRoute(
        path: AppRoutes.rankFilter,
        builder: (context, state) => RankFilterScreen(currentFilter: state.extra as String?),
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
        builder: (context, state) => const DuelInviteScreen(),
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
        builder: (context, state) =>
            LanguageScreen(currentLanguage: (state.extra as String?) ?? AppStrings.languageEnglish),
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
    ],
  );
});
