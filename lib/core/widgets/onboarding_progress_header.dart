import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../extensions/context_x.dart';
import '../extensions/num_x.dart';
import '../theme/app_spacing.dart';

/// Top bar shown on every wizard step: back button, a progress bar that
/// fills as the user advances, and a "step / total" counter — mirrors the
/// prototype's `.setup-topbar`. Shared by the Onboarding wizard and the
/// Introduction walkthrough.
class OnboardingProgressHeader extends StatelessWidget {
  const OnboardingProgressHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onBack,
    this.trailing,
  });

  final int currentStep;
  final int totalSteps;

  /// Null hides the back button (e.g. the first page of a flow with no
  /// screen to go back to) while keeping the progress bar aligned.
  final VoidCallback? onBack;

  /// Optional trailing widget, e.g. a "Skip" button.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onBack != null)
          IconButton(
            onPressed: onBack,
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            icon: const Icon(TablerIcons.arrowLeft),
          )
        else
          const SizedBox(width: 48),
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
        if (trailing != null) ...[AppSpacing.xs.hGap, trailing!],
      ],
    );
  }
}
