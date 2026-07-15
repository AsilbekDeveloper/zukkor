import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/num_x.dart';
import '../../../../core/locale/locale_controller.dart';
import '../../../../core/locale/locale_display.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../core/widgets/checkmark_option_list.dart';
import '../../../../i18n/strings.g.dart';

/// Single-select "choose the app language" screen — drives
/// [localeControllerProvider], so picking a language retranslates the
/// whole app immediately (and persists the choice).
class LanguageScreen extends ConsumerWidget {
  const LanguageScreen({super.key});

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.settings);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocale current = ref.watch(localeControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              BackHeader(title: context.t.settings.language, onBack: () => _goBack(context)),
              AppSpacing.lg.vGap,
              CheckmarkOptionList(
                options: [
                  for (final AppLocale locale in appLocaleDisplayOrder)
                    CheckmarkOption(
                      icon: TablerIcons.world,
                      label: locale.displayName,
                      isActive: locale == current,
                      onTap: () {
                        ref.read(localeControllerProvider.notifier).setLocale(locale);
                        _goBack(context);
                      },
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
