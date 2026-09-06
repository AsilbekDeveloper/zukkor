import 'package:flutter/material.dart';

import '../models/achievement.dart';

class AchievementBadge extends StatelessWidget {
  const AchievementBadge({required this.achievement, required this.unlocked, super.key});

  final Achievement achievement;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final Color iconColor = unlocked ? Colors.white : const Color(0xFFB5ACA5);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
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
              gradient: unlocked
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFFF7A50), Color(0xFFE05D30)],
                    )
                  : const LinearGradient(colors: [Color(0xFFEEEEEE), Color(0xFFDDDDDD)]),
            ),
            alignment: Alignment.center,
            child: Icon(achievement.icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            achievement.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: unlocked ? null : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
