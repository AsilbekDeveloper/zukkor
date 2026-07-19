/// Which event a notification is about — the actual display text is
/// resolved client-side (see [NotificationKindTitle] in the presentation
/// model), the server only sends this discriminator.
enum NotificationKind { duelChallenge, streakReminder, top50, friendRequest, welcome }

/// One row of `GET /notifications` — a real, persisted notification.
class NotificationRecord {
  const NotificationRecord({
    required this.id,
    required this.kind,
    required this.createdAt,
    required this.isRead,
  });

  final String id;
  final NotificationKind kind;
  final DateTime createdAt;
  final bool isRead;
}
