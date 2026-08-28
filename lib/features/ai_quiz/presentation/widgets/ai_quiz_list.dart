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
    final double subLine = (scaler.scale(11) * 1.2).ceilToDouble();
    // Back to just 2 text lines (title + question-count/source) now that
    // the visibility control moved out to its own trailing button, sized
    // against the fixed 40px icon block instead of stacking under the text.
    final double textBlock = titleLine + subLine;
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
                  ],
                ),
              ),
              AppSpacing.sm.hGap,
              // Icon-only, right where the old delete button used to be —
              // a real (40x40) tap target, not a cramped inline chip.
              // Tooltip carries the word (Nobody/Friends/Everyone) for
              // anyone who taps-and-holds or uses a screen reader.
              _VisibilityButton(
                icon: _visibilityIcon(),
                tooltip: _visibilityLabel(context),
                enabled: !selectionMode,
                onTap: onVisibilityTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VisibilityButton extends StatelessWidget {
  const _VisibilityButton({
    required this.icon,
    required this.tooltip,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Same solid-coral-fill + white-icon language as the app's actual
    // primary buttons (e.g. "+ Create a new AI quiz") and the row's own
    // coral sparkle-icon square right next to this one — not a pale
    // tint, which read as off-brand/washed-out.
    return Tooltip(
      message: tooltip,
      child: Material(
        color: enabled ? context.colors.coral : context.colors.line,
        borderRadius: BorderRadius.circular(11),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(11),
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, color: enabled ? Colors.white : context.colors.muted, size: 18),
          ),
        ),
      ),
    );
  }
}
