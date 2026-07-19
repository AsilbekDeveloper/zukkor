import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../models/leaderboard_entry.dart';

/// A column of leaderboard rows — mirrors the prototype's `.rank-list` /
/// `.rank-row`. The current user's row ([LeaderboardEntry.isCurrentUser])
/// gets the dark "me" styling regardless of where it appears in the list.
class RankList extends StatelessWidget {
  const RankList({required this.entries, required this.onEntryTap, super.key});

  final List<LeaderboardEntry> entries;
  final ValueChanged<LeaderboardEntry> onEntryTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < entries.length; i++) ...[
          _RankRow(entry: entries[i], onTap: () => onEntryTap(entries[i])),
          if (i < entries.length - 1) AppSpacing.xs.vGap,
        ],
      ],
    );
  }
}

class _RankRow extends StatelessWidget {
  const _RankRow({required this.entry, required this.onTap});

  final LeaderboardEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool isMe = entry.isCurrentUser;
    final Color bg = isMe ? context.colors.surfaceDark : context.colors.card;
    final Color textColor = isMe ? Colors.white : context.colors.ink;
    final Color scoreColor =
        isMe ? Colors.white.withValues(alpha: 0.75) : context.colors.muted;

    return Material(
      color: bg,
      borderRadius: AppRadius.smAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smAll,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm - 1),
          decoration: BoxDecoration(
            borderRadius: AppRadius.smAll,
            border: Border.all(color: isMe ? bg : context.colors.line),
            boxShadow: isMe ? null : context.colors.shadowSm,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 22,
                child: Text(
                  '${entry.rank}',
                  textAlign: TextAlign.center,
                  style: context.textStyles.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isMe ? Colors.white : context.colors.muted,
                  ),
                ),
              ),
              AppSpacing.sm.hGap,
              UserAvatar(
                size: 36,
                initials: entry.initials,
                avatarImagePath: entry.avatarImagePath,
                backgroundColor: entry.avatarColor.resolve(context),
                fontSize: 11.5,
              ),
              AppSpacing.sm.hGap,
              Expanded(
                child: Text(
                  entry.displayName(context),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                    color: textColor,
                  ),
                ),
              ),
              Text(
                formatThousands(entry.xp),
                style: context.textStyles.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scoreColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
