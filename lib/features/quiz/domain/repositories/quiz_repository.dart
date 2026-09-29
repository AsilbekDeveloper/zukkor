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

  /// `GET /quiz/{category_id}/export/pdf` — quizni bosma A4 test qog'ozi
  /// sifatida PDF qilib eksport qiladi (javoblar kaliti bilan birga).
  /// Diamond bilan to'lanadi; balans yetarli bo'lmasa `ValidationFailure`
  /// (402) ko'taradi.
  Future<List<int>> exportQuizPdf(int categoryId);

  /// `GET /quiz/{category_id}/export/docx` — [exportQuizPdf]ning Word
  /// (.docx) varianti, narxi bir xil.
  Future<List<int>> exportQuizDocx(int categoryId);
}
