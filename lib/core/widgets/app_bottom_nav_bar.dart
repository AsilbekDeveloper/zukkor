import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../constants/app_strings.dart';
import '../extensions/context_x.dart';
import '../theme/app_spacing.dart';

/// Which tab is active. [home] and [leaderboard] have real screens behind
/// them — [friends] and [profile] plus the center "play" button still go
/// through [onTabTap]/[onPlayTap] as coming-soon stubs until built.
enum AppTab { home, leaderboard, friends, profile }

/// Bottom navigation bar shared by every top-level screen — mirrors the
/// prototype's `.tabbar` (5 items, elevated center "play" button).
class AppBottomNavBar extends StatelessWidget {
  const AppBottomNavBar({
    super.key,
    required this.current,
    required this.onTabTap,
    required this.onPlayTap,
  });

  final AppTab current;

  /// Called when the user taps a tab other than [current]. The screen
  /// decides whether that means navigating (Home, Leaderboard) or showing
  /// a coming-soon message (Friends, Profile).
  final ValueChanged<AppTab> onTabTap;

  /// Called when the user taps the elevated center "play" button —
  /// mirrors the prototype's `data-nav="categories"`.
  final VoidCallback onPlayTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: context.colors.card,
        border: Border(top: BorderSide(color: context.colors.line)),
        boxShadow: context.colors.shadowSm,
      ),
      child: SafeArea(
        top: false,
        // Scaffold sizes `bottomNavigationBar` by its own intrinsic height,
        // and a bare `Center` expands to fill *any* bounded height it's
        // offered, which made the bar claim the whole screen height.
        // `Align(heightFactor: 1)` shrink-wraps to the row's natural
        // height instead.
        child: Align(
          heightFactor: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.sm,
            ),
            // Tab items are `Expanded` (not natural-width in a
            // spaceBetween Row) so 4 labels + the center button always
            // fit on narrow phones instead of overflowing.
            child: Row(
              children: [
                Expanded(
                  child: _TabItem(
                    icon: TablerIcons.home,
                    label: AppStrings.navHome,
                    isActive: current == AppTab.home,
                    onTap: current == AppTab.home ? null : () => onTabTap(AppTab.home),
                  ),
                ),
                Expanded(
                  child: _TabItem(
                    icon: TablerIcons.trophy,
                    label: AppStrings.navLeaderboard,
                    isActive: current == AppTab.leaderboard,
                    onTap: current == AppTab.leaderboard ? null : () => onTabTap(AppTab.leaderboard),
                  ),
                ),
                _CenterPlayButton(onTap: onPlayTap),
                Expanded(
                  child: _TabItem(
                    icon: TablerIcons.users,
                    label: AppStrings.navFriends,
                    isActive: current == AppTab.friends,
                    onTap: current == AppTab.friends ? null : () => onTabTap(AppTab.friends),
                  ),
                ),
                Expanded(
                  child: _TabItem(
                    icon: TablerIcons.user,
                    label: AppStrings.navProfile,
                    isActive: current == AppTab.profile,
                    onTap: current == AppTab.profile ? null : () => onTabTap(AppTab.profile),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = isActive ? context.colors.coralDeep : context.colors.muted;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs, horizontal: AppSpacing.xs),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.labelSmall?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _CenterPlayButton extends StatelessWidget {
  const _CenterPlayButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -22),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [context.colors.coral, context.colors.coralDeep],
          ),
          borderRadius: AppRadius.mdAll,
          boxShadow: context.colors.shadowCoral,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            borderRadius: AppRadius.mdAll,
            child: const SizedBox(
              width: 56,
              height: 56,
              child: Icon(TablerIcons.playerPlay, color: Colors.white, size: 28),
            ),
          ),
        ),
      ),
    );
  }
}
