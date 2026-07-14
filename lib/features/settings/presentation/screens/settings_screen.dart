import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../profile/presentation/widgets/settings_list.dart';

/// The Settings screen — mirrors the prototype's `view-settings`: a
/// "General" group (language, notifications, a theme switch) and an
/// "Account" group (privacy, help, terms), plus a standalone "Log out"
/// row.
///
/// CURRENT STATE: the theme switch is real — it drives [themeControllerProvider],
/// which persists the choice and re-themes the whole app. Language only
/// changes the selection shown here — no i18n mechanism exists yet.
/// Notification toggles and the Log out row are otherwise real; Log out
/// clears back to the Login screen, matching the prototype's
/// `data-nav="login"`.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _language = AppStrings.languageEnglish;

  Future<void> _openLanguage(BuildContext context) async {
    final String? result =
        await context.push<String>(AppRoutes.languageSettings, extra: _language);
    if (!mounted || result == null) return;
    setState(() => _language = result);
  }

  List<Widget> _generalGroup(BuildContext context, bool isDark) => [
        const _GroupLabel(AppStrings.settingsGroupGeneral),
        AppSpacing.xs.vGap,
        SettingsList(
          rows: [
            SettingsRowData(
              icon: TablerIcons.world,
              label: AppStrings.settingsLanguage,
              trailingLabel: _language,
              onTap: () => _openLanguage(context),
            ),
            SettingsRowData(
              icon: TablerIcons.bell,
              label: AppStrings.settingsNotifications,
              onTap: () => context.push(AppRoutes.notificationSettings),
            ),
            SettingsRowData(
              icon: TablerIcons.moon,
              label: AppStrings.settingsTheme,
              trailingLabel: isDark ? AppStrings.settingsThemeDark : AppStrings.settingsThemeLight,
              trailingWidget: Switch(
                value: isDark,
                onChanged: (value) => ref.read(themeControllerProvider.notifier).toggleDark(value),
                activeThumbColor: context.colors.coral,
              ),
              onTap: () => ref.read(themeControllerProvider.notifier).toggleDark(!isDark),
            ),
          ],
        ),
      ];

  List<Widget> _accountGroup(BuildContext context) => [
        const _GroupLabel(AppStrings.settingsGroupAccount),
        AppSpacing.xs.vGap,
        SettingsList(
          rows: [
            SettingsRowData(
              icon: TablerIcons.lock,
              label: AppStrings.settingsPrivacy,
              onTap: () => context.push(AppRoutes.privacyPolicy),
            ),
            SettingsRowData(
              icon: TablerIcons.helpCircle,
              label: AppStrings.settingsHelpCenter,
              onTap: () => context.push(AppRoutes.helpCenter),
            ),
            SettingsRowData(
              icon: TablerIcons.fileText,
              label: AppStrings.settingsTermsOfUse,
              onTap: () => context.push(AppRoutes.termsOfUse),
            ),
          ],
        ),
      ];

  Widget _logOutGroup(BuildContext context) => SettingsList(
        rows: [
          SettingsRowData(
            icon: TablerIcons.logout,
            label: AppStrings.settingsLogOut,
            isDanger: true,
            trailingWidget: const SizedBox.shrink(),
            onTap: () => context.go(AppRoutes.login),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    final double hPad = context.screenHPad;
    final bool isDark = ref.watch(themeControllerProvider) == ThemeMode.dark;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(hPad, AppSpacing.xs, hPad, AppSpacing.lg),
          children: [
            BackHeader(title: AppStrings.settings, onBack: () => context.pop()),
            AppSpacing.lg.vGap,
            ..._generalGroup(context, isDark),
            AppSpacing.md.vGap,
            ..._accountGroup(context),
            AppSpacing.md.vGap,
            _logOutGroup(context),
          ],
        ),
      ),
    );
  }
}

/// Small uppercase caption — mirrors the prototype's `.settings-group-label`.
class _GroupLabel extends StatelessWidget {
  const _GroupLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxs),
      child: Text(
        text.toUpperCase(),
        style: context.textStyles.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
