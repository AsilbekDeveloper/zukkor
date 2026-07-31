import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../core/widgets/error_retry_view.dart';
import '../../../../core/widgets/section_head.dart';
import '../../../../core/widgets/shimmer_placeholder.dart';
import '../../../../i18n/strings.g.dart';
import '../controllers/friend_requests_controller.dart';
import '../controllers/friends_controller.dart';
import '../models/friend_entry.dart';
import '../widgets/friend_list.dart';
import '../widgets/friends_header.dart';
import '../widgets/friends_search_bar.dart';

/// The Friends tab — mirrors the prototype's `view-friends`: header +
/// add-friend button, search bar, then the full "All friends" list with
/// a per-friend duel-challenge button.
///
/// CURRENT STATE: real `GET /friends` data. Search filters the fetched
/// list by name or username client-side. Tapping the duel button on any
/// friend row starts a duel with that friend directly (same
/// category-picker flow as the Duel screen).
class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    // The friend list only changes via this device's own actions
    // (accepting a request already reloads it directly) — cached for the
    // session. Pending requests stay unconditional: a new incoming
    // request has no other signal telling this screen to refresh.
    if (ref.read(friendsControllerProvider).data == null) {
      Future.microtask(() => ref.read(friendsControllerProvider.notifier).load());
    }
    Future.microtask(() => ref.read(friendRequestsControllerProvider.notifier).load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _comingSoon(BuildContext context) => context.showSnack(context.t.bottomNav.comingSoon);

  void _openPlayerDetail(BuildContext context, FriendEntry friend) {
    final String? id = friend.id;
    if (id == null) return;
    context.push(AppRoutes.playerDetail, extra: {'userId': id, 'relation': 'friend'});
  }

  List<FriendEntry> _filteredFriends(List<FriendEntry> friends) {
    if (_query.isEmpty) return friends;
    final String needle = _query.toLowerCase();
    return friends
        .where((f) =>
            f.name.toLowerCase().contains(needle) ||
            (f.username?.toLowerCase().contains(needle) ?? false))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final double hPad = context.screenHPad;
    final bool isSearching = _query.isNotEmpty;
    final friendsState = ref.watch(friendsControllerProvider);
    final List<FriendEntry>? allFriends = friendsState.data?.map(FriendEntry.fromEntity).toList();
    final List<FriendEntry> results = allFriends == null ? const [] : _filteredFriends(allFriends);
    final int pendingRequestCount = ref.watch(friendRequestsControllerProvider).data?.length ?? 0;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: friendsState.hasError
            ? ErrorRetryView(onRetry: () => ref.read(friendsControllerProvider.notifier).load())
            : allFriends == null
            ? Padding(
                padding: EdgeInsets.fromLTRB(hPad, AppSpacing.xl, hPad, AppSpacing.lg),
                child: const ShimmerListSkeleton(trailingWidth: 36),
              )
            : RefreshIndicator(
                onRefresh: () => ref.read(friendsControllerProvider.notifier).load(),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(hPad, AppSpacing.xs, hPad, AppSpacing.lg),
                  children: [
                    FriendsHeader(
                      onAddFriendTap: () => context.push(AppRoutes.addFriend),
                      onRequestsTap: () => context.push(AppRoutes.friendRequests),
                      pendingRequestCount: pendingRequestCount,
                    ),
                    AppSpacing.lg.vGap,
                    FriendsSearchBar(
                      placeholder: context.t.friends.searchPlaceholder,
                      controller: _searchController,
                      onChanged: (value) => setState(() => _query = value),
                    ),
                    AppSpacing.lg.vGap,
                    SectionHead(
                      title: context.t.friends.allSection,
                      trailing: isSearching ? null : '${allFriends.length}',
                    ),
                    AppSpacing.sm.vGap,
                    if (results.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                        child: Center(
                          child: Text(
                            context.t.friends.noneFound,
                            style: context.textStyles.bodySmall?.copyWith(color: context.colors.muted),
                          ),
                        ),
                      )
                    else
                      FriendList(
                        entries: results,
                        onDuelTap: (friend) => context.push(AppRoutes.categories, extra: friend),
                        onRowTap: (friend) => _openPlayerDetail(context, friend),
                      ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        current: AppTab.friends,
        onTabTap: (tab) => switch (tab) {
          AppTab.home => context.go(AppRoutes.home),
          AppTab.leaderboard => context.push(AppRoutes.leaderboard),
          AppTab.profile => context.push(AppRoutes.profile),
          AppTab.friends => _comingSoon(context),
        },
        onPlayTap: () => context.push(AppRoutes.categories),
      ),
    );
  }
}
