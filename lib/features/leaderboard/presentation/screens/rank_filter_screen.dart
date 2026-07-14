import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../core/widgets/checkmark_option_list.dart';
import '../../../quiz/presentation/models/quiz_category.dart';

/// Single-select "filter the leaderboard by category" — mirrors the
/// prototype's `view-rank-filter`. Pops with the chosen category name,
/// or `null` for "All categories" — the caller (Leaderboard) reflects
/// the choice in its header label.
class RankFilterScreen extends StatelessWidget {
  const RankFilterScreen({required this.currentFilter, super.key});

  final String? currentFilter;

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop(currentFilter);
    } else {
      context.go(AppRoutes.leaderboard);
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
              BackHeader(title: AppStrings.rankFilterScreenTitle, onBack: () => _goBack(context)),
              AppSpacing.lg.vGap,
              CheckmarkOptionList(
                options: [
                  CheckmarkOption(
                    icon: TablerIcons.list,
                    label: AppStrings.allCategories,
                    isActive: currentFilter == null,
                    onTap: () => context.pop(null),
                  ),
                ],
              ),
              AppSpacing.md.vGap,
              CheckmarkOptionList(
                options: [
                  for (final QuizCategory category in QuizCategory.sample)
                    CheckmarkOption(
                      icon: category.icon,
                      label: category.name,
                      isActive: currentFilter == category.name,
                      onTap: () => context.pop(category.name),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

