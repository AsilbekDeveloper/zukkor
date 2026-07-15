import 'package:flutter/material.dart';

import '../../../../core/widgets/pill_segment_control.dart';
import '../../../../i18n/strings.g.dart';

/// Which leaderboard slice is shown. Only [weekly] has real (sample) data
/// wired up right now — the others are stubs until a real backend exists.
enum LeaderboardSegment { weekly, allTime, friends }

extension LeaderboardSegmentLabel on LeaderboardSegment {
  /// Needs [context] (not a const field) so the label re-translates when
  /// the locale changes — see [LeaderboardSegmentControl.build].
  String label(BuildContext context) => switch (this) {
        LeaderboardSegment.weekly => context.t.leaderboard.segmentWeekly,
        LeaderboardSegment.allTime => context.t.leaderboard.segmentAllTime,
        LeaderboardSegment.friends => context.t.leaderboard.segmentFriends,
      };
}

/// Pill-shaped 3-way segmented control — mirrors the prototype's
/// `.segment` / `.seg-btn`. Thin wrapper around [PillSegmentControl] for
/// call-site clarity (`LeaderboardSegmentControl(selected:, onChanged:)`).
class LeaderboardSegmentControl extends StatelessWidget {
  const LeaderboardSegmentControl({
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final LeaderboardSegment selected;
  final ValueChanged<LeaderboardSegment> onChanged;

  @override
  Widget build(BuildContext context) {
    return PillSegmentControl<LeaderboardSegment>(
      values: LeaderboardSegment.values,
      selected: selected,
      labelBuilder: (segment) => segment.label(context),
      onChanged: onChanged,
    );
  }
}
