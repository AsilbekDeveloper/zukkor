import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/pill_segment_control.dart';

/// Which leaderboard slice is shown. Only [weekly] has real (sample) data
/// wired up right now — the others are stubs until a real backend exists.
enum LeaderboardSegment {
  weekly(AppStrings.segmentWeekly),
  allTime(AppStrings.segmentAllTime),
  friends(AppStrings.segmentFriends);

  const LeaderboardSegment(this.label);

  final String label;
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
      labelBuilder: (segment) => segment.label,
      onChanged: onChanged,
    );
  }
}
