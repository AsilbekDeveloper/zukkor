/// The other player in a duel invite — a small user summary sent over
/// the WebSocket, distinct from [Friend] since it comes from a different
/// channel (the duel socket, not `GET /friends`).
class DuelParticipant {
  const DuelParticipant({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.avatarColor,
    required this.avatarImagePath,
  });

  final String id;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? avatarColor;
  final String? avatarImagePath;
}
