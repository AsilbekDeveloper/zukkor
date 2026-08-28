import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/ai_quiz/presentation/screens/create_manual_quiz_screen.dart';
import '../../features/ai_quiz/presentation/screens/discover_screen.dart';
import '../../features/ai_quiz/presentation/screens/generate_ai_quiz_screen.dart';
import '../../features/ai_quiz/presentation/screens/my_ai_quizzes_screen.dart';
import '../../features/ai_quiz/presentation/screens/user_quizzes_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/reset_password_screen.dart';
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
import '../../features/leaderboard/presentation/screens/full_leaderboard_screen.dart';
import '../../features/leaderboard/presentation/screens/leaderboard_screen.dart';
import '../../features/lobby/presentation/controllers/lobby_controller.dart';
import '../../features/lobby/presentation/models/lobby_result_args.dart';
import '../../features/lobby/presentation/screens/join_code_screen.dart';
import '../../features/lobby/presentation/screens/lobby_game_screen.dart';
import '../../features/lobby/presentation/screens/lobby_result_screen.dart';
import '../../features/lobby/presentation/screens/lobby_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/player_detail/presentation/models/player_detail_args.dart';
import '../../features/player_detail/presentation/screens/player_detail_screen.dart';
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
import 'app_routes.dart';

/// [QuizSetupScreen]'s route `extra` — the category just picked, plus a
/// closure deciding what "start" means for whichever flow got it there
/// (solo, a duel challenge, or a lobby game). Built as a record instead
/// of a class so QuizSetupScreen doesn't need to import Friends'/Lobby's
/// types just to carry this - only this router (which is allowed to
/// know about every feature) ever constructs one.
typedef QuizSetupExtra = ({QuizCategory category, void Function(BuildContext, WidgetRef, int) onStart});

CategoryPickedCallback _duelCategoryPicked(FriendEntry opponent) => (context, ref, category) => context.push(
      AppRoutes.quizSetup,
      extra: (
        category: category,
        onStart: (BuildContext ctx, WidgetRef ref, int count) => ctx.push(
          AppRoutes.duelWaiting,
          extra: DuelMatch(opponent: opponent, category: category, questionCount: count),
        ),
      ),
    );

CategoryPickedCallback _lobbyCategoryPicked(String roomId) => (context, ref, category) => context.push(
      AppRoutes.quizSetup,
      extra: (
        category: category,
        onStart: (BuildContext ctx, WidgetRef ref, int count) {
          ref.read(lobbyControllerProvider.notifier).startGame(category.id, questionCount: count);
          ctx.pop();
        },
      ),
    );

/// Marshrutlar. Ilova [SplashScreen]dan boshlanadi: u saqlangan token'ni
/// tekshirib, tegishli ekranga yo'naltiradi — token bo'lsa Home, aks holda
/// (Introduction ko'rilmagan bo'lsa) Introduction, yoki Login. Ekranlar
/// orasida to'g'ridan-to'g'ri `context.go(...)` bilan o'tiladi; sessiya
/// majburan tugaganda [ZukkorApp] Login'ga qaytaradi.
final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
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
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPasswordScreen,
        builder: (context, state) => ResetPasswordScreen(email: state.extra! as String),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      // `extra` carries the pending duel opponent (a FriendEntry) or a
      // pending Lobby room id (a String) when reached from those flows;
      // absent (or a deep link) means the plain solo picker. Building the
      // actual per-flow tap behavior here — rather than inside
      // CategoriesScreen itself — keeps Quiz from needing to know about
      // Friends' or Lobby's types at all; this router is the one place
      // allowed to know about every feature.
      GoRoute(
        path: AppRoutes.categories,
        builder: (context, state) {
          final Object? extra = state.extra;
          if (extra is FriendEntry) {
            return CategoriesScreen(
              onCategoryPicked: _duelCategoryPicked(extra),
              onAiQuizEntryTap: () => context.push(AppRoutes.myAiQuizzes, extra: extra),
              onOpponentQuizEntryTap: extra.id == null
                  ? null
                  : () => context.push(
                        AppRoutes.userQuizzes,
                        extra: (userId: extra.id!, displayName: extra.name, onPicked: _duelCategoryPicked(extra)),
                      ),
            );
          }
          if (extra is String) {
            return CategoriesScreen(
              onCategoryPicked: _lobbyCategoryPicked(extra),
              onAiQuizEntryTap: () => context.push(AppRoutes.myAiQuizzes, extra: extra),
            );
          }
          return const CategoriesScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.myAiQuizzes,
        builder: (context, state) {
          final Object? extra = state.extra;
          if (extra is FriendEntry) {
            return MyAiQuizzesScreen(onCategoryPicked: _duelCategoryPicked(extra));
          }
          if (extra is String) {
            return MyAiQuizzesScreen(onCategoryPicked: _lobbyCategoryPicked(extra));
          }
          return const MyAiQuizzesScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.userQuizzes,
        builder: (context, state) {
          final extra = state.extra as ({String userId, String displayName, CategoryPickedCallback? onPicked});
          return UserQuizzesScreen(
            userId: extra.userId,
            displayName: extra.displayName,
            onCategoryPicked: extra.onPicked,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.generateAiQuiz,
        builder: (context, state) => const GenerateAiQuizScreen(),
      ),
      GoRoute(
        path: AppRoutes.discover,
        builder: (context, state) => const DiscoverScreen(),
      ),
      GoRoute(
        path: AppRoutes.createManualQuiz,
        builder: (context, state) => const CreateManualQuizScreen(),
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
        redirect: (context, state) => state.extra is QuizSetupExtra ? null : AppRoutes.home,
        builder: (context, state) {
          final QuizSetupExtra extra = state.extra! as QuizSetupExtra;
          return QuizSetupScreen(category: extra.category, onStart: extra.onStart);
        },
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
      // `extra` is a plain `Map` (userId + optional relation/requestId/
      // requestSent) rather than a typed args object — this is the one
      // place [PlayerDetailArgs] gets constructed, so none of its
      // callers (Leaderboard, Friends, Add Friend, Friend Requests) need
      // to import the player_detail feature just to navigate here.
      GoRoute(
        path: AppRoutes.playerDetail,
        redirect: (context, state) =>
            state.extra is Map && (state.extra! as Map)['userId'] is String ? null : AppRoutes.leaderboard,
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
