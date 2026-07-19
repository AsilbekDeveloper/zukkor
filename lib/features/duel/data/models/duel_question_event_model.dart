import '../../domain/entities/duel_question.dart';
import '../../domain/entities/duel_question_event.dart';

/// `duel_question` WebSocket message body.
class DuelQuestionEventModel {
  const DuelQuestionEventModel({required this.duelId, required this.questionIndex, required this.question});

  factory DuelQuestionEventModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> questionJson = json['question'] as Map<String, dynamic>;
    return DuelQuestionEventModel(
      duelId: json['duel_id'] as String,
      questionIndex: json['question_index'] as int,
      question: DuelQuestion(
        text: questionJson['text'] as String,
        options: (questionJson['options'] as List<dynamic>).cast<String>(),
        timeLimitMs: questionJson['time_limit_ms'] as int,
      ),
    );
  }

  final String duelId;
  final int questionIndex;
  final DuelQuestion question;

  DuelQuestionEvent toEntity() =>
      DuelQuestionEvent(duelId: duelId, questionIndex: questionIndex, question: question);
}
