import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/models/avatar_color_option.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../i18n/strings.g.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/controllers/current_user_controller.dart';
import '../../../leaderboard/domain/entities/player_stats.dart';
import '../../../leaderboard/presentation/controllers/my_stats_controller.dart';
import '../widgets/level_card.dart';
import '../widgets/profile_banner.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_name_block.dart';
import '../widgets/profile_stats_row.dart';
import '../widgets/settings_list.dart';

/// The Profile tab — mirrors the prototype's `view-profile`: header +
/// settings shortcut, coral banner with an overlapping avatar, name
/// block, level ring card, a 3-stat strip, and a settings shortcut list.
///
/// Name/username/avatar initials come from the real backend user
/// (`GET /auth/me`, fetched on open). Level/XP/game stats are real too,
/// from `GET /leaderboard/{my_user_id}` via [MyStatsController] (shared
/// with [HomeScreen]).
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Loaded once per session, not on every visit — [EditProfileScreen]
    // already reloads [currentUserControllerProvider] directly after a
    // successful save, and finishing a game invalidates
    // [myStatsControllerProvider], so both stay correct without a
    // refetch here every time this screen mounts.
    if (ref.read(currentUserControllerProvider).data == null || ref.read(myStatsControllerProvider).data == null) {
      Future.microtask(() async {
        await ref.read(currentUserControllerProvider.notifier).load();
        final String? userId = ref.read(currentUserControllerProvider).data?.id;
        if (userId != null) await ref.read(myStatsControllerProvider.notifier).load(userId);
      });
    }
  }

  void _comingSoon(BuildContext context) => context.showSnack(context.t.bottomNav.comingSoon);

  /// Level ring + 3-stat strip.
  List<Widget> _progressSection(BuildContext context) {
    final PlayerStats? stats = ref.watch(myStatsControllerProvider).data;
    return [
      LevelCard(
        level: stats?.level ?? 0,
        levelTitle: stats?.levelTitle ?? '',
        currentXp: stats?.totalXp ?? 0,
        targetXp: stats?.nextLevelXp ?? 0,
        levelStartXp: stats?.currentLevelXp ?? 0,
      ),
      AppSpacing.sm.vGap,
      ProfileStatsRow(
        totalGames: stats?.gamesPlayed ?? 0,
        winRatePercent: stats?.winRatePercent ?? 0,
        longestStreak: stats?.longestStreak ?? 0,
      ),
    ];
  }

  /// Settings shortcuts.
  Widget _settingsSection(BuildContext context) {
    return SettingsList(
      rows: [
        SettingsRowData(
          icon: TablerIcons.history,
          label: context.t.profile.gameHistory,
          onTap: () => context.push(AppRoutes.history),
        ),
        SettingsRowData(
          icon: TablerIcons.settings,
          label: context.t.profile.settingsAndHelp,
          onTap: () => context.push(AppRoutes.settings),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double hPad = context.screenHPad;
    final User? user = ref.watch(currentUserControllerProvider).data;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(hPad, AppSpacing.xs, hPad, AppSpacing.lg),
          children: [
            ProfileHeader(onSettingsTap: () => context.push(AppRoutes.settings)),
            AppSpacing.lg.vGap,
            ProfileBanner(
              initials: user.initials,
              avatarColor: AvatarColorOption.fromApiValue(user?.avatarColor),
              avatarImagePath: user?.avatarImagePath,
              onEditTap: () => context.push(AppRoutes.editProfile),
            ),
            ProfileNameBlock(name: user.displayName, username: user?.username ?? ''),
            AppSpacing.lg.vGap,
            ..._progressSection(context),
            AppSpacing.lg.vGap,
            _settingsSection(context),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        current: AppTab.profile,
        onTabTap: (tab) => switch (tab) {
          AppTab.home => context.go(AppRoutes.home),
          AppTab.leaderboard => context.push(AppRoutes.leaderboard),
          AppTab.friends => context.push(AppRoutes.friends),
          AppTab.profile => _comingSoon(context),
        },
        onPlayTap: () => context.push(AppRoutes.myAiQuizzes),
      ),
    );
  }
}
