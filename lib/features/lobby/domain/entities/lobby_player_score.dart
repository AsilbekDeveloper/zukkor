/// One row of the room's final standings — [participantId] cross-refers
/// to a `LobbyParticipant.id` from the room roster the client already
/// has, so the server doesn't need to resend name/avatar per entry.
class LobbyPlayerScore {
  const LobbyPlayerScore({
    required this.participantId,
    required this.correct,
    required this.total,
    required this.totalTimeMs,
  });

  final String participantId;
  final int correct;
  final int total;
  final int totalTimeMs;
}
