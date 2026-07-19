import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/extensions/context_x.dart';
import '../../../../core/extensions/num_x.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/user_avatar.dart';
import '../../../../i18n/strings.g.dart';
import '../models/discoverable_user.dart';

/// Search results on the Add Friend screen — one row per matching user,
/// with an Add/Sent action button.
class DiscoverableUserList extends StatelessWidget {
  const DiscoverableUserList({
    required this.users,
    required this.addedIds,
    required this.onAddTap,
    super.key,
  });

  final List<DiscoverableUser> users;
  final Set<String> addedIds;
  final ValueChanged<DiscoverableUser> onAddTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < users.length; i++) ...[
          _ResultRow(
            user: users[i],
            isAdded: users[i].requestPending || addedIds.contains(users[i].id),
            onTap: () => onAddTap(users[i]),
          ),
          if (i < users.length - 1) AppSpacing.xs.vGap,
        ],
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.user, required this.isAdded, required this.onTap});

  final DiscoverableUser user;
  final bool isAdded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm - 1),
      decoration: BoxDecoration(
        color: context.colors.card,
        borderRadius: AppRadius.smAll,
        border: Border.all(color: context.colors.line),
        boxShadow: context.colors.shadowSm,
      ),
      child: Row(
        children: [
          UserAvatar(
            size: 36,
            initials: user.initials,
            avatarImagePath: user.avatarImagePath,
            backgroundColor: user.avatarColor.resolve(context),
            fontSize: 11.5,
          ),
          AppSpacing.sm.hGap,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodySmall?.copyWith(fontWeight: FontWeight.w600, fontSize: 13.5),
                ),
                if (user.handle != null)
                  Text(
                    user.handle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.textStyles.labelSmall?.copyWith(color: context.colors.muted),
                  ),
              ],
            ),
          ),
          AppSpacing.sm.hGap,
          _AddButton(isAdded: isAdded, onTap: onTap),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  const _AddButton({required this.isAdded, required this.onTap});

  final bool isAdded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(999);
    final Widget content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm + 2, vertical: AppSpacing.xs),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAdded ? TablerIcons.check : TablerIcons.userPlus,
            size: 14,
            color: isAdded ? context.colors.muted : Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            isAdded ? context.t.addFriend.requestedLabel : context.t.addFriend.addButton,
            style: context.textStyles.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: isAdded ? context.colors.muted : Colors.white,
            ),
          ),
        ],
      ),
    );

    // "Added" mirrors a disabled secondary control — a neutral outline
    // instead of a pale tint of the Add button's coral (that reads as
    // muddy rather than clearly "done").
    if (isAdded) {
      return DecoratedBox(
        decoration: BoxDecoration(borderRadius: radius, border: Border.all(color: context.colors.line)),
        child: content,
      );
    }
    return Material(
      color: context.colors.coral,
      borderRadius: radius,
      child: InkWell(onTap: onTap, borderRadius: radius, child: content),
    );
  }
}
