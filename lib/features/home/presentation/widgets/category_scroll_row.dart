import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/pressable_scale.dart';
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
        Row(
          children: [
            for (int i = 0; i < categories.length; i++) ...[
              Expanded(child: _CategoryTile(category: categories[i], onTap: () => onCategoryTap(categories[i]))),
              if (i < categories.length - 1) AppSpacing.sm.hGap,
            ],
          ],
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
    final Color base = category.color(context);
    return PressableScale(
      child: Material(
        color: context.colors.card,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.mdAll,
          child: Container(
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
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [base, Color.lerp(base, Colors.black, 0.18)!],
                    ),
                    borderRadius: AppRadius.smAll,
                  ),
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
      ),
    );
  }
}
