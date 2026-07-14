import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_spacing.dart';

/// "Friends" title + add-friend icon button — mirrors the prototype's
/// `view-friends` `.header`.
class FriendsHeader extends StatelessWidget {
  const FriendsHeader({required this.onAddFriendTap, super.key});

  final VoidCallback onAddFriendTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            AppStrings.navFriends,
            style: context.textStyles.titleLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Material(
          color: context.colors.card,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.smAll,
            side: BorderSide(color: context.colors.line),
          ),
          child: InkWell(
            onTap: onAddFriendTap,
            borderRadius: AppRadius.smAll,
            child: SizedBox(
              width: 44,
              height: 44,
              child: Icon(TablerIcons.userPlus, color: context.colors.ink, size: 20),
            ),
          ),
        ),
      ],
    );
  }
}
