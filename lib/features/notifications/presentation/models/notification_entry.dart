import 'package:flutter/material.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';

import '../../../../i18n/strings.g.dart';
import '../../../quiz/presentation/models/quiz_category.dart';
import '../../domain/entities/notification_record.dart';

String _titleFor(BuildContext context, NotificationKind kind, String? relatedUserName) {
  final name = relatedUserName;
  return switch (kind) {
    NotificationKind.duelChallenge =>
      name == null ? context.t.notifications.duelChallengeGeneric : context.t.notifications.duelChallenge(name: name),
    NotificationKind.streakReminder => context.t.notifications.streakReminder,
    NotificationKind.top50 => context.t.notifications.top50,
    NotificationKind.friendRequest =>
      name == null ? context.t.notifications.friendRequestGeneric : context.t.notifications.friendRequest(name: name),
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
    required this.relatedUserName,
    required this.timeLabel,
    required this.isUnread,
  });

  /// Builds a row from a real `GET /notifications` entry — icon/color are
  /// derived client-side from [NotificationRecord.kind] (the server only
  /// sends the discriminator, not display styling).
  factory NotificationEntry.fromEntity(NotificationRecord record) {
    final (IconData icon, CategoryColorKey colorKey) = switch (record.kind) {
      NotificationKind.duelChallenge => (TablerIcons.swords, CategoryColorKey.coral),
      NotificationKind.streakReminder => (TablerIcons.flame, CategoryColorKey.terra),
      NotificationKind.top50 => (TablerIcons.trophy, CategoryColorKey.teal),
      NotificationKind.friendRequest => (TablerIcons.userPlus, CategoryColorKey.blue),
      NotificationKind.welcome => (TablerIcons.sparkles, CategoryColorKey.pink),
    };
    return NotificationEntry(
      icon: icon,
      colorKey: colorKey,
      kind: record.kind,
      relatedUserName: record.relatedUserName,
      timeLabel: _formatTimeLabel(record.createdAt),
      isUnread: !record.isRead,
    );
  }

  final IconData icon;
  final CategoryColorKey colorKey;
  final NotificationKind kind;
  final String? relatedUserName;
  final String timeLabel;
  final bool isUnread;

  String title(BuildContext context) => _titleFor(context, kind, relatedUserName);

  static String _formatTimeLabel(DateTime createdAt) {
    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime day = DateTime(createdAt.year, createdAt.month, createdAt.day);
    final int diffDays = today.difference(day).inDays;

    if (diffDays == 0) return t.history.today;
    if (diffDays == 1) return t.history.yesterday;
    if (diffDays > 1 && diffDays < 7) return t.history.daysAgo(days: diffDays);
    final String dd = createdAt.day.toString().padLeft(2, '0');
    final String mm = createdAt.month.toString().padLeft(2, '0');
    return '$dd.$mm.${createdAt.year}';
  }
}
