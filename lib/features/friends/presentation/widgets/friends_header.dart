import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../i18n/strings.g.dart';

/// "Friends" title + requests icon button — finding and adding friends
/// is now handled by the search bar in [FriendsScreen].
class FriendsHeader extends StatelessWidget {
  const FriendsHeader({
    required this.onRequestsTap,
    this.pendingRequestCount = 0,
    super.key,
  });

  final VoidCallback onRequestsTap;
  final int pendingRequestCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            context.t.bottomNav.friends,
            style: context.textStyles.titleLarge,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        _HeaderIconButton(
          icon: TablerIcons.userCheck,
          badgeCount: pendingRequestCount,
          onTap: onRequestsTap,
          semanticLabel: context.t.friendRequests.title,
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.onTap,
    required this.semanticLabel,
    this.badgeCount = 0,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String semanticLabel;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: context.colors.card,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.smAll,
        side: BorderSide(color: context.colors.line),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smAll,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Center(child: Icon(icon, color: context.colors.ink, size: 20, semanticLabel: semanticLabel)),
              if (badgeCount > 0)
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: context.colors.coral),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
