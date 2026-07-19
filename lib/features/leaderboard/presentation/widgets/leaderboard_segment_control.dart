import 'package:flutter/material.dart';

import '../../../../core/widgets/pill_segment_control.dart';
import '../../../../i18n/strings.g.dart';
import '../../domain/entities/leaderboard_scope.dart';

extension LeaderboardScopeLabel on LeaderboardScope {
  /// Needs [context] (not a const field) so the label re-translates when
  /// the locale changes — see [LeaderboardSegmentControl.build].
  String label(BuildContext context) => switch (this) {
        LeaderboardScope.weekly => context.t.leaderboard.segmentWeekly,
        LeaderboardScope.allTime => context.t.leaderboard.segmentAllTime,
        LeaderboardScope.friends => context.t.leaderboard.segmentFriends,
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

  final LeaderboardScope selected;
  final ValueChanged<LeaderboardScope> onChanged;

  @override
  Widget build(BuildContext context) {
    return PillSegmentControl<LeaderboardScope>(
      values: LeaderboardScope.values,
      selected: selected,
      labelBuilder: (scope) => scope.label(context),
      onChanged: onChanged,
    );
  }
}
