import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../core/widgets/error_retry_view.dart';
import '../../../../core/widgets/shimmer_placeholder.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/entities/leaderboard_data.dart';
import '../controllers/leaderboard_controller.dart';
import '../models/leaderboard_entry.dart';
import '../widgets/rank_list.dart';

/// The complete ranking (+ the current user's own rank pinned at the
/// bottom) — mirrors the prototype's `view-full-leaderboard`. Shares
/// [leaderboardControllerProvider] with the main Leaderboard tab, so no
/// second fetch happens if it's already loaded. Tapping anyone but
/// yourself opens their profile (`AppRoutes.playerDetail`, in the
/// player_detail feature).
class FullLeaderboardScreen extends ConsumerStatefulWidget {
  const FullLeaderboardScreen({super.key});

  @override
  ConsumerState<FullLeaderboardScreen> createState() => _FullLeaderboardScreenState();
}

class _FullLeaderboardScreenState extends ConsumerState<FullLeaderboardScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    if (ref.read(leaderboardControllerProvider).data == null) {
      Future.microtask(() => ref.read(leaderboardControllerProvider.notifier).load());
    }
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  // Fires the next page a little before the user actually hits the
  // bottom, so the new rows are ready by the time they get there.
  void _onScroll() {
    if (_scrollController.position.pixels < _scrollController.position.maxScrollExtent - 200) return;
    ref.read(leaderboardControllerProvider.notifier).loadMore();
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.leaderboard);
    }
  }

  void _openPlayerDetail(BuildContext context, LeaderboardEntry entry) {
    if (entry.isCurrentUser || entry.id == null) return;
    context.push(AppRoutes.playerDetail, extra: {'userId': entry.id!});
  }

  @override
  Widget build(BuildContext context) {
    final LeaderboardState leaderboardState = ref.watch(leaderboardControllerProvider);
    final LeaderboardData? data = leaderboardState.data;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: context.screenHPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              BackHeader(title: context.t.fullLeaderboard.title, onBack: () => _goBack(context)),
              AppSpacing.lg.vGap,
              if (leaderboardState.hasError)
                Expanded(
                  child: ErrorRetryView(
                    onRetry: () => ref.read(leaderboardControllerProvider.notifier).load(),
                  ),
                )
              else if (data == null)
                const Expanded(child: ShimmerListSkeleton())
              else
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    child: Column(
                      children: [
                        RankList(
                          entries: data.rankedWithMe,
                          onEntryTap: (entry) => _openPlayerDetail(context, entry),
                        ),
                        if (leaderboardState.isLoadingMore) ...[
                          AppSpacing.md.vGap,
                          const Center(
                            child: SizedBox.square(
                              dimension: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5),
                            ),
                          ),
                          AppSpacing.md.vGap,
                        ],
                      ],
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
