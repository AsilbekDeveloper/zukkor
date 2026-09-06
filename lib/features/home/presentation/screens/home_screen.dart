import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/models/avatar_color_option.dart';
import '../../../../core/notifications/push_notification_service.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/state/game_status_provider.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/inline_retry_row.dart';
import '../../../../i18n/strings.g.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/controllers/current_user_controller.dart';
import '../../../duel/presentation/controllers/duel_controller.dart';
import '../../../history/presentation/controllers/weekly_activity_controller.dart';
import '../../../leaderboard/data/repositories/leaderboard_repository_impl.dart';
import '../../../leaderboard/domain/entities/leaderboard_data.dart';
import '../../../leaderboard/domain/entities/leaderboard_scope.dart';
import '../../../leaderboard/domain/entities/player_stats.dart';
import '../../../leaderboard/presentation/controllers/my_stats_controller.dart';
import '../../../leaderboard/presentation/models/leaderboard_entry.dart';
import '../../../lobby/presentation/controllers/lobby_controller.dart';
import '../../../lobby/presentation/screens/lobby_screen.dart';
import '../../../notifications/presentation/controllers/notifications_controller.dart';
import '../../../quiz/presentation/controllers/categories_controller.dart';
import '../../../quiz/presentation/models/quiz_category.dart';
import '../../../quiz/presentation/models/quiz_launch_args.dart';
import '../widgets/category_scroll_row.dart';
import '../widgets/duel_hero_card.dart';
import '../widgets/home_header.dart';
import '../widgets/multiplayer_row.dart';
import '../widgets/rival_card.dart';
import '../widgets/stats_strip.dart';

