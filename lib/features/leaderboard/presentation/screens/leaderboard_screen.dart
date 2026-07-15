import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../i18n/strings.g.dart';
import '../models/leaderboard_entry.dart';
import '../widgets/leaderboard_header.dart';
import '../widgets/leaderboard_podium.dart';
import '../widgets/leaderboard_segment_control.dart';
import '../widgets/rank_list.dart';

/// The Leaderboard tab — mirrors the prototype's `view-leaderboard`:
/// header + filter button, weekly/all-time/friends segment control, top-3
/// podium, then the rest of the ranked list with the current user's own
/// (much lower) rank pinned at the bottom.
///
/// CURRENT STATE: presentation only, [LeaderboardEntry.sample] placeholder
/// data. Segments other than "Weekly" show the same sample data for now
/// (there's no backend yet to slice by time range), and the category
/// filter only relabels the header — it doesn't actually re-slice the
/// sample data either. Tapping anyone but yourself opens their
/// [PlayerDetailScreen]; "See full ranking" opens [FullLeaderboardScreen].
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  LeaderboardSegment _segment = LeaderboardSegment.weekly;
  String? _categoryFilter;

  void _comingSoon() => context.showSnack(context.t.bottomNav.comingSoon);

  Future<void> _openFilter() async {
    final String? result = await context.push<String?>(
      AppRoutes.rankFilter,
      extra: _categoryFilter,
    );
    if (!mounted) return;
    setState(() => _categoryFilter = result);
  }

  void _openPlayerDetail(LeaderboardEntry entry) {
    if (entry.isCurrentUser) return;
    context.push(AppRoutes.playerDetail, extra: entry);
  }

  /// Segment control + top-3 podium.
  List<Widget> _podiumSection(BuildContext context) {
    return [
      LeaderboardSegmentControl(
        selected: _segment,
        onChanged: (segment) => setState(() => _segment = segment),
      ),
      AppSpacing.lg.vGap,
      LeaderboardPodium(
        entries: LeaderboardEntry.samplePodium,
        onEntryTap: _openPlayerDetail,
      ),
    ];
  }

  /// The ranked list + "see full ranking".
  List<Widget> _listSection(BuildContext context) {
    return [
      RankList(
        entries: LeaderboardEntry.sampleRestOfList,
        onEntryTap: _openPlayerDetail,
      ),
      _SeeFullRankingButton(onTap: () => context.push(AppRoutes.fullLeaderboard)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final double hPad = context.screenHPad;
    final String greeting = _categoryFilter == null
        ? context.t.leaderboard.greeting
        : context.t.leaderboard.greetingFiltered(category: _categoryFilter!);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(hPad, AppSpacing.xs, hPad, AppSpacing.lg),
          children: [
            LeaderboardHeader(greeting: greeting, onFilterTap: _openFilter),
            AppSpacing.lg.vGap,
            ..._podiumSection(context),
            AppSpacing.lg.vGap,
            ..._listSection(context),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        current: AppTab.leaderboard,
        onTabTap: (tab) => switch (tab) {
          AppTab.home => context.go(AppRoutes.home),
          AppTab.friends => context.push(AppRoutes.friends),
          AppTab.profile => context.push(AppRoutes.profile),
          AppTab.leaderboard => _comingSoon(),
        },
        onPlayTap: () => context.push(AppRoutes.categories),
      ),
    );
  }
}

class _SeeFullRankingButton extends StatelessWidget {
  const _SeeFullRankingButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton.icon(
        onPressed: onTap,
        icon: const Icon(TablerIcons.chevronRight, size: 16),
        label: Text(context.t.leaderboard.seeFullRanking),
        iconAlignment: IconAlignment.end,
      ),
    );
  }
}
