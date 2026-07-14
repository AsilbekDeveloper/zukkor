import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../core/widgets/invite_code_card.dart';
import '../models/discoverable_user.dart';
import '../widgets/discoverable_user_list.dart';
import '../widgets/friends_search_bar.dart';

/// Add a friend — mirrors the prototype's `view-add-friend`: search by
/// username, or share a static invite code/link.
///
/// CURRENT STATE: presentation only, mock invite code. Search filters
/// [DiscoverableUser.sample] by username client-side (hides the invite-
/// link section while searching); "Add" is a local mock toggle (no real
/// request is sent). Sharing still goes through [_comingSoon] — there's
/// no backend yet to generate a real invite link.
class AddFriendScreen extends StatefulWidget {
  const AddFriendScreen({super.key});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  static const String _mockInviteCode = 'ZKR-AZ312';

  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  final Set<String> _sentUsernames = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _comingSoon(BuildContext context) => context.showSnack(AppStrings.comingSoon);

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.friends);
    }
  }

  List<DiscoverableUser> get _results {
    final String needle = _query.toLowerCase();
    return DiscoverableUser.sample.where((u) => u.username.toLowerCase().contains(needle)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bool isSearching = _query.isNotEmpty;
    final List<DiscoverableUser> results = _results;

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
              BackHeader(title: AppStrings.addFriend, onBack: () => _goBack(context)),
              AppSpacing.lg.vGap,
              FriendsSearchBar(
                placeholder: AppStrings.searchByUsername,
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
              ),
              if (isSearching) ...[
                AppSpacing.lg.vGap,
                if (results.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                    child: Center(
                      child: Text(
                        AppStrings.noUsersFound,
                        style: context.textStyles.bodySmall?.copyWith(color: context.colors.muted),
                      ),
                    ),
                  )
                else
                  DiscoverableUserList(
                    users: results,
                    sentUsernames: _sentUsernames,
                    onAddTap: (user) => setState(() => _sentUsernames.add(user.username)),
                  ),
              ] else ...[
                AppSpacing.lg.vGap,
                Text(AppStrings.orViaInviteLink, style: context.textStyles.titleLarge),
                AppSpacing.sm.vGap,
                const InviteCodeCard(label: AppStrings.yourInviteCode, code: _mockInviteCode),
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
                AppStrings.shareLink,
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
