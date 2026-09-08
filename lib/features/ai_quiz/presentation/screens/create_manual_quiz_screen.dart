import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/pressable_scale.dart';
import '../../../../i18n/strings.g.dart';
import '../../../quiz/presentation/controllers/categories_controller.dart';
import '../../domain/entities/manual_question_input.dart';
import '../controllers/ai_quiz_controller.dart';
import '../widgets/draft_question_card.dart';
import '../widgets/topic_selection_row.dart';

/// AI chaqirmasdan, foydalanuvchi o'zi yozgan savollardan quiz yaratish —
/// nom + dinamik savollar ro'yxati (har biri 4 variant + to'g'ri javob).
class CreateManualQuizScreen extends ConsumerStatefulWidget {
  const CreateManualQuizScreen({super.key});

  @override
  ConsumerState<CreateManualQuizScreen> createState() =>
      _CreateManualQuizScreenState();
}

class _CreateManualQuizScreenState
    extends ConsumerState<CreateManualQuizScreen> {
  final TextEditingController _nameController = TextEditingController();
  final List<DraftQuestion> _questions = [DraftQuestion()];
  bool _isSubmitting = false;
  int? _topicCategoryId;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(categoriesControllerProvider.notifier).load(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (final question in _questions) {
      question.dispose();
    }
    super.dispose();
  }

  void _addQuestion() => setState(() => _questions.add(DraftQuestion()));

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
      if (!draft.isFilledIn) {
        context.showSnack(context.t.aiQuiz.manualFillAllFields);
        return;
      }
      questions.add(draft.toInput());
    }

    context.hideKeyboard();
    setState(() => _isSubmitting = true);
    try {
      await ref
          .read(aiQuizControllerProvider.notifier)
          .createManual(
            name: name,
            questions: questions,
            topicCategoryId: _topicCategoryId,
          );
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
              FadeSlideIn(
                child: BackHeader(
                  title: context.t.aiQuiz.createManualTitle,
                  onBack: _goBack,
                ),
              ),
              AppSpacing.xl.vGap,
              FadeSlideIn(
                delay: const Duration(milliseconds: 60),
                child: AppTextField(
                  label: context.t.aiQuiz.manualNameLabel,
                  hint: context.t.aiQuiz.manualNameHint,
                  controller: _nameController,
                  enabled: !_isSubmitting,
                ),
              ),
              AppSpacing.lg.vGap,
              FadeSlideIn(
                delay: const Duration(milliseconds: 100),
                child: TopicSelectionRow(
                  selectedId: _topicCategoryId,
                  onChanged: (id) => setState(() => _topicCategoryId = id),
                ),
              ),
              AppSpacing.lg.vGap,
              FadeSlideIn(
                delay: const Duration(milliseconds: 140),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (int i = 0; i < _questions.length; i++) ...[
                      DraftQuestionCard(
                        label: context.t.aiQuiz.manualQuestionLabel(
                          number: i + 1,
                        ),
                        draft: _questions[i],
                        canRemove: _questions.length > 1 && !_isSubmitting,
                        enabled: !_isSubmitting,
                        onRemove: () => _removeQuestion(i),
                        onChanged: () => setState(() {}),
                      ),
                      AppSpacing.md.vGap,
                    ],
                    PressableScale(
                      enabled: !_isSubmitting,
                      child: OutlinedButton.icon(
                        onPressed: _isSubmitting
                            ? null
                            : () {
                                HapticFeedback.lightImpact();
                                _addQuestion();
                              },
                        icon: const Icon(TablerIcons.plus, size: 18),
                        label: Text(context.t.aiQuiz.manualAddQuestion),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.xl.vGap,
              FadeSlideIn(
                delay: const Duration(milliseconds: 180),
                child: AppButton.primary(
                  label: context.t.aiQuiz.manualSubmit,
                  isLoading: _isSubmitting,
                  onPressed: _isSubmitting ? null : _submit,
                ),
              ),
              AppSpacing.lg.vGap,
            ],
          ),
        ),
      ),
    );
  }
}
