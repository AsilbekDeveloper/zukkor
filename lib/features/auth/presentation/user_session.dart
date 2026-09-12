import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/session_expired_notifier.dart';
import '../../../core/notifications/push_notification_service.dart';
import '../../../core/router/app_router.dart';
import '../../../core/router/app_routes.dart';
import '../../ai_quiz/data/repositories/ai_quiz_repository_impl.dart';
import '../../ai_quiz/presentation/controllers/ai_quiz_controller.dart';
import '../../auth/data/repositories/auth_repository_impl.dart';
import '../../duel/data/datasources/duel_socket_data_source.dart';
import '../../duel/data/models/duel_invite_model.dart';
import '../../duel/data/repositories/duel_repository_impl.dart';
import '../../duel/domain/entities/duel_invite.dart';
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
import '../../quiz/presentation/controllers/categories_controller.dart';
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

/// [resetUserScopedState]dan KEYIN, agar ENDI HAQIQATAN HAM YANGI faol
/// sessiya bo'lsa (login, register, Google — logout/sessiya-tugashida
/// EMAS, u yerda faol sessiya yo'q) chaqiriladi — asosiy ekranlarning
/// ma'lumotini DARHOL qayta yuklaydi.
///
/// MUHIM: bu shart, chunki doimiy pastki-navigatsiya qobig'i ([MainShell] /
/// `StatefulShellRoute.indexedStack`) Home/Profile kabi ekranlarni qayta
/// QURMAYDI — ular `IndexedStack`da tirik saqlanadi, shuning uchun
/// ularning `initState`dagi "ma'lumot yo'q bo'lsa yukla" mantig'i qayta
/// ishga TUSHMAYDI. `resetUserScopedState` faqat holatni bo'shatadi
/// (invalidate) — buni chaqirmasak, yangi sessiyadan keyin ma'lumot
/// abadiy bo'sh qolib ketardi (2026-09-06'da real qurilmada aynan shu
/// holat topilgan).
Future<void> reloadEssentialDataForNewAccount(Ref ref) async {
  // Profil, kategoriyalar va bildirishnomalar bir-biriga bog'liq emas —
  // ketma-ket kutish o'rniga birga yuboriladi. Statistika esa profildan
  // olingan userId'ga muhtoj, shuning uchun keyin.
  await Future.wait([
    ref.read(currentUserControllerProvider.notifier).load(),
    ref.read(categoriesControllerProvider.notifier).load(),
    ref.read(notificationsControllerProvider.notifier).load(),
  ]);
  final String? userId = ref.read(currentUserControllerProvider).data?.id;
  if (userId != null) {
    await ref.read(myStatsControllerProvider.notifier).load(userId);
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

/// Push-bildirishnoma bosilganda kerakli ekranga yo'naltiradi - har bir
/// push endi backend'dan `data: {"type": "..."}` bilan keladi
/// (`app/services/push.py`), shu turga qarab mos ekran ochiladi.
/// [ZukkorApp] uni `watch` qiladi.
final Provider<void> pushNotificationHandlerProvider = Provider<void>((ref) {
  final service = ref.read(pushNotificationServiceProvider);
  service.onTap.listen((message) {
    final String? type = message.data['type'] as String?;
    switch (type) {
      case 'duel_challenge':
        _openDuelInviteFromPush(ref, message.data['invite'] as String?);
      case 'friend_request':
        ref.read(appRouterProvider).push(AppRoutes.friendRequests);
      case 'ai_quiz_ready':
      case 'ai_quiz_failed':
        // Muvaffaqiyatli bo'lsa yangi quiz ro'yxat boshida ko'rinadi;
        // muvaffaqiyatsiz bo'lsa ham qayta urinish shu yerdan qulay.
        ref.read(appRouterProvider).push(AppRoutes.myAiQuizzes);
      case 'streak_reminder':
        ref.read(appRouterProvider).go(AppRoutes.home);
      default:
        // Eski ilova versiyasidan kelgan yoki hali routing yozilmagan
        // kelajakdagi tur - eng xavfsiz variant sifatida Home.
        ref.read(appRouterProvider).go(AppRoutes.home);
    }
  });
});

/// `duel_challenge` push payload'i `duel_invite_received` WebSocket
/// xabari bilan bir xil JSON shaklda keladi (backend'dagi
/// `_handle_duel_invite`) - ilova sovuq/fonda bo'lib socket hali
/// ulanmagan bo'lsa ham, HECH QANDAY qo'shimcha so'rovsiz to'liq
/// [DuelInvite] qurish mumkin.
void _openDuelInviteFromPush(Ref ref, String? inviteJson) {
  if (inviteJson == null) return;
  try {
    final DuelInvite invite = DuelInviteModel.fromJson(
      jsonDecode(inviteJson) as Map<String, dynamic>,
    ).toEntity();
    ref.read(appRouterProvider).push(AppRoutes.duelInvite, extra: invite);
  } catch (_) {
    // Yaroqsiz/eskirgan payload - hech bo'lmasa ilova ochiq qolaveradi,
    // foydalanuvchi Home'dan davom etadi.
  }
}
