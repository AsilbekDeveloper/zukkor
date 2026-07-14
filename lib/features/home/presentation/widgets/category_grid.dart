import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../quiz/presentation/models/quiz_category.dart';
import '../../../quiz/presentation/widgets/category_grid_view.dart';

/// "Categories" section head + a 2-column grid of category cards —
/// mirrors the prototype's `.section-head` + `.cat-grid`. The grid itself
/// is [CategoryGridView], shared with the full Categories screen.
class CategoryGrid extends StatelessWidget {
  const CategoryGrid({
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
                AppStrings.categoriesTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.titleLarge,
              ),
            ),
            TextButton(onPressed: onSeeAll, child: const Text(AppStrings.seeAll)),
          ],
        ),
        CategoryGridView(categories: categories, onCategoryTap: onCategoryTap),
      ],
    );
  }
}
