import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../i18n/strings.g.dart';
import '../../../profile/presentation/widgets/settings_list.dart';
import '../../domain/entities/notification_preferences.dart';
import '../controllers/notification_preferences_controller.dart';

/// Which notification categories are on/off — mirrors the 5 types shown
/// in the Notifications inbox (duel challenge, streak reminder, top-50,
/// friend request, welcome/product tips).
///
/// Real `GET|PATCH /users/me/notification-preferences`: toggling flips
/// the switch immediately (optimistic) and saves in the background;
/// a failed save reverts the switch and shows an error.
class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  // Optimistic local copy — once set, takes priority over the provider's
  // state so a save-in-flight (or a revert after a failed save) doesn't
  // flicker back to a stale server value mid-toggle.
  NotificationPreferences? _current;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(notificationPreferencesControllerProvider.notifier).load());
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.settings);
    }
  }

  Future<void> _toggle(NotificationPreferences updated) async {
    final NotificationPreferences? previous = _current;
    setState(() => _current = updated);
    try {
      await ref.read(notificationPreferencesControllerProvider.notifier).update(updated);
    } on Failure catch (e) {
      if (!mounted) return;
      setState(() => _current = previous);
      context.showSnack(e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _current = previous);
      context.showSnack(t.errors.unknown);
    }
  }

  SettingsRowData _toggleRow({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SettingsRowData(
      icon: icon,
      label: label,
      trailingWidget: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: context.colors.coral,
      ),
      onTap: () => onChanged(!value),
    );
  }

  @override
  Widget build(BuildContext context) {
    final NotificationPreferences? prefs = _current ?? ref.watch(notificationPreferencesControllerProvider);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              BackHeader(title: context.t.notificationSettings.title, onBack: () => _goBack(context)),
              AppSpacing.lg.vGap,
              if (prefs == null)
                const Center(child: CircularProgressIndicator())
              else
                SettingsList(
                  rows: [
                    _toggleRow(
                      icon: TablerIcons.swords,
                      label: context.t.notificationSettings.duelInvites,
                      value: prefs.duelInvites,
                      onChanged: (v) => _toggle(prefs.copyWith(duelInvites: v)),
                    ),
                    _toggleRow(
                      icon: TablerIcons.flame,
                      label: context.t.notificationSettings.streakReminders,
                      value: prefs.streakReminders,
                      onChanged: (v) => _toggle(prefs.copyWith(streakReminders: v)),
                    ),
                    _toggleRow(
                      icon: TablerIcons.trophy,
                      label: context.t.notificationSettings.leaderboardUpdates,
                      value: prefs.leaderboardUpdates,
                      onChanged: (v) => _toggle(prefs.copyWith(leaderboardUpdates: v)),
                    ),
                    _toggleRow(
                      icon: TablerIcons.userPlus,
                      label: context.t.notificationSettings.friendRequests,
                      value: prefs.friendRequests,
                      onChanged: (v) => _toggle(prefs.copyWith(friendRequests: v)),
                    ),
                    _toggleRow(
                      icon: TablerIcons.sparkles,
                      label: context.t.notificationSettings.productUpdates,
                      value: prefs.productUpdates,
                      onChanged: (v) => _toggle(prefs.copyWith(productUpdates: v)),
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
