/// Which event a notification is about — the actual display text is
/// resolved client-side (see `NotificationEntry.title` in the presentation
/// model), the server only sends this discriminator plus, for kinds about
/// a specific person, [NotificationRecord.relatedUserName].
enum NotificationKind { duelChallenge, streakReminder, top50, friendRequest, welcome }

/// One row of `GET /notifications` — a real, persisted notification.
class NotificationRecord {
  const NotificationRecord({
    required this.id,
    required this.kind,
    required this.createdAt,
    required this.isRead,
    this.relatedUserName,
  });

  final String id;
  final NotificationKind kind;
  final DateTime createdAt;
  final bool isRead;

  /// The other person's name — set for [NotificationKind.duelChallenge]
  /// and [NotificationKind.friendRequest] (who challenged/requested).
  /// Null for kinds that aren't about a specific person, and possibly
  /// null even for those two if the server hasn't sent one yet — the
  /// display text falls back to a generic phrasing in that case.
  final String? relatedUserName;
}
