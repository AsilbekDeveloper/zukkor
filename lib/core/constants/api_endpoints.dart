/// Backend endpoint'lari.
abstract final class ApiEndpoints {
  // Auth — FastAPI backendga 1:1 mos (2026-07-15 holatiga ko'ra tayyor).
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String google = '/auth/google'; // hali backendda yo'q, TODO
  static const String tokenRefresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Profil (Zukkor_Profil_Yaratish.docx) — Onboarding wizard'ini yakunlash.
  static const String profileSetup = '/users/me/profile';
  static const String usernameAvailable = '/users/username-available';

  // Quiz (Zukkor_Ball_XP_Tizimi.docx)
  static const String categories = '/api/categories/';
  static const String quizStart = '/api/quiz/start/';

  static String categoryQuestions(int categoryId, {int count = 10}) =>
      '/api/categories/$categoryId/questions/random/?count=$count';

  static String quizAnswer(int sessionId) => '/api/quiz/$sessionId/answer/';
}
