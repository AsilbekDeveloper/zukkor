import '../entities/question_submission_result.dart';

abstract interface class QuestionSubmissionRepository {
  /// `POST /questions/submit` — foydalanuvchi ochiq kategoriyaga yangi
  /// savol taklif qiladi, Gemini uni so'rov paytida sinxron tekshiradi.
  Future<QuestionSubmissionResult> submit({
    required String questionText,
    required List<String> options,
    required int correctOptionIndex,
    int? categoryId,
  });
}
