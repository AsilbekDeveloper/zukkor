import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../core/widgets/error_retry_view.dart';
import '../../../../core/widgets/shimmer_placeholder.dart';
import '../../../../i18n/strings.g.dart';
import '../../../quiz/presentation/models/quiz_category.dart';
import '../../../quiz/presentation/models/quiz_launch_args.dart';
import '../../domain/entities/ai_quiz.dart';
import '../controllers/ai_quiz_controller.dart';
import '../widgets/ai_quiz_list.dart';

/// "Mening AI quizlarim" — foydalanuvchi hujjatdan yaratgan shaxsiy
/// quizlar ro'yxati. Bosilsa to'g'ridan-to'g'ri o'ynash boshlanadi
/// (savollar soni allaqachon generatsiyada belgilangan, qayta so'ralmaydi).
class MyAiQuizzesScreen extends ConsumerStatefulWidget {
  const MyAiQuizzesScreen({super.key});

  @override
  ConsumerState<MyAiQuizzesScreen> createState() => _MyAiQuizzesScreenState();
}

class _MyAiQuizzesScreenState extends ConsumerState<MyAiQuizzesScreen> {
  @override
  void initState() {
    super.initState();
    if (ref.read(aiQuizControllerProvider).quizzes == null) {
      Future.microtask(() => ref.read(aiQuizControllerProvider.notifier).loadList());
    }
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  Future<void> _showCreateOptions() async {
    final String? choice = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(context.t.aiQuiz.createChooseTitle),
        children: [
          SimpleDialogOption(
            onPressed: () => dialogContext.pop('ai'),
            child: Text(context.t.aiQuiz.createViaAi),
          ),
          SimpleDialogOption(
            onPressed: () => dialogContext.pop('manual'),
            child: Text(context.t.aiQuiz.createManually),
          ),
        ],
      ),
    );
    if (!mounted || choice == null) return;
    if (choice == 'ai') {
      await context.push(AppRoutes.generateAiQuiz);
    } else {
      await context.push(AppRoutes.createManualQuiz);
    }
  }

  void _play(AiQuiz quiz) {
    final QuizCategory category = QuizCategory(
      id: quiz.id,
      name: quiz.name,
      questionCount: quiz.questionCount,
      icon: TablerIcons.sparkle,
      colorKey: CategoryColorKey.coral,
    );
    context.push(
      AppRoutes.quizIntro,
      extra: QuizLaunchArgs(category: category, questionCount: quiz.questionCount),
    );
  }

  Future<void> _confirmDelete(AiQuiz quiz) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.t.aiQuiz.deleteConfirmTitle),
        content: Text(context.t.aiQuiz.deleteConfirmMessage(name: quiz.name)),
        actions: [
          TextButton(onPressed: () => dialogContext.pop(false), child: Text(context.t.common.cancel)),
          TextButton(onPressed: () => dialogContext.pop(true), child: Text(context.t.common.delete)),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await ref.read(aiQuizControllerProvider.notifier).delete(quiz.id);
    } on Failure catch (e) {
      if (mounted) context.showSnack(e.message);
    } catch (_) {
      if (mounted) context.showSnack(t.errors.unknown);
    }
  }

  Future<void> _changeVisibility(AiQuiz quiz) async {
    final String? selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(context.t.aiQuiz.visibilityDialogTitle),
        children: [
          SimpleDialogOption(
            onPressed: () => dialogContext.pop('private'),
            child: Text(context.t.aiQuiz.visibilityPrivate),
          ),
          SimpleDialogOption(
            onPressed: () => dialogContext.pop('friends'),
            child: Text(context.t.aiQuiz.visibilityFriends),
          ),
          SimpleDialogOption(
            onPressed: () => dialogContext.pop('public'),
            child: Text(context.t.aiQuiz.visibilityPublic),
          ),
        ],
      ),
    );
    if (selected == null || selected == quiz.visibility || !mounted) return;

    try {
      await ref.read(aiQuizControllerProvider.notifier).updateVisibility(quiz.id, selected);
      if (mounted) context.showSnack(context.t.aiQuiz.visibilityUpdated);
    } on Failure catch (e) {
      if (mounted) context.showSnack(e.message);
    } catch (_) {
      if (mounted) context.showSnack(t.errors.unknown);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AiQuizState state = ref.watch(aiQuizControllerProvider);
    final List<AiQuiz>? quizzes = state.quizzes;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.screenHPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              BackHeader(title: context.t.aiQuiz.myQuizzesTitle, onBack: _goBack),
              AppSpacing.lg.vGap,
              AppButton.primary(label: context.t.aiQuiz.createButton, onPressed: _showCreateOptions),
              AppSpacing.lg.vGap,
              Expanded(
                child: state.hasListError
                    ? ErrorRetryView(onRetry: () => ref.read(aiQuizControllerProvider.notifier).loadList())
                    : quizzes == null
                        ? const ShimmerListSkeleton(count: 4, trailingWidth: 36)
                        : quizzes.isEmpty
                            ? _EmptyState(onCreate: _showCreateOptions)
                            : SingleChildScrollView(
                                child: AiQuizList(
                                  quizzes: quizzes,
                                  onTap: _play,
                                  onDelete: _confirmDelete,
                                  onVisibilityTap: _changeVisibility,
                                ),
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(TablerIcons.sparkle, size: 32, color: context.colors.muted),
            AppSpacing.sm.vGap,
            Text(
              context.t.aiQuiz.emptyTitle,
              textAlign: TextAlign.center,
              style: context.textStyles.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            AppSpacing.xs.vGap,
            Text(
              context.t.aiQuiz.emptySubtitle,
              textAlign: TextAlign.center,
              style: context.textStyles.bodySmall?.copyWith(color: context.colors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
