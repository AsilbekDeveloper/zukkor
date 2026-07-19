import '../../domain/entities/duel_question_result.dart';

/// `duel_question_result` WebSocket message body.
class DuelQuestionResultModel {
  const DuelQuestionResultModel({
    required this.duelId,
    required this.questionIndex,
    required this.correctOption,
    required this.yourSelectedOption,
    required this.yourCorrect,
    required this.opponentSelectedOption,
    required this.opponentCorrect,
  });

  factory DuelQuestionResultModel.fromJson(Map<String, dynamic> json) => DuelQuestionResultModel(
        duelId: json['duel_id'] as String,
        questionIndex: json['question_index'] as int,
        correctOption: json['correct_option'] as int,
        yourSelectedOption: json['your_selected_option'] as int?,
        yourCorrect: json['your_correct'] as bool,
        opponentSelectedOption: json['opponent_selected_option'] as int?,
        opponentCorrect: json['opponent_correct'] as bool,
      );

  final String duelId;
  final int questionIndex;
  final int correctOption;
  final int? yourSelectedOption;
  final bool yourCorrect;
  final int? opponentSelectedOption;
  final bool opponentCorrect;

  DuelQuestionResult toEntity() => DuelQuestionResult(
        duelId: duelId,
        questionIndex: questionIndex,
        correctOption: correctOption,
        yourSelectedOption: yourSelectedOption,
        yourCorrect: yourCorrect,
        opponentSelectedOption: opponentSelectedOption,
        opponentCorrect: opponentCorrect,
      );
}
