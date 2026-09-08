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
import '../../../../core/widgets/back_header.dart';
import '../../../../core/widgets/error_retry_view.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/pressable_scale.dart';
import '../../../../core/widgets/shimmer_placeholder.dart';
import '../../../../i18n/strings.g.dart';
import '../../data/repositories/ai_quiz_repository_impl.dart';
import '../../domain/entities/quiz_question.dart';
import '../controllers/ai_quiz_controller.dart';
import '../models/edit_manual_quiz_args.dart';
import '../widgets/draft_question_card.dart';

/// Add/edit/delete individual questions on a quiz the user built with
/// "Qo'lda yaratish" — unlike [CreateManualQuizScreen] (one atomic
/// submit), every action here is its own immediate backend call, since
/// that's how `POST/PATCH/DELETE /ai-quiz/{id}/questions/...` work: each
/// question is its own resource once the quiz already exists.
class EditManualQuizScreen extends ConsumerStatefulWidget {
  const EditManualQuizScreen({required this.args, super.key});

  final EditManualQuizArgs args;

  @override
  ConsumerState<EditManualQuizScreen> createState() =>
      _EditManualQuizScreenState();
}

class _EditManualQuizScreenState extends ConsumerState<EditManualQuizScreen> {
  /// Null while the initial load is in flight.
  List<DraftQuestion>? _drafts;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  @override
  void dispose() {
    for (final draft in _drafts ?? const <DraftQuestion>[]) {
      draft.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _hasError = false;
      _drafts = null;
    });
    try {
      final List<QuizQuestion> questions = await ref
          .read(listQuizQuestionsUseCaseProvider)
          .call(widget.args.quizId);
      if (!mounted) return;
      setState(
        () => _drafts = questions.map(DraftQuestion.fromExisting).toList(),
      );
    } catch (_) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  void _addBlankQuestion() => setState(() => _drafts!.add(DraftQuestion()));

  Future<void> _removeAt(int index) async {
    final DraftQuestion draft = _drafts![index];
    if (draft.id == null) {
      // Never saved - nothing on the server to delete, just drop it.
      setState(() {
        draft.dispose();
        _drafts!.removeAt(index);
      });
      return;
    }

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.t.aiQuiz.deleteQuestionConfirmTitle),
        content: Text(context.t.aiQuiz.deleteQuestionConfirmMessage),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              dialogContext.pop(false);
            },
            child: Text(context.t.common.cancel),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              dialogContext.pop(true);
            },
            child: Text(
              context.t.common.delete,
              style: TextStyle(
                color: context.colors.coralDeep,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => draft.isBusy = true);
    try {
      await ref
          .read(deleteQuizQuestionUseCaseProvider)
          .call(widget.args.quizId, draft.id!);
      if (!mounted) return;
      ref
          .read(aiQuizControllerProvider.notifier)
          .bumpQuestionCount(widget.args.quizId, -1);
      setState(() {
        draft.dispose();
        _drafts!.remove(draft);
      });
    } on Failure catch (e) {
      if (mounted) context.showSnack(e.message);
    } catch (_) {
      if (mounted) context.showSnack(t.errors.unknown);
    } finally {
      if (mounted) setState(() => draft.isBusy = false);
    }
  }

  Future<void> _save(DraftQuestion draft) async {
    if (!draft.isFilledIn) {
      context.showSnack(context.t.aiQuiz.manualFillAllFields);
      return;
    }

    setState(() => draft.isBusy = true);
    try {
      if (draft.id == null) {
        final QuizQuestion created = await ref
            .read(addQuizQuestionUseCaseProvider)
            .call(widget.args.quizId, draft.toInput());
        if (!mounted) return;
        ref
            .read(aiQuizControllerProvider.notifier)
            .bumpQuestionCount(widget.args.quizId, 1);
        setState(() => draft.id = created.id);
        context.showSnack(context.t.aiQuiz.questionAdded);
      } else {
        await ref
            .read(updateQuizQuestionUseCaseProvider)
            .call(widget.args.quizId, draft.id!, draft.toInput());
        if (!mounted) return;
        context.showSnack(context.t.aiQuiz.questionSaved);
      }
    } on Failure catch (e) {
      if (mounted) context.showSnack(e.message);
    } catch (_) {
      if (mounted) context.showSnack(t.errors.unknown);
    } finally {
      if (mounted) setState(() => draft.isBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              FadeSlideIn(
                child: BackHeader(title: widget.args.quizName, onBack: _goBack),
              ),
              AppSpacing.lg.vGap,
              Expanded(
                child: FadeSlideIn(
                  delay: const Duration(milliseconds: 60),
                  child: _buildBody(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_hasError) {
      return ErrorRetryView(onRetry: _load);
    }
    final List<DraftQuestion>? drafts = _drafts;
    if (drafts == null) {
      return const ShimmerListSkeleton(count: 3);
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < drafts.length; i++) ...[
            DraftQuestionCard(
              label: context.t.aiQuiz.manualQuestionLabel(number: i + 1),
              draft: drafts[i],
              // A not-yet-saved draft can always be dropped locally; a
              // persisted one stays removable in the UI even when it's
              // the last one - the backend's own guard (400, shown via
              // the snackbar in `_removeAt`) is the real source of truth,
              // this is just not worth duplicating client-side.
              canRemove: true,
              enabled: !drafts[i].isBusy,
              onRemove: () => _removeAt(i),
              onChanged: () => setState(() {}),
              footer: Align(
                alignment: Alignment.centerRight,
                child: AppButton.secondary(
                  label: drafts[i].id == null
                      ? context.t.aiQuiz.manualAddQuestion
                      : context.t.aiQuiz.manualSaveQuestion,
                  isLoading: drafts[i].isBusy,
                  onPressed: () => _save(drafts[i]),
                ),
              ),
            ),
            AppSpacing.md.vGap,
          ],
          PressableScale(
            child: OutlinedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                _addBlankQuestion();
              },
              icon: const Icon(TablerIcons.plus, size: 18),
              label: Text(context.t.aiQuiz.manualAddQuestion),
            ),
          ),
          AppSpacing.lg.vGap,
        ],
      ),
    );
  }
}
