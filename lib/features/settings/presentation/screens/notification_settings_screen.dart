import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../i18n/strings.g.dart';
import '../../../profile/presentation/widgets/settings_list.dart';

/// Which notification categories are on/off — mirrors the 5 types shown
/// in the Notifications inbox (duel challenge, streak reminder, top-50,
/// friend request, welcome/product tips).
///
/// CURRENT STATE: presentation only — toggling flips local state (all on
/// by default) but there's no push-notification backend to actually
/// subscribe/unsubscribe from yet.
class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _duelInvites = true;
  bool _streakReminders = true;
  bool _leaderboardUpdates = true;
  bool _friendRequests = true;
  bool _productUpdates = true;

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.settings);
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
              SettingsList(
                rows: [
                  _toggleRow(
                    icon: TablerIcons.swords,
                    label: context.t.notificationSettings.duelInvites,
                    value: _duelInvites,
                    onChanged: (v) => setState(() => _duelInvites = v),
                  ),
                  _toggleRow(
                    icon: TablerIcons.flame,
                    label: context.t.notificationSettings.streakReminders,
                    value: _streakReminders,
                    onChanged: (v) => setState(() => _streakReminders = v),
                  ),
                  _toggleRow(
                    icon: TablerIcons.trophy,
                    label: context.t.notificationSettings.leaderboardUpdates,
                    value: _leaderboardUpdates,
                    onChanged: (v) => setState(() => _leaderboardUpdates = v),
                  ),
                  _toggleRow(
                    icon: TablerIcons.userPlus,
                    label: context.t.notificationSettings.friendRequests,
                    value: _friendRequests,
                    onChanged: (v) => setState(() => _friendRequests = v),
                  ),
                  _toggleRow(
                    icon: TablerIcons.sparkles,
                    label: context.t.notificationSettings.productUpdates,
                    value: _productUpdates,
                    onChanged: (v) => setState(() => _productUpdates = v),
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
