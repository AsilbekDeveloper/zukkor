import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../domain/entities/player_stats.dart';

enum AchievementCriteria { streak, wins, xp, rank }

class Achievement {
  const Achievement({
    required this.criteria,
    required this.threshold,
    required this.label,
    required this.icon,
  });

  final AchievementCriteria criteria;
  final int threshold;
  final String label;
  final IconData icon;

  bool isUnlocked(PlayerStats stats) => switch (criteria) {
        AchievementCriteria.streak => stats.longestStreak >= threshold,
        AchievementCriteria.wins => stats.totalWins >= threshold,
        AchievementCriteria.xp => stats.totalXp >= threshold,
        // pastroq raqam = yaxshiroq o'rin, shuning uchun <=.
        AchievementCriteria.rank => stats.bestRankAchieved <= threshold,
      };
}

/// To'liq ro'yxat - yangi bosqich qo'shish uchun shu yerga bitta qator
/// yetarli, boshqa hech qayerda o'zgartirish kerak emas.
const List<Achievement> allAchievements = [
  Achievement(criteria: AchievementCriteria.streak, threshold: 3, label: '3 kunlik olov', icon: TablerIcons.flame),
  Achievement(criteria: AchievementCriteria.streak, threshold: 7, label: '7 kunlik olov', icon: TablerIcons.flame),
  Achievement(criteria: AchievementCriteria.streak, threshold: 30, label: '30 kunlik olov', icon: TablerIcons.flame),
  Achievement(criteria: AchievementCriteria.wins, threshold: 10, label: '10-g\'alaba', icon: TablerIcons.swords),
  Achievement(criteria: AchievementCriteria.wins, threshold: 50, label: '50-g\'alaba', icon: TablerIcons.swords),
  Achievement(criteria: AchievementCriteria.wins, threshold: 100, label: '100-g\'alaba', icon: TablerIcons.swords),
  Achievement(criteria: AchievementCriteria.xp, threshold: 100, label: '100 XP', icon: TablerIcons.star),
  Achievement(criteria: AchievementCriteria.xp, threshold: 500, label: '500 XP', icon: TablerIcons.star),
  Achievement(criteria: AchievementCriteria.xp, threshold: 1000, label: '1000 XP', icon: TablerIcons.star),
  Achievement(criteria: AchievementCriteria.rank, threshold: 10, label: 'Top 10', icon: TablerIcons.medal),
  Achievement(criteria: AchievementCriteria.rank, threshold: 3, label: 'Top 3', icon: TablerIcons.medal),
  Achievement(criteria: AchievementCriteria.rank, threshold: 1, label: '#1 o\'rin', icon: TablerIcons.medal),
];
