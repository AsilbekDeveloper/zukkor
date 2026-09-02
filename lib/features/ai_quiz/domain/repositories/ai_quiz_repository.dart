import '../entities/ai_quiz.dart';
import '../entities/discover_quiz.dart';
import '../entities/manual_question_input.dart';

abstract interface class AiQuizRepository {
  /// `POST /ai-quiz/generate` — hujjatni yuklaydi, AI orqali savollar
  /// generatsiya qilib, darhol shaxsiy quiz sifatida saqlaydi (alohida
  /// "saqlash" qadami yo'q — natija allaqachon saqlangan holda qaytadi).
  Future<AiQuiz> generate({
    String? filePath,
    String? fileName,
    String? instruction,
    String? topic,
    required int questionCount,
    int? topicCategoryId,
  });

  /// `GET /ai-quiz` — joriy foydalanuvchining o'z AI quizlari, eng
  /// yangisi birinchi.
  Future<List<AiQuiz>> list();

  /// `DELETE /ai-quiz/{id}`.
  Future<void> delete(int id);

  /// `PATCH /ai-quiz/{id}/visibility`.
  Future<AiQuiz> updateVisibility(int id, String visibility);

  /// `PATCH /ai-quiz/{id}/topic`.
  Future<AiQuiz> updateTopic(int id, int? topicCategoryId);

  /// `POST /ai-quiz/manual` — AI chaqirmasdan, foydalanuvchi o'zi yozgan
  /// savollardan quiz yaratadi.
  Future<AiQuiz> createManual({
    required String name,
    required List<ManualQuestionInput> questions,
    int? topicCategoryId,
  });

  /// `POST /ai-quiz/generate-async` — darhol job_id qaytaradi.
  Future<String> generateAsync({
    String? filePath,
    String? fileName,
    String? instruction,
    String? topic,
    required int questionCount,
    int? topicCategoryId,
  });

  /// `GET /ai-quiz/generate-async/{jobId}` — holatni tekshirish.
  Future<({String status, AiQuiz? quiz, String? error})> getAsyncJobStatus(String jobId);

  /// `GET /ai-quiz/users/{userId}` — shu foydalanuvchining sizga
  /// ko'rinadigan (ommaviy, yoki do'st bo'lsangiz — do'stlar uchun) quizlari.
  Future<List<AiQuiz>> listForUser(String userId);

  /// `GET /ai-quiz/discover` — boshqa foydalanuvchilarning ommaviy va
  /// do'stlar uchun (agar do'st bo'lsangiz) quizlari feed'i.
  Future<List<DiscoverQuiz>> discover({int? categoryId});

  /// `GET /ai-quiz/discover/search?q=...` — quiz nomi bo'yicha qidiruv.
  Future<List<DiscoverQuiz>> searchDiscover(String query, {int? categoryId});
}
