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
///
/// [selectionMode] bo'lsa, qatorga bosish o'ynashni emas, tanlashni
/// almashtiradi ("O'chirish" endi shu yerda emas — ekranning app bar
/// qismida "tanlash" rejimi orqali amalga oshiriladi).
class AiQuizList extends StatelessWidget {
  const AiQuizList({
    required this.quizzes,
    required this.onTap,
    required this.onVisibilityTap,
    this.selectionMode = false,
    this.selectedIds = const {},
    super.key,
  });

  final List<AiQuiz> quizzes;
  final ValueChanged<AiQuiz> onTap;
  final ValueChanged<AiQuiz> onVisibilityTap;
  final bool selectionMode;
  final Set<int> selectedIds;

  double _rowExtent(BuildContext context) {
    final TextScaler scaler = MediaQuery.textScalerOf(context);
    final double titleLine = (scaler.scale(14) * 1.4).ceilToDouble();
    final double countLine = (scaler.scale(11) * 1.2).ceilToDouble();
    // The visibility button has its own explicit padding independent of
    // scaled text (12/11px content + 8px vertical padding), plus a couple
    // of px of slack — a real device rendered 2px taller than this
    // block's old plain-text estimate, so this is deliberately generous
    // rather than shaving it as tight as possible again.
    final double visibilityButton = (scaler.scale(12) * 1.2).ceilToDouble() + 10;
    final double textBlock = titleLine + countLine + AppSpacing.xxs + visibilityButton + AppSpacing.xxs;
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
          onVisibilityTap: () => onVisibilityTap(quiz),
          selectionMode: selectionMode,
          selected: selectedIds.contains(quiz.id),
        );
      },
    );
  }
}

class _AiQuizRow extends StatelessWidget {
  const _AiQuizRow({
    required this.quiz,
    required this.onTap,
    required this.onVisibilityTap,
    required this.selectionMode,
    required this.selected,
  });

  final AiQuiz quiz;
  final VoidCallback onTap;
  final VoidCallback onVisibilityTap;
  final bool selectionMode;
  final bool selected;

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
            border: Border.all(color: selected ? context.colors.coral : context.colors.line, width: selected ? 1.5 : 1),
            boxShadow: context.colors.shadowSm,
          ),
          child: Row(
            children: [
              if (selectionMode) ...[
                Icon(
                  selected ? TablerIcons.checkbox : TablerIcons.square,
                  color: selected ? context.colors.coral : context.colors.muted,
                  size: 22,
                ),
                AppSpacing.sm.hGap,
              ] else ...[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: context.colors.coral, borderRadius: AppRadius.smAll),
                  alignment: Alignment.center,
                  child: const Icon(TablerIcons.sparkle, color: Colors.white, size: 18),
                ),
                AppSpacing.sm.hGap,
              ],
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
                    Row(
                      children: [
                        Text(
                          context.t.common.questionCount(count: quiz.questionCount),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textStyles.labelSmall?.copyWith(color: context.colors.muted),
                        ),
                        Text(
                          '  •  ',
                          style: context.textStyles.labelSmall?.copyWith(color: context.colors.muted),
                        ),
                        Text(
                          _sourceLabel(context),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textStyles.labelSmall?.copyWith(color: context.colors.muted),
                        ),
                      ],
                    ),
                    AppSpacing.xxs.vGap,
                    // A proper button (not a bare inline chip) — bigger,
                    // clearly tappable, and no longer sharing the row with
                    // a delete icon (that moved to the app bar's "select"
                    // mode, freeing up this whole width for it).
                    IgnorePointer(
                      ignoring: selectionMode,
                      child: Opacity(
                        opacity: selectionMode ? 0.5 : 1,
                        child: Material(
                          color: context.colors.line,
                          borderRadius: AppRadius.smAll,
                          child: InkWell(
                            onTap: onVisibilityTap,
                            borderRadius: AppRadius.smAll,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(_visibilityIcon(), size: 14, color: context.colors.coral),
                                  4.hGap,
                                  Text(
                                    _visibilityLabel(context),
                                    style: context.textStyles.labelSmall?.copyWith(
                                      color: context.colors.coral,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  2.hGap,
                                  Icon(TablerIcons.chevronDown, size: 12, color: context.colors.coral),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
