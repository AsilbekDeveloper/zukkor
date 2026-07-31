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
import '../controllers/friends_controller.dart';
import '../models/friend_entry.dart';
import '../widgets/friend_list.dart';

/// Choose a friend to challenge to a 1v1 duel — mirrors the prototype's
/// `view-duel`, now over the real friends list (there's no online/offline
/// restriction — any friend can be challenged).
///
/// Picking a friend opens the Categories screen with that friend as the
/// pending duel opponent — the same category picker Solo uses, per the
/// prototype's `pendingDuelOpponent` flow.
class DuelScreen extends ConsumerStatefulWidget {
  const DuelScreen({super.key});

  @override
  ConsumerState<DuelScreen> createState() => _DuelScreenState();
}

class _DuelScreenState extends ConsumerState<DuelScreen> {
  @override
  void initState() {
    super.initState();
    if (ref.read(friendsControllerProvider).data == null) {
      Future.microtask(() => ref.read(friendsControllerProvider.notifier).load());
    }
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  void _openPlayerDetail(BuildContext context, FriendEntry friend) {
    final String? id = friend.id;
    if (id == null) return;
    context.push(AppRoutes.playerDetail, extra: {'userId': id, 'relation': 'friend'});
  }

  @override
  Widget build(BuildContext context) {
    final friendsState = ref.watch(friendsControllerProvider);
    final List<FriendEntry>? friends = friendsState.data?.map(FriendEntry.fromEntity).toList();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.screenHPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              BackHeader(title: context.t.duelPick.title, onBack: () => _goBack(context)),
              AppSpacing.lg.vGap,
              Text(context.t.duelPick.chooseYourFriend, style: context.textStyles.titleLarge),
              AppSpacing.sm.vGap,
              Expanded(
                child: friendsState.hasError
                    ? ErrorRetryView(onRetry: () => ref.read(friendsControllerProvider.notifier).load())
                    : friends == null
                    ? const ShimmerListSkeleton(trailingWidth: 36)
                    : SingleChildScrollView(
                        child: FriendList(
                          entries: friends,
                          onDuelTap: (friend) => context.push(AppRoutes.categories, extra: friend),
                          onRowTap: (friend) => _openPlayerDetail(context, friend),
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
