import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/animated_counter.dart';
import '../../../../core/widgets/pressable_scale.dart';
import '../../../../i18n/strings.g.dart';

/// Two tappable cards — friends count (→ Friends tab) and public-quiz
/// count (→ "Mening quizlarim") — added per user request (2026-09-12) so
/// the owner's own profile shows the same kind of social/content info
/// [PlayerDetailScreen] already shows for OTHER users. Kept visually
/// distinct from the (non-tappable) [ProfileStatsRow] above it via a
/// chevron, matching how every other "leads somewhere" card in the app
/// signals that (e.g. the Discover card on Home).
class ProfileSocialRow extends StatelessWidget {
  const ProfileSocialRow({
    required this.friendsCount,
    required this.publicQuizCount,
    required this.onFriendsTap,
    required this.onPublicQuizzesTap,
    super.key,
  });

  final int friendsCount;
  final int publicQuizCount;
  final VoidCallback onFriendsTap;
  final VoidCallback onPublicQuizzesTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SocialChip(
            icon: TablerIcons.users,
            color: context.colors.blue,
            value: friendsCount,
            label: context.t.profile.friendsChipLabel,
            onTap: onFriendsTap,
          ),
        ),
        AppSpacing.sm.hGap,
        Expanded(
          child: _SocialChip(
            icon: TablerIcons.sparkle,
            color: context.colors.coral,
            value: publicQuizCount,
            label: context.t.profile.publicQuizzesChipLabel,
            onTap: onPublicQuizzesTap,
          ),
        ),
      ],
    );
  }
}

class _SocialChip extends StatelessWidget {
  const _SocialChip({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final int value;
  final String label;
  final VoidCallback onTap;

  void _handleTap() {
    HapticFeedback.lightImpact();
    onTap();
  }

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      child: Material(
        color: context.colors.card,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          onTap: _handleTap,
          borderRadius: AppRadius.mdAll,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: AppRadius.mdAll,
              border: Border.all(color: context.colors.line),
              boxShadow: context.colors.shadowSm,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: AppRadius.smAll,
                  ),
                  alignment: Alignment.center,
                  child: Icon(icon, color: Colors.white, size: 18),
                ),
                AppSpacing.sm.hGap,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedCounter(
                        value: value,
                        formatter: (v) => '$v',
                        style: context.textStyles.titleMedium?.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.labelSmall,
                      ),
                    ],
                  ),
                ),
                Icon(
                  TablerIcons.chevronRight,
                  color: context.colors.muted,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
