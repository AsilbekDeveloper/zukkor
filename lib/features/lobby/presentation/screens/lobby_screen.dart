import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/invite_code_card.dart';
import '../../../../core/widgets/section_head.dart';
import '../../../quiz/presentation/models/quiz_category.dart';
import '../models/lobby_player.dart';
import '../widgets/lobby_waiting_indicator.dart';
import '../widgets/player_list.dart';

/// Whether the current device created the room (and can start the game)
/// or joined it via a code (and waits for the host instead).
enum LobbyRole { host, guest }

/// A multiplayer room, before the quiz starts — mirrors the prototype's
/// `view-lobby`. Hosts see the full mock roster and a "Start the game"
/// button; guests additionally see themselves added to the roster and a
/// pulsing "waiting for the host" indicator instead of that button.
///
/// CURRENT STATE: presentation only, [LobbyPlayer] placeholder roster —
/// once realtime multiplayer exists this comes from a room-state
/// WebSocket instead. The host's "Start the game" jumps straight to the
/// Quiz screen with a fixed category, matching the prototype (which has
/// no category-selection step inside the lobby itself).
class LobbyScreen extends StatelessWidget {
  const LobbyScreen({required this.role, super.key});

  final LobbyRole role;

  static const String _mockRoomCode = '482913';

  bool get _isHost => role == LobbyRole.host;

  List<LobbyPlayer> get _players => _isHost
      ? LobbyPlayer.sampleHostAndGuests
      : [...LobbyPlayer.sampleHostAndGuests, LobbyPlayer.you];

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              _LobbyHeader(isHost: _isHost, onBack: () => _goBack(context)),
              AppSpacing.lg.vGap,
              const InviteCodeCard(label: AppStrings.roomCodeLabel, code: _mockRoomCode),
              AppSpacing.lg.vGap,
              SectionHead(
                title: AppStrings.playersLabel,
                trailing: AppStrings.playerCount(_players.length, LobbyPlayer.maxPlayers),
              ),
              AppSpacing.sm.vGap,
              PlayerList(players: _players),
              AppSpacing.lg.vGap,
              if (_isHost) _StartGameButton(onTap: () => _startGame(context)) else const LobbyWaitingIndicator(),
            ],
          ),
        ),
      ),
    );
  }

  void _startGame(BuildContext context) =>
      context.push(AppRoutes.quiz, extra: QuizCategory.sample.first);
}

class _LobbyHeader extends StatelessWidget {
  const _LobbyHeader({required this.isHost, required this.onBack});

  final bool isHost;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: context.colors.card,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.smAll,
            side: BorderSide(color: context.colors.line),
          ),
          child: InkWell(
            onTap: onBack,
            borderRadius: AppRadius.smAll,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(TablerIcons.arrowLeft, color: context.colors.ink, size: 20),
            ),
          ),
        ),
        Expanded(
          child: Text(
            AppStrings.lobbyScreenTitle,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.titleLarge,
          ),
        ),
        _RoleTag(isHost: isHost),
      ],
    );
  }
}

class _RoleTag extends StatelessWidget {
  const _RoleTag({required this.isHost});

  final bool isHost;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 7),
      decoration: BoxDecoration(
        color: context.colors.card,
        border: Border.all(color: context.colors.line),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        (isHost ? AppStrings.hostRoleLabel : AppStrings.guestRoleLabel).toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: context.colors.coralDeep,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _StartGameButton extends StatelessWidget {
  const _StartGameButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surfaceDark,
      borderRadius: AppRadius.smAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smAll,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm + 2, horizontal: AppSpacing.sm),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(TablerIcons.playerPlay, color: Colors.white, size: 18),
              AppSpacing.xs.hGap,
              Flexible(
                child: Text(
                  AppStrings.startGameButton,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14.5,
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
