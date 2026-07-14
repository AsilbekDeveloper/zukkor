import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';

/// Shared header for each wizard step: a colored icon badge, a headline,
/// and a short explanatory subtext — mirrors the prototype's
/// `.setup-badge` / `.setup-headline` / `.setup-subtext`.
class StepHeader extends StatelessWidget {
  const StepHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badgeColor,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  /// Defaults to the brand coral if not given.
  final Color? badgeColor;

  @override
  Widget build(BuildContext context) {
    final Color color = badgeColor ?? context.colors.coral;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(color: color, borderRadius: AppRadius.smAll),
          alignment: Alignment.center,
          child: Icon(icon, color: Colors.white, size: 26),
        ),
        AppSpacing.md.vGap,
        Text(title, style: context.textStyles.headlineMedium),
        AppSpacing.xxs.vGap,
        Text(subtitle, style: context.textStyles.bodyMedium),
      ],
    );
  }
}
