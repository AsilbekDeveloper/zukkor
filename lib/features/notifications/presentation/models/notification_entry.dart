import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../i18n/strings.g.dart';
import '../../../quiz/presentation/models/quiz_category.dart';

/// Which notification message a row shows — the actual text is resolved
/// via [NotificationKindTitle.title] at render time (not a const field)
/// so it re-translates when the locale changes.
enum NotificationKind { duelChallenge, streakReminder, top50, friendRequest, welcome }

extension NotificationKindTitle on NotificationKind {
  String title(BuildContext context) => switch (this) {
        NotificationKind.duelChallenge => context.t.notifications.duelChallenge,
        NotificationKind.streakReminder => context.t.notifications.streakReminder,
        NotificationKind.top50 => context.t.notifications.top50,
        NotificationKind.friendRequest => context.t.notifications.friendRequest,
        NotificationKind.welcome => context.t.notifications.welcome,
      };
}

/// A single row on the Notifications screen (`view-notifications`'s
/// `.notif-row`). [colorKey] reuses [CategoryColorKey] — the notification
/// icon tiles use the exact same solid-fill/white-glyph treatment as a
/// category icon, just with different icon+color pairings.
class NotificationEntry {
  const NotificationEntry({
    required this.icon,
    required this.colorKey,
    required this.kind,
    required this.timeLabel,
    required this.isUnread,
    this.opensDuelInvite = false,
  });

  final IconData icon;
  final CategoryColorKey colorKey;
  final NotificationKind kind;
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
      kind: NotificationKind.duelChallenge,
      timeLabel: '2 minutes ago',
      isUnread: true,
      opensDuelInvite: true,
    ),
    NotificationEntry(
      icon: TablerIcons.flame,
      colorKey: CategoryColorKey.terra,
      kind: NotificationKind.streakReminder,
      timeLabel: '3 hours ago',
      isUnread: true,
    ),
    NotificationEntry(
      icon: TablerIcons.trophy,
      colorKey: CategoryColorKey.teal,
      kind: NotificationKind.top50,
      timeLabel: 'Yesterday',
      isUnread: true,
    ),
    NotificationEntry(
      icon: TablerIcons.userPlus,
      colorKey: CategoryColorKey.blue,
      kind: NotificationKind.friendRequest,
      timeLabel: '2 days ago',
      isUnread: false,
    ),
    NotificationEntry(
      icon: TablerIcons.sparkles,
      colorKey: CategoryColorKey.pink,
      kind: NotificationKind.welcome,
      timeLabel: '5 days ago',
      isUnread: false,
    ),
  ];
}
