import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/pressable_scale.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/entities/manual_question_input.dart';
import '../../domain/entities/quiz_question.dart';

/// One question being edited — used by both [CreateManualQuizScreen] (all
/// drafts are brand new, [id] always null) and `EditManualQuizScreen`
/// (drafts can be pre-filled from an existing [QuizQuestion], [id] set).
class DraftQuestion {
  DraftQuestion({
    String questionText = '',
    List<String>? options,
    this.correctIndex = 0,
    this.id,
  }) : questionController = TextEditingController(text: questionText),
       optionControllers = List.generate(
         4,
         (i) => TextEditingController(
           text: options != null && i < options.length ? options[i] : '',
         ),
       );

  factory DraftQuestion.fromExisting(QuizQuestion question) => DraftQuestion(
    id: question.id,
    questionText: question.questionText,
    options: question.options,
    correctIndex: question.correctOptionIndex,
  );

  /// Null for a question that only exists in this draft so far (never
  /// saved) - non-null once it's the server's copy of an existing
  /// question. `EditManualQuizScreen` uses this to decide whether saving
  /// should POST (create) or PATCH (update).
  int? id;

  final TextEditingController questionController;
  final List<TextEditingController> optionControllers;
  int correctIndex;

  /// `EditManualQuizScreen` only - true while THIS card's own save/add/
  /// delete request is in flight, so its controls disable independently
  /// of every other card instead of freezing the whole screen.
  bool isBusy = false;

  bool get isFilledIn =>
      questionController.text.trim().isNotEmpty &&
      optionControllers.every((c) => c.text.trim().isNotEmpty);

  ManualQuestionInput toInput() => ManualQuestionInput(
    questionText: questionController.text.trim(),
    options: optionControllers.map((c) => c.text.trim()).toList(),
    correctOptionIndex: correctIndex,
  );

  void dispose() {
    questionController.dispose();
    for (final controller in optionControllers) {
      controller.dispose();
    }
  }
}

/// The actual name+4-options+correct-answer-picker editor card, shared by
/// [CreateManualQuizScreen] and `EditManualQuizScreen` — the only
/// difference between the two flows is what happens on submit/remove,
/// which the caller supplies via [onRemove]/[onChanged] and an optional
/// [footer] (e.g. a per-question "Saqlash" button on the edit screen).
class DraftQuestionCard extends StatelessWidget {
  const DraftQuestionCard({
    required this.label,
    required this.draft,
    required this.canRemove,
    required this.onRemove,
    required this.onChanged,
    this.enabled = true,
    this.footer,
    super.key,
  });

  final String label;
  final DraftQuestion draft;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback onChanged;
  final bool enabled;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: context.colors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: context.textStyles.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.colors.ink2,
                  ),
                ),
              ),
              if (canRemove)
                PressableScale(
                  enabled: enabled,
                  child: InkWell(
                    onTap: enabled
                        ? () {
                            HapticFeedback.lightImpact();
                            onRemove();
                          }
                        : null,
                    borderRadius: AppRadius.smAll,
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        TablerIcons.trash,
                        size: 18,
                        color: enabled
                            ? context.colors.coralDeep
                            : context.colors.muted,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          AppSpacing.xs.vGap,
          AppTextField(
            label: context.t.aiQuiz.manualQuestionTextLabel,
            controller: draft.questionController,
            enabled: enabled,
          ),
          AppSpacing.sm.vGap,
          for (int i = 0; i < 4; i++) ...[
            Row(
              children: [
                PressableScale(
                  enabled: enabled,
                  child: InkWell(
                    onTap: enabled
                        ? () {
                            HapticFeedback.lightImpact();
                            draft.correctIndex = i;
                            onChanged();
                          }
                        : null,
                    borderRadius: BorderRadius.circular(999),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        draft.correctIndex == i
                            ? TablerIcons.circleCheckFilled
                            : TablerIcons.circle,
                        size: 22,
                        color: draft.correctIndex == i
                            ? context.colors.coral
                            : context.colors.muted,
                      ),
                    ),
                  ),
                ),
                AppSpacing.xs.hGap,
                Expanded(
                  child: AppTextField(
                    label: context.t.aiQuiz.manualOptionLabel(number: i + 1),
                    controller: draft.optionControllers[i],
                    enabled: enabled,
                  ),
                ),
              ],
            ),
            if (i < 3) AppSpacing.xs.vGap,
          ],
          if (footer != null) ...[AppSpacing.sm.vGap, footer!],
        ],
      ),
    );
  }
}
