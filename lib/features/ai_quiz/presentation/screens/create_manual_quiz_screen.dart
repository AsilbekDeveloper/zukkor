import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../i18n/strings.g.dart';
import '../../../quiz/presentation/controllers/categories_controller.dart';
import '../../domain/entities/manual_question_input.dart';
import '../controllers/ai_quiz_controller.dart';
import '../widgets/topic_selection_row.dart';

class _DraftQuestion {
  _DraftQuestion()
      : questionController = TextEditingController(),
        optionControllers = List.generate(4, (_) => TextEditingController());

  final TextEditingController questionController;
  final List<TextEditingController> optionControllers;
  int correctIndex = 0;

  void dispose() {
    questionController.dispose();
    for (final controller in optionControllers) {
      controller.dispose();
    }
  }
}

/// AI chaqirmasdan, foydalanuvchi o'zi yozgan savollardan quiz yaratish —
/// nom + dinamik savollar ro'yxati (har biri 4 variant + to'g'ri javob).
class CreateManualQuizScreen extends ConsumerStatefulWidget {
  const CreateManualQuizScreen({super.key});

  @override
  ConsumerState<CreateManualQuizScreen> createState() => _CreateManualQuizScreenState();
}

class _CreateManualQuizScreenState extends ConsumerState<CreateManualQuizScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<_DraftQuestion> _questions = [_DraftQuestion()];
  bool _isSubmitting = false;
  int? _topicCategoryId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(categoriesControllerProvider.notifier).load());
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final question in _questions) {
      question.dispose();
    }
    super.dispose();
  }

  void _addQuestion() => setState(() => _questions.add(_DraftQuestion()));

  void _removeQuestion(int index) {
    if (_questions.length <= 1) return;
    setState(() {
      _questions[index].dispose();
      _questions.removeAt(index);
    });
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  Future<void> _submit() async {
    final String name = _nameController.text.trim();
    if (name.isEmpty) {
      context.showSnack(context.t.aiQuiz.manualNameRequired);
      return;
    }

    final List<ManualQuestionInput> questions = [];
    for (final draft in _questions) {
      final String questionText = draft.questionController.text.trim();
      final List<String> options = draft.optionControllers.map((c) => c.text.trim()).toList();
      if (questionText.isEmpty || options.any((option) => option.isEmpty)) {
        context.showSnack(context.t.aiQuiz.manualFillAllFields);
        return;
      }
      questions.add(
        ManualQuestionInput(questionText: questionText, options: options, correctOptionIndex: draft.correctIndex),
      );
    }

    context.hideKeyboard();
    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(aiQuizControllerProvider.notifier)
          .createManual(name: name, questions: questions, topicCategoryId: _topicCategoryId);
      if (!mounted) return;
      context.showSnack(context.t.aiQuiz.generated);
      context.pop();
    } on Failure catch (e) {
      if (mounted) context.showSnack(e.message);
    } catch (_) {
      if (mounted) context.showSnack(t.errors.unknown);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              BackHeader(title: context.t.aiQuiz.createManualTitle, onBack: _goBack),
              AppSpacing.xl.vGap,
              AppTextField(
                label: context.t.aiQuiz.manualNameLabel,
                hint: context.t.aiQuiz.manualNameHint,
                controller: _nameController,
                enabled: !_isSubmitting,
              ),
              AppSpacing.lg.vGap,
              TopicSelectionRow(
                selectedId: _topicCategoryId,
                onChanged: (id) => setState(() => _topicCategoryId = id),
              ),
              AppSpacing.lg.vGap,
              for (int i = 0; i < _questions.length; i++) ...[
                _QuestionCard(
                  index: i,
                  draft: _questions[i],
                  canRemove: _questions.length > 1 && !_isSubmitting,
                  onRemove: () => _removeQuestion(i),
                  onChanged: () => setState(() {}),
                ),
                AppSpacing.md.vGap,
              ],
              OutlinedButton.icon(
                onPressed: _isSubmitting ? null : _addQuestion,
                icon: const Icon(TablerIcons.plus, size: 18),
                label: Text(context.t.aiQuiz.manualAddQuestion),
              ),
              AppSpacing.xl.vGap,
              AppButton.primary(
                label: context.t.aiQuiz.manualSubmit,
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : _submit,
              ),
              AppSpacing.lg.vGap,
            ],
          ),
        ),
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    required this.index,
    required this.draft,
    required this.canRemove,
    required this.onRemove,
    required this.onChanged,
  });

  final int index;
  final _DraftQuestion draft;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

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
                  context.t.aiQuiz.manualQuestionLabel(number: index + 1),
                  style: context.textStyles.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.colors.ink2,
                  ),
                ),
              ),
              if (canRemove)
                InkWell(
                  onTap: onRemove,
                  borderRadius: AppRadius.smAll,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(TablerIcons.trash, size: 18, color: context.colors.coralDeep),
                  ),
                ),
            ],
          ),
          AppSpacing.xs.vGap,
          AppTextField(label: context.t.aiQuiz.manualQuestionTextLabel, controller: draft.questionController),
          AppSpacing.sm.vGap,
          for (int i = 0; i < 4; i++) ...[
            Row(
              children: [
                InkWell(
                  onTap: () {
                    draft.correctIndex = i;
                    onChanged();
                  },
                  borderRadius: BorderRadius.circular(999),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      draft.correctIndex == i ? TablerIcons.circleCheckFilled : TablerIcons.circle,
                      size: 22,
                      color: draft.correctIndex == i ? context.colors.coral : context.colors.muted,
                    ),
                  ),
                ),
                AppSpacing.xs.hGap,
                Expanded(
                  child: AppTextField(
                    label: context.t.aiQuiz.manualOptionLabel(number: i + 1),
                    controller: draft.optionControllers[i],
                  ),
                ),
              ],
            ),
            if (i < 3) AppSpacing.xs.vGap,
          ],
        ],
      ),
    );
  }
}
