import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../i18n/strings.g.dart';

/// "Leaderboard / Who's the best?" title block — mirrors the prototype's
/// leaderboard `.header`.
class LeaderboardHeader extends StatelessWidget {
  const LeaderboardHeader({required this.greeting, super.key});

  final String greeting;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.bodySmall,
        ),
        Text(
          context.t.leaderboard.title,
          style: context.textStyles.titleLarge,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
