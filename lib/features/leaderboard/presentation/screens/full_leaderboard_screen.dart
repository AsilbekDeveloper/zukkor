import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/back_header.dart';
import '../../../../i18n/strings.g.dart';
import '../models/leaderboard_entry.dart';
import '../widgets/rank_list.dart';

/// The complete top-10 ranking (+ the current user's own rank pinned at
/// the bottom) — mirrors the prototype's `view-full-leaderboard`.
/// Tapping anyone but yourself opens their [PlayerDetailScreen].
class FullLeaderboardScreen extends StatelessWidget {
  const FullLeaderboardScreen({super.key});

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.leaderboard);
    }
  }

  void _openPlayerDetail(BuildContext context, LeaderboardEntry entry) {
    if (entry.isCurrentUser) return;
    context.push(AppRoutes.playerDetail, extra: entry);
  }

  @override
  Widget build(BuildContext context) {
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
              Expanded(
                child: SingleChildScrollView(
                  child: RankList(
                    entries: LeaderboardEntry.sampleFull,
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
