import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/entities/leaderboard_data.dart';
import '../controllers/leaderboard_controller.dart';
import '../models/leaderboard_entry.dart';
import '../widgets/rank_list.dart';

/// The complete ranking (+ the current user's own rank pinned at the
/// bottom) — mirrors the prototype's `view-full-leaderboard`. Shares
/// [leaderboardControllerProvider] with the main Leaderboard tab, so no
/// second fetch happens if it's already loaded. Tapping anyone but
/// yourself opens their [PlayerDetailScreen].
class FullLeaderboardScreen extends ConsumerStatefulWidget {
  const FullLeaderboardScreen({super.key});

  @override
  ConsumerState<FullLeaderboardScreen> createState() => _FullLeaderboardScreenState();
}

class _FullLeaderboardScreenState extends ConsumerState<FullLeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    if (ref.read(leaderboardControllerProvider) == null) {
      Future.microtask(() => ref.read(leaderboardControllerProvider.notifier).load());
    }
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
    context.push(AppRoutes.playerDetail, extra: entry);
  }

  @override
  Widget build(BuildContext context) {
    final LeaderboardData? data = ref.watch(leaderboardControllerProvider);

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
              if (data == null)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else
                Expanded(
                  child: SingleChildScrollView(
                    child: RankList(
                      entries: data.rankedWithMe,
                      onEntryTap: (entry) => _openPlayerDetail(context, entry),
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
