class QuestionSubmissionResult {
  const QuestionSubmissionResult({
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
}
