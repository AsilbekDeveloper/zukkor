/// Which notification categories are on/off for the current user —
/// `GET|PATCH /users/me/notification-preferences`.
class NotificationPreferences {
  const NotificationPreferences({
    required this.duelInvites,
    required this.streakReminders,
    required this.leaderboardUpdates,
    required this.friendRequests,
    required this.productUpdates,
  });

  final bool duelInvites;
  final bool streakReminders;
  final bool leaderboardUpdates;
  final bool friendRequests;
  final bool productUpdates;

  NotificationPreferences copyWith({
    bool? duelInvites,
    bool? streakReminders,
    bool? leaderboardUpdates,
    bool? friendRequests,
    bool? productUpdates,
  }) =>
      NotificationPreferences(
        duelInvites: duelInvites ?? this.duelInvites,
        streakReminders: streakReminders ?? this.streakReminders,
        leaderboardUpdates: leaderboardUpdates ?? this.leaderboardUpdates,
        friendRequests: friendRequests ?? this.friendRequests,
        productUpdates: productUpdates ?? this.productUpdates,
      );
}
