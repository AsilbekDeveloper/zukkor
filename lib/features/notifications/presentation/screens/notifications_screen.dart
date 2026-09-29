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
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/shimmer_placeholder.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/entities/notification_record.dart' show NotificationKind;
import '../controllers/notifications_controller.dart';
import '../models/notification_entry.dart';
import '../widgets/notification_list.dart';

/// The notification inbox — mirrors the prototype's `view-notifications`.
/// Loads real entries from `GET /notifications` and marks them all read
/// on open. A LIVE incoming duel challenge doesn't open from here — it
/// arrives over the duel WebSocket and opens Duel Invite directly (see
/// [HomeScreen]); a `duel_challenge` row here is always a PAST, already
/// resolved one, so tapping it goes to game history instead.
///
/// 2026-09-30, pre-launch audit finding: every kind other than
/// `friend_request` used to show a dead-end "coming soon" toast, even
/// though `duel_challenge`/`streak_reminder`/`top50`/`welcome` are all
/// real notification kinds the backend actually sends - a real user
/// would hit this often, not a hypothetical edge case.
class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
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
    switch (entry.kind) {
      case NotificationKind.friendRequest:
        context.push(AppRoutes.friendRequests);
      case NotificationKind.top50:
        context.push(AppRoutes.fullLeaderboard);
      case NotificationKind.duelChallenge:
        context.push(AppRoutes.history);
      case NotificationKind.streakReminder:
      case NotificationKind.welcome:
        context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final notificationsState = ref.watch(notificationsControllerProvider);
    final entries = notificationsState.data
        ?.map(NotificationEntry.fromEntity)
        .toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.screenHPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              FadeSlideIn(
                child: BackHeader(
                  title: context.t.notifications.title,
                  onBack: () => _goBack(context),
                ),
              ),
              AppSpacing.lg.vGap,
              Expanded(
                child: notificationsState.hasError
                    ? ErrorRetryView(
                        onRetry: () => ref
                            .read(notificationsControllerProvider.notifier)
                            .load(),
                      )
                    : entries == null
                    ? const ShimmerListSkeleton()
                    : entries.isEmpty
                    ? FadeSlideIn(
                        delay: const Duration(milliseconds: 60),
                        child: Center(
                          child: Text(
                            context.t.notifications.emptyState,
                            style: context.textStyles.bodySmall?.copyWith(
                              color: context.colors.muted,
                            ),
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        child: FadeSlideIn(
                          delay: const Duration(milliseconds: 60),
                          child: NotificationList(
                            entries: entries,
                            onEntryTap: (entry) => _onEntryTap(context, entry),
                          ),
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
