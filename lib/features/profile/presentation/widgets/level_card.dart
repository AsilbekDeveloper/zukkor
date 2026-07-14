import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';

/// Level ring + "Level N · Title" / XP-to-next-level text — mirrors the
/// prototype's `.level-card` / `.mini-ring`.
class LevelCard extends StatelessWidget {
  const LevelCard({
    required this.level,
    required this.levelTitle,
    required this.currentXp,
    required this.targetXp,
    super.key,
  });

  final int level;
  final String levelTitle;
  final int currentXp;
  final int targetXp;

  static const double _ringSize = 56;

  @override
  Widget build(BuildContext context) {
    final double progress = targetXp == 0 ? 0 : (currentXp / targetXp).clamp(0, 1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: context.colors.line),
        boxShadow: context.colors.shadowSm,
      ),
      child: Row(
        children: [
          SizedBox(
            width: _ringSize,
            height: _ringSize,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: _ringSize,
                  height: _ringSize,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 10,
                    strokeCap: StrokeCap.round,
                    backgroundColor: context.colors.line,
                    valueColor: AlwaysStoppedAnimation(context.colors.coralDeep),
                  ),
                ),
                Text(
                  '$level',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: context.colors.coralDeep,
                  ),
                ),
              ],
            ),
          ),
          AppSpacing.sm.hGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppStrings.levelWithTitle(level, levelTitle),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: context.colors.ink,
                  ),
                ),
                Text(
                  AppStrings.xpProgressLabel(currentXp, targetXp, targetXp - currentXp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.labelSmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
