import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../i18n/strings.g.dart';

/// Coral-fonli, e'tiborni tortadigan chaqiruv — qo'lda quiz yaratish
/// ekraniga olib boradi. [FriendsCard]ning rang sxemasi aksi (bu safar
/// coral fon, oq ikonkalar) — bir xil grid ostida ikkinchi coral element
/// bo'lib qolmasligi va ko'zga alohida tashlanishi uchun.
class CreateQuizCard extends StatelessWidget {
  const CreateQuizCard({required this.onTap, super.key});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.coral,
      borderRadius: AppRadius.mdAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
          decoration: BoxDecoration(borderRadius: AppRadius.mdAll, boxShadow: context.colors.shadowCoral),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: AppRadius.smAll,
                ),
                alignment: Alignment.center,
                child: const Icon(TablerIcons.notebook, color: Colors.white, size: 20),
              ),
              AppSpacing.sm.hGap,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.t.home.createQuizTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodyMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      context.t.home.createQuizSubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.85)),
                    ),
                  ],
                ),
              ),
              AppSpacing.xs.hGap,
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Icon(TablerIcons.arrowRight, color: Colors.white, size: 18),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
