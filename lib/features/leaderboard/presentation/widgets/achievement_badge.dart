import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../models/achievement.dart';

class AchievementBadge extends StatelessWidget {
  const AchievementBadge({
    required this.achievement,
    required this.unlocked,
    super.key,
  });

  final Achievement achievement;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final Color iconColor = unlocked ? Colors.white : context.colors.muted;
    return Container(
      decoration: BoxDecoration(
        color: context.colors.card,
        border: Border.all(color: context.colors.line),
        borderRadius: AppRadius.mdAll,
        boxShadow: context.colors.shadowSm,
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: unlocked ? null : context.colors.line,
              gradient: unlocked
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [context.colors.coral, context.colors.coralDeep],
                    )
                  : null,
            ),
            alignment: Alignment.center,
            child: Icon(achievement.icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            achievement.label(context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: context.textStyles.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: unlocked ? context.colors.ink : context.colors.muted,
            ),
          ),
        ],
      ),
    );
  }
}
