import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../i18n/strings.g.dart';
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
/// CURRENT STATE: presentation only, placeholder user data (matches the
/// mock user used on Home: 2 140/3 000 XP, level 12). Every action here
/// now opens a real screen — the settings gear, the banner's edit
/// pencil, and "Game history"/"Settings & help".
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _comingSoon(BuildContext context) => context.showSnack(context.t.bottomNav.comingSoon);

  /// Level ring + 3-stat strip.
  List<Widget> _progressSection(BuildContext context) {
    return [
      const LevelCard(level: 12, levelTitle: 'Scholar', currentXp: 2140, targetXp: 3000),
      AppSpacing.sm.vGap,
      const ProfileStatsRow(totalGames: 184, winRatePercent: 68, longestStreak: 12),
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

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(hPad, AppSpacing.xs, hPad, AppSpacing.lg),
          children: [
            ProfileHeader(onSettingsTap: () => context.push(AppRoutes.settings)),
            AppSpacing.lg.vGap,
            ProfileBanner(initials: 'AZ', onEditTap: () => context.push(AppRoutes.editProfile)),
            const ProfileNameBlock(name: 'Aziz Karimov', username: 'aziz_karimov'),
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
        onPlayTap: () => context.push(AppRoutes.categories),
      ),
    );
  }
}
