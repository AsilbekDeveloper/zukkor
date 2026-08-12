import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/entities/ai_quiz.dart';

/// AI orqali yaratilgan quizlar ro'yxati — [FriendList] bilan bir xil
/// responsiv grid naqshi (bitta telefonda, 2 ustun kengroq ekranlarda).
class AiQuizList extends StatelessWidget {
  const AiQuizList({required this.quizzes, required this.onTap, required this.onDelete, super.key});

  final List<AiQuiz> quizzes;
  final ValueChanged<AiQuiz> onTap;
  final ValueChanged<AiQuiz> onDelete;

  double _rowExtent(BuildContext context) {
    final TextScaler scaler = MediaQuery.textScalerOf(context);
    final double textBlock =
        (scaler.scale(14) * 1.4).ceilToDouble() + (scaler.scale(11) * 1.2).ceilToDouble() + 2;
    const double iconBlock = 40;
    const double verticalPadding = AppSpacing.sm * 2;
    return (textBlock > iconBlock ? textBlock : iconBlock) + verticalPadding;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: quizzes.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 480,
        mainAxisSpacing: AppSpacing.xs,
        crossAxisSpacing: AppSpacing.xs,
        mainAxisExtent: _rowExtent(context),
      ),
      itemBuilder: (context, index) {
        final AiQuiz quiz = quizzes[index];
        return _AiQuizRow(quiz: quiz, onTap: () => onTap(quiz), onDelete: () => onDelete(quiz));
      },
    );
  }
}

class _AiQuizRow extends StatelessWidget {
  const _AiQuizRow({required this.quiz, required this.onTap, required this.onDelete});

  final AiQuiz quiz;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.card,
      borderRadius: AppRadius.smAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smAll,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: AppRadius.smAll,
            border: Border.all(color: context.colors.line),
            boxShadow: context.colors.shadowSm,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: context.colors.coral, borderRadius: AppRadius.smAll),
                alignment: Alignment.center,
                child: const Icon(TablerIcons.sparkle, color: Colors.white, size: 18),
              ),
              AppSpacing.sm.hGap,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      quiz.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: context.colors.ink,
                      ),
                    ),
                    Text(
                      context.t.common.questionCount(count: quiz.questionCount),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.labelSmall?.copyWith(color: context.colors.muted),
                    ),
                  ],
                ),
              ),
              AppSpacing.sm.hGap,
              _DeleteButton(onTap: onDelete),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeleteButton extends StatelessWidget {
  const _DeleteButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(11),
        side: BorderSide(color: context.colors.line),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(
            TablerIcons.trash,
            color: context.colors.coralDeep,
            size: 16,
            semanticLabel: context.t.common.delete,
          ),
        ),
      ),
    );
  }
}
