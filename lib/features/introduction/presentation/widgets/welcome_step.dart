import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/pill_segment_control.dart';
import 'intro_explainer_page.dart';

/// Introduction page 1 — the welcome explainer plus a language picker,
/// since this is the very first screen the app ever shows.
///
/// CURRENT STATE: presentation only, same as Settings' own language
/// picker — there's no i18n layer yet, so picking a language just
/// records the choice without retranslating anything.
class WelcomeStep extends StatelessWidget {
  const WelcomeStep({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageChanged,
  });

  static const List<String> languages = [
    AppStrings.languageEnglish,
    AppStrings.languageUzbek,
    AppStrings.languageRussian,
  ];

  final String selectedLanguage;
  final ValueChanged<String> onLanguageChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IntroExplainerPage(
          icon: TablerIcons.sparkles,
          iconColor: context.colors.coral,
          title: AppStrings.introWelcomeTitle,
          subtitle: AppStrings.introWelcomeSubtitle,
        ),
        AppSpacing.xl.vGap,
        Text(
          AppStrings.introLanguageLabel,
          textAlign: TextAlign.center,
          style: context.textStyles.titleMedium,
        ),
        AppSpacing.sm.vGap,
        PillSegmentControl<String>(
          values: languages,
          selected: selectedLanguage,
          labelBuilder: (value) => value,
          onChanged: onLanguageChanged,
        ),
      ],
    );
  }
}
