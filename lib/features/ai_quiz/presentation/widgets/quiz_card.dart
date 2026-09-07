import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/pressable_scale.dart';
import '../../../../i18n/strings.g.dart';

/// One tile in [DiscoverScreen]'s quiz grid. Vertical "app-store card"
/// layout so all four pieces of info the user actually wants when
/// scanning a list of other people's quizzes fit without crowding a
/// single row: category (icon + chip), name, creator, and question
/// count.
class QuizCard extends StatelessWidget {
  const QuizCard({
    required this.name,
    required this.questionCount,
    required this.creatorName,
    required this.onTap,
    this.topicName,
    super.key,
  });

  final String name;
  final int questionCount;
  final String creatorName;
  final String? topicName;
  final VoidCallback onTap;

  static const double _iconSize = 34;

  /// The fixed cell height every card in the grid needs, driven by its
  /// WORST-CASE content (a full 2-line name, scaled by [TextScaler]) —
  /// not a `childAspectRatio` (forbidden for grids in this app: a ratio
  /// ties height to width and collapses below the real content height on
  /// a narrow phone). A quiz with a short one-line name doesn't stretch
  /// to fill this - the card's `spaceBetween` column just leaves its
  /// footer row anchored to the bottom instead of floating right under
  /// the name, so every tile in the grid still lines up.
  static double gridExtent(BuildContext context) {
    final TextScaler scaler = MediaQuery.textScalerOf(context);
    final double nameLine = (scaler.scale(14.5) * 1.2).ceilToDouble();
    final double nameBlock = nameLine * 2;
    final double creatorLine = (scaler.scale(11) * 1.2).ceilToDouble();
    final double footerLine = (scaler.scale(11) * 1.2).ceilToDouble();
    const double footerChipPadding = 4;
    const double verticalPadding = AppSpacing.sm * 2;
    const double gaps = AppSpacing.xs + AppSpacing.xxs + AppSpacing.sm;
    return _iconSize +
        nameBlock +
        creatorLine +
        footerLine +
        footerChipPadding +
        verticalPadding +
        gaps;
  }

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      child: Material(
        color: context.colors.card,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          onTap: () {
            HapticFeedback.lightImpact();
            onTap();
          },
          borderRadius: AppRadius.mdAll,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: AppRadius.mdAll,
              border: Border.all(color: context.colors.line),
              boxShadow: context.colors.shadowSm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: _iconSize,
                      height: _iconSize,
                      decoration: BoxDecoration(
                        color: context.colors.coral,
                        borderRadius: AppRadius.smAll,
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        TablerIcons.sparkle,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    AppSpacing.xs.vGap,
                    Text(
                      name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.colors.ink,
                        height: 1.2,
                      ),
                    ),
                    AppSpacing.xxs.vGap,
                    Text(
                      creatorName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.labelSmall,
                    ),
                  ],
                ),
                AppSpacing.sm.vGap,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: topicName == null
                          ? const SizedBox.shrink()
                          : Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: context.colors.teal.withValues(
                                  alpha: 0.12,
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                topicName!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.textStyles.labelSmall?.copyWith(
                                  color: context.colors.teal,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                    ),
                    AppSpacing.xs.hGap,
                    Text(
                      context.t.common.questionCount(count: questionCount),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textStyles.labelSmall?.copyWith(
                        color: context.colors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
