import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';

/// Centered name + "@username" — mirrors the prototype's
/// `.profile-name-block`.
class ProfileNameBlock extends StatelessWidget {
  const ProfileNameBlock({required this.name, required this.username, super.key});

  final String name;
  final String username;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          name,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: context.textStyles.titleLarge?.copyWith(fontSize: 17),
        ),
        const SizedBox(height: 2),
        Text(
          '@$username',
          style: context.textStyles.bodySmall?.copyWith(color: context.colors.muted),
        ),
      ],
    );
  }
}
