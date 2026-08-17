import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../core/widgets/error_retry_view.dart';
import '../../../../i18n/strings.g.dart';
import '../../../quiz/presentation/models/quiz_category.dart';
import '../../../quiz/presentation/models/quiz_launch_args.dart';
import '../../domain/entities/ai_quiz.dart';
import '../controllers/ai_quiz_controller.dart';

/// Boshqa foydalanuvchining (masalan, duel raqibining) sizga ko'rinadigan
/// quizlari — faqat ko'rish/tanlash uchun, [MyAiQuizzesScreen]dan farqli
/// o'laroq yaratish/o'chirish/ko'rinish-o'zgartirish yo'q.
class UserQuizzesScreen extends ConsumerStatefulWidget {
  const UserQuizzesScreen({
    required this.userId,
    required this.displayName,
    this.onCategoryPicked,
    super.key,
  });

  final String userId;
  final String displayName;
  final CategoryPickedCallback? onCategoryPicked;

  @override
  ConsumerState<UserQuizzesScreen> createState() => _UserQuizzesScreenState();
}

class _UserQuizzesScreenState extends ConsumerState<UserQuizzesScreen> {
  List<AiQuiz>? _quizzes;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(_load);
  }

  Future<void> _load() async {
    setState(() => _hasError = false);
    try {
      final List<AiQuiz> quizzes = await ref.read(aiQuizControllerProvider.notifier).listForUser(widget.userId);
      if (!mounted) return;
      setState(() => _quizzes = quizzes);
    } catch (_) {
      if (!mounted) return;
      setState(() => _hasError = true);
    }
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  void _pick(AiQuiz quiz) {
    final QuizCategory category = QuizCategory(
      id: quiz.id,
      name: quiz.name,
      questionCount: quiz.questionCount,
      icon: TablerIcons.sparkle,
      colorKey: CategoryColorKey.coral,
    );
    final CategoryPickedCallback? onPicked = widget.onCategoryPicked;
    if (onPicked != null) {
      onPicked(context, ref, category);
    } else {
      context.push(
        AppRoutes.quizIntro,
        extra: QuizLaunchArgs(category: category, questionCount: quiz.questionCount),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<AiQuiz>? quizzes = _quizzes;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              BackHeader(title: widget.displayName, onBack: _goBack),
              AppSpacing.lg.vGap,
              Expanded(
                child: _hasError
                    ? ErrorRetryView(onRetry: _load)
                    : quizzes == null
                        ? const Center(child: CircularProgressIndicator())
                        : quizzes.isEmpty
                            ? Center(
                                child: Text(
                                  context.t.aiQuiz.noSharedQuizzes,
                                  textAlign: TextAlign.center,
                                  style: context.textStyles.bodyMedium?.copyWith(color: context.colors.muted),
                                ),
                              )
                            : SingleChildScrollView(
                                child: Column(
                                  children: [
                                    for (final quiz in quizzes) ...[
                                      _UserQuizRow(quiz: quiz, onTap: () => _pick(quiz)),
                                      AppSpacing.xs.vGap,
                                    ],
                                  ],
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

class _UserQuizRow extends StatelessWidget {
  const _UserQuizRow({required this.quiz, required this.onTap});

  final AiQuiz quiz;
  final VoidCallback onTap;

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
          decoration: BoxDecoration(borderRadius: AppRadius.smAll, border: Border.all(color: context.colors.line)),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: context.colors.coral, borderRadius: AppRadius.smAll),
                alignment: Alignment.center,
                child: const Icon(TablerIcons.sparkle, color: Colors.white, size: 16),
              ),
              AppSpacing.sm.hGap,
              Expanded(
                child: Text(
                  quiz.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                context.t.common.questionCount(count: quiz.questionCount),
                style: context.textStyles.labelSmall?.copyWith(color: context.colors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
