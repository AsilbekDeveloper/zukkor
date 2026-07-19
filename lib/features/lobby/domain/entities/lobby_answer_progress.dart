/// `lobby_answer_progress` — a live "X of N have answered" count for the
/// current question, broadcast to the room as members answer. No
/// per-player breakdown (unlike Duel's 1v1 opponent-answered signal,
/// there are too many players here for that to be useful).
class LobbyAnswerProgress {
  const LobbyAnswerProgress({
    required this.roomId,
    required this.questionIndex,
    required this.answeredCount,
    required this.totalCount,
  });

  final String roomId;
  final int questionIndex;
  final int answeredCount;
  final int totalCount;
}
