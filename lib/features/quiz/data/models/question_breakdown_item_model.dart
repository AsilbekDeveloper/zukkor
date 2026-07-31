import '../../domain/entities/question_breakdown_item.dart';

class QuestionBreakdownItemModel {
  const QuestionBreakdownItemModel({
    required this.order,
    required this.questionText,
    required this.isCorrect,
  });

  factory QuestionBreakdownItemModel.fromJson(Map<String, dynamic> json) => QuestionBreakdownItemModel(
        order: json['order'] as int,
        questionText: json['question_text'] as String,
        isCorrect: json['is_correct'] as bool,
      );

  final int order;
  final String questionText;
  final bool isCorrect;

  QuestionBreakdownItem toEntity() => QuestionBreakdownItem(
        order: order,
        questionText: questionText,
        isCorrect: isCorrect,
      );
}

/// Parses the `breakdown` array present on Solo/Duel/Lobby's finish
/// payloads — a plain top-level function (rather than a named
/// constructor) since it's shared across three otherwise-unrelated
/// models.
List<QuestionBreakdownItem> parseQuestionBreakdown(dynamic json) => (json as List<dynamic>? ?? [])
    .map((item) => QuestionBreakdownItemModel.fromJson(item as Map<String, dynamic>).toEntity())
    .toList();
