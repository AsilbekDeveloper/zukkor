import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/constants/app_durations.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../i18n/strings.g.dart';

/// Introduction-only progress bar: back button, a row of pill segments
/// (one per page, filled as the player advances) and a Skip button — a
/// more playful, game-like alternative to the shared
/// `OnboardingProgressHeader`'s single bar. Kept as its own widget so
/// this styling doesn't leak into the profile-setup wizard.
class IntroProgressHeader extends StatelessWidget {
  const IntroProgressHeader({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.onSkip,
    this.onBack,
  });

  final int currentStep;
  final int totalSteps;
  final VoidCallback onSkip;

  /// Null hides the back button (page 1 has nothing to go back to) while
  /// keeping the segments aligned.
  final VoidCallback? onBack;

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
          child: Row(
            children: [
              for (int i = 0; i < totalSteps; i++) ...[
                Expanded(
                  child: _Segment(filled: i < currentStep, isCurrent: i == currentStep - 1),
                ),
                if (i < totalSteps - 1) AppSpacing.xxs.hGap,
              ],
            ],
          ),
        ),
        AppSpacing.xs.hGap,
        TextButton(onPressed: onSkip, child: Text(context.t.introduction.skip)),
      ],
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({required this.filled, required this.isCurrent});

  final bool filled;
  final bool isCurrent;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: AppDurations.normal,
      curve: AppDurations.ease,
      height: isCurrent ? 8 : 6,
      decoration: BoxDecoration(
        color: filled ? context.colors.coral : context.colors.line,
        borderRadius: BorderRadius.circular(999),
        boxShadow: isCurrent
            ? [BoxShadow(color: context.colors.coral.withValues(alpha: 0.4), blurRadius: 8)]
            : null,
      ),
    );
  }
}
