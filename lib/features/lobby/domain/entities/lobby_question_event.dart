import 'lobby_question.dart';

/// `lobby_question` — the same question pushed to every room member at
/// once.
class LobbyQuestionEvent {
  const LobbyQuestionEvent({
    required this.roomId,
    required this.questionIndex,
    required this.question,
  });

  final String roomId;
  final int questionIndex;
  final LobbyQuestion question;
}
