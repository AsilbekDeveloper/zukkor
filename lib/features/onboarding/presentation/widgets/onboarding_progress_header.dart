import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';

/// Top bar shown on every wizard step: back button, a progress bar that
/// fills as the user advances, and a "step / total" counter — mirrors the
/// prototype's `.setup-topbar`.
class OnboardingProgressHeader extends StatelessWidget {
  const OnboardingProgressHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.onBack,
  });

  final int currentStep;
  final int totalSteps;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          icon: const Icon(TablerIcons.arrowLeft),
        ),
        AppSpacing.xs.hGap,
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.xxs),
            child: LinearProgressIndicator(
              value: currentStep / totalSteps,
              minHeight: 6,
              backgroundColor: context.colors.line,
              valueColor: AlwaysStoppedAnimation(context.colors.coral),
            ),
          ),
        ),
        AppSpacing.sm.hGap,
        Text(
          '$currentStep/$totalSteps',
          style: context.textStyles.bodySmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colors.ink2,
          ),
        ),
      ],
    );
  }
}
