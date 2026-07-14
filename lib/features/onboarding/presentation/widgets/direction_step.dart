import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/step_header.dart';
import '../models/onboarding_direction.dart';

/// Onboarding step 3 — single-select "why are you using Zukkor" cards
/// (Zukkor_Profil_Yaratish.docx: `direction`, required).
class DirectionStep extends StatelessWidget {
  const DirectionStep({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final OnboardingDirection? selected;
  final ValueChanged<OnboardingDirection> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const StepHeader(
          icon: TablerIcons.compass,
          title: AppStrings.directionStepTitle,
          subtitle: AppStrings.directionStepSubtitle,
        ),
        AppSpacing.xl.vGap,
        for (final OnboardingDirection direction in OnboardingDirection.values)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _DirectionCard(
              direction: direction,
              isSelected: direction == selected,
              onTap: () => onSelected(direction),
            ),
          ),
      ],
    );
  }
}

class _DirectionCard extends StatelessWidget {
  const _DirectionCard({
    required this.direction,
    required this.isSelected,
    required this.onTap,
  });

  final OnboardingDirection direction;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color accent = direction.accentColor(context);

    return Material(
      color: context.colors.card,
      borderRadius: AppRadius.mdAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.mdAll,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadius.mdAll,
            border: Border.all(
              color: isSelected ? accent : context.colors.line,
              width: isSelected ? 2 : 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Icon(direction.icon, color: Colors.white, size: 22),
              ),
              AppSpacing.sm.hGap,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(direction.title, style: context.textStyles.titleMedium),
                    Text(direction.subtitle, style: context.textStyles.bodySmall),
                  ],
                ),
              ),
              AppSpacing.xs.hGap,
              _RadioIndicator(isSelected: isSelected, accent: accent),
            ],
          ),
        ),
      ),
    );
  }
}

class _RadioIndicator extends StatelessWidget {
  const _RadioIndicator({required this.isSelected, required this.accent});

  final bool isSelected;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? accent : Colors.transparent,
        border: Border.all(
          color: isSelected ? accent : context.colors.line,
          width: 2,
        ),
      ),
      alignment: Alignment.center,
      // Plain Material checkmark on purpose — same reasoning as the
      // avatar color swatch: it sits on a circle we already draw.
      child: isSelected
          ? const Icon(TablerIcons.check, color: Colors.white, size: 16)
          : null,
    );
  }
}
