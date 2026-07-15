import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../i18n/strings.g.dart';

/// "Leaderboard / Who's the best?" title + filter icon button — mirrors
/// the prototype's leaderboard `.header`. [greeting] reflects the active
/// category filter (plain "Leaderboard", or "Leaderboard · Math").
class LeaderboardHeader extends StatelessWidget {
  const LeaderboardHeader({required this.greeting, required this.onFilterTap, super.key});

  final String greeting;
  final VoidCallback onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.bodySmall,
              ),
              Text(
                context.t.leaderboard.title,
                style: context.textStyles.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Material(
          color: context.colors.card,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.smAll,
            side: BorderSide(color: context.colors.line),
          ),
          child: InkWell(
            onTap: onFilterTap,
            borderRadius: AppRadius.smAll,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(
                TablerIcons.adjustmentsHorizontal,
                color: context.colors.ink,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
