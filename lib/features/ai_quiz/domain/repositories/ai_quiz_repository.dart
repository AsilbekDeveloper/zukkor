import '../entities/ai_quiz.dart';

abstract interface class AiQuizRepository {
  /// `POST /ai-quiz/generate` — hujjatni yuklaydi, AI orqali savollar
  /// generatsiya qilib, darhol shaxsiy quiz sifatida saqlaydi (alohida
  /// "saqlash" qadami yo'q — natija allaqachon saqlangan holda qaytadi).
  Future<AiQuiz> generate({
    required String filePath,
    required String fileName,
    required String instruction,
    required int questionCount,
  });

  /// `GET /ai-quiz` — joriy foydalanuvchining o'z AI quizlari, eng
  /// yangisi birinchi.
  Future<List<AiQuiz>> list();

  /// `DELETE /ai-quiz/{id}`.
  Future<void> delete(int id);
}