/// The main screen — mirrors the prototype's `view-home` 1:1: greeting
/// header, duel hero card, stats strip, create/join room buttons,
/// and category row.
///
/// CURRENT STATE: name/avatar, the unread-notifications dot, and the
/// stats strip (XP/rank/level) + streak are all real, from
/// `GET /leaderboard/{my_user_id}` via [MyStatsController] (shared with
/// [ProfileScreen]). "Start a duel" pushes the Duel (choose a friend)
/// screen; "See all", the center Play tab, and tapping a category all go
/// to the Categories/quiz flow; "Create a room" and "Join with a code"
/// go to the Lobby flow; the bell opens Notifications, which marks
/// everything read on open — the dot here reflects that live, shared
/// state (see [NotificationsController]), not a local flag. Every other
/// action without a real destination yet (the Home tab itself) goes
/// through [_comingSoon].
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Categories/profile/stats only change via this device's own actions
    // (each of those flows refreshes its own provider directly) or an
    // explicit pull-to-refresh (see [_reloadEssentialData]), so
    // re-fetching them on every Home visit is wasted traffic — loaded
    // once per session and reused. If any of the three failed or never
    // finished loading (e.g. this device's very first Home visit, or a
    // network hiccup during it), retry all three together here; on
    // failure again, [_playSection]/[_discoverSection] show an
    // [InlineRetryRow] in place of just the broken piece - previously a
    // failed one-time load here left the screen silently stuck showing
    // 0/0 stats with no way to recover. Notifications stay separately
    // unconditional: a new one can arrive from the backend at any time
    // with no other signal telling this screen to refresh, so the unread
    // dot would go stale otherwise.
    final bool needsInitialLoad = ref.read(currentUserControllerProvider).data == null ||
        ref.read(myStatsControllerProvider).data == null ||
        ref.read(categoriesControllerProvider).data == null;
    if (needsInitialLoad) {
      Future.microtask(_reloadEssentialData);
    }
    Future.microtask(() => ref.read(duelControllerProvider.notifier).connect());
    Future.microtask(() => ref.read(lobbyControllerProvider.notifier).connect());
    Future.microtask(() => ref.read(notificationsControllerProvider.notifier).load());
    Future.microtask(() => ref.read(weeklyActivityControllerProvider.notifier).load());
    Future.microtask(_syncPushToken);
  }

  /// Categories + current user + my stats, reloaded together - used both
  /// for the initial load (if it never finished or failed) and for pull-
  /// to-refresh / the error-state retry button.
  Future<void> _reloadEssentialData() async {
    await Future.wait([
      ref.read(currentUserControllerProvider.notifier).load(),
      ref.read(categoriesControllerProvider.notifier).load(),
      ref.read(weeklyActivityControllerProvider.notifier).load(),
    ]);
    final String? userId = ref.read(currentUserControllerProvider).data?.id;
    if (userId != null) {
      await ref.read(myStatsControllerProvider.notifier).load(userId);
    }
  }

  /// Ruxsat so'raydi, FCM token'ni backendga bog'laydi va token
  /// almashtirilgan holatlarni (masalan qayta o'rnatilgandan keyin) ham
  /// kuzatib boradi — har safar Home ochilganda emas, bir marta.
  Future<void> _syncPushToken() async {
    final PushNotificationService service = ref.read(pushNotificationServiceProvider);
    final String? token = await service.requestTokenOrNull();
    if (!mounted) return;
    if (token != null) {
      unawaited(ref.read(registerPushTokenUseCaseProvider).call(token));
    }
    service.listenTokenRefresh(
      (newToken) => ref.read(registerPushTokenUseCaseProvider).call(newToken),
    );
    service.listenForeground();
  }

  void _openNotifications(BuildContext context) => context.push(AppRoutes.notifications);

  @override
  Widget build(BuildContext context) {
    // Fires regardless of which screen is on top, as long as Home stays
    // mounted underneath (go_router's `push` doesn't dispose it) — a
    // real incoming challenge opens Duel Invite from wherever the user
    // is in the app.
    ref.listen(duelControllerProvider, (previous, next) {
      if (next.incomingInvite != null && next.incomingInvite != previous?.incomingInvite) {
        final invite = next.incomingInvite!;
        ref.read(duelControllerProvider.notifier).clearIncoming();

        if (ref.read(isInActiveGameProvider)) {
          // O'yin paytida xalaqit bermaslik uchun shunchaki xabarnoma chiqaramiz.
          context.showSnack(
            context.t.notifications.duelChallenge(name: invite.fromUser.displayName),
            action: SnackBarAction(
              label: context.t.common.ok, // "Ko'rish" deb o'zgartirish ham mumkin
              onPressed: () => context.push(AppRoutes.duelInvite, extra: invite),
            ),
          );
        } else {
          context.push(AppRoutes.duelInvite, extra: invite);
        }
      }
    });

    final double hPad = context.screenHPad;
    final User? user = ref.watch(currentUserControllerProvider).data;
    final bool hasUnreadNotifications =
        ref.watch(notificationsControllerProvider).data?.any((n) => !n.isRead) ?? false;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _reloadEssentialData,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.fromLTRB(hPad, AppSpacing.xs, hPad, AppSpacing.lg),
            children: [
              FadeSlideIn(
                child: HomeHeader(
                  initials: user.initials,
                  avatarColor: AvatarColorOption.fromApiValue(user?.avatarColor),
                  avatarImagePath: user?.avatarImagePath,
                  hasUnreadNotifications: hasUnreadNotifications,
                  onNotificationsTap: () => _openNotifications(context),
                  coinBalance: user?.coinBalance ?? 0,
                  diamondBalance: user?.diamondBalance ?? 0,
                ),
              ),
              AppSpacing.lg.vGap,
              for (final Widget section in _playSection(context))
                FadeSlideIn(delay: const Duration(milliseconds: 60), child: section),
              AppSpacing.xxs.vGap,
              for (final Widget section in _discoverSection(context))
                FadeSlideIn(delay: const Duration(milliseconds: 120), child: section),
              ...[
                AppSpacing.md.vGap,
                for (final Widget section in _enrichmentSection(context))
                  FadeSlideIn(delay: const Duration(milliseconds: 180), child: section),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Hero card + stats + create/join room buttons. The stats strip shows
  /// an [InlineRetryRow] instead of silently falling back to 0/0 when its
  /// own load failed — the rest of the screen (including this section's
  /// own hero card/buttons) stays fully usable either way.
  List<Widget> _playSection(BuildContext context) {
    final myStatsState = ref.watch(myStatsControllerProvider);
    final weeklyActivityState = ref.watch(weeklyActivityControllerProvider);
    final PlayerStats? stats = myStatsState.data;

    return [
      DuelHeroCard(
        streakDays: stats?.currentStreak ?? 0,
        weeklyActivity: weeklyActivityState.data?.days,
        onStartDuel: () => context.push(AppRoutes.duel),
      ),
      AppSpacing.md.vGap,
      myStatsState.hasError
          ? InlineRetryRow(onRetry: _reloadMyStats)
          : StatsStrip(totalXp: stats?.totalXp ?? 0, rank: stats?.rank ?? 0),
      AppSpacing.md.vGap,
      MultiplayerRow(
        onCreateRoom: () => context.push(AppRoutes.lobby, extra: LobbyRole.host),
        onJoinWithCode: () => context.push(AppRoutes.joinCode),
      ),
    ];
  }

  Future<void> _reloadMyStats() async {
    final String? userId = ref.read(currentUserControllerProvider).data?.id;
    if (userId != null) {
      await ref.read(myStatsControllerProvider.notifier).load(userId);
    }
  }

  /// Categories, horizontally scrollable — shows an [InlineRetryRow]
  /// instead of silently going empty when categories failed to load.
  /// Manual-quiz-creation/question-submission shortcuts used to live here
  /// too but moved to the "Mening quizlarim" hub (reached via the bottom
  /// nav's center button) - Discover moved there too at first, then came
  /// back (2026-09-06): unlike those two (pure content-creation, rarely
  /// used), Discover leads straight to playing someone else's quiz, so it
  /// belongs with the rest of Home's "play now" actions - and removing
  /// all three left a large, awkward empty gap above the bottom nav bar
  /// once there were only 3 short "play now" blocks left.
  List<Widget> _discoverSection(BuildContext context) {
    final categoriesState = ref.watch(categoriesControllerProvider);
    final List<QuizCategory> categories =
        categoriesState.data?.map(QuizCategory.fromEntity).take(3).toList() ?? const [];

    return [
      categoriesState.hasError
          ? InlineRetryRow(onRetry: () => ref.read(categoriesControllerProvider.notifier).load())
          : CategoryScrollRow(
        categories: categories,
        onSeeAll: () => context.push(AppRoutes.categories),
        onCategoryTap: (category) => context.push(
          AppRoutes.quizSetup,
          extra: (
            category: category,
            onStart: (BuildContext ctx, WidgetRef ref, int count) => ctx.push(
              AppRoutes.quizIntro,
              extra: QuizLaunchArgs(category: category, questionCount: count),
            ),
          ),
        ),
      ),
    ];
  }

  /// New section with "Closest Rival" (nearest friend in XP) and a
  /// Discover shortcut. "Continue Playing" and an achievements preview
  /// used to live here too - both pulled per user feedback 2026-09-06
  /// (continue-playing didn't earn its place; achievements is deferred to
  /// a later version) - see [[home_dashboard_achievements_2026_09_06]].
  /// The underlying widgets/models/screen/route for both are left intact,
  /// just unreferenced from Home, so they're easy to bring back later.
  List<Widget> _enrichmentSection(BuildContext context) {
    final friendsLeaderboard = ref.watch(_homeFriendsLeaderboardProvider);

    final List<Widget> widgets = [];

    if (friendsLeaderboard.hasValue) {
      final data = friendsLeaderboard.value!;
      final meXp = data.me.totalXp;
      final ahead = data.entries.where((e) => !e.isMe && e.totalXp > meXp).toList()
        ..sort((a, b) => a.totalXp.compareTo(b.totalXp));

      if (ahead.isNotEmpty) {
        final rival = ahead.first;
        widgets.addAll([
          RivalCard(
            rival: LeaderboardEntry.fromEntity(rival),
            xpGap: rival.totalXp - meXp,
            onTap: () => context.push(AppRoutes.playerDetail, extra: {'userId': rival.userId}),
          ),
          AppSpacing.sm.vGap,
        ]);
      }
    }

    widgets.addAll([
      _DiscoverFeedCard(onTap: () => context.push(AppRoutes.discover)),
    ]);

    return widgets;
  }
}

final _homeFriendsLeaderboardProvider = FutureProvider.autoDispose<LeaderboardData>((ref) {
  return ref.watch(getLeaderboardUseCaseProvider).call(scope: LeaderboardScope.friends, limit: 50);
});

class _DiscoverFeedCard extends StatelessWidget {
  const _DiscoverFeedCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.card,
      borderRadius: AppRadius.mdAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
          decoration: BoxDecoration(
            borderRadius: AppRadius.mdAll,
            border: Border.all(color: context.colors.line),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: context.colors.teal,
                  borderRadius: AppRadius.smAll,
                ),
                alignment: Alignment.center,
                child: const Icon(TablerIcons.world, color: Colors.white, size: 20),
              ),
              AppSpacing.sm.hGap,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.t.discover.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      context.t.discover.homeCardSubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.labelSmall?.copyWith(color: context.colors.muted),
                    ),
                  ],
                ),
              ),
              const Icon(TablerIcons.chevronRight, color: Colors.grey, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
