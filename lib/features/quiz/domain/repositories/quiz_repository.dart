import '../entities/answer_result.dart';
import '../entities/category.dart';
import '../entities/quiz_start_result.dart';

abstract interface class QuizRepository {
  /// `GET /categories`.
  Future<List<Category>> getCategories();

  /// `POST /quiz/start` — yangi sessiya boshlaydi, birinchi savolni qaytaradi.
  Future<QuizStartResult> startQuiz({required int categoryId, required int questionCount});

  /// `POST /quiz/{session_id}/answer`. `selectedOption` — `null` bo'lsa
  /// vaqt tugagan (javob berilmagan) holatni bildiradi.
  Future<AnswerResult> submitAnswer({
    required String sessionId,
    required int sessionQuestionId,
    required int? selectedOption,
  });

  /// `POST /questions/{question_id}/report`. `reason` is one of
  /// 'wrong_answer' | 'unclear' | 'offensive' | 'other'.
  Future<void> reportQuestion({required int questionId, required String reason, String? comment});
}
