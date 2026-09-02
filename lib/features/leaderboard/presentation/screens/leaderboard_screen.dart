import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/error_retry_view.dart';
import '../../../../core/widgets/shimmer_placeholder.dart';
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
/// Switching segments re-fetches (not cached). Loaded once per session
/// like Friends/Categories/Home — a cached [LeaderboardState.data] isn't
/// re-fetched on re-entry; pull-to-refresh or a segment switch are the
/// only ways to force a new request. Tapping anyone but yourself opens
/// their profile (`AppRoutes.playerDetail`, in the player_detail
/// feature); "See full ranking" opens [FullLeaderboardScreen] (which
/// shows whichever segment was last loaded here, via the shared
/// [leaderboardControllerProvider]).
class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  late LeaderboardScope _scope;

  @override
  void initState() {
    super.initState();
    final LeaderboardState current = ref.read(leaderboardControllerProvider);
    // Boshqa "bir marta yukla" ekranlari bilan bir xil: ma'lumot
    // allaqachon (masalan oldingi tashrifdan) keshlangan bo'lsa, qayta
    // so'ralmaydi. Mahalliy segment tanlovi ham keshlangan holatga mos
    // qilib tiklanadi — aks holda ekran har safar "All Time"dan
    // boshlanib, ko'rsatilayotgan ma'lumot (masalan "Weekly") bilan mos
    // kelmay qolardi.
    _scope = current.scope;
    if (current.data == null) {
      Future.microtask(() => ref.read(leaderboardControllerProvider.notifier).load(scope: _scope));
    }
  }

  void _onScopeChanged(LeaderboardScope scope) {
    setState(() => _scope = scope);
    ref.read(leaderboardControllerProvider.notifier).load(scope: scope);
  }

  void _openPlayerDetail(LeaderboardEntry entry) {
    if (entry.isCurrentUser || entry.id == null) return;
    context.push(AppRoutes.playerDetail, extra: {'userId': entry.id!});
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
    final leaderboardState = ref.watch(leaderboardControllerProvider);
    final LeaderboardData? data = leaderboardState.data;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: leaderboardState.hasError
            ? ErrorRetryView(onRetry: () => ref.read(leaderboardControllerProvider.notifier).load(scope: _scope))
            : data == null
            ? Padding(
                padding: EdgeInsets.fromLTRB(hPad, AppSpacing.xl, hPad, AppSpacing.lg),
                child: const ShimmerListSkeleton(),
              )
            : RefreshIndicator(
                onRefresh: () => ref.read(leaderboardControllerProvider.notifier).load(scope: _scope),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(hPad, AppSpacing.xs, hPad, AppSpacing.lg),
                  children: [
                    LeaderboardHeader(greeting: context.t.leaderboard.greeting),
                    AppSpacing.lg.vGap,
                    ..._bodySections(context, data),
                  ],
                ),
              ),
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
