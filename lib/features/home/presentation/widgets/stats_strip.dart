import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';

/// The 3-stat strip (Total XP with progress bar, Rank, Level) — mirrors
/// the prototype's `.stats`.
class StatsStrip extends StatelessWidget {
  const StatsStrip({
    required this.totalXp,
    required this.xpProgress,
    required this.rank,
    required this.level,
    super.key,
  });

  final int totalXp;

  /// 0.0–1.0 progress toward the next level, drives the small bar under
  /// the XP number.
  final double xpProgress;
  final int rank;
  final int level;

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
          Expanded(
            child: _Stat(
              value: formatThousands(totalXp),
              label: AppStrings.totalXpLabel,
              progress: xpProgress,
            ),
          ),
          _divider(context),
          Expanded(child: _Stat(value: '#$rank', label: AppStrings.rankLabel)),
          _divider(context),
          Expanded(child: _Stat(value: '$level', label: AppStrings.levelLabel)),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) {
    return Container(width: 1, margin: const EdgeInsets.symmetric(vertical: AppSpacing.xxs), color: context.colors.line);
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.progress});

  final String value;
  final String label;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: context.textStyles.titleMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w700),
        ),
        Text(label, style: context.textStyles.labelSmall),
        if (progress != null) ...[
          AppSpacing.xxs.vGap,
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              width: 64,
              height: 5,
              child: LinearProgressIndicator(
                value: progress!.clamp(0, 1),
                backgroundColor: context.colors.line,
                valueColor: AlwaysStoppedAnimation(context.colors.coralDeep),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
