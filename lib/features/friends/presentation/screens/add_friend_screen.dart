import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../core/widgets/invite_code_card.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/entities/discovered_user.dart';
import '../controllers/send_friend_request_controller.dart';
import '../controllers/user_search_controller.dart';
import '../models/discoverable_user.dart';
import '../widgets/discoverable_user_list.dart';
import '../widgets/friends_search_bar.dart';

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

  Future<void> _addFriend(DiscoverableUser user) async {
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
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    child: Center(child: CircularProgressIndicator()),
                  )
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
                    onAddTap: _addFriend,
                  ),
              ] else ...[
                AppSpacing.lg.vGap,
                Text(context.t.addFriend.orViaInviteLink, style: context.textStyles.titleLarge),
                AppSpacing.sm.vGap,
                InviteCodeCard(label: context.t.addFriend.yourInviteCode, code: _mockInviteCode),
                AppSpacing.lg.vGap,
                _ShareLinkButton(onTap: () => _comingSoon(context)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ShareLinkButton extends StatelessWidget {
  const _ShareLinkButton({required this.onTap});

  final VoidCallback onTap;

  // rgba(33,20,16,.22), matching the prototype's `.mp-btn.dark` box-shadow.
  static const List<BoxShadow> _shadow = [
    BoxShadow(color: Color(0x38211410), offset: Offset(0, 10), blurRadius: 22),
  ];

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surfaceDark,
      borderRadius: AppRadius.smAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smAll,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2),
          decoration: const BoxDecoration(borderRadius: AppRadius.smAll, boxShadow: _shadow),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(TablerIcons.share3, size: 17, color: Colors.white),
              const SizedBox(width: 6),
              Text(
                context.t.addFriend.shareLink,
                style: context.textStyles.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
