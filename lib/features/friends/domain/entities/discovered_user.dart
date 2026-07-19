/// Someone found via `GET /friends/search` — not yet a friend. Kept
/// separate from [Friend] since they mean different things (a search
/// result you can add vs. someone already on your friends list).
class DiscoveredUser {
  const DiscoveredUser({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.avatarColor,
    required this.avatarImagePath,
    required this.requestPending,
  });

  final String id;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? avatarColor;
  final String? avatarImagePath;

  // True when you already have an outgoing pending request to this user —
  // lets Add Friend show "Requested" correctly even after reopening the
  // screen or re-running the same search, instead of allowing a duplicate.
  final bool requestPending;
}
