/// Backend endpoint'lari — Zukkor backend hujjatlariga 1:1 mos:
///  - Zukkor_Login.docx
///  - Zukkor_Profil_Yaratish.docx
///  - Zukkor_Ball_XP_Tizimi.docx
abstract final class ApiEndpoints {
  // Auth (Zukkor_Login.docx)
  static const String register = '/api/auth/register/';
  static const String login = '/api/auth/login/';
  static const String google = '/api/auth/google/';
  static const String tokenRefresh = '/api/auth/token/refresh/';

  // Profil (Zukkor_Profil_Yaratish.docx)
  static const String profileSetup = '/api/profile/setup/';
  static const String profileMe = '/api/profile/me/';

  // Quiz (Zukkor_Ball_XP_Tizimi.docx)
  static const String categories = '/api/categories/';
  static const String quizStart = '/api/quiz/start/';

  static String categoryQuestions(int categoryId, {int count = 10}) =>
      '/api/categories/$categoryId/questions/random/?count=$count';

  static String quizAnswer(int sessionId) => '/api/quiz/$sessionId/answer/';
}
