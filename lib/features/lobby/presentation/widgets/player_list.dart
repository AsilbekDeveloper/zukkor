import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../models/lobby_player.dart';

/// The lobby's roster — mirrors the prototype's `.player-list` /
/// `.player-row`. Always a single column (unlike the fluid Friends
/// grid): player order matters here, so it never reflows into columns
/// on wide screens.
class PlayerList extends StatelessWidget {
  const PlayerList({required this.players, super.key});

  final List<LobbyPlayer> players;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < players.length; i++) ...[
          _PlayerRow(player: players[i]),
          if (i < players.length - 1) AppSpacing.sm.vGap,
        ],
      ],
    );
  }
}

class _PlayerRow extends StatelessWidget {
  const _PlayerRow({required this.player});

  final LobbyPlayer player;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: AppRadius.smAll,
        border: Border.all(color: context.colors.line),
        boxShadow: context.colors.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: player.avatarColor.resolve(context),
            ),
            alignment: Alignment.center,
            child: Text(
              player.initials,
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w700,
                fontSize: 11.5,
                color: Colors.white,
              ),
            ),
          ),
          AppSpacing.sm.hGap,
          Expanded(
            child: Row(
              children: [
                Flexible(
                  child: Text(
                    player.displayName(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.5,
                      color: context.colors.ink,
                    ),
                  ),
                ),
                if (player.isHost) ...[
                  const SizedBox(width: 5),
                  Icon(TablerIcons.crown, size: 14, color: context.colors.terra),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
