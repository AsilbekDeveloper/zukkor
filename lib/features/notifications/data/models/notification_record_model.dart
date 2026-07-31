import '../../domain/entities/notification_record.dart';

class NotificationRecordModel {
  const NotificationRecordModel({
    required this.id,
    required this.kind,
    required this.createdAt,
    required this.isRead,
    this.relatedUserName,
  });

  factory NotificationRecordModel.fromJson(Map<String, dynamic> json) => NotificationRecordModel(
        id: json['id'] as String,
        kind: _kindFromString(json['kind'] as String?),
        createdAt: DateTime.parse(json['created_at'] as String),
        isRead: json['is_read'] as bool,
        relatedUserName: json['related_user_name'] as String?,
      );

  final String id;
  final NotificationKind kind;
  final DateTime createdAt;
  final bool isRead;
  final String? relatedUserName;

  static NotificationKind _kindFromString(String? raw) => switch (raw) {
        'duel_challenge' => NotificationKind.duelChallenge,
        'streak_reminder' => NotificationKind.streakReminder,
        'top_50' => NotificationKind.top50,
        'friend_request' => NotificationKind.friendRequest,
        _ => NotificationKind.welcome,
      };

  NotificationRecord toEntity() => NotificationRecord(
        id: id,
        kind: kind,
        createdAt: createdAt.toLocal(),
        isRead: isRead,
        relatedUserName: relatedUserName,
      );
}
