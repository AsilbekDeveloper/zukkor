import '../../domain/entities/question_breakdown_item.dart';
import '../../domain/entities/quiz_summary.dart';
import 'question_breakdown_item_model.dart';

class QuizSummaryModel {
  const QuizSummaryModel({
    required this.totalBall,
    required this.correctCount,
    required this.totalQuestions,
    required this.xpEarned,
    required this.newTotalXp,
    required this.breakdown,
  });

  factory QuizSummaryModel.fromJson(Map<String, dynamic> json) => QuizSummaryModel(
        totalBall: json['total_ball'] as int,
        correctCount: json['correct_count'] as int,
        totalQuestions: json['total_questions'] as int,
        xpEarned: json['xp_earned'] as int,
        newTotalXp: json['new_total_xp'] as int,
        breakdown: parseQuestionBreakdown(json['breakdown']),
      );

  final int totalBall;
  final int correctCount;
  final int totalQuestions;
  final int xpEarned;
  final int newTotalXp;
  final List<QuestionBreakdownItem> breakdown;

  QuizSummary toEntity() => QuizSummary(
        totalBall: totalBall,
        correctCount: correctCount,
        totalQuestions: totalQuestions,
        xpEarned: xpEarned,
        newTotalXp: newTotalXp,
        breakdown: breakdown,
      );
}
