import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../i18n/strings.g.dart';
import '../models/leaderboard_entry.dart';

/// Top-3 podium (2nd, 1st, 3rd) — mirrors the prototype's `.podium`.
/// [entries] must have exactly 3 items, already in podium display order
/// (see [LeaderboardEntry.samplePodium]).
class LeaderboardPodium extends StatelessWidget {
  const LeaderboardPodium({
    required this.entries,
    required this.onEntryTap,
    super.key,
  }) : assert(entries.length == 3, 'Podium always shows exactly 3 entries');

  final List<LeaderboardEntry> entries;
  final ValueChanged<LeaderboardEntry> onEntryTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: _PodiumColumn(entry: entries[0], place: 2, onTap: () => onEntryTap(entries[0]))),
        AppSpacing.sm.hGap,
        Expanded(child: _PodiumColumn(entry: entries[1], place: 1, onTap: () => onEntryTap(entries[1]))),
        AppSpacing.sm.hGap,
        Expanded(child: _PodiumColumn(entry: entries[2], place: 3, onTap: () => onEntryTap(entries[2]))),
      ],
    );
  }
}

class _PodiumColumn extends StatelessWidget {
  const _PodiumColumn({required this.entry, required this.place, required this.onTap});

  final LeaderboardEntry entry;
  final int place;
  final VoidCallback onTap;

  bool get _isFirst => place == 1;

  static const Map<int, double> _barHeights = {1: 78, 2: 56, 3: 42};
  static const Map<int, List<Color>> _barColors = {
    1: [Color(0xFFFBBF24), Color(0xFFD97706)],
    2: [Color(0xFFCBD5E1), Color(0xFF6B7280)],
    3: [Color(0xFFD9A066), Color(0xFFB45309)],
  };
  static const Map<int, Color> _medalColors = {
    1: Color(0xFFD97706),
    2: Color(0xFF6B7280),
    3: Color(0xFFB45309),
  };

  @override
  Widget build(BuildContext context) {
    final double avatarSize = _isFirst ? 68 : 52;

    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.mdAll,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: avatarSize,
                height: avatarSize,
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isFirst ? null : context.colors.surfaceDark,
                  gradient: _isFirst
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [context.colors.coral, context.colors.coralDeep],
                        )
                      : null,
                  boxShadow: _isFirst ? context.colors.shadowCoral : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  entry.initials,
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w700,
                    fontSize: _isFirst ? 17 : 14,
                    color: Colors.white,
                  ),
                ),
              ),
              Positioned(
                top: -12,
                child: Icon(
                  _isFirst ? TablerIcons.crown : TablerIcons.medal,
                  color: _medalColors[place],
                  size: 20,
                ),
              ),
            ],
          ),
          Text(
            entry.displayName(context),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.bodySmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              color: context.colors.ink,
            ),
          ),
          Text(
            context.t.leaderboard.xpValue(xp: formatThousands(entry.xp)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.labelSmall,
          ),
          AppSpacing.xs.vGap,
          Container(
            width: double.infinity,
            height: _barHeights[place],
            alignment: Alignment.topCenter,
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: _barColors[place]!,
              ),
            ),
            child: Text(
              '$place',
              style: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
