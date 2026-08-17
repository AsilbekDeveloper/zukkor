import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../core/widgets/error_retry_view.dart';
import '../../../../core/widgets/shimmer_placeholder.dart';
import '../../../../i18n/strings.g.dart';
import '../controllers/categories_controller.dart';
import '../models/quiz_category.dart';
import '../models/quiz_launch_args.dart';
import '../widgets/category_grid_view.dart';

/// Full category list — mirrors the prototype's `view-categories`:
/// a back button + centered title header, then the same grid shown on
/// Home's "Categories" section (here, the complete list). Categories are
/// fetched from `GET /categories` on open.
///
/// Also doubles as the category picker for other flows (a pending duel,
/// starting a Lobby room's game) — rather than this screen knowing about
/// those features itself (which would tangle Quiz up with Friends and
/// Lobby), the caller supplies [onCategoryPicked] to react to a tap its
/// own way. Null means the plain solo picker: push Quiz Setup.
///
/// In Duel/Lobby context, it also shows an entry point to the user's
/// own AI/manual quizzes, so they can be picked for the match.
class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({this.onCategoryPicked, this.onAiQuizEntryTap, super.key});

  final CategoryPickedCallback? onCategoryPicked;

  /// "Mening AI/qo'lda quizlarim" kartasi bosilganda — berilmasa, oddiy
  /// `context.push(AppRoutes.myAiQuizzes)` ishlatiladi (Solo). Duel/Lobby
  /// caller'lari buni "Mening AI quizlarim" ekraniga ham to'g'ri
  /// `extra`ni yetkazish uchun beradi (router darajasida).
  final VoidCallback? onAiQuizEntryTap;

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  @override
  void initState() {
    super.initState();
    if (ref.read(categoriesControllerProvider).data == null) {
      Future.microtask(() => ref.read(categoriesControllerProvider.notifier).load());
    }
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  void _onCategoryTap(BuildContext context, QuizCategory category) {
    final onPicked = widget.onCategoryPicked;
    if (onPicked != null) {
      onPicked(context, ref, category);
    } else {
      context.push(
        AppRoutes.quizSetup,
        extra: (
          category: category,
          onStart: (BuildContext ctx, WidgetRef ref, int count) => ctx.push(
            AppRoutes.quizIntro,
            extra: QuizLaunchArgs(category: category, questionCount: count),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoriesControllerProvider);
    final List<QuizCategory>? categories = categoriesState.data?.map(QuizCategory.fromEntity).toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.screenHPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              BackHeader(title: context.t.categories.title, onBack: () => _goBack(context)),
              // Faqat Duel/Lobby kontekstida (kategoriya birovga taklif
              // qilinganda/o'yin uchun tanlanganda) ko'rinadi — bu holda
              // foydalanuvchi o'zining quizini ham tanlay olishi kerak.
              // Oddiy Solo ko'rish/yaratish endi Profile'dan.
              if (widget.onCategoryPicked != null) ...[
                AppSpacing.md.vGap,
                _AiQuizEntryCard(onTap: widget.onAiQuizEntryTap ?? () => context.push(AppRoutes.myAiQuizzes)),
              ],
              AppSpacing.lg.vGap,
              Expanded(
                child: categoriesState.hasError
                    ? ErrorRetryView(onRetry: () => ref.read(categoriesControllerProvider.notifier).load())
                    : categories == null
                        ? const ShimmerCategoryGridSkeleton()
                        : SingleChildScrollView(
                            child: CategoryGridView(
                              categories: categories,
                              onCategoryTap: (category) => _onCategoryTap(context, category),
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

/// Entry point into "Mening AI quizlarim" — hujjatdan AI orqali yaratilgan
/// shaxsiy quizlar. Ko'p o'yinchili rejimda o'z quizini tanlash uchun
/// ishlatiladi.
class _AiQuizEntryCard extends StatelessWidget {
  const _AiQuizEntryCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surfaceDark,
      borderRadius: AppRadius.mdAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(borderRadius: AppRadius.mdAll, boxShadow: context.colors.shadowSm),
          child: Row(
            children: [
              const Icon(TablerIcons.sparkle, color: Colors.white, size: 20),
              AppSpacing.sm.hGap,
              Expanded(
                child: Text(
                  context.t.aiQuiz.entryCardLabel,
                  style: context.textStyles.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Icon(TablerIcons.chevronRight, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}
