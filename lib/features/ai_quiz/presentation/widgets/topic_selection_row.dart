import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/pressable_scale.dart';
import '../../../../i18n/strings.g.dart';
import '../../../quiz/domain/entities/category.dart';
import '../../../quiz/presentation/controllers/categories_controller.dart';
import '../../../quiz/presentation/models/quiz_category.dart';

class TopicSelectionRow extends ConsumerWidget {
  const TopicSelectionRow({
    required this.selectedId,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final int? selectedId;
  final ValueChanged<int?> onChanged;

  /// Same convention as [PillSegmentControl.enabled] - false while
  /// changing the topic doesn't make sense right now (e.g. a submission
  /// in progress), instead of leaving chips looking tappable but doing
  /// (and feeling, via a stray haptic) nothing.
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(categoriesControllerProvider);
    final List<Category>? categories = categoriesState.data;

    if (categories == null || categories.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<QuizCategory> quizCategories = categories
        .map(QuizCategory.fromEntity)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.t.aiQuiz.topicSelectionLabel,
          style: context.textStyles.labelSmall,
        ),
        AppSpacing.sm.vGap,
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              for (final cat in quizCategories) ...[
                _CategoryChip(
                  category: cat,
                  isSelected: cat.id == selectedId,
                  enabled: enabled,
                  onTap: () => onChanged(cat.id == selectedId ? null : cat.id),
                ),
                AppSpacing.sm.hGap,
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.isSelected,
    required this.onTap,
    required this.enabled,
  });

  final QuizCategory category;
  final bool isSelected;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final Color color = category.color(context);

    return PressableScale(
      enabled: enabled,
      child: Material(
        color: isSelected ? color : context.colors.card,
        borderRadius: AppRadius.smAll,
        child: InkWell(
          onTap: enabled
              ? () {
                  HapticFeedback.lightImpact();
                  onTap();
                }
              : null,
          borderRadius: AppRadius.smAll,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm - 2,
            ),
            decoration: BoxDecoration(
              borderRadius: AppRadius.smAll,
              border: Border.all(
                color: isSelected ? color : context.colors.line,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  category.icon,
                  size: 16,
                  color: isSelected ? Colors.white : color,
                ),
                AppSpacing.xs.hGap,
                Text(
                  category.name,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: isSelected ? Colors.white : context.colors.ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
