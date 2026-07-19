import '../../domain/entities/lobby_question_result.dart';

/// `lobby_question_result` WebSocket message body.
class LobbyQuestionResultModel {
  const LobbyQuestionResultModel({
    required this.roomId,
    required this.questionIndex,
    required this.correctOption,
    required this.yourSelectedOption,
    required this.yourCorrect,
  });

  factory LobbyQuestionResultModel.fromJson(Map<String, dynamic> json) => LobbyQuestionResultModel(
        roomId: json['room_id'] as String,
        questionIndex: json['question_index'] as int,
        correctOption: json['correct_option'] as int,
        yourSelectedOption: json['your_selected_option'] as int?,
        yourCorrect: json['your_correct'] as bool,
      );

  final String roomId;
  final int questionIndex;
  final int correctOption;
  final int? yourSelectedOption;
  final bool yourCorrect;

  LobbyQuestionResult toEntity() => LobbyQuestionResult(
        roomId: roomId,
        questionIndex: questionIndex,
        correctOption: correctOption,
        yourSelectedOption: yourSelectedOption,
        yourCorrect: yourCorrect,
      );
}
