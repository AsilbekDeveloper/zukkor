/// Build-time konfiguratsiya. Qiymat `--dart-define` orqali beriladi:
///
/// ```sh
/// flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
/// ```
///
/// Hech qanday qiymat berilmasa, production backend (Render) ishlatiladi —
/// istalgan qurilma, istalgan tarmoqdan ishlaydi, LAN IP/emulator loopback
/// sozlash shart emas.
abstract final class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://zukkor-backend.onrender.com',
  );

  /// Tarmoq so'rovlari uchun umumiy timeout.
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 20);

  /// [apiBaseUrl]dan hosil qilingan WebSocket manzili (`http`→`ws`,
  /// `https`→`wss`) — Duel real vaqtli ulanishi uchun.
  static String get wsBaseUrl => apiBaseUrl.replaceFirst('http', 'ws');

  /// Google Cloud Console'dagi "Web application" turidagi OAuth client
  /// ID — Google Sign-In natijasidagi ID token shu client uchun
  /// mo'ljallangan (`aud` da'vosi) bo'lishini ta'minlaydi, backend ham
  /// tokenni shu client ID'ga qarshi tekshiradi. Bo'sh bo'lsa Google
  /// Sign-In tugmasi ishlamaydi (hali sozlanmagan).
  static const String googleServerClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
}
