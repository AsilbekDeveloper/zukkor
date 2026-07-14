import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/back_header.dart';
import '../models/notification_entry.dart';
import '../widgets/notification_list.dart';

/// The notification inbox — mirrors the prototype's `view-notifications`.
/// Only the duel-challenge row opens a real screen (Duel Invite); the
/// rest have no destination yet, matching the prototype's `data-nav`.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  void _onEntryTap(BuildContext context, NotificationEntry entry) {
    if (entry.opensDuelInvite) {
      context.push(AppRoutes.duelInvite);
    } else {
      context.showSnack(AppStrings.comingSoon);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.screenHPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              BackHeader(title: AppStrings.notificationsTitle, onBack: () => _goBack(context)),
              AppSpacing.lg.vGap,
              Expanded(
                child: SingleChildScrollView(
                  child: NotificationList(
                    entries: NotificationEntry.sample,
                    onEntryTap: (entry) => _onEntryTap(context, entry),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
