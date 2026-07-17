import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../i18n/strings.g.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/controllers/current_user_controller.dart';
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
/// (`GET /auth/me`, fetched on open). Level/XP/game stats are still
/// placeholder — the backend doesn't expose that data yet.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Har safar ekran ochilganda yangilanadi — masalan Profilni tahrirlash
    // ekranidan qaytgach ma'lumot eskirmasin.
    Future.microtask(() => ref.read(currentUserControllerProvider.notifier).load());
  }

  void _comingSoon(BuildContext context) => context.showSnack(context.t.bottomNav.comingSoon);

  String _initials(User? user) {
    final String first = (user?.firstName?.isNotEmpty ?? false) ? user!.firstName![0] : '';
    final String last = (user?.lastName?.isNotEmpty ?? false) ? user!.lastName![0] : '';
    final String combined = '$first$last'.toUpperCase();
    return combined.isNotEmpty ? combined : '?';
  }

  String _displayName(User? user) {
    final String name = [user?.firstName, user?.lastName]
        .where((part) => part != null && part.isNotEmpty)
        .join(' ');
    return name.isNotEmpty ? name : (user?.username ?? '');
  }

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
    final User? user = ref.watch(currentUserControllerProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(hPad, AppSpacing.xs, hPad, AppSpacing.lg),
          children: [
            ProfileHeader(onSettingsTap: () => context.push(AppRoutes.settings)),
            AppSpacing.lg.vGap,
            ProfileBanner(
              initials: _initials(user),
              onEditTap: () => context.push(AppRoutes.editProfile),
            ),
            ProfileNameBlock(name: _displayName(user), username: user?.username ?? ''),
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
