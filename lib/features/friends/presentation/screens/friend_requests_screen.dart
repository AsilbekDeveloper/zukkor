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
import '../../../../core/widgets/error_retry_view.dart';
import '../../../../core/widgets/fade_slide_in.dart';
import '../../../../core/widgets/shimmer_placeholder.dart';
import '../../../../i18n/strings.g.dart';
import '../controllers/friend_requests_controller.dart';
import '../models/friend_request_entry.dart';
import '../widgets/friend_request_list.dart';

/// Incoming friend requests — reachable from the Friends header's badge
/// button and from tapping a `friend_request` notification.
class FriendRequestsScreen extends ConsumerStatefulWidget {
  const FriendRequestsScreen({super.key});

  @override
  ConsumerState<FriendRequestsScreen> createState() =>
      _FriendRequestsScreenState();
}

class _FriendRequestsScreenState extends ConsumerState<FriendRequestsScreen> {
  /// So'rov hali javob kutayotgan yozuvlar — tugmalar shu vaqtda
  /// o'chirilgan turadi. Aks holda tez ketma-ket ikki bosish bitta
  /// so'rovga IKKITA accept/decline chaqiruvi yuborardi (backend'da
  /// buning oldini oluvchi cheklov yo'q, va bunday holatda ikkinchi
  /// chaqiruv chalkash xato snackbar'i bilan tugardi).
  final Set<String> _processingIds = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(friendRequestsControllerProvider.notifier).load(),
    );
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.friends);
    }
  }

  Future<void> _accept(FriendRequestEntry entry) async {
    if (_processingIds.contains(entry.id)) return;
    setState(() => _processingIds.add(entry.id));
    try {
      await ref
          .read(friendRequestsControllerProvider.notifier)
          .accept(entry.id);
    } on Failure catch (e) {
      if (!mounted) return;
      context.showSnack(e.message);
    } catch (_) {
      if (!mounted) return;
      context.showSnack(t.errors.unknown);
    } finally {
      if (mounted) setState(() => _processingIds.remove(entry.id));
    }
  }

  Future<void> _decline(FriendRequestEntry entry) async {
    if (_processingIds.contains(entry.id)) return;
    setState(() => _processingIds.add(entry.id));
    try {
      await ref
          .read(friendRequestsControllerProvider.notifier)
          .decline(entry.id);
    } on Failure catch (e) {
      if (!mounted) return;
      context.showSnack(e.message);
    } catch (_) {
      if (!mounted) return;
      context.showSnack(t.errors.unknown);
    } finally {
      if (mounted) setState(() => _processingIds.remove(entry.id));
    }
  }

  void _openPlayerDetail(FriendRequestEntry entry) {
    context.push(
      AppRoutes.playerDetail,
      extra: {
        'userId': entry.userId,
        'relation': 'incomingRequest',
        'requestId': entry.id,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final friendRequestsState = ref.watch(friendRequestsControllerProvider);
    final entries = friendRequestsState.data
        ?.map(FriendRequestEntry.fromEntity)
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
                  title: context.t.friendRequests.title,
                  onBack: () => _goBack(context),
                ),
              ),
              AppSpacing.lg.vGap,
              Expanded(
                child: friendRequestsState.hasError
                    ? ErrorRetryView(
                        onRetry: () => ref
                            .read(friendRequestsControllerProvider.notifier)
                            .load(),
                      )
                    : entries == null
                    ? const ShimmerListSkeleton(count: 4, trailingWidth: 80)
                    : entries.isEmpty
                    ? FadeSlideIn(
                        delay: const Duration(milliseconds: 60),
                        child: Center(
                          child: Text(
                            context.t.friendRequests.emptyState,
                            style: context.textStyles.bodySmall?.copyWith(
                              color: context.colors.muted,
                            ),
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        child: FadeSlideIn(
                          delay: const Duration(milliseconds: 60),
                          child: FriendRequestList(
                            entries: entries,
                            processingIds: _processingIds,
                            onAcceptTap: _accept,
                            onDeclineTap: _decline,
                            onRowTap: _openPlayerDetail,
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
