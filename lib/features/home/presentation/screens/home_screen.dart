import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../i18n/strings.g.dart';
import '../../../lobby/presentation/screens/lobby_screen.dart';
import '../../../quiz/presentation/models/quiz_category.dart';
import '../widgets/category_grid.dart';
import '../widgets/duel_hero_card.dart';
import '../widgets/friends_online_card.dart';
import '../widgets/home_header.dart';
import '../widgets/multiplayer_row.dart';
import '../widgets/stats_strip.dart';

/// The main screen — mirrors the prototype's `view-home` 1:1: greeting
/// header, duel hero card, stats strip, create/join room buttons,
/// category grid, and an online-friends shortcut.
///
/// CURRENT STATE: presentation only. All the data below (name, XP, rank,
/// categories, friend count) is placeholder — it starts coming from the
/// `quiz`/`accounts` data layers once those are rebuilt. "Start a duel"
/// and the friends-online shortcut both push the Duel (choose a friend)
/// screen; "See all", the center Play tab, and tapping a category all go
/// to the Categories/quiz flow; "Create a room" and "Join with a code"
/// go to the Lobby flow; the bell opens Notifications and clears its own
/// unread dot on return, matching the prototype's `notif-bell-btn`
/// handler. Every other action without a real destination yet (the Home
/// tab itself) goes through [_comingSoon].
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasUnreadNotifications = true;

  void _comingSoon(BuildContext context) => context.showSnack(context.t.bottomNav.comingSoon);

  Future<void> _openNotifications(BuildContext context) async {
    await context.push(AppRoutes.notifications);
    if (!mounted) return;
    setState(() => _hasUnreadNotifications = false);
  }

  @override
  Widget build(BuildContext context) {
    final double hPad = context.screenHPad;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(hPad, AppSpacing.xs, hPad, AppSpacing.lg),
          children: [
            HomeHeader(
              name: 'Aziz Karimov',
              initials: 'AK',
              hasUnreadNotifications: _hasUnreadNotifications,
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
    return [
      DuelHeroCard(streakDays: 5, onStartDuel: () => context.push(AppRoutes.duel)),
      AppSpacing.md.vGap,
      const StatsStrip(totalXp: 2140, xpProgress: 0.71, rank: 312, level: 12),
      AppSpacing.md.vGap,
      MultiplayerRow(
        onCreateRoom: () => context.push(AppRoutes.lobby, extra: LobbyRole.host),
        onJoinWithCode: () => context.push(AppRoutes.joinCode),
      ),
    ];
  }

  /// Categories grid + friends-online shortcut.
  List<Widget> _discoverSection(BuildContext context) {
    return [
      CategoryGrid(
        categories: QuizCategory.sample,
        onSeeAll: () => context.push(AppRoutes.categories),
        onCategoryTap: (category) => context.push(AppRoutes.quizIntro, extra: category),
      ),
      AppSpacing.md.vGap,
      FriendsOnlineCard(onlineCount: 3, onTap: () => context.push(AppRoutes.duel)),
    ];
  }
}
