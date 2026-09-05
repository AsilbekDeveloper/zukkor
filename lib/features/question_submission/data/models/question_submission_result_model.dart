import '../../domain/entities/question_submission_result.dart';

class QuestionSubmissionResultModel {
  const QuestionSubmissionResultModel({
    required this.approved,
    this.rejectionReason,
    this.categoryId,
    this.categoryName,
    this.questionId,
  });

  final bool approved;
  final String? rejectionReason;
  final int? categoryId;
  final String? categoryName;
  final int? questionId;

  factory QuestionSubmissionResultModel.fromJson(Map<String, dynamic> json) {
    return QuestionSubmissionResultModel(
      approved: json['approved'] as bool,
      rejectionReason: json['rejection_reason'] as String?,
      categoryId: json['category_id'] as int?,
      categoryName: json['category_name'] as String?,
      questionId: json['question_id'] as int?,
    );
  }

  QuestionSubmissionResult toEntity() => QuestionSubmissionResult(
        approved: approved,
        rejectionReason: rejectionReason,
        categoryId: categoryId,
        categoryName: categoryName,
        questionId: questionId,
      );
}
