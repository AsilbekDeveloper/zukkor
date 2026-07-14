import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../core/widgets/section_head.dart';
import '../models/friend_entry.dart';
import '../widgets/friend_list.dart';
import '../widgets/friends_header.dart';
import '../widgets/friends_search_bar.dart';
import '../widgets/online_friends_row.dart';

/// The Friends tab — mirrors the prototype's `view-friends` 1:1: header +
/// add-friend button, search bar, an "Online" avatar row, then the full
/// "All friends" list with a per-friend duel-challenge button.
///
/// CURRENT STATE: presentation only, [FriendEntry] placeholder data.
/// "Add friend" pushes the real Add Friend screen. Search filters
/// [FriendEntry.sampleAll] by name client-side (hides the Online row
/// while searching). Tapping an online friend's avatar, or the duel
/// button on any friend row, both start a duel with that friend directly
/// (same category-picker flow as the Duel screen) — the "All friends"
/// list has no online/offline restriction here since it's a direct
/// challenge to a specific person, not the "who's around right now"
/// picker.
class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _comingSoon(BuildContext context) => context.showSnack(AppStrings.comingSoon);

  List<FriendEntry> get _filteredFriends {
    if (_query.isEmpty) return FriendEntry.sampleAll;
    final String needle = _query.toLowerCase();
    return FriendEntry.sampleAll.where((f) => f.name.toLowerCase().contains(needle)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final double hPad = context.screenHPad;
    final bool isSearching = _query.isNotEmpty;
    final List<FriendEntry> results = _filteredFriends;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(hPad, AppSpacing.xs, hPad, AppSpacing.lg),
          children: [
            FriendsHeader(onAddFriendTap: () => context.push(AppRoutes.addFriend)),
            AppSpacing.lg.vGap,
            FriendsSearchBar(
              placeholder: AppStrings.searchFriendsPlaceholder,
              controller: _searchController,
              onChanged: (value) => setState(() => _query = value),
            ),
            AppSpacing.lg.vGap,
            if (!isSearching) ...[
              const SectionHead(title: AppStrings.onlineSectionTitle),
              AppSpacing.sm.vGap,
              OnlineFriendsRow(
                entries: FriendEntry.sampleOnline,
                onEntryTap: (friend) => context.push(AppRoutes.categories, extra: friend),
              ),
              AppSpacing.lg.vGap,
            ],
            SectionHead(
              title: AppStrings.allFriendsSectionTitle,
              trailing: isSearching ? null : '${FriendEntry.totalFriendCount}',
            ),
            AppSpacing.sm.vGap,
            if (results.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                child: Center(
                  child: Text(
                    AppStrings.noFriendsFound,
                    style: context.textStyles.bodySmall?.copyWith(color: context.colors.muted),
                  ),
                ),
              )
            else
              FriendList(
                entries: results,
                onDuelTap: (friend) => context.push(AppRoutes.categories, extra: friend),
              ),
          ],
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
