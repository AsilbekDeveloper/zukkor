import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../core/widgets/checkmark_option_list.dart';

/// Single-select "choose the app language" screen. Pops with the chosen
/// language name; the caller (Settings) reflects it in the Language row.
///
/// CURRENT STATE: presentation only — there's no i18n mechanism yet
/// (`AppStrings` is English-only for now), so picking a language changes
/// the selection shown here and on Settings but doesn't retranslate the
/// app.
class LanguageScreen extends StatelessWidget {
  const LanguageScreen({required this.currentLanguage, super.key});

  final String currentLanguage;

  static const List<String> _languages = [
    AppStrings.languageEnglish,
    AppStrings.languageUzbek,
    AppStrings.languageRussian,
  ];

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop(currentLanguage);
    } else {
      context.go(AppRoutes.settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              BackHeader(title: AppStrings.settingsLanguage, onBack: () => _goBack(context)),
              AppSpacing.lg.vGap,
              CheckmarkOptionList(
                options: [
                  for (final String language in _languages)
                    CheckmarkOption(
                      icon: TablerIcons.world,
                      label: language,
                      isActive: language == currentLanguage,
                      onTap: () => context.pop(language),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
