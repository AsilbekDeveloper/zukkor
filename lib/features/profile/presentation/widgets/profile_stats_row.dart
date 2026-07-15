import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../i18n/strings.g.dart';

/// 3-stat strip (total games, win rate, longest streak) — mirrors the
/// prototype's `.stats` (same container as Home's [StatsStrip], but
/// without a progress bar on any of the values).
class ProfileStatsRow extends StatelessWidget {
  const ProfileStatsRow({
    required this.totalGames,
    required this.winRatePercent,
    required this.longestStreak,
    super.key,
  });

  final int totalGames;
  final int winRatePercent;
  final int longestStreak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: context.colors.line),
        boxShadow: context.colors.shadowSm,
      ),
      child: Row(
        children: [
          Expanded(child: _Stat(value: '$totalGames', label: context.t.profile.statTotalGames)),
          _divider(context),
          Expanded(child: _Stat(value: '$winRatePercent%', label: context.t.profile.statWinRate)),
          _divider(context),
          Expanded(child: _Stat(value: '$longestStreak', label: context.t.profile.statLongestStreak)),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) {
    return Container(width: 1, margin: const EdgeInsets.symmetric(vertical: AppSpacing.xxs), color: context.colors.line);
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: context.textStyles.titleMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w700)),
        Text(label, style: context.textStyles.labelSmall, textAlign: TextAlign.center),
      ],
    );
  }
}
