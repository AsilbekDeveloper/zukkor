import 'package:flutter/material.dart';

import '../../../../core/extensions/context_x.dart';
import '../models/friend_entry.dart';

/// Horizontal row of online friends' avatars — mirrors the prototype's
/// `.online-row` / `.online-item`.
class OnlineFriendsRow extends StatelessWidget {
  const OnlineFriendsRow({required this.entries, required this.onEntryTap, super.key});

  final List<FriendEntry> entries;
  final ValueChanged<FriendEntry> onEntryTap;

  @override
  Widget build(BuildContext context) {
    // Horizontally scrollable (like a stories strip): however many
    // friends are online — and at any font scale — the row can never
    // overflow, it just scrolls.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < entries.length; i++) ...[
            _OnlineAvatar(entry: entries[i], onTap: () => onEntryTap(entries[i])),
            if (i < entries.length - 1) const SizedBox(width: 16),
          ],
        ],
      ),
    );
  }
}

class _OnlineAvatar extends StatelessWidget {
  const _OnlineAvatar({required this.entry, required this.onTap});

  final FriendEntry entry;
  final VoidCallback onTap;

  static const double _size = 44;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(_size / 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: _size,
                height: _size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: entry.avatarColor.resolve(context),
                ),
                alignment: Alignment.center,
                child: Text(
                  entry.initials,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              ),
              if (entry.isOnline)
                Positioned(
                  bottom: -1,
                  right: -1,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colors.green,
                      border: Border.all(color: context.colors.cream, width: 2.5),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          // Fixed label width slightly wider than the avatar: a long name
          // ellipsizes under its avatar instead of widening the column.
          SizedBox(
            width: _size + 16,
            child: Text(
              entry.name,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.labelSmall?.copyWith(
                color: context.colors.muted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
