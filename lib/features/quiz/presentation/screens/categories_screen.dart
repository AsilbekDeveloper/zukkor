import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../friends/presentation/models/duel_match.dart';
import '../../../friends/presentation/models/friend_entry.dart';
import '../models/quiz_category.dart';
import '../widgets/category_grid_view.dart';

/// Full category list — mirrors the prototype's `view-categories`:
/// a back button + centered title header, then the same grid shown on
/// Home's "Categories" section (here, the complete list).
///
/// Doubles as the category picker for a pending duel: when reached from
/// the Duel (choose a friend) screen with [duelOpponent] set, tapping a
/// category opens Duel Waiting for that friend+category instead of the
/// solo quiz-intro countdown — mirrors the prototype's `pendingDuelOpponent`
/// flow (Duel and Solo share this same category-picker screen).
class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({this.duelOpponent, super.key});

  final FriendEntry? duelOpponent;

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  void _onCategoryTap(BuildContext context, QuizCategory category) {
    if (duelOpponent != null) {
      context.push(
        AppRoutes.duelWaiting,
        extra: DuelMatch(opponent: duelOpponent!, category: category),
      );
    } else {
      context.push(AppRoutes.quizIntro, extra: category);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.screenHPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              BackHeader(title: AppStrings.categoriesScreenTitle, onBack: () => _goBack(context)),
              AppSpacing.lg.vGap,
              Expanded(
                child: SingleChildScrollView(
                  child: CategoryGridView(
                    categories: QuizCategory.sample,
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
