import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/session_expired_notifier.dart';
import '../../../core/router/app_router.dart';
import '../../../core/router/app_routes.dart';
import '../../duel/presentation/controllers/duel_controller.dart';
import '../../friends/presentation/controllers/friend_requests_controller.dart';
import '../../friends/presentation/controllers/friends_controller.dart';
import '../../friends/presentation/controllers/send_friend_request_controller.dart';
import '../../friends/presentation/controllers/user_search_controller.dart';
import '../../history/presentation/controllers/history_controller.dart';
import '../../leaderboard/presentation/controllers/leaderboard_controller.dart';
import '../../leaderboard/presentation/controllers/my_stats_controller.dart';
import '../../leaderboard/presentation/controllers/player_stats_controller.dart';
import '../../lobby/presentation/controllers/lobby_controller.dart';
import '../../notifications/presentation/controllers/notifications_controller.dart';
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
  // Profil / identifikatsiya
  ref.invalidate(currentUserControllerProvider);

  // Statistika / reyting
  ref.invalidate(myStatsControllerProvider);
  ref.invalidate(leaderboardControllerProvider);
  ref.invalidate(playerStatsControllerProvider);

  // Do'stlar
  ref.invalidate(friendsControllerProvider);
  ref.invalidate(friendRequestsControllerProvider);
  ref.invalidate(sendFriendRequestControllerProvider);
  ref.invalidate(userSearchControllerProvider);

  // Bildirishnomalar / sozlamalar
  ref.invalidate(notificationsControllerProvider);
  ref.invalidate(notificationPreferencesControllerProvider);

  // O'yin tarixi
  ref.invalidate(historyControllerProvider);

  // Real vaqtli ulanishlar — token o'zgargani uchun WebSocket'lar yopilib,
  // keyingi hisobda qayta ulanishi kerak.
  ref.invalidate(duelControllerProvider);
  ref.invalidate(lobbyControllerProvider);
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
