import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/error_retry_view.dart';
import '../../../../core/widgets/section_head.dart';
import '../../../../core/widgets/shimmer_placeholder.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/entities/discovered_user.dart';
import '../controllers/friend_requests_controller.dart';
import '../controllers/friends_controller.dart';
import '../controllers/send_friend_request_controller.dart';
import '../controllers/user_search_controller.dart';
import '../models/discoverable_user.dart';
import '../models/friend_entry.dart';
import '../widgets/compact_invite_card.dart';
import '../widgets/discoverable_user_list.dart';
import '../widgets/friend_list.dart';
import '../widgets/friends_header.dart';
import '../widgets/friends_search_bar.dart';

/// The Friends tab — search bar now does double duty: filters the
/// caller's existing friends AND (when there's a query) runs the same
/// server-side discover search `AddFriendScreen` used to own, so finding
/// and adding a new person no longer needs a separate page.
class FriendsScreen extends ConsumerStatefulWidget {
  const FriendsScreen({super.key});

  @override
  ConsumerState<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends ConsumerState<FriendsScreen> {
  static const String _mockInviteCode = 'ZKR-AZ312';
  static const Duration _debounce = Duration(milliseconds: 350);

  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  Timer? _debounceTimer;
  final Set<String> _addedIds = {};

  /// So'rov hali javob kutayotgan foydalanuvchilar — tugma shu vaqtda
  /// o'chirilgan turadi (qo'sh so'rov yuborilmasligi uchun).
  final Set<String> _sendingIds = {};

  @override
  void initState() {
    super.initState();
    if (ref.read(friendsControllerProvider).data == null) {
      Future.microtask(() => ref.read(friendsControllerProvider.notifier).load());
    }
    Future.microtask(() => ref.read(friendRequestsControllerProvider.notifier).load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _openFriendDetail(BuildContext context, FriendEntry friend) {
    final String? id = friend.id;
    if (id == null) return;
    context.push(AppRoutes.playerDetail, extra: {'userId': id, 'relation': 'friend'});
  }

  void _openDiscoveredDetail(DiscoverableUser user) {
    context.push(
      AppRoutes.playerDetail,
      extra: {
        'userId': user.id,
        if (user.requestPending || _addedIds.contains(user.id)) 'requestSent': true,
      },
    );
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);
    _debounceTimer?.cancel();
    if (value.isEmpty) {
      ref.read(userSearchControllerProvider.notifier).clear();
      return;
    }
    _debounceTimer = Timer(_debounce, () {
      ref.read(userSearchControllerProvider.notifier).search(value);
    });
  }

  Future<void> _addFriend(DiscoverableUser user) async {
    if (_sendingIds.contains(user.id)) return;
    setState(() => _sendingIds.add(user.id));
    try {
      await ref.read(sendFriendRequestControllerProvider.notifier).sendRequest(user.id);
      if (!mounted) return;
      setState(() => _addedIds.add(user.id));
    } on Failure catch (e) {
      if (!mounted) return;
      context.showSnack(e.message);
    } catch (_) {
      if (!mounted) return;
      context.showSnack(t.errors.unknown);
    } finally {
      if (mounted) setState(() => _sendingIds.remove(user.id));
    }
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
    final List<FriendEntry> matchedFriends = allFriends == null ? const [] : _filteredFriends(allFriends);
    final int pendingRequestCount = ref.watch(friendRequestsControllerProvider).data?.length ?? 0;

    final List<DiscoveredUser>? searchResults = isSearching ? ref.watch(userSearchControllerProvider) : null;
    final List<DiscoverableUser> discovered =
        (searchResults ?? const []).map(DiscoverableUser.fromEntity).toList();

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
                      onRequestsTap: () => context.push(AppRoutes.friendRequests),
                      pendingRequestCount: pendingRequestCount,
                    ),
                    AppSpacing.lg.vGap,
                    FriendsSearchBar(
                      placeholder: context.t.friends.searchPlaceholder,
                      controller: _searchController,
                      onChanged: _onQueryChanged,
                    ),
                    if (!isSearching) ...[
                      AppSpacing.md.vGap,
                      CompactInviteCard(
                        code: _mockInviteCode,
                        onShareTap: () => context.showSnack(context.t.bottomNav.comingSoon),
                      ),
                    ],
                    AppSpacing.lg.vGap,
                    if (matchedFriends.isNotEmpty) ...[
                      SectionHead(
                        title: context.t.friends.allSection,
                        trailing: isSearching ? null : '${allFriends.length}',
                      ),
                      AppSpacing.sm.vGap,
                      FriendList(
                        entries: matchedFriends,
                        onDuelTap: (friend) => context.push(AppRoutes.categories, extra: friend),
                        onRowTap: (friend) => _openFriendDetail(context, friend),
                      ),
                    ],
                    if (isSearching) ...[
                      if (matchedFriends.isNotEmpty) AppSpacing.lg.vGap,
                      SectionHead(title: context.t.friends.otherUsersSection),
                      AppSpacing.sm.vGap,
                      if (searchResults == null)
                        const ShimmerListSkeleton(count: 3, trailingWidth: 70)
                      else if (discovered.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                          child: Center(
                            child: Text(
                              context.t.addFriend.noUsersFound,
                              style: context.textStyles.bodySmall?.copyWith(color: context.colors.muted),
                            ),
                          ),
                        )
                      else
                        DiscoverableUserList(
                          users: discovered,
                          addedIds: _addedIds,
                          sendingIds: _sendingIds,
                          onAddTap: _addFriend,
                          onRowTap: _openDiscoveredDetail,
                        ),
                    ],
                    if (!isSearching && matchedFriends.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                        child: Center(
                          child: Text(
                            context.t.friends.noneFound,
                            style: context.textStyles.bodySmall?.copyWith(color: context.colors.muted),
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
