import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/invite_code_card.dart';
import '../../../../core/widgets/section_head.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/entities/lobby_room_state.dart';
import '../controllers/lobby_controller.dart';
import '../models/lobby_player.dart';
import '../widgets/lobby_waiting_indicator.dart';
import '../widgets/player_list.dart';

/// Whether this device created the room (and should send `lobby_create`
/// on open) or already joined it via [JoinCodeScreen] (and just watches
/// the live roster [LobbyController] already has).
enum LobbyRole { host, guest }

/// A multiplayer room, before the quiz starts — mirrors the prototype's
/// `view-lobby`. Hosts see the live roster and a "Start the game"
/// button (which opens the category picker, then sends `lobby_start`);
/// guests additionally see a pulsing "waiting for the host" indicator
/// instead of that button. Everyone in the room — host included — is
/// pushed into [LobbyGameScreen] once `lobby_game_started` arrives.
class LobbyScreen extends ConsumerStatefulWidget {
  const LobbyScreen({required this.role, super.key});

  final LobbyRole role;

  @override
  ConsumerState<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends ConsumerState<LobbyScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.role == LobbyRole.host) {
      Future.microtask(() => ref.read(lobbyControllerProvider.notifier).createRoom());
    }
  }

  void _leaveAndGoBack(BuildContext context) {
    ref.read(lobbyControllerProvider.notifier).leaveRoom();
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.home);
    }
  }

  void _startGame(BuildContext context, String roomId) => context.push(AppRoutes.categories, extra: roomId);

  @override
  Widget build(BuildContext context) {
    ref.listen(lobbyControllerProvider, (previous, next) {
      if (next.closed && !(previous?.closed ?? false)) {
        ref.read(lobbyControllerProvider.notifier).clearClosed();
        context.showSnack(context.t.lobby.closedMessage);
        context.go(AppRoutes.home);
      } else if (next.game != null && previous?.game == null) {
        context.pushReplacement(AppRoutes.lobbyGame);
      }
    });

    final LobbyRoomState? room = ref.watch(lobbyControllerProvider).room;

    if (room == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final List<LobbyPlayer> players = room.participants
        .map((p) => LobbyPlayer.fromEntity(p, isYou: p.id == room.youParticipantId))
        .toList();
    final bool isHost = room.participants.firstWhere((p) => p.id == room.youParticipantId).isHost;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppSpacing.xs.vGap,
              _LobbyHeader(isHost: isHost, onBack: () => _leaveAndGoBack(context)),
              AppSpacing.lg.vGap,
              InviteCodeCard(label: context.t.lobby.roomCode, code: room.roomCode),
              AppSpacing.lg.vGap,
              SectionHead(
                title: context.t.lobby.players,
                trailing: context.t.lobby.playerCount(current: players.length, max: LobbyPlayer.maxPlayers),
              ),
              AppSpacing.sm.vGap,
              PlayerList(players: players),
              AppSpacing.lg.vGap,
              if (isHost)
                _StartGameButton(onTap: () => _startGame(context, room.roomId))
              else
                const LobbyWaitingIndicator(),
            ],
          ),
        ),
      ),
    );
  }
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
            context.t.lobby.title,
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
        (isHost ? context.t.lobby.hostRole : context.t.lobby.guestRole).toUpperCase(),
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
                  context.t.lobby.startGame,
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
