import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../models/quiz_category.dart';

/// A fluid grid of category cards — mirrors the prototype's `.cat-grid`.
/// The column count is NOT hardcoded: `maxCrossAxisExtent` lets the grid
/// derive it from whatever width its container actually has (2 columns
/// on phones, 3–4 on tablets, 2 again inside a tablet two-pane column) —
/// the adaptive-grid approach recommended by the Flutter team. Used on
/// its own by the full Categories screen, and wrapped with a
/// "Categories / See all" header on Home.
class CategoryGridView extends StatelessWidget {
  const CategoryGridView({
    required this.categories,
    required this.onCategoryTap,
    super.key,
  });

  final List<QuizCategory> categories;
  final ValueChanged<QuizCategory> onCategoryTap;

  /// Card height is driven by its CONTENT, not by the column width:
  /// `childAspectRatio` ties height to width, which collapses the cell
  /// below the icon+padding height on narrow phones (a real 6px overflow
  /// at 320px). A fixed `mainAxisExtent` — icon (42) or the scaled text
  /// block, whichever is taller, plus vertical padding — stays correct at
  /// every width and every font scale.
  double _rowExtent(BuildContext context) {
    final TextScaler scaler = MediaQuery.textScalerOf(context);
    // Two lines: name (13.5px @ 1.4 height) + count (11px @ 1.2 height).
    // Each line is ceil'ed (Flutter rounds line boxes up to whole pixels)
    // plus a small cushion for platform/font metric differences.
    final double textBlock = (scaler.scale(13.5) * 1.4).ceilToDouble() +
        (scaler.scale(11) * 1.2).ceilToDouble() +
        2;
    const double iconBlock = 42;
    const double verticalPadding = AppSpacing.sm * 2;
    return (textBlock > iconBlock ? textBlock : iconBlock) + verticalPadding;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        // ~260px per card → 2 columns on a 320–520 container, 3 on
        // 520–780, 4 on wider — always proportional, never stretched.
        maxCrossAxisExtent: 260,
        mainAxisSpacing: AppSpacing.sm - 1,
        crossAxisSpacing: AppSpacing.sm - 1,
        mainAxisExtent: _rowExtent(context),
      ),
      itemBuilder: (context, index) {
        final QuizCategory category = categories[index];
        return _CategoryCard(
          category: category,
          onTap: () => onCategoryTap(category),
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.onTap});

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
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: AppRadius.mdAll,
            border: Border.all(color: context.colors.line),
            boxShadow: context.colors.shadowSm,
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: category.color(context),
                  borderRadius: AppRadius.smAll,
                ),
                alignment: Alignment.center,
                child: Icon(category.icon, color: Colors.white, size: 20),
              ),
              AppSpacing.sm.hGap,
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodySmall?.copyWith(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: context.colors.ink,
                      ),
                    ),
                    Text(
                      AppStrings.questionCount(category.questionCount),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.labelSmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
