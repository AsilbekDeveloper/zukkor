import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/entities/leaderboard_data.dart';
import '../../domain/entities/leaderboard_scope.dart';
import '../controllers/leaderboard_controller.dart';
import '../models/leaderboard_entry.dart';
import '../widgets/leaderboard_header.dart';
import '../widgets/leaderboard_podium.dart';
import '../widgets/leaderboard_segment_control.dart';
import '../widgets/rank_list.dart';

/// The Leaderboard tab — mirrors the prototype's `view-leaderboard`:
/// header, weekly/all-time/friends segment control, top-3 podium, then
/// the rest of the ranked list with the current user's own (much lower)
/// rank pinned at the bottom.
///
/// CURRENT STATE: all 3 segments are real — `GET /leaderboard?scope=...`
/// returns a different ranked slice for weekly/all-time/friends.
/// Switching segments re-fetches (not cached). Tapping anyone but
/// yourself opens their [PlayerDetailScreen]; "See full ranking" opens
/// [FullLeaderboardScreen] (which shows whichever segment was last
/// loaded here, via the shared [leaderboardControllerProvider]).
class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  LeaderboardScope _scope = LeaderboardScope.allTime;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(leaderboardControllerProvider.notifier).load(scope: _scope));
  }

  void _onScopeChanged(LeaderboardScope scope) {
    setState(() => _scope = scope);
    ref.read(leaderboardControllerProvider.notifier).load(scope: scope);
  }

  void _comingSoon() => context.showSnack(context.t.bottomNav.comingSoon);

  void _openPlayerDetail(LeaderboardEntry entry) {
    if (entry.isCurrentUser || entry.id == null) return;
    context.push(AppRoutes.playerDetail, extra: entry);
  }

  /// Segment control + top-3 podium + the rest of the ranked list. Falls
  /// back to a plain list (no podium) if there aren't at least 3 ranked
  /// players yet.
  List<Widget> _bodySections(BuildContext context, LeaderboardData data) {
    final List<LeaderboardEntry> withMe = data.rankedWithMe;
    final List<Widget> segmentControl = [
      LeaderboardSegmentControl(
        selected: _scope,
        onChanged: _onScopeChanged,
      ),
      AppSpacing.lg.vGap,
    ];

    if (data.entries.length < 3) {
      return [
        ...segmentControl,
        RankList(entries: withMe, onEntryTap: _openPlayerDetail),
        _SeeFullRankingButton(onTap: () => context.push(AppRoutes.fullLeaderboard)),
      ];
    }

    return [
      ...segmentControl,
      LeaderboardPodium(entries: [withMe[1], withMe[0], withMe[2]], onEntryTap: _openPlayerDetail),
      AppSpacing.lg.vGap,
      RankList(entries: withMe.sublist(3), onEntryTap: _openPlayerDetail),
      _SeeFullRankingButton(onTap: () => context.push(AppRoutes.fullLeaderboard)),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final double hPad = context.screenHPad;
    final LeaderboardData? data = ref.watch(leaderboardControllerProvider);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: data == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: EdgeInsets.fromLTRB(hPad, AppSpacing.xs, hPad, AppSpacing.lg),
                children: [
                  LeaderboardHeader(greeting: context.t.leaderboard.greeting),
                  AppSpacing.lg.vGap,
                  ..._bodySections(context, data),
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
