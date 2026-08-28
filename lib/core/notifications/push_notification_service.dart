import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// FCM push-token'ni backendga yetkazish uchun yupqa o'ram. Ruxsat so'rash,
/// token olish va uning yangilanishini kuzatish shu yerda.
class PushNotificationService {
  PushNotificationService();

  FirebaseMessaging get _messaging => FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  StreamSubscription<String>? _tokenRefreshSub;
  StreamSubscription<RemoteMessage>? _foregroundSub;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'zukkor_main',
    'Zukkor Notifications',
    description: 'Used for important game events like duel invites.',
    importance: Importance.max,
  );

  void _initLocal() {
    try {
      // FlutterLocalNotificationsPlugin's internal platform instance
      // access might throw a LateInitializationError in some widget test
      // environments before any real platform implementation is
      // registered. We wrap the whole initialization to be best-effort.
      const AndroidInitializationSettings android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings init = InitializationSettings(android: android);
      _local.initialize(init).catchError((_) => false);
    } catch (_) {
      // Silently ignore initialization failures (common in tests).
    }
  }

  /// Ruxsat so'raydi va joriy token'ni qaytaradi.
  Future<String?> requestTokenOrNull() async {
    try {
      final NotificationSettings settings = await _messaging.requestPermission();
      if (settings.authorizationStatus == AuthorizationStatus.denied) return null;
      return await _messaging.getToken();
    } catch (_) {
      return null;
    }
  }

  /// Token qurilmada almashtirilganda chaqiriladi.
  void listenTokenRefresh(void Function(String token) onToken) {
    _tokenRefreshSub?.cancel();
    try {
      _tokenRefreshSub = _messaging.onTokenRefresh.listen(onToken);
    } catch (_) {}
  }

  /// Ilova ochiq turganda (foreground) kelgan xabarlarni tutib, lokal
  /// bildirishnoma sifatida ko'rsatadi — aks holda Firebase ularni
  /// jimgina yutib yuboradi.
  void listenForeground() {
    _initLocal();
    _foregroundSub?.cancel();
    try {
      _foregroundSub = FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        final RemoteNotification? notification = message.notification;
        final AndroidNotification? android = message.notification?.android;

        if (notification != null && android != null) {
          _local.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                _channel.id,
                _channel.name,
                channelDescription: _channel.description,
                importance: _channel.importance,
                priority: Priority.high,
                icon: android.smallIcon,
              ),
            ),
          );
        }
      });
    } catch (_) {}
  }
}

final Provider<PushNotificationService> pushNotificationServiceProvider =
    Provider<PushNotificationService>((ref) => PushNotificationService());
