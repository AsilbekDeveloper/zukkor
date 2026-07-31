import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/models/avatar_color_option.dart';
import '../../../../core/notifications/push_notification_service.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../i18n/strings.g.dart';
import '../../../auth/data/repositories/auth_repository_impl.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/controllers/current_user_controller.dart';
import '../../../duel/presentation/controllers/duel_controller.dart';
import '../../../friends/presentation/controllers/friends_controller.dart';
import '../../../leaderboard/domain/entities/player_stats.dart';
import '../../../leaderboard/presentation/controllers/my_stats_controller.dart';
import '../../../lobby/presentation/controllers/lobby_controller.dart';
import '../../../lobby/presentation/screens/lobby_screen.dart';
import '../../../notifications/presentation/controllers/notifications_controller.dart';
import '../../../quiz/presentation/controllers/categories_controller.dart';
import '../../../quiz/presentation/models/quiz_category.dart';
import '../../../quiz/presentation/models/quiz_launch_args.dart';
import '../widgets/category_grid.dart';
import '../widgets/duel_hero_card.dart';
import '../widgets/friends_card.dart';
import '../widgets/home_header.dart';
import '../widgets/multiplayer_row.dart';
import '../widgets/stats_strip.dart';

/// The main screen — mirrors the prototype's `view-home` 1:1: greeting
/// header, duel hero card, stats strip, create/join room buttons,
/// category grid, and an online-friends shortcut.
///
/// CURRENT STATE: name/avatar, the unread-notifications dot, and the
/// stats strip (XP/rank/level) + streak are all real, from
/// `GET /leaderboard/{my_user_id}` via [MyStatsController] (shared with
/// [ProfileScreen]). "Start a duel" and the friends-online shortcut both
/// push the Duel (choose a friend) screen;
/// "See all", the center Play tab, and tapping a category all go to the
/// Categories/quiz flow; "Create a room" and "Join with a code" go to
/// the Lobby flow; the bell opens Notifications, which marks everything
/// read on open — the dot here reflects that live, shared state (see
/// [NotificationsController]), not a local flag. Every other action
/// without a real destination yet (the Home tab itself) goes through
/// [_comingSoon].
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Categories/friends/profile/stats only change via this device's own
    // actions (each of those flows refreshes its own provider directly),
    // so re-fetching them on every Home visit is wasted traffic — loaded
    // once per session and reused. Notifications stay unconditional: a
    // new one can arrive from the backend at any time with no other
    // signal telling this screen to refresh, so the unread dot would go
    // stale for the rest of the session otherwise.
    if (ref.read(categoriesControllerProvider).data == null) {
      Future.microtask(() => ref.read(categoriesControllerProvider.notifier).load());
    }
    if (ref.read(friendsControllerProvider).data == null) {
      Future.microtask(() => ref.read(friendsControllerProvider.notifier).load());
    }
    if (ref.read(currentUserControllerProvider).data == null || ref.read(myStatsControllerProvider).data == null) {
      Future.microtask(() async {
        await ref.read(currentUserControllerProvider.notifier).load();
        final String? userId = ref.read(currentUserControllerProvider).data?.id;
        if (userId != null) await ref.read(myStatsControllerProvider.notifier).load(userId);
      });
    }
    Future.microtask(() => ref.read(duelControllerProvider.notifier).connect());
    Future.microtask(() => ref.read(lobbyControllerProvider.notifier).connect());
    Future.microtask(() => ref.read(notificationsControllerProvider.notifier).load());
    Future.microtask(_syncPushToken);
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
  }

  void _comingSoon(BuildContext context) => context.showSnack(context.t.bottomNav.comingSoon);

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
        context.push(AppRoutes.duelInvite, extra: invite);
      }
    });

    final double hPad = context.screenHPad;
    final User? user = ref.watch(currentUserControllerProvider).data;
    final bool hasUnreadNotifications =
        ref.watch(notificationsControllerProvider).data?.any((n) => !n.isRead) ?? false;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(hPad, AppSpacing.xs, hPad, AppSpacing.lg),
          children: [
            HomeHeader(
              name: user.displayName,
              initials: user.initials,
              avatarColor: AvatarColorOption.fromApiValue(user?.avatarColor),
              avatarImagePath: user?.avatarImagePath,
              hasUnreadNotifications: hasUnreadNotifications,
              onNotificationsTap: () => _openNotifications(context),
            ),
            AppSpacing.lg.vGap,
            ..._playSection(context),
            AppSpacing.xl.vGap,
            ..._discoverSection(context),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        current: AppTab.home,
        onTabTap: (tab) => switch (tab) {
          AppTab.leaderboard => context.push(AppRoutes.leaderboard),
          AppTab.friends => context.push(AppRoutes.friends),
          AppTab.profile => context.push(AppRoutes.profile),
          AppTab.home => _comingSoon(context),
        },
        onPlayTap: () => context.push(AppRoutes.categories),
      ),
    );
  }

  /// Hero card + stats + create/join room buttons.
  List<Widget> _playSection(BuildContext context) {
    final PlayerStats? stats = ref.watch(myStatsControllerProvider).data;
    final int levelSpan = (stats == null) ? 0 : stats.nextLevelXp - stats.currentLevelXp;
    final double xpProgress = (stats == null || levelSpan == 0)
        ? 0
        : ((stats.totalXp - stats.currentLevelXp) / levelSpan).clamp(0, 1).toDouble();

    return [
      DuelHeroCard(streakDays: stats?.currentStreak ?? 0, onStartDuel: () => context.push(AppRoutes.duel)),
      AppSpacing.md.vGap,
      StatsStrip(
        totalXp: stats?.totalXp ?? 0,
        xpProgress: xpProgress,
        rank: stats?.rank ?? 0,
        level: stats?.level ?? 0,
      ),
      AppSpacing.md.vGap,
      MultiplayerRow(
        onCreateRoom: () => context.push(AppRoutes.lobby, extra: LobbyRole.host),
        onJoinWithCode: () => context.push(AppRoutes.joinCode),
      ),
    ];
  }

  /// Categories grid + friends-online shortcut.
  List<Widget> _discoverSection(BuildContext context) {
    final List<QuizCategory> categories = ref
            .watch(categoriesControllerProvider)
            .data
            ?.map(QuizCategory.fromEntity)
            .take(6)
            .toList() ??
        const [];

    return [
      CategoryGrid(
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
      AppSpacing.md.vGap,
      FriendsCard(
        friendCount: ref.watch(friendsControllerProvider).data?.length ?? 0,
        onTap: () => context.push(AppRoutes.duel),
      ),
    ];
  }
}
