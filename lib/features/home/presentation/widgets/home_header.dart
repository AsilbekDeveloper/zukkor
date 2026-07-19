import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/models/avatar_color_option.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../i18n/strings.g.dart';

/// Greeting + avatar on the left, notifications bell on the right —
/// mirrors the prototype's `.header`.
class HomeHeader extends StatelessWidget {
  const HomeHeader({
    required this.name,
    required this.initials,
    required this.avatarColor,
    required this.hasUnreadNotifications,
    required this.onNotificationsTap,
    this.avatarImagePath,
    super.key,
  });

  final String name;
  final String initials;
  final AvatarColorOption avatarColor;
  final String? avatarImagePath;
  final bool hasUnreadNotifications;
  final VoidCallback onNotificationsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(borderRadius: AppRadius.smAll, boxShadow: context.colors.shadowCoral),
          child: UserAvatar(
            size: 48,
            initials: initials,
            avatarImagePath: avatarImagePath,
            backgroundColor: avatarColor.resolve(context),
            borderRadius: AppRadius.smAll,
            fontSize: 15.5,
          ),
        ),
        AppSpacing.sm.hGap,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.t.home.greeting, style: context.textStyles.bodySmall),
              Text(
                name,
                style: context.textStyles.titleLarge,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        _NotificationButton(
          hasUnread: hasUnreadNotifications,
          onTap: onNotificationsTap,
        ),
      ],
    );
  }
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.hasUnread, required this.onTap});

  final bool hasUnread;
  final VoidCallback onTap;

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
            alignment: Alignment.center,
            children: [
              Icon(TablerIcons.bell, color: context.colors.ink, size: 22),
              if (hasUnread)
                Positioned(
                  top: 9,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colors.coral,
                      border: Border.all(color: context.colors.card, width: 2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
