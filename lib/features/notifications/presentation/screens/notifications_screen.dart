import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../core/widgets/error_retry_view.dart';
import '../../../../core/widgets/shimmer_placeholder.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/entities/notification_record.dart' show NotificationKind;
import '../controllers/notifications_controller.dart';
import '../models/notification_entry.dart';
import '../widgets/notification_list.dart';

/// The notification inbox — mirrors the prototype's `view-notifications`.
/// Loads real entries from `GET /notifications` and marks them all read
/// on open. A real incoming duel challenge no longer opens from here —
/// it arrives live over the duel WebSocket and opens Duel Invite directly
/// (see [HomeScreen]). Tapping a `friend_request` entry opens the Friend
/// Requests screen; other kinds still show a coming-soon snackbar.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref.read(notificationsControllerProvider.notifier).load();
      if (!mounted) return;
      await ref.read(notificationsControllerProvider.notifier).markAllRead();
    });
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  void _onEntryTap(BuildContext context, NotificationEntry entry) {
    if (entry.kind == NotificationKind.friendRequest) {
      context.push(AppRoutes.friendRequests);
      return;
    }
    context.showSnack(context.t.bottomNav.comingSoon);
  }

  @override
  Widget build(BuildContext context) {
    final notificationsState = ref.watch(notificationsControllerProvider);
    final entries = notificationsState.data?.map(NotificationEntry.fromEntity).toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.screenHPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              BackHeader(title: context.t.notifications.title, onBack: () => _goBack(context)),
              AppSpacing.lg.vGap,
              Expanded(
                child: notificationsState.hasError
                    ? ErrorRetryView(onRetry: () => ref.read(notificationsControllerProvider.notifier).load())
                    : entries == null
                    ? const ShimmerListSkeleton()
                    : entries.isEmpty
                        ? Center(
                            child: Text(
                              context.t.notifications.emptyState,
                              style: context.textStyles.bodySmall?.copyWith(color: context.colors.muted),
                            ),
                          )
                        : SingleChildScrollView(
                            child: NotificationList(
                              entries: entries,
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
