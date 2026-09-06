import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/pressable_scale.dart';
import '../../../../i18n/strings.g.dart';
import '../../../leaderboard/presentation/models/leaderboard_entry.dart';

class RivalCard extends StatelessWidget {
  const RivalCard({
    required this.rival,
    required this.xpGap,
    required this.onTap,
    super.key,
  });

  final LeaderboardEntry rival;
  final int xpGap;
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
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: AppRadius.mdAll,
              border: Border.all(color: context.colors.line),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: rival.avatarColor.resolve(context),
                  child: Text(
                    rival.initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                AppSpacing.sm.hGap,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.t.home.rivalAheadMessage(
                          name: rival.name,
                          xp: formatThousands(xpGap),
                        ),
                        style: context.textStyles.bodySmall?.copyWith(
                          color: context.colors.ink,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        context.t.home.rivalCatchUpSubtitle,
                        style: context.textStyles.labelSmall?.copyWith(
                          color: context.colors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  TablerIcons.chevronRight,
                  color: context.colors.muted,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
