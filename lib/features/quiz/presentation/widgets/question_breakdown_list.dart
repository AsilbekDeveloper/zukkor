import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/entities/question_breakdown_item.dart';

/// The "which questions were right/wrong" list shown on every game's
/// result screen (Solo/Duel/Lobby) — a title + one row per question,
/// numbered in play order with a check/x badge for correctness. Renders
/// nothing if [items] is empty (e.g. an older cached result screen state
/// from before the backend sent this).
class QuestionBreakdownList extends StatelessWidget {
  const QuestionBreakdownList({required this.items, super.key});

  final List<QuestionBreakdownItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(context.t.result.breakdownTitle, style: context.textStyles.labelSmall),
        AppSpacing.sm.vGap,
        for (int i = 0; i < items.length; i++) ...[
          _BreakdownRow(item: items[i]),
          if (i < items.length - 1) AppSpacing.xs.vGap,
        ],
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({required this.item});

  final QuestionBreakdownItem item;

  @override
  Widget build(BuildContext context) {
    final Color color = item.isCorrect ? context.colors.green : context.colors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: AppRadius.smAll,
        border: Border.all(color: context.colors.line),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Text(
              '${item.order}',
              textAlign: TextAlign.center,
              style: context.textStyles.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: context.colors.muted,
              ),
            ),
          ),
          AppSpacing.sm.hGap,
          Expanded(
            child: Text(
              item.questionText,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.ink,
              ),
            ),
          ),
          AppSpacing.sm.hGap,
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Icon(
              item.isCorrect ? TablerIcons.check : TablerIcons.x,
              size: 14,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
