import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../quiz/presentation/models/quiz_category.dart';

/// A single row on the Notifications screen (`view-notifications`'s
/// `.notif-row`). [colorKey] reuses [CategoryColorKey] — the notification
/// icon tiles use the exact same solid-fill/white-glyph treatment as a
/// category icon, just with different icon+color pairings.
class NotificationEntry {
  const NotificationEntry({
    required this.icon,
    required this.colorKey,
    required this.title,
    required this.timeLabel,
    required this.isUnread,
    this.opensDuelInvite = false,
  });

  final IconData icon;
  final CategoryColorKey colorKey;
  final String title;
  final String timeLabel;
  final bool isUnread;

  /// Only the duel-challenge notification opens a real screen right now
  /// — the rest have no destination yet (matches the prototype: only
  /// that row carries a `data-nav`).
  final bool opensDuelInvite;

  static const List<NotificationEntry> sample = [
    NotificationEntry(
      icon: TablerIcons.swords,
      colorKey: CategoryColorKey.coral,
      title: AppStrings.notifDuelChallenge,
      timeLabel: '2 minutes ago',
      isUnread: true,
      opensDuelInvite: true,
    ),
    NotificationEntry(
      icon: TablerIcons.flame,
      colorKey: CategoryColorKey.terra,
      title: AppStrings.notifStreakReminder,
      timeLabel: '3 hours ago',
      isUnread: true,
    ),
    NotificationEntry(
      icon: TablerIcons.trophy,
      colorKey: CategoryColorKey.teal,
      title: AppStrings.notifTop50,
      timeLabel: 'Yesterday',
      isUnread: true,
    ),
    NotificationEntry(
      icon: TablerIcons.userPlus,
      colorKey: CategoryColorKey.blue,
      title: AppStrings.notifFriendRequest,
      timeLabel: '2 days ago',
      isUnread: false,
    ),
    NotificationEntry(
      icon: TablerIcons.sparkles,
      colorKey: CategoryColorKey.pink,
      title: AppStrings.notifWelcome,
      timeLabel: '5 days ago',
      isUnread: false,
    ),
  ];
}
