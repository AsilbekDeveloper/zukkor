import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Refresh token ham eskirganda (foydalanuvchini majburan chiqarish kerak
/// bo'lganda) interceptor shu notifier orqali signal beradi.
///
/// Auth feature qayta qurilganda buni `ref.listen` qiladi va logout
/// holatiga o'tadi. Bu core → feature yo'nalishidagi to'g'ridan-to'g'ri
/// bog'liqlikni oldini oladi: core faqat "sessiya tugadi" deb e'lon
/// qiladi, kim qanday munosabat bildirishini bilmaydi.
class SessionExpiredNotifier extends Notifier<int> {
  @override
  int build() => 0;

  /// Har chaqirilganda hisoblagich oshadi — tinglovchilar o'zgarishni sezadi.
  void notify() => state++;
}

final NotifierProvider<SessionExpiredNotifier, int> sessionExpiredProvider =
    NotifierProvider<SessionExpiredNotifier, int>(SessionExpiredNotifier.new);
