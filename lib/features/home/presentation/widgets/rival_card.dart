import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../leaderboard/presentation/models/leaderboard_entry.dart';

class RivalCard extends StatelessWidget {
  const RivalCard({required this.rival, required this.xpGap, required this.onTap, super.key});

  final LeaderboardEntry rival;
  final int xpGap;
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
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(borderRadius: AppRadius.mdAll, border: Border.all(color: context.colors.line)),
          child: Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: rival.avatarColor.resolve(context),
                child: Text(rival.initials, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
              ),
              AppSpacing.sm.hGap,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: context.textStyles.bodySmall?.copyWith(color: context.colors.ink),
                        children: [
                          TextSpan(text: '${rival.name} ', style: const TextStyle(fontWeight: FontWeight.w700)),
                          const TextSpan(text: 'sizdan '),
                          TextSpan(text: '${formatThousands(xpGap)} XP ', style: TextStyle(fontWeight: FontWeight.w700, color: context.colors.blue)),
                          const TextSpan(text: 'oldinda'),
                        ],
                      ),
                    ),
                    Text('Quvib yetish uchun bitta duel yetarli!',
                        style: context.textStyles.labelSmall?.copyWith(color: context.colors.muted)),
                  ],
                ),
              ),
              Icon(TablerIcons.chevronRight, color: context.colors.muted, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
