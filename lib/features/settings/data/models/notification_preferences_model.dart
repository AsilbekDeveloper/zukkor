import '../../domain/entities/notification_preferences.dart';

class NotificationPreferencesModel {
  const NotificationPreferencesModel({
    required this.duelInvites,
    required this.streakReminders,
    required this.leaderboardUpdates,
    required this.friendRequests,
    required this.productUpdates,
  });

  factory NotificationPreferencesModel.fromJson(Map<String, dynamic> json) => NotificationPreferencesModel(
        duelInvites: json['duel_invites'] as bool,
        streakReminders: json['streak_reminders'] as bool,
        leaderboardUpdates: json['leaderboard_updates'] as bool,
        friendRequests: json['friend_requests'] as bool,
        productUpdates: json['product_updates'] as bool,
      );

  factory NotificationPreferencesModel.fromEntity(NotificationPreferences entity) => NotificationPreferencesModel(
        duelInvites: entity.duelInvites,
        streakReminders: entity.streakReminders,
        leaderboardUpdates: entity.leaderboardUpdates,
        friendRequests: entity.friendRequests,
        productUpdates: entity.productUpdates,
      );

  final bool duelInvites;
  final bool streakReminders;
  final bool leaderboardUpdates;
  final bool friendRequests;
  final bool productUpdates;

  Map<String, dynamic> toJson() => {
        'duel_invites': duelInvites,
        'streak_reminders': streakReminders,
        'leaderboard_updates': leaderboardUpdates,
        'friend_requests': friendRequests,
        'product_updates': productUpdates,
      };

  NotificationPreferences toEntity() => NotificationPreferences(
        duelInvites: duelInvites,
        streakReminders: streakReminders,
        leaderboardUpdates: leaderboardUpdates,
        friendRequests: friendRequests,
        productUpdates: productUpdates,
      );
}
