import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../i18n/strings.g.dart';
import '../../../quiz/presentation/models/quiz_category.dart';

/// "Categories" section head + a horizontally-scrolling row of compact
/// category tiles — Home's space-constrained alternative to the full
/// [CategoryGridView] grid (still used, unchanged, by the full
/// Categories screen).
class CategoryScrollRow extends StatelessWidget {
  const CategoryScrollRow({
    required this.categories,
    required this.onSeeAll,
    required this.onCategoryTap,
    super.key,
  });

  final List<QuizCategory> categories;
  final VoidCallback onSeeAll;
  final ValueChanged<QuizCategory> onCategoryTap;

  /// Tile height driven by its CONTENT (icon + up to 2 text lines), not a
  /// fixed guess - same reasoning as CategoryGridView's `_rowExtent`: a
  /// hardcoded height overflows once text scale/fonts push the text
  /// block taller than the guess.
  double _tileHeight(BuildContext context) {
    final TextScaler scaler = MediaQuery.textScalerOf(context);
    final double nameLine = (scaler.scale(12) * 1.3).ceilToDouble();
    final double countLine = (scaler.scale(10.5) * 1.2).ceilToDouble();
    const double iconBlock = 40;
    const double gap = AppSpacing.xs;
    const double verticalPadding = AppSpacing.sm * 2;
    return iconBlock + gap + nameLine + countLine + verticalPadding;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                context.t.home.categoriesTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.titleLarge,
              ),
            ),
            TextButton(onPressed: onSeeAll, child: Text(context.t.home.seeAll)),
          ],
        ),
        AppSpacing.xs.vGap,
        SizedBox(
          height: _tileHeight(context),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (context, index) => AppSpacing.sm.hGap,
            itemBuilder: (context, index) {
              final QuizCategory category = categories[index];
              return _CategoryTile(category: category, onTap: () => onCategoryTap(category));
            },
          ),
        ),
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.onTap});

  final QuizCategory category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.card,
      borderRadius: AppRadius.mdAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Container(
          width: 92,
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.xs),
          decoration: BoxDecoration(
            borderRadius: AppRadius.mdAll,
            border: Border.all(color: context.colors.line),
            boxShadow: context.colors.shadowSm,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: category.color(context), borderRadius: AppRadius.smAll),
                alignment: Alignment.center,
                child: Icon(category.icon, color: Colors.white, size: 18),
              ),
              AppSpacing.xs.vGap,
              Text(
                category.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: context.textStyles.labelSmall?.copyWith(fontWeight: FontWeight.w600, color: context.colors.ink),
              ),
              Text(
                context.t.common.questionCount(count: category.questionCount),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: context.textStyles.labelSmall?.copyWith(fontSize: 10, color: context.colors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
