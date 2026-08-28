import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/entities/ai_quiz.dart';

/// AI orqali yoki qo'lda yaratilgan quizlar ro'yxati — [FriendList] bilan
/// bir xil responsiv grid naqshi (bitta telefonda, 2 ustun kengroq
/// ekranlarda).
class AiQuizList extends StatelessWidget {
  const AiQuizList({
    required this.quizzes,
    required this.onTap,
    required this.onDelete,
    required this.onVisibilityTap,
    super.key,
  });

  final List<AiQuiz> quizzes;
  final ValueChanged<AiQuiz> onTap;
  final ValueChanged<AiQuiz> onDelete;
  final ValueChanged<AiQuiz> onVisibilityTap;

  double _rowExtent(BuildContext context) {
    final TextScaler scaler = MediaQuery.textScalerOf(context);
    final double textBlock = (scaler.scale(14) * 1.4).ceilToDouble() +
        (scaler.scale(11) * 1.2).ceilToDouble() +
        (scaler.scale(11) * 1.2).ceilToDouble() +
        AppSpacing.xxs +
        2;
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
        return _AiQuizRow(
          quiz: quiz,
          onTap: () => onTap(quiz),
          onDelete: () => onDelete(quiz),
          onVisibilityTap: () => onVisibilityTap(quiz),
        );
      },
    );
  }
}

class _AiQuizRow extends StatelessWidget {
  const _AiQuizRow({
    required this.quiz,
    required this.onTap,
    required this.onDelete,
    required this.onVisibilityTap,
  });

  final AiQuiz quiz;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onVisibilityTap;

  String _sourceLabel(BuildContext context) =>
      quiz.source == 'manual' ? context.t.aiQuiz.sourceManual : context.t.aiQuiz.sourceAi;

  IconData _visibilityIcon() {
    switch (quiz.visibility) {
      case 'public':
        return TablerIcons.world;
      case 'friends':
        return TablerIcons.users;
      default:
        return TablerIcons.lock;
    }
  }

  String _visibilityLabel(BuildContext context) {
    switch (quiz.visibility) {
      case 'public':
        return context.t.aiQuiz.visibilityPublic;
      case 'friends':
        return context.t.aiQuiz.visibilityFriends;
      default:
        return context.t.aiQuiz.visibilityPrivate;
    }
  }

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
                    AppSpacing.xxs.vGap,
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _sourceLabel(context),
                          style: context.textStyles.labelSmall?.copyWith(color: context.colors.muted),
                        ),
                        Text(
                          '  •  ',
                          style: context.textStyles.labelSmall?.copyWith(color: context.colors.muted),
                        ),
                        // A subtle chip (not just plain muted text like the
                        // "Manual"/"AI" label beside it) so it's visually
                        // obvious this one is tappable — otherwise it reads
                        // as inert metadata and the visibility control is
                        // easy to miss entirely (reported by the user).
                        InkWell(
                          onTap: onVisibilityTap,
                          borderRadius: AppRadius.smAll,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: context.colors.line,
                              borderRadius: AppRadius.smAll,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_visibilityIcon(), size: 12, color: context.colors.coral),
                                4.hGap,
                                Text(
                                  _visibilityLabel(context),
                                  style: context.textStyles.labelSmall?.copyWith(
                                    color: context.colors.coral,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                2.hGap,
                                Icon(TablerIcons.chevronDown, size: 10, color: context.colors.coral),
                              ],
                            ),
                          ),
                        ),
                      ],
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
