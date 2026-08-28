import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../i18n/strings.g.dart';

class QuizCard extends StatelessWidget {
  const QuizCard({
    required this.name,
    required this.questionCount,
    required this.creatorName,
    required this.onTap,
    super.key,
  });

  final String name;
  final int questionCount;
  final String creatorName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.card,
      borderRadius: AppRadius.smAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smAll,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
          decoration: BoxDecoration(
            borderRadius: AppRadius.smAll,
            border: Border.all(color: context.colors.line),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(color: context.colors.coral, borderRadius: AppRadius.smAll),
                alignment: Alignment.center,
                child: const Icon(TablerIcons.sparkle, color: Colors.white, size: 18),
              ),
              AppSpacing.md.hGap,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      creatorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.labelSmall?.copyWith(color: context.colors.muted),
                    ),
                  ],
                ),
              ),
              AppSpacing.sm.hGap,
              Text(
                context.t.common.questionCount(count: questionCount),
                style: context.textStyles.labelSmall?.copyWith(
                  color: context.colors.muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
