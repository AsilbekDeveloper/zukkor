import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';

/// Dark card holding the category tag + question text — mirrors the
/// prototype's `.question-card`.
class QuestionCard extends StatelessWidget {
  const QuestionCard({
    required this.categoryName,
    required this.question,
    super.key,
  });

  final String categoryName;
  final String question;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl + AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: context.colors.surfaceDark,
        borderRadius: AppRadius.lgAll,
        boxShadow: context.colors.shadowMd,
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm,
              vertical: AppSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: context.colors.coral,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              categoryName,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          AppSpacing.sm.vGap,
          Text(
            question,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 17,
              fontWeight: FontWeight.w600,
              height: 1.4,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
