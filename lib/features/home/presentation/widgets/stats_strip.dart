import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/animated_counter.dart';
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
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.xxs),
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
              icon: TablerIcons.star,
              iconColor: context.colors.coral,
              targetValue: totalXp,
              formatter: formatThousands,
              label: context.t.home.totalXpLabel,
            ),
          ),
          _divider(context),
          Expanded(
            child: _Stat(
              icon: TablerIcons.trophy,
              iconColor: context.colors.teal,
              targetValue: rank,
              formatter: (r) => '#$r',
              label: context.t.home.rankLabel,
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) {
    return Container(width: 1, margin: const EdgeInsets.symmetric(vertical: AppSpacing.xxs), color: context.colors.line);
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.iconColor,
    required this.targetValue,
    required this.formatter,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final int targetValue;
  final String Function(int) formatter;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 15, color: iconColor),
        const SizedBox(width: 6),
        AnimatedCounter(
          value: targetValue,
          formatter: formatter,
          style: context.textStyles.titleMedium?.copyWith(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 4),
        Flexible(child: Text(label, style: context.textStyles.labelSmall, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
