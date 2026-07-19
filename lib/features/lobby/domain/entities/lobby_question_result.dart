/// `lobby_question_result` — sent to each player individually once the
/// question is over (everyone answered or the time limit elapsed):
/// reveals the correct option and this player's own outcome only — no
/// per-opponent breakdown, unlike Duel's 1v1 result (the room's overall
/// standings only settle at the very end, see [LobbyFinalResult]).
class LobbyQuestionResult {
  const LobbyQuestionResult({
    required this.roomId,
    required this.questionIndex,
    required this.correctOption,
    required this.yourSelectedOption,
    required this.yourCorrect,
  });

  final String roomId;
  final int questionIndex;
  final int correctOption;
  final int? yourSelectedOption;
  final bool yourCorrect;
}
