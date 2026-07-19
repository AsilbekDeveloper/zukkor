/// One player in a lobby room's roster — a small user summary sent over
/// the lobby WebSocket, distinct from [Friend] since it comes from a
/// different channel (the lobby socket, not `GET /friends`).
class LobbyParticipant {
  const LobbyParticipant({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.avatarColor,
    required this.avatarImagePath,
    required this.isHost,
  });

  final String id;
  final String? username;
  final String? firstName;
  final String? lastName;
  final String? avatarColor;
  final String? avatarImagePath;
  final bool isHost;
}
