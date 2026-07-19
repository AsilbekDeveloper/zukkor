import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/close_header.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../i18n/strings.g.dart';
import '../../../friends/presentation/controllers/send_friend_request_controller.dart';
import '../../domain/entities/player_stats.dart';
import '../controllers/player_stats_controller.dart';
import '../models/leaderboard_entry.dart';

/// A read-only profile card for someone else's leaderboard row — mirrors
/// the prototype's `view-player-detail` / `openPlayerDetail()`.
///
/// [entry] (rank/name/xp/avatar, already known from the list that was
/// tapped) paints instantly; level/streak/games/win-rate come from
/// `GET /leaderboard/{user_id}`, fetched on open. "Add to friends" sends
/// a real `POST /friends/requests` (same flow as Add Friend's search
/// results).
class PlayerDetailScreen extends ConsumerStatefulWidget {
  const PlayerDetailScreen({required this.entry, super.key});

  final LeaderboardEntry entry;

  @override
  ConsumerState<PlayerDetailScreen> createState() => _PlayerDetailScreenState();
}

class _PlayerDetailScreenState extends ConsumerState<PlayerDetailScreen> {
  bool _requestSent = false;
  PlayerStats? _stats;

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadStats);
  }

  Future<void> _loadStats() async {
    try {
      final PlayerStats stats =
          await ref.read(playerStatsControllerProvider.notifier).getPlayerStats(widget.entry.id!);
      if (!mounted) return;
      setState(() => _stats = stats);
    } on Failure catch (e) {
      if (!mounted) return;
      context.showSnack(e.message);
      _close(context);
    } catch (_) {
      if (!mounted) return;
      context.showSnack(t.errors.unknown);
      _close(context);
    }
  }

  void _close(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.leaderboard);
    }
  }

  Future<void> _addToFriends() async {
    try {
      await ref.read(sendFriendRequestControllerProvider.notifier).sendRequest(widget.entry.id!);
      if (!mounted) return;
      setState(() => _requestSent = true);
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
    final LeaderboardEntry entry = widget.entry;
    final PlayerStats? stats = _stats;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              CloseHeader(title: context.t.playerDetail.title, onClose: () => _close(context)),
              AppSpacing.xl.vGap,
              Center(
                child: UserAvatar(
                  size: 76,
                  initials: entry.initials,
                  avatarImagePath: entry.avatarImagePath,
                  backgroundColor: entry.avatarColor.resolve(context),
                  fontSize: 24,
                ),
              ),
              AppSpacing.md.vGap,
              Center(
                child: Text(
                  entry.displayName(context),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.titleLarge,
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  context.t.playerDetail.rankedLabel(rank: entry.rank, xp: formatThousands(entry.xp)),
                  style: context.textStyles.bodySmall?.copyWith(color: context.colors.muted),
                ),
              ),
              AppSpacing.lg.vGap,
              if (stats == null)
                const Center(child: CircularProgressIndicator())
              else
                _PlayerStatsRow(
                  level: stats.level,
                  winRatePercent: stats.winRatePercent,
                  streak: stats.currentStreak,
                ),
              AppSpacing.xl.vGap,
              AppButton.primary(
                label: _requestSent ? context.t.playerDetail.requestSent : context.t.playerDetail.addToFriends,
                icon: Icon(
                  _requestSent ? TablerIcons.check : TablerIcons.userPlus,
                  color: Colors.white,
                  size: 18,
                ),
                onPressed: _requestSent ? null : _addToFriends,
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
          Expanded(child: _Stat(value: '$level', label: context.t.home.levelLabel)),
          _divider(context),
          Expanded(child: _Stat(value: '$winRatePercent%', label: context.t.profile.statWinRate)),
          _divider(context),
          Expanded(child: _Stat(value: '$streak', label: context.t.playerDetail.streakLabel)),
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
