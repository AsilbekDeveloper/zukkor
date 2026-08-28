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
  const MyAiQuizzesScreen({this.onCategoryPicked, super.key});

  final CategoryPickedCallback? onCategoryPicked;

  @override
  ConsumerState<MyAiQuizzesScreen> createState() => _MyAiQuizzesScreenState();
}

class _MyAiQuizzesScreenState extends ConsumerState<MyAiQuizzesScreen> {
  bool _selectionMode = false;
  final Set<int> _selectedIds = {};

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

  void _enterSelectionMode() => setState(() => _selectionMode = true);

  void _exitSelectionMode() => setState(() {
        _selectionMode = false;
        _selectedIds.clear();
      });

  void _toggleSelect(AiQuiz quiz) {
    setState(() {
      if (!_selectedIds.remove(quiz.id)) _selectedIds.add(quiz.id);
    });
  }

  Future<void> _createViaAi() async {
    await context.push(AppRoutes.generateAiQuiz);
  }

  void _rowTapped(AiQuiz quiz) {
    if (_selectionMode) {
      _toggleSelect(quiz);
    } else {
      _play(quiz);
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

  Future<void> _confirmDeleteSelected() async {
    if (_selectedIds.isEmpty) return;
    final int count = _selectedIds.length;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.t.aiQuiz.deleteSelectedConfirmTitle),
        content: Text(context.t.aiQuiz.deleteSelectedConfirmMessage(count: count)),
        actions: [
          TextButton(onPressed: () => dialogContext.pop(false), child: Text(context.t.common.cancel)),
          TextButton(onPressed: () => dialogContext.pop(true), child: Text(context.t.common.delete)),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    // Sequential, not Future.wait — AiQuizController.delete() updates
    // state.quizzes by filtering whatever the CURRENT state.quizzes is at
    // the time it runs. Firing all the deletes concurrently would have
    // every call read the same stale snapshot and each write back a list
    // missing only its own id - the last write would win, silently
    // "undoing" the others from the local list (the backend would still
    // have deleted them all, but the UI wouldn't reflect it without a
    // full reload).
    for (final int id in _selectedIds.toList()) {
      try {
        await ref.read(aiQuizControllerProvider.notifier).delete(id);
      } on Failure catch (e) {
        if (mounted) context.showSnack(e.message);
      } catch (_) {
        if (mounted) context.showSnack(t.errors.unknown);
      }
    }
    if (mounted) _exitSelectionMode();
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

  Widget _buildHeader(BuildContext context, {required bool canSelect}) {
    if (_selectionMode) {
      final bool hasSelection = _selectedIds.isNotEmpty;
      return Row(
        children: [
          _HeaderIconButton(icon: TablerIcons.x, onTap: _exitSelectionMode),
          Expanded(
            child: Text(
              context.t.aiQuiz.selectedCount(count: _selectedIds.length),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.titleLarge,
            ),
          ),
          _HeaderIconButton(
            icon: TablerIcons.trash,
            color: hasSelection ? context.colors.coralDeep : context.colors.muted,
            onTap: hasSelection ? _confirmDeleteSelected : null,
          ),
        ],
      );
    }

    return Row(
      children: [
        _HeaderIconButton(icon: TablerIcons.arrowLeft, onTap: _goBack),
        Expanded(
          child: Text(
            context.t.aiQuiz.myQuizzesTitle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.titleLarge,
          ),
        ),
        TextButton(
          onPressed: canSelect ? _enterSelectionMode : null,
          child: Text(context.t.aiQuiz.selectAction),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final AiQuizState state = ref.watch(aiQuizControllerProvider);
    final List<AiQuiz>? quizzes = state.quizzes;
    // Nothing to select once the list is empty (or still loading) - the
    // "Select" action would just open selection mode with nothing to act on.
    final bool canSelect = quizzes != null && quizzes.isNotEmpty;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.screenHPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              _buildHeader(context, canSelect: canSelect),
              AppSpacing.lg.vGap,
              if (!_selectionMode) ...[
                AppButton.primary(label: context.t.aiQuiz.createButton, onPressed: _createViaAi),
                AppSpacing.lg.vGap,
              ],
              Expanded(
                child: state.hasListError
                    ? ErrorRetryView(onRetry: () => ref.read(aiQuizControllerProvider.notifier).loadList())
                    : quizzes == null
                        ? const ShimmerListSkeleton(count: 4, trailingWidth: 36)
                        : quizzes.isEmpty
                            ? _EmptyState(onCreate: _createViaAi)
                            : SingleChildScrollView(
                                child: AiQuizList(
                                  quizzes: quizzes,
                                  onTap: _rowTapped,
                                  onVisibilityTap: _changeVisibility,
                                  selectionMode: _selectionMode,
                                  selectedIds: _selectedIds,
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

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onTap, this.color});

  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.smAll,
        side: BorderSide(color: context.colors.line),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smAll,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: color ?? context.colors.ink, size: 20),
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
