import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/models/avatar_color_option.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../leaderboard/presentation/models/leaderboard_entry.dart';
import '../../../leaderboard/presentation/widgets/leaderboard_podium.dart';
import '../../../leaderboard/presentation/widgets/rank_list.dart';
import '../../../quiz/presentation/models/quiz_result.dart';
import '../models/lobby_player.dart';
import 'lobby_screen.dart';

/// Shown instead of the plain solo [ResultScreen] when a quiz was started
/// from the Lobby ([QuizLaunchArgs.isLobbyGame]) — the whole room's
/// standing, not just your own score, reusing the same podium/rank-list
/// widgets as the main Leaderboard tab.
///
/// CURRENT STATE: presentation only — the other players' scores are
/// [LobbyPlayer.sampleHostAndGuests] placeholder numbers (there's no
/// realtime room-state to pull real scores from yet); only "You" reflects
/// the quiz [result] that was actually just played.
class LobbyResultScreen extends StatelessWidget {
  const LobbyResultScreen({required this.result, super.key});

  final QuizResult result;

  /// Mock scores for the room's other players, one per
  /// [LobbyPlayer.sampleHostAndGuests] entry (same order) — roughly
  /// spread around a typical 5-question game's XP range.
  static const List<int> _mockScores = [62, 54, 47, 38];

  List<LeaderboardEntry> get _ranked {
    final List<({String name, String initials, AvatarColorOption avatarColor, int xp, bool isCurrentUser})>
        contestants = [
      for (int i = 0; i < LobbyPlayer.sampleHostAndGuests.length; i++)
        (
          name: LobbyPlayer.sampleHostAndGuests[i].name,
          initials: LobbyPlayer.sampleHostAndGuests[i].initials,
          avatarColor: LobbyPlayer.sampleHostAndGuests[i].avatarColor,
          xp: _mockScores[i],
          isCurrentUser: false,
        ),
      (
        name: AppStrings.currentUserName,
        initials: LobbyPlayer.you.initials,
        avatarColor: LobbyPlayer.you.avatarColor,
        xp: result.xpEarned,
        isCurrentUser: true,
      ),
    ]..sort((a, b) => b.xp.compareTo(a.xp));

    return [
      for (int i = 0; i < contestants.length; i++)
        LeaderboardEntry(
          rank: i + 1,
          name: contestants[i].name,
          initials: contestants[i].initials,
          xp: contestants[i].xp,
          avatarColor: contestants[i].avatarColor,
          isCurrentUser: contestants[i].isCurrentUser,
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final List<LeaderboardEntry> ranked = _ranked;
    final List<LeaderboardEntry> podium = [ranked[1], ranked[0], ranked[2]];
    final List<LeaderboardEntry> rest = ranked.sublist(3);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: context.screenHPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xl.vGap,
              Center(
                child: Text(AppStrings.lobbyResultTitle, style: context.textStyles.labelSmall),
              ),
              AppSpacing.xs.vGap,
              Center(
                child: Text(
                  AppStrings.lobbyResultSubtitle,
                  textAlign: TextAlign.center,
                  style: context.textStyles.bodyMedium,
                ),
              ),
              AppSpacing.xl.vGap,
              LeaderboardPodium(entries: podium, onEntryTap: (_) {}),
              AppSpacing.lg.vGap,
              RankList(entries: rest, onEntryTap: (_) {}),
              AppSpacing.xxl.vGap,
              AppButton.primary(
                label: AppStrings.backToLobby,
                onPressed: () => context.pushReplacement(AppRoutes.lobby, extra: LobbyRole.host),
              ),
              AppSpacing.sm.vGap,
              Center(
                child: TextButton(
                  onPressed: () => context.go(AppRoutes.home),
                  child: const Text(AppStrings.backToHome),
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
