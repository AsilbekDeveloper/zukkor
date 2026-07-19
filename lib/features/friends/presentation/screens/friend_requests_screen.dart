import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../i18n/strings.g.dart';
import '../controllers/friend_requests_controller.dart';
import '../models/friend_request_entry.dart';
import '../widgets/friend_request_list.dart';

/// Incoming friend requests — reachable from the Friends header's badge
/// button and from tapping a `friend_request` notification.
class FriendRequestsScreen extends ConsumerStatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  ConsumerState<FriendRequestsScreen> createState() => _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends ConsumerState<FriendRequestsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(friendRequestsControllerProvider.notifier).load());
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.friends);
    }
  }

  Future<void> _accept(FriendRequestEntry entry) async {
    try {
      await ref.read(friendRequestsControllerProvider.notifier).accept(entry.id);
    } on Failure catch (e) {
      if (!mounted) return;
      context.showSnack(e.message);
    } catch (_) {
      if (!mounted) return;
      context.showSnack(t.errors.unknown);
    }
  }

  Future<void> _decline(FriendRequestEntry entry) async {
    try {
      await ref.read(friendRequestsControllerProvider.notifier).decline(entry.id);
    } on Failure catch (e) {
      if (!mounted) return;
      context.showSnack(e.message);
    } catch (_) {
      if (!mounted) return;
      context.showSnack(t.errors.unknown);
    }
  }

  @override
  Widget build(BuildContext context) {
    final entries =
        ref.watch(friendRequestsControllerProvider)?.map(FriendRequestEntry.fromEntity).toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.screenHPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              BackHeader(title: context.t.friendRequests.title, onBack: () => _goBack(context)),
              AppSpacing.lg.vGap,
              Expanded(
                child: entries == null
                    ? const Center(child: CircularProgressIndicator())
                    : entries.isEmpty
                        ? Center(
                            child: Text(
                              context.t.friendRequests.emptyState,
                              style: context.textStyles.bodySmall?.copyWith(color: context.colors.muted),
                            ),
                          )
                        : SingleChildScrollView(
                            child: FriendRequestList(
                              entries: entries,
                              onAcceptTap: _accept,
                              onDeclineTap: _decline,
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
