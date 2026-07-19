import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/audio/sound_controller.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/locale/locale_controller.dart';
import '../../../../core/locale/locale_display.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/theme_controller.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../i18n/strings.g.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../../profile/presentation/widgets/settings_list.dart';

/// The Settings screen — mirrors the prototype's `view-settings`: a
/// "General" group (language, notifications, a theme switch) and an
/// "Account" group (privacy, help, terms), plus a standalone "Log out"
/// row.
///
/// CURRENT STATE: the theme switch is real — it drives [themeControllerProvider],
/// which persists the choice and re-themes the whole app. The sound
/// effects switch is likewise real — it drives [soundControllerProvider],
/// which every [AppSound] call site checks before playing. Language is
/// also real — it drives [localeControllerProvider], which persists the
/// choice and retranslates the app. Notification toggles and the Log out
/// row are otherwise real; Log out clears back to the Login screen,
/// matching the prototype's `data-nav="login"`.
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  List<Widget> _generalGroup(BuildContext context, bool isDark, bool soundEnabled, String language) => [
        _GroupLabel(context.t.settings.groupGeneral),
        AppSpacing.xs.vGap,
        SettingsList(
          rows: [
            SettingsRowData(
              icon: TablerIcons.world,
              label: context.t.settings.language,
              trailingLabel: language,
              onTap: () => context.push(AppRoutes.languageSettings),
            ),
            SettingsRowData(
              icon: TablerIcons.bell,
              label: context.t.settings.notifications,
              onTap: () => context.push(AppRoutes.notificationSettings),
            ),
            SettingsRowData(
              icon: TablerIcons.moon,
              label: context.t.settings.theme,
              trailingLabel: isDark ? context.t.settings.themeDark : context.t.settings.themeLight,
              trailingWidget: Switch(
                value: isDark,
                onChanged: (value) => ref.read(themeControllerProvider.notifier).toggleDark(value),
                activeThumbColor: context.colors.coral,
              ),
              onTap: () => ref.read(themeControllerProvider.notifier).toggleDark(!isDark),
            ),
            SettingsRowData(
              icon: TablerIcons.volume2,
              label: context.t.settings.soundEffects,
              trailingWidget: Switch(
                value: soundEnabled,
                onChanged: (value) => ref.read(soundControllerProvider.notifier).setEnabled(value),
                activeThumbColor: context.colors.coral,
              ),
              onTap: () => ref.read(soundControllerProvider.notifier).setEnabled(!soundEnabled),
            ),
          ],
        ),
      ];

  List<Widget> _accountGroup(BuildContext context) => [
        _GroupLabel(context.t.settings.groupAccount),
        AppSpacing.xs.vGap,
        SettingsList(
          rows: [
            SettingsRowData(
              icon: TablerIcons.lock,
              label: context.t.settings.privacy,
              onTap: () => context.push(AppRoutes.privacyPolicy),
            ),
            SettingsRowData(
              icon: TablerIcons.helpCircle,
              label: context.t.settings.helpCenter,
              onTap: () => context.push(AppRoutes.helpCenter),
            ),
            SettingsRowData(
              icon: TablerIcons.fileText,
              label: context.t.settings.termsOfUse,
              onTap: () => context.push(AppRoutes.termsOfUse),
            ),
            SettingsRowData(
              icon: TablerIcons.key,
              label: context.t.settings.changePassword,
              onTap: () => context.push(AppRoutes.changePassword),
            ),
          ],
        ),
      ];

  Future<void> _logOut() async {
    // Tokenlar lokal xotiradan har doim tozalanadi (repository'ning
    // `finally` blokida) — server so'rovi (refresh token'ni bekor qilish)
    // muvaffaqiyatsiz bo'lsa ham, foydalanuvchi qurilmada baribir chiqishi
    // kerak, shuning uchun xatolik e'tiborsiz qoldiriladi.
    try {
      await ref.read(authControllerProvider.notifier).logout();
    } catch (_) {
      // e'tiborsiz qoldiriladi — pastga qarang.
    }
    if (!mounted) return;
    context.go(AppRoutes.login);
  }

  Widget _logOutGroup(BuildContext context) => SettingsList(
        rows: [
          SettingsRowData(
            icon: TablerIcons.logout,
            label: context.t.settings.logOut,
            isDanger: true,
            trailingWidget: const SizedBox.shrink(),
            onTap: _logOut,
          ),
        ],
      );

  Future<void> _deleteAccount() async {
    final bool? deleted = await ConfirmDialog.show(
      context,
      title: context.t.deleteAccount.confirmTitle,
      message: context.t.deleteAccount.confirmMessage,
      confirmLabel: context.t.deleteAccount.confirmButton,
      isDanger: true,
      passwordLabel: context.t.auth.passwordLabel,
      passwordHint: context.t.auth.passwordHint,
      onConfirm: (password) => ref.read(authControllerProvider.notifier).deleteAccount(password!),
    );
    if (deleted != true || !mounted) return;
    context.go(AppRoutes.login);
  }

  List<Widget> _dangerZoneGroup(BuildContext context) => [
        _GroupLabel(context.t.settings.groupDangerZone),
        AppSpacing.xs.vGap,
        SettingsList(
          rows: [
            SettingsRowData(
              icon: TablerIcons.userX,
              label: context.t.settings.deleteAccount,
              isDanger: true,
              trailingWidget: const SizedBox.shrink(),
              onTap: _deleteAccount,
            ),
          ],
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final double hPad = context.screenHPad;
    final bool isDark = ref.watch(themeControllerProvider) == ThemeMode.dark;
    final bool soundEnabled = ref.watch(soundControllerProvider);
    final String language = ref.watch(localeControllerProvider).displayName;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(hPad, AppSpacing.xs, hPad, AppSpacing.lg),
          children: [
            BackHeader(title: context.t.profile.settings, onBack: () => context.pop()),
            AppSpacing.lg.vGap,
            ..._generalGroup(context, isDark, soundEnabled, language),
            AppSpacing.md.vGap,
            ..._accountGroup(context),
            AppSpacing.md.vGap,
            _logOutGroup(context),
            AppSpacing.md.vGap,
            ..._dangerZoneGroup(context),
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
