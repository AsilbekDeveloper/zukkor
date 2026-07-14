import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../quiz/presentation/models/quiz_category.dart';

/// A small pill showing which category a duel is being played in —
/// mirrors the prototype's `.duel-category-chip` (used by both Duel
/// Waiting and Duel Invite).
class DuelCategoryChip extends StatelessWidget {
  const DuelCategoryChip({required this.category, super.key});

  final QuizCategory category;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(AppSpacing.xxs + 2, AppSpacing.xxs + 2, AppSpacing.md, AppSpacing.xxs + 2),
      decoration: BoxDecoration(
        color: context.colors.card,
        border: Border.all(color: context.colors.line),
        borderRadius: BorderRadius.circular(999),
        boxShadow: context.colors.shadowSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(color: category.color(context), borderRadius: BorderRadius.circular(10)),
            alignment: Alignment.center,
            child: Icon(category.icon, color: Colors.white, size: 15),
          ),
          AppSpacing.xs.hGap,
          Text(
            category.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
