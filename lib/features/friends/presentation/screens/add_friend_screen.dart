import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../core/widgets/invite_code_card.dart';
import '../../../../core/widgets/shimmer_placeholder.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/entities/discovered_user.dart';
import '../controllers/send_friend_request_controller.dart';
import '../controllers/user_search_controller.dart';
import '../models/discoverable_user.dart';
import '../widgets/discoverable_user_list.dart';
import '../widgets/friends_search_bar.dart';
import '../widgets/share_link_button.dart';

/// Add a friend — mirrors the prototype's `view-add-friend`: search by
/// username or name, or share a static invite code/link.
///
/// CURRENT STATE: search hits the real `GET /friends/search` (debounced
/// while typing). "Add" sends a real `POST /friends/requests` and becomes
/// a disabled "Requested" state — the other user must accept it before
/// you're actually friends (see [FriendRequestsScreen]). Sharing still
/// goes through [_comingSoon] and the invite code is a static
/// placeholder — there's no backend yet to generate a real invite link.
class AddFriendScreen extends ConsumerStatefulWidget {
  const AddFriendScreen({super.key});

  @override
  ConsumerState<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends ConsumerState<AddFriendScreen> {
  static const String _mockInviteCode = 'ZKR-AZ312';
  static const Duration _debounce = Duration(milliseconds: 350);

  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  Timer? _debounceTimer;
  final Set<String> _addedIds = {};

  /// So'rov hali javob kutayotgan foydalanuvchilar — tugma shu vaqtda
  /// o'chirilgan turadi. Aks holda tez ketma-ket ikki bosish bitta
  /// odamga IKKITA so'rov yuborardi (backend'da ularning bir juftligi
  /// uchun takrorlanmaslik cheklovi yo'q).
  final Set<String> _sendingIds = {};

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _comingSoon(BuildContext context) => context.showSnack(context.t.bottomNav.comingSoon);

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.friends);
    }
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

  void _openPlayerDetail(DiscoverableUser user) {
    context.push(
      AppRoutes.playerDetail,
      extra: {
        'userId': user.id,
        if (user.requestPending || _addedIds.contains(user.id)) 'requestSent': true,
      },
    );
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

  @override
  Widget build(BuildContext context) {
    final bool isSearching = _query.isNotEmpty;
    final List<DiscoveredUser>? searchResults = ref.watch(userSearchControllerProvider);
    final List<DiscoverableUser> results =
        (searchResults ?? const []).map(DiscoverableUser.fromEntity).toList();

    return Scaffold(
      body: SafeArea(
        // Scrollable so very short viewports (landscape phones, large
        // font scales) can never clip the content vertically.
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              BackHeader(title: context.t.friends.addFriend, onBack: () => _goBack(context)),
              AppSpacing.lg.vGap,
              FriendsSearchBar(
                placeholder: context.t.addFriend.searchByUsername,
                controller: _searchController,
                onChanged: _onQueryChanged,
              ),
              if (isSearching) ...[
                AppSpacing.lg.vGap,
                if (searchResults == null)
                  const ShimmerListSkeleton(count: 4, trailingWidth: 70)
                else if (results.isEmpty)
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
                    users: results,
                    addedIds: _addedIds,
                    sendingIds: _sendingIds,
                    onAddTap: _addFriend,
                    onRowTap: _openPlayerDetail,
                  ),
              ] else ...[
                AppSpacing.lg.vGap,
                Text(context.t.addFriend.orViaInviteLink, style: context.textStyles.titleLarge),
                AppSpacing.sm.vGap,
                InviteCodeCard(label: context.t.addFriend.yourInviteCode, code: _mockInviteCode),
                AppSpacing.lg.vGap,
                ShareLinkButton(onTap: () => _comingSoon(context)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

