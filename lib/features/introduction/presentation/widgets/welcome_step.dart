import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/locale/locale_controller.dart';
import '../../../../core/locale/locale_display.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/pill_segment_control.dart';
import '../../../../i18n/strings.g.dart';
import 'intro_explainer_page.dart';

/// Introduction page 1 — the welcome explainer plus a language picker,
/// since this is the very first screen the app ever shows. Picking a
/// language here retranslates the whole app immediately via
/// [localeControllerProvider].
class WelcomeStep extends ConsumerWidget {
  const WelcomeStep({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocale current = ref.watch(localeControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IntroExplainerPage(
          icon: TablerIcons.sparkles,
          iconColor: context.colors.coral,
          title: context.t.introduction.welcomeTitle,
          subtitle: context.t.introduction.welcomeSubtitle,
        ),
        AppSpacing.xl.vGap,
        Text(
          context.t.introduction.languageLabel,
          textAlign: TextAlign.center,
          style: context.textStyles.titleMedium,
        ),
        AppSpacing.sm.vGap,
        PillSegmentControl<AppLocale>(
          values: appLocaleDisplayOrder,
          selected: current,
          labelBuilder: (locale) => locale.displayName,
          onChanged: (locale) {
            HapticFeedback.selectionClick();
            ref.read(localeControllerProvider.notifier).setLocale(locale);
          },
        ),
      ],
    );
  }
}
