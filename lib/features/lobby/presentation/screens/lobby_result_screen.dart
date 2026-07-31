import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../i18n/strings.g.dart';
import '../../../leaderboard/presentation/models/leaderboard_entry.dart';
import '../../../leaderboard/presentation/widgets/leaderboard_podium.dart';
import '../../../leaderboard/presentation/widgets/rank_list.dart';
import '../../../quiz/presentation/widgets/question_breakdown_list.dart';
import '../../domain/entities/lobby_participant.dart';
import '../../domain/entities/lobby_player_score.dart';
import '../../domain/entities/lobby_room_state.dart';
import '../controllers/lobby_controller.dart';
import '../models/lobby_player.dart';
import '../models/lobby_result_args.dart';
import 'lobby_screen.dart';

/// Shown once a synchronized room game finishes — the whole room's
/// standing (server-ranked by correct answers, then time), reusing the
/// same podium/rank-list widgets as the main Leaderboard tab.
///
/// Takes an immutable [args] snapshot rather than reading live
/// [LobbyController] state — that state gets cleared (`clearGame()`) once
/// this screen mounts, and a widget that kept `ref.watch`-ing it would
/// flash back to a loading spinner the instant that happened. Clearing
/// happens once this builds, not from `dispose()` — mutating provider
/// state there is unsafe, see [LobbyController].
class LobbyResultScreen extends ConsumerWidget {
  const LobbyResultScreen({required this.args, super.key});

  final LobbyResultArgs args;

  List<LeaderboardEntry> _ranked(LobbyRoomState room) {
    final Map<String, LobbyParticipant> byId = {for (final p in room.participants) p.id: p};
    return [
      for (int i = 0; i < args.result.standings.length; i++)
        if (byId[args.result.standings[i].participantId] case final LobbyParticipant participant)
          _entryFor(participant, args.result.standings[i], room.youParticipantId, i + 1),
    ];
  }

  LeaderboardEntry _entryFor(LobbyParticipant participant, LobbyPlayerScore score, String youId, int rank) {
    final LobbyPlayer player = LobbyPlayer.fromEntity(participant, isYou: participant.id == youId);
    return LeaderboardEntry(
      rank: rank,
      name: player.name,
      initials: player.initials,
      xp: score.correct,
      avatarColor: player.avatarColor,
      isCurrentUser: player.isYou,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final LobbyRoomState room = args.room;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(lobbyControllerProvider.notifier).clearGame();
    });

    // A defensive default rather than a bare `firstWhere` — "you" not
    // being in the roster shouldn't be possible, but this beats crashing
    // the screen outright if it ever momentarily isn't.
    final bool isHost = room.participants.where((p) => p.id == room.youParticipantId).isEmpty
        ? false
        : room.participants.firstWhere((p) => p.id == room.youParticipantId).isHost;
    final List<LeaderboardEntry> ranked = _ranked(room);
    final bool hasPodium = ranked.length >= 3;
    final List<LeaderboardEntry> podium = hasPodium ? [ranked[1], ranked[0], ranked[2]] : const [];
    final List<LeaderboardEntry> rest = hasPodium ? ranked.sublist(3) : ranked;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: context.screenHPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xl.vGap,
              Center(
                child: Text(context.t.lobbyResult.title, style: context.textStyles.labelSmall),
              ),
              AppSpacing.xs.vGap,
              Center(
                child: Text(
                  context.t.lobbyResult.subtitle,
                  textAlign: TextAlign.center,
                  style: context.textStyles.bodyMedium,
                ),
              ),
              AppSpacing.xl.vGap,
              if (hasPodium) ...[
                LeaderboardPodium(entries: podium, onEntryTap: (_) {}),
                AppSpacing.lg.vGap,
              ],
              RankList(entries: rest, onEntryTap: (_) {}),
              AppSpacing.lg.vGap,
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(TablerIcons.target, size: 16, color: context.colors.ink),
                        const SizedBox(width: 6),
                        Text(
                          context.t.result.totalBall(ball: args.result.ballEarned),
                          style: context.textStyles.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: context.colors.ink,
                          ),
                        ),
                      ],
                    ),
                    Icon(TablerIcons.arrowRight, size: 14, color: context.colors.muted),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(TablerIcons.bolt, size: 16, color: context.colors.coralDeep),
                        const SizedBox(width: 6),
                        Text(
                          context.t.result.xpEarned(xp: args.result.xpEarned),
                          style: context.textStyles.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: context.colors.coralDeep,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              AppSpacing.xl.vGap,
              QuestionBreakdownList(items: args.result.breakdown),
              AppSpacing.xxl.vGap,
              if (isHost) ...[
                AppButton.primary(
                  label: context.t.lobbyResult.playAgain,
                  onPressed: () => context.pushReplacement(AppRoutes.lobby, extra: LobbyRole.host),
                ),
                AppSpacing.sm.vGap,
              ],
              Center(
                child: TextButton(
                  onPressed: () {
                    ref.read(lobbyControllerProvider.notifier).leaveRoom();
                    context.go(AppRoutes.home);
                  },
                  child: Text(context.t.result.backToHome),
                ),
              ),
              AppSpacing.lg.vGap,
            ],
          ),
        ),
      ),
    );
  }
}
