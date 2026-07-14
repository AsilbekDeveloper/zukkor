import 'package:flutter/material.dart';

import '../extensions/context_x.dart';

/// A section title with an optional trailing badge/count — mirrors the
/// prototype's `.section-head` (used by Friends' "Online"/"All friends",
/// and Lobby's "Players" count).
class SectionHead extends StatelessWidget {
  const SectionHead({required this.title, this.trailing, super.key});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.titleLarge,
          ),
        ),
        if (trailing != null)
          Text(
            trailing!,
            style: context.textStyles.bodySmall?.copyWith(
              color: context.colors.coralDeep,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}
