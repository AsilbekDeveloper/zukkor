import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/close_header.dart';
import '../models/leaderboard_entry.dart';

/// A read-only profile card for someone else's leaderboard row — mirrors
/// the prototype's `view-player-detail` / `openPlayerDetail()`.
///
/// CURRENT STATE: presentation only. Level/win-rate/streak aren't real
/// stats — they're derived from the player's name length, exactly
/// mirroring the prototype's `seed = name.length` demo formula, so they
/// vary per person without a backend. "Add to friends" is a local mock
/// toggle (no real request is sent).
class PlayerDetailScreen extends StatefulWidget {
  const PlayerDetailScreen({required this.entry, super.key});

  final LeaderboardEntry entry;

  @override
  State<PlayerDetailScreen> createState() => _PlayerDetailScreenState();
}

class _PlayerDetailScreenState extends State<PlayerDetailScreen> {
  bool _requestSent = false;

  int get _seed => widget.entry.name.length;
  int get _level => 8 + (_seed % 10);
  int get _winRate => 55 + (_seed % 35);
  int get _streak => 1 + (_seed % 15);

  void _close(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.leaderboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final LeaderboardEntry entry = widget.entry;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              CloseHeader(title: AppStrings.playerDetailTitle, onClose: () => _close(context)),
              AppSpacing.xl.vGap,
              Center(
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: entry.avatarColor.resolve(context),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    entry.initials,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontWeight: FontWeight.w700,
                      fontSize: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              AppSpacing.md.vGap,
              Center(
                child: Text(
                  entry.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.titleLarge,
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  AppStrings.rankedLabel(entry.rank, entry.xp),
                  style: context.textStyles.bodySmall?.copyWith(color: context.colors.muted),
                ),
              ),
              AppSpacing.lg.vGap,
              _PlayerStatsRow(level: _level, winRatePercent: _winRate, streak: _streak),
              AppSpacing.xl.vGap,
              AppButton.primary(
                label: _requestSent ? AppStrings.friendRequestSentLabel : AppStrings.addToFriendsButton,
                icon: Icon(
                  _requestSent ? TablerIcons.check : TablerIcons.userPlus,
                  color: Colors.white,
                  size: 18,
                ),
                onPressed: _requestSent ? null : () => setState(() => _requestSent = true),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerStatsRow extends StatelessWidget {
  const _PlayerStatsRow({required this.level, required this.winRatePercent, required this.streak});

  final int level;
  final int winRatePercent;
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.xxs),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: context.colors.line),
        boxShadow: context.colors.shadowSm,
      ),
      child: Row(
        children: [
          Expanded(child: _Stat(value: '$level', label: AppStrings.levelLabel)),
          _divider(context),
          Expanded(child: _Stat(value: '$winRatePercent%', label: AppStrings.statWinRate)),
          _divider(context),
          Expanded(child: _Stat(value: '$streak', label: AppStrings.streakLabel)),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) {
    return Container(width: 1, margin: const EdgeInsets.symmetric(vertical: AppSpacing.xxs), color: context.colors.line);
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: context.textStyles.titleMedium?.copyWith(fontSize: 18, fontWeight: FontWeight.w700)),
        Text(label, style: context.textStyles.labelSmall, textAlign: TextAlign.center),
      ],
    );
  }
}
