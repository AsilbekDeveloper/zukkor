import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// FCM push-token'ni backendga yetkazish uchun yupqa o'ram. Ruxsat so'rash,
/// token olish va uning yangilanishini kuzatish shu yerda — token bilan
/// nima qilish (backendga yuborish) chaqiruvchining ishi, bu klass faqat
/// Firebase SDK'ni bilishi kerak bo'lgan yagona joy.
class PushNotificationService {
  // Lazy getter, eager field emas — Firebase ilova ishga tushmagan
  // kontekstda (masalan widget testlarida, `Firebase.initializeApp()`
  // hech qachon chaqirilmaydi) obyekt yaratilishining o'zi qulab
  // tushmasligi uchun; xato faqat quyidagi metodlar chaqirilganda,
  // ularning o'z try/catch'i ichida ushlanadi.
  FirebaseMessaging get _messaging => FirebaseMessaging.instance;

  // HomeScreen har `context.go(home)` da qayta yaratiladi — har safar
  // yangi obuna qo'shmaslik uchun oldingi obuna bekor qilinadi.
  StreamSubscription<String>? _tokenRefreshSub;

  /// Ruxsat so'raydi va joriy token'ni qaytaradi (foydalanuvchi ruxsat
  /// bermasa yoki token olib bo'lmasa `null` — xato emas, chunki push
  /// bildirishnoma ilovaning asosiy funksiyasi emas).
  Future<String?> requestTokenOrNull() async {
    try {
      final NotificationSettings settings = await _messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) return null;
      return await _messaging.getToken();
    } catch (_) {
      return null;
    }
  }

  /// Token qurilmada almashtirilganda (masalan ilova qayta o'rnatilganda)
  /// chaqiriladi — backend har doim eng so'nggi token'ni bilib turishi
  /// uchun [onToken] shu yerda beriladi. Takroran chaqirilganda oldingi
  /// obuna bekor qilinadi (faqat bitta aktiv obuna bo'ladi).
  void listenTokenRefresh(void Function(String token) onToken) {
    _tokenRefreshSub?.cancel();
    try {
      _tokenRefreshSub = _messaging.onTokenRefresh.listen(onToken);
    } catch (_) {
      // Best-effort — see class doc.
    }
  }
}

final Provider<PushNotificationService> pushNotificationServiceProvider =
    Provider<PushNotificationService>((ref) => PushNotificationService());
