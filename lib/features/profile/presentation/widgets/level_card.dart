import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../i18n/strings.g.dart';

/// Level ring + "Level N · Title" / XP-to-next-level text — mirrors the
/// prototype's `.level-card` / `.mini-ring`.
class LevelCard extends StatelessWidget {
  const LevelCard({
    required this.level,
    required this.levelTitle,
    required this.currentXp,
    required this.targetXp,
    required this.levelStartXp,
    super.key,
  });

  final int level;
  final String levelTitle;
  final int currentXp;
  final int targetXp;

  /// Absolute XP threshold where [level] itself started — the ring shows
  /// progress *within this level*, not `currentXp / targetXp` (which
  /// treats every level as starting from 0 XP and inflates the ring for
  /// anyone above level 1).
  final int levelStartXp;

  static const double _ringSize = 56;

  @override
  Widget build(BuildContext context) {
    final int levelSpan = targetXp - levelStartXp;
    final double progress = levelSpan == 0 ? 0 : ((currentXp - levelStartXp) / levelSpan).clamp(0, 1);

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
                  context.t.profile.levelWithTitle(level: level, title: levelTitle),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: context.colors.ink,
                  ),
                ),
                Text(
                  context.t.profile.xpProgressLabel(
                    current: formatThousands(currentXp),
                    target: formatThousands(targetXp),
                    remaining: targetXp - currentXp,
                  ),
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
