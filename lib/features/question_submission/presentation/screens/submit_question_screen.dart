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
import '../../../ai_quiz/presentation/widgets/topic_selection_row.dart';
import '../../../quiz/presentation/controllers/categories_controller.dart';
import '../../data/repositories/question_submission_repository_impl.dart';
import '../../domain/entities/question_submission_result.dart';

/// Foydalanuvchi ochiq (global) kategoriyalardan biriga yangi savol
/// taklif qiladi - Gemini uni so'rov paytida sinxron tekshiradi va
/// darhol tasdiqlaydi (savol faol bo'lib qo'shiladi) yoki rad etadi.
class SubmitQuestionScreen extends ConsumerStatefulWidget {
  const SubmitQuestionScreen({super.key});

  @override
  ConsumerState<SubmitQuestionScreen> createState() => _SubmitQuestionScreenState();
}

class _SubmitQuestionScreenState extends ConsumerState<SubmitQuestionScreen> {
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = List.generate(4, (_) => TextEditingController());
  int _correctIndex = 0;
  int? _categoryId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(categoriesControllerProvider.notifier).load());
  }

  @override
  void dispose() {
    _questionController.dispose();
    for (final controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  void _clearForm() {
    _questionController.clear();
    for (final controller in _optionControllers) {
      controller.clear();
    }
    setState(() => _correctIndex = 0);
  }

  Future<void> _submit() async {
    final String questionText = _questionController.text.trim();
    final List<String> options = _optionControllers.map((c) => c.text.trim()).toList();

    if (questionText.isEmpty || options.any((option) => option.isEmpty)) {
      context.showSnack(context.t.questionSubmission.fillAllFields);
      return;
    }

    context.hideKeyboard();
    setState(() => _isSubmitting = true);
    try {
      final QuestionSubmissionResult result = await ref.read(questionSubmissionRepositoryProvider).submit(
            questionText: questionText,
            options: options,
            correctOptionIndex: _correctIndex,
            categoryId: _categoryId,
          );
      if (!mounted) return;

      if (result.approved) {
        context.showSnack(context.t.questionSubmission.approved(category: result.categoryName ?? ''));
        _clearForm();
      } else {
        context.showSnack(
          context.t.questionSubmission.rejected(reason: result.rejectionReason ?? t.errors.unknown),
        );
      }
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
              BackHeader(title: context.t.questionSubmission.title, onBack: _goBack),
              AppSpacing.xl.vGap,
              AppTextField(
                label: context.t.questionSubmission.questionTextLabel,
                controller: _questionController,
                enabled: !_isSubmitting,
                maxLines: 3,
              ),
              AppSpacing.md.vGap,
              for (int i = 0; i < 4; i++) ...[
                Row(
                  children: [
                    InkWell(
                      onTap: _isSubmitting ? null : () => setState(() => _correctIndex = i),
                      borderRadius: BorderRadius.circular(999),
                      child: Padding(
                        padding: const EdgeInsets.all(4),
                        child: Icon(
                          _correctIndex == i ? TablerIcons.circleCheckFilled : TablerIcons.circle,
                          size: 22,
                          color: _correctIndex == i ? context.colors.coral : context.colors.muted,
                        ),
                      ),
                    ),
                    AppSpacing.xs.hGap,
                    Expanded(
                      child: AppTextField(
                        label: context.t.aiQuiz.manualOptionLabel(number: i + 1),
                        controller: _optionControllers[i],
                        enabled: !_isSubmitting,
                      ),
                    ),
                  ],
                ),
                if (i < 3) AppSpacing.xs.vGap,
              ],
              AppSpacing.lg.vGap,
              TopicSelectionRow(
                selectedId: _categoryId,
                onChanged: _isSubmitting ? (_) {} : (id) => setState(() => _categoryId = id),
              ),
              AppSpacing.xs.vGap,
              Text(
                context.t.questionSubmission.categoryHint,
                style: context.textStyles.labelSmall?.copyWith(color: context.colors.muted),
              ),
              AppSpacing.xl.vGap,
              AppButton.primary(
                label: context.t.questionSubmission.submit,
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
