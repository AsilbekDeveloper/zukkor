/// Backend endpoint'lari.
abstract final class ApiEndpoints {
  // Auth — FastAPI backendga 1:1 mos (2026-07-15 holatiga ko'ra tayyor).
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String google = '/auth/google'; // endi Firebase ID token qabul qiladi — backendda Firebase Admin SDK bilan tekshiriladi
  static const String tokenRefresh = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String me = '/auth/me';

  // Profil (Zukkor_Profil_Yaratish.docx) — Onboarding wizard'ini yakunlash.
  static const String profileSetup = '/users/me/profile';
  static const String usernameAvailable = '/users/username-available';

  // Avatar rasm yuklash (2026-07-18'da qo'shildi, hali backend'da yo'q).
  static const String avatarUpload = '/users/me/avatar';

  // Parol o'zgartirish / akkaunt o'chirish (2026-07-18'da qo'shildi, hali
  // backend'da yo'q).
  static const String changePassword = '/auth/change-password';
  static const String deleteAccount = '/auth/me';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';

  // Bildirishnoma sozlamalari (2026-07-18'da qo'shildi, hali backend'da yo'q).
  static const String notificationPreferences = '/users/me/notification-preferences';

  // Quiz (Zukkor_Ball_XP_Tizimi.docx, ball formulasi 2026-07-17'da yangilangan)
  static const String categories = '/categories';
  static const String quizStart = '/quiz/start';

  static String quizAnswer(String sessionId) => '/quiz/$sessionId/answer';

  static String reportQuestion(int questionId) => '/questions/$questionId/report';

  // Leaderboard (2026-07-17'da qo'shildi; scope 2026-07-19'da qo'shildi —
  // weekly/all_time/friends kesimlari).
  static String leaderboard({int limit = 50, String scope = 'all_time', int offset = 0}) =>
      '/leaderboard?limit=$limit&scope=$scope&offset=$offset';
  static String playerStats(String userId) => '/leaderboard/$userId';

  // Game history (2026-07-18'da qo'shildi).
  static String history({int limit = 50, int offset = 0}) => '/history?limit=$limit&offset=$offset';

  // Friends (2026-07-18'da qo'shildi).
  static const String friends = '/friends';
  static String friendsSearch(String query) => '/friends/search?q=${Uri.encodeQueryComponent(query)}';

  // Friend requests (2026-07-19'da qo'shildi, hali backend'da yo'q — instant
  // mutual add o'rniga request/accept oqimiga o'tildi).
  static const String friendRequests = '/friends/requests';
  static const String incomingFriendRequests = '/friends/requests/incoming';
  static String acceptFriendRequest(String requestId) => '/friends/requests/$requestId/accept';
  static String declineFriendRequest(String requestId) => '/friends/requests/$requestId/decline';

  // Notifications (2026-07-19'da qo'shildi, hali backend'da yo'q).
  static const String notifications = '/notifications';
  static const String notificationsMarkAllRead = '/notifications/mark-all-read';

  // Push-token ro'yxatga olish — FCM (2026-07-21'da qo'shildi, hali backend'da yo'q).
  static const String pushToken = '/users/me/push-token';

  // AI orqali hujjatdan quiz yaratish (2026-08-11'da qo'shildi).
  static const String aiQuiz = '/ai-quiz';
  static const String aiQuizGenerate = '/ai-quiz/generate';
  static String aiQuizDelete(int id) => '/ai-quiz/$id';
  static String aiQuizVisibility(int id) => '/ai-quiz/$id/visibility';
  static const String aiQuizManual = '/ai-quiz/manual';
  static String aiQuizForUser(String userId) => '/ai-quiz/users/$userId';
  static const String aiQuizDiscover = '/ai-quiz/discover';
  static String aiQuizDiscoverSearch(String query) => '/ai-quiz/discover/search?q=${Uri.encodeQueryComponent(query)}';
}
