import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../i18n/strings.g.dart';
import '../../domain/entities/player_stats.dart';

enum AchievementCriteria { streak, wins, xp, rank }

class Achievement {
  const Achievement({
    required this.criteria,
    required this.threshold,
    required this.icon,
  });

  final AchievementCriteria criteria;
  final int threshold;
  final IconData icon;

  bool isUnlocked(PlayerStats stats) => switch (criteria) {
    AchievementCriteria.streak => stats.longestStreak >= threshold,
    AchievementCriteria.wins => stats.totalWins >= threshold,
    AchievementCriteria.xp => stats.totalXp >= threshold,
    // pastroq raqam = yaxshiroq o'rin, shuning uchun <=.
    AchievementCriteria.rank => stats.bestRankAchieved <= threshold,
  };

  // Needs [context] (not a stored field) so the label re-translates when
  // the locale changes — same reasoning as [LeaderboardScopeLabel.label].
  // #1 o'rin is special-cased rather than routed through "Top $count" —
  // "Top 1" reads oddly in every locale this app ships.
  String label(BuildContext context) => switch (criteria) {
    AchievementCriteria.streak => context.t.achievements.streakBadge(
      count: threshold,
    ),
    AchievementCriteria.wins => context.t.achievements.winsBadge(
      count: threshold,
    ),
    AchievementCriteria.xp => context.t.achievements.xpBadge(xp: threshold),
    AchievementCriteria.rank =>
      threshold == 1
          ? context.t.achievements.firstRankBadge
          : context.t.achievements.topRankBadge(count: threshold),
  };
}

/// To'liq ro'yxat - yangi bosqich qo'shish uchun shu yerga bitta qator
/// yetarli, boshqa hech qayerda o'zgartirish kerak emas.
const List<Achievement> allAchievements = [
  Achievement(
    criteria: AchievementCriteria.streak,
    threshold: 3,
    icon: TablerIcons.flame,
  ),
  Achievement(
    criteria: AchievementCriteria.streak,
    threshold: 7,
    icon: TablerIcons.flame,
  ),
  Achievement(
    criteria: AchievementCriteria.streak,
    threshold: 30,
    icon: TablerIcons.flame,
  ),
  Achievement(
    criteria: AchievementCriteria.wins,
    threshold: 10,
    icon: TablerIcons.swords,
  ),
  Achievement(
    criteria: AchievementCriteria.wins,
    threshold: 50,
    icon: TablerIcons.swords,
  ),
  Achievement(
    criteria: AchievementCriteria.wins,
    threshold: 100,
    icon: TablerIcons.swords,
  ),
  Achievement(
    criteria: AchievementCriteria.xp,
    threshold: 100,
    icon: TablerIcons.star,
  ),
  Achievement(
    criteria: AchievementCriteria.xp,
    threshold: 500,
    icon: TablerIcons.star,
  ),
  Achievement(
    criteria: AchievementCriteria.xp,
    threshold: 1000,
    icon: TablerIcons.star,
  ),
  Achievement(
    criteria: AchievementCriteria.rank,
    threshold: 10,
    icon: TablerIcons.medal,
  ),
  Achievement(
    criteria: AchievementCriteria.rank,
    threshold: 3,
    icon: TablerIcons.medal,
  ),
  Achievement(
    criteria: AchievementCriteria.rank,
    threshold: 1,
    icon: TablerIcons.medal,
  ),
];
