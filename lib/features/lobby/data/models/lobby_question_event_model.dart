import '../../domain/entities/lobby_question.dart';
import '../../domain/entities/lobby_question_event.dart';

/// `lobby_question` WebSocket message body.
class LobbyQuestionEventModel {
  const LobbyQuestionEventModel({required this.roomId, required this.questionIndex, required this.question});

  factory LobbyQuestionEventModel.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> questionJson = json['question'] as Map<String, dynamic>;
    return LobbyQuestionEventModel(
      roomId: json['room_id'] as String,
      questionIndex: json['question_index'] as int,
      question: LobbyQuestion(
        text: questionJson['text'] as String,
        options: (questionJson['options'] as List<dynamic>).cast<String>(),
        correctOption: questionJson['correct_option'] as int,
        timeLimitMs: questionJson['time_limit_ms'] as int,
      ),
    );
  }

  final String roomId;
  final int questionIndex;
  final LobbyQuestion question;

  LobbyQuestionEvent toEntity() =>
      LobbyQuestionEvent(roomId: roomId, questionIndex: questionIndex, question: question);
}
