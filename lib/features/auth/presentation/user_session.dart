import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/session_expired_notifier.dart';
import '../../../core/notifications/push_notification_service.dart';
import '../../../core/router/app_router.dart';
import '../../../core/router/app_routes.dart';
import '../../ai_quiz/data/repositories/ai_quiz_repository_impl.dart';
import '../../ai_quiz/presentation/controllers/ai_quiz_controller.dart';
import '../../auth/data/repositories/auth_repository_impl.dart';
import '../../duel/data/datasources/duel_socket_data_source.dart';
import '../../duel/data/repositories/duel_repository_impl.dart';
import '../../duel/presentation/controllers/duel_controller.dart';
import '../../friends/data/repositories/friends_repository_impl.dart';
import '../../friends/presentation/controllers/friend_requests_controller.dart';
import '../../friends/presentation/controllers/friends_controller.dart';
import '../../friends/presentation/controllers/send_friend_request_controller.dart';
import '../../friends/presentation/controllers/user_search_controller.dart';
import '../../history/data/repositories/history_repository_impl.dart';
import '../../history/presentation/controllers/history_controller.dart';
import '../../leaderboard/data/repositories/leaderboard_repository_impl.dart';
import '../../leaderboard/presentation/controllers/leaderboard_controller.dart';
import '../../leaderboard/presentation/controllers/my_stats_controller.dart';
import '../../leaderboard/presentation/controllers/player_stats_controller.dart';
import '../../lobby/data/datasources/lobby_socket_data_source.dart';
import '../../lobby/data/repositories/lobby_repository_impl.dart';
import '../../lobby/presentation/controllers/lobby_controller.dart';
import '../../notifications/data/repositories/notifications_repository_impl.dart';
import '../../notifications/presentation/controllers/notifications_controller.dart';
import '../../quiz/data/repositories/quiz_repository_impl.dart';
import '../../settings/data/repositories/notification_preferences_repository_impl.dart';
import '../../settings/presentation/controllers/notification_preferences_controller.dart';
import 'controllers/current_user_controller.dart';

/// Foydalanuvchiga bog'liq barcha keshlangan holatni dastlabki holatiga
/// qaytaradi. Auth o'zgarishlarida chaqiriladi: kirish, ro'yxatdan o'tish,
/// Google kirish, chiqish, hisobni o'chirish ([AuthController]dan) va
/// sessiya majburan tugaganda ([sessionExpiryHandlerProvider]dan).
///
/// Aks holda bu holatlar sessiya davomida keshlanadi (ekranlar "bir marta
/// yukla" optimizatsiyasidan foydalanadi), va bir hisobdan chiqib boshqasiga
/// kirilganda oldingi foydalanuvchining profili, avatari, statistikasi,
/// reytingi, do'stlari va bildirishnomalari yangisiga "sizib" o'tadi.
///
/// Kategoriyalar ataylab qoldirilgan — ular hamma uchun bir xil (foydalanuvchiga
/// bog'liq emas), qayta yuklash keraksiz.
void resetUserScopedState(Ref ref) {
  // 1. Real vaqtli ulanishlarni uzish. WebSocket'lar token'ga bog'langan,
  //    shuning uchun ularni darhol yopish shart — aks holda eski user'ning
  //    ulanishi yangisiga "meros" qolib ketadi (leak).
  try {
    ref.read(duelSocketDataSourceProvider).disconnect();
    ref.read(lobbySocketDataSourceProvider).disconnect();
  } catch (_) {}

  // 2. Profil / identifikatsiya
  ref.invalidate(currentUserControllerProvider);

  // 3. Statistika / reyting
  ref.invalidate(myStatsControllerProvider);
  ref.invalidate(leaderboardControllerProvider);
  ref.invalidate(playerStatsControllerProvider);

  // 4. Do'stlar
  ref.invalidate(friendsControllerProvider);
  ref.invalidate(friendRequestsControllerProvider);
  ref.invalidate(sendFriendRequestControllerProvider);
  ref.invalidate(userSearchControllerProvider);

  // 5. Bildirishnomalar / sozlamalar
  ref.invalidate(notificationsControllerProvider);
  ref.invalidate(notificationPreferencesControllerProvider);

  // 6. O'yin tarixi
  ref.invalidate(historyControllerProvider);

  // 7. AI quizlar (shaxsiy ro'yxat)
  ref.invalidate(aiQuizControllerProvider);

  // 8. Controller'lar holati
  ref.invalidate(duelControllerProvider);
  ref.invalidate(lobbyControllerProvider);

  // 10. Data layer (Repositories & Data Sources)
  ref.invalidate(authRepositoryProvider);
  ref.invalidate(leaderboardRepositoryProvider);
  ref.invalidate(historyRepositoryProvider);
  ref.invalidate(friendsRepositoryProvider);
  ref.invalidate(notificationsRepositoryProvider);
  ref.invalidate(notificationPreferencesRepositoryProvider);
  ref.invalidate(aiQuizRepositoryProvider);
  ref.invalidate(quizRepositoryProvider);

  ref.invalidate(duelRepositoryProvider);
  ref.invalidate(duelSocketDataSourceProvider);
  ref.invalidate(lobbyRepositoryProvider);
  ref.invalidate(lobbySocketDataSourceProvider);
}

