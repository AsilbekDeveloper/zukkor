import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../history/domain/entities/session_history_entry.dart';
import '../../../quiz/presentation/models/quiz_category.dart';

class ContinuePlayingCard extends StatelessWidget {
  const ContinuePlayingCard({required this.entry, required this.onTap, super.key});

  final SessionHistoryEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final CategoryColorKey colorKey =
        CategoryColorKey.values.firstWhere((k) => k.name == entry.categoryColorKey, orElse: () => CategoryColorKey.coral);
    final Color base = colorKey.resolve(context);

    return Material(
      color: context.colors.card,
      borderRadius: AppRadius.mdAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(borderRadius: AppRadius.mdAll, border: Border.all(color: context.colors.line)),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [base, Color.lerp(base, Colors.black, 0.18)!]),
                  borderRadius: AppRadius.smAll,
                ),
              ),
              AppSpacing.sm.hGap,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Davom ettirish', style: context.textStyles.labelSmall?.copyWith(color: context.colors.muted)),
                    Text('${entry.categoryName} - qayta o\'ynang',
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: context.textStyles.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs + 2),
                decoration: BoxDecoration(color: context.colors.cream, borderRadius: BorderRadius.circular(999)),
                child: Text('O\'ynash',
                    style: context.textStyles.labelSmall?.copyWith(color: context.colors.coralDeep, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
