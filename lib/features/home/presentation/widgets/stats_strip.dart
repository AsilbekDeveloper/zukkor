import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../i18n/strings.g.dart';

/// The 2-stat strip (Total XP, Rank) — mirrors the prototype's `.stats`
/// (originally had a third "Level" stat and an XP progress bar toward the
/// next level; both were level-derived and removed with the level concept).
class StatsStrip extends StatelessWidget {
  const StatsStrip({
    required this.totalXp,
    required this.rank,
    super.key,
  });

  final int totalXp;
  final int rank;

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
          Expanded(child: _Stat(value: formatThousands(totalXp), label: context.t.home.totalXpLabel)),
          _divider(context),
          Expanded(child: _Stat(value: '#$rank', label: context.t.home.rankLabel)),
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
        Text(
          value,
          style: context.textStyles.titleMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        Text(label, style: context.textStyles.labelSmall),
      ],
    );
  }
}