/// Bir necha akkaunt orasida almashtirilganda (yoki yangi akkaunt
/// qo'shilib, u darhol faol bo'lganda) FCM push-tokenni ENDI FAOL bo'lgan
/// akkauntga qayta bog'laydi.
///
/// `PUT /users/me/push-token` allaqachon "token boshqa userga bog'langan
/// bo'lsa, undan olib qayta bog'laydi" mantig'iga ega (bitta qurilma
/// tokeni bir vaqtda faqat bitta userga tegishli bo'ladi) — shuning uchun
/// bu yerda faqat SHU SO'ROVNI QAYTA YUBORISH kifoya, alohida
/// "unregister" chaqiruvi shart emas.
///
/// `HomeScreen._syncPushToken` buni ilova sessiyasi davomida FAQAT BIR
/// MARTA (birinchi Home ochilganda) qiladi — akkaunt almashtirish/qo'shish
/// esa Home'ni qayta ochmasdan sodir bo'lishi mumkin, shuning uchun bu
/// alohida, aniq chaqiriladigan funksiya kerak.
Future<void> syncPushTokenForActiveAccount(Ref ref) async {
  final String? token = await ref.read(pushNotificationServiceProvider).requestTokenOrNull();
  if (token != null) {
    await ref.read(registerPushTokenUseCaseProvider).call(token);
  }
}

/// Sessiya majburan tugaganini ushlaydigan provider. Interceptor refresh
/// muvaffaqiyatsiz bo'lganda `sessionExpiredProvider`ni oshiradi; bu yerda
/// (Ref mavjud bo'lgan joyda) uni tinglab, keshni tozalab, Login'ga
/// qaytaramiz. [ZukkorApp] uni `watch` qilib butun ilova umri davomida
/// jonli saqlaydi. Tokenlar interceptor tomonidan allaqachon tozalangan.
final Provider<void> sessionExpiryHandlerProvider = Provider<void>((ref) {
  ref.listen(sessionExpiredProvider, (previous, next) {
    resetUserScopedState(ref);
    ref.read(appRouterProvider).go(AppRoutes.login);
  });
});

/// Push-bildirishnoma bosilganda kerakli ekranga yo'naltiradi.
/// [ZukkorApp] uni `watch` qiladi.
final Provider<void> pushNotificationHandlerProvider = Provider<void>((ref) {
  final service = ref.read(pushNotificationServiceProvider);
  service.onTap.listen((message) {
    // Hozircha barcha push'lar (pdf_ready va h.k.) foydalanuvchini
    // "Mening quizlarim" bo'limiga yo'naltiradi.
    ref.read(appRouterProvider).push(AppRoutes.myAiQuizzes);
  });
});
