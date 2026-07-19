import 'duel_question.dart';

/// `duel_question` — a question pushed to both players simultaneously.
class DuelQuestionEvent {
  const DuelQuestionEvent({
    required this.duelId,
    required this.questionIndex,
    required this.question,
  });

  final String duelId;
  final int questionIndex;
  final DuelQuestion question;
}
