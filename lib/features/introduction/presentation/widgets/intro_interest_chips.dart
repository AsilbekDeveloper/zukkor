import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/constants/app_durations.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../i18n/strings.g.dart';
import '../models/intro_interest.dart';

/// Multi-select chip grid for "what are you into?" — plus an "Other" chip
/// that reveals a free-text field for interests not in the list.
class IntroInterestChips extends StatelessWidget {
  const IntroInterestChips({
    super.key,
    required this.selected,
    required this.onToggle,
    required this.otherSelected,
    required this.onToggleOther,
    required this.otherController,
  });

  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final bool otherSelected;
  final VoidCallback onToggleOther;
  final TextEditingController otherController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            for (final IntroInterest interest in IntroInterest.sample)
              _InterestChip(
                label: interest.label,
                icon: interest.icon,
                color: interest.color(context),
                isSelected: selected.contains(interest.label),
                onTap: () => onToggle(interest.label),
              ),
            _InterestChip(
              label: context.t.introduction.otherOption,
              icon: TablerIcons.dots,
              color: context.colors.muted,
              isSelected: otherSelected,
              onTap: onToggleOther,
            ),
          ],
        ),
        if (otherSelected) ...[
          AppSpacing.md.vGap,
          AppTextField(
            label: context.t.introduction.otherFieldLabel,
            hint: context.t.introduction.otherFieldHint,
            controller: otherController,
            textInputAction: TextInputAction.done,
          ),
        ],
      ],
    );
  }
}

class _InterestChip extends StatelessWidget {
  const _InterestChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // A brief overshoot "pop" on selection — the scale settles just past
    // 1.0 before AnimatedScale eases it back, so picking a chip feels
    // tactile rather than a flat color swap.
    return AnimatedScale(
      scale: isSelected ? 1.06 : 1,
      duration: AppDurations.normal,
      curve: Curves.easeOutBack,
      child: Material(
        color: isSelected ? color : context.colors.card,
        borderRadius: BorderRadius.circular(999),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(999),
          child: AnimatedContainer(
            duration: AppDurations.fast,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: isSelected ? color : context.colors.line, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: isSelected ? Colors.white : color),
                AppSpacing.xs.hGap,
                Text(
                  label,
                  style: context.textStyles.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : context.colors.ink,
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
