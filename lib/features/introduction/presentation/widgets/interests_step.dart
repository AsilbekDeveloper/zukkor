import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/step_header.dart';
import 'intro_interest_chips.dart';

/// Introduction page 5 — the "what are you into?" survey.
class InterestsStep extends StatelessWidget {
  const InterestsStep({
    super.key,
    required this.selected,
    required this.onToggle,
    required this.otherSelected,
    required this.onToggleOther,
    required this.otherController,
    this.accentColor,
  });

  final Set<String> selected;
  final ValueChanged<String> onToggle;
  final bool otherSelected;
  final VoidCallback onToggleOther;
  final TextEditingController otherController;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StepHeader(
          icon: TablerIcons.heart,
          title: AppStrings.introInterestsTitle,
          subtitle: AppStrings.introInterestsSubtitle,
          badgeColor: accentColor,
        ),
        AppSpacing.xl.vGap,
        IntroInterestChips(
          selected: selected,
          onToggle: onToggle,
          otherSelected: otherSelected,
          onToggleOther: onToggleOther,
          otherController: otherController,
        ),
      ],
    );
  }
}
