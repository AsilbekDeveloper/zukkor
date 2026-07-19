import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../i18n/strings.g.dart';
import '../models/friend_entry.dart';

/// Friend rows with a duel-challenge button — mirrors the prototype's
/// `.friend-list` / `.friend-row`. Laid out as a fluid grid
/// (`maxCrossAxisExtent`): a single column on phones — identical to the
/// prototype — and automatically 2 columns when the container is wide
/// (tablets), so the list fills the screen instead of stretching rows.
class FriendList extends StatelessWidget {
  const FriendList({required this.entries, required this.onDuelTap, super.key});

  final List<FriendEntry> entries;
  final ValueChanged<FriendEntry> onDuelTap;

  /// Row height from its content (same technique as the category grid):
  /// avatar (36) or the scaled two-line text block, whichever is taller,
  /// plus vertical padding — correct at any width and font scale.
  double _rowExtent(BuildContext context) {
    final TextScaler scaler = MediaQuery.textScalerOf(context);
    final double textBlock = (scaler.scale(13.5) * 1.4).ceilToDouble() +
        (scaler.scale(11) * 1.2).ceilToDouble() +
        2;
    const double avatarBlock = 36;
    const double verticalPadding = (AppSpacing.sm - 1) * 2;
    return (textBlock > avatarBlock ? textBlock : avatarBlock) + verticalPadding;
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: entries.length,
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 480,
        mainAxisSpacing: AppSpacing.xs,
        crossAxisSpacing: AppSpacing.xs,
        mainAxisExtent: _rowExtent(context),
      ),
      itemBuilder: (context, index) {
        final FriendEntry entry = entries[index];
        return _FriendRow(entry: entry, onDuelTap: () => onDuelTap(entry));
      },
    );
  }
}

class _FriendRow extends StatelessWidget {
  const _FriendRow({required this.entry, required this.onDuelTap});

  final FriendEntry entry;
  final VoidCallback onDuelTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm - 1),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: AppRadius.smAll,
        border: Border.all(color: context.colors.line),
        boxShadow: context.colors.shadowSm,
      ),
      child: Row(
        children: [
          UserAvatar(
            size: 36,
            initials: entry.initials,
            avatarImagePath: entry.avatarImagePath,
            backgroundColor: entry.avatarColor.resolve(context),
            fontSize: 11.5,
          ),
          AppSpacing.sm.hGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                    color: context.colors.ink,
                  ),
                ),
                if (entry.handle != null)
                  Text(
                    entry.handle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.labelSmall?.copyWith(color: context.colors.muted),
                  ),
              ],
            ),
          ),
          AppSpacing.sm.hGap,
          _DuelButton(onTap: onDuelTap),
        ],
      ),
    );
  }
}

class _DuelButton extends StatelessWidget {
  const _DuelButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.surfaceDark,
      borderRadius: BorderRadius.circular(11),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(11),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(TablerIcons.swords, color: Colors.white, size: 16, semanticLabel: context.t.home.challengeToDuel),
        ),
      ),
    );
  }
}
