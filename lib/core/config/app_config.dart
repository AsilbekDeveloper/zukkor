/// Build-time konfiguratsiya. Qiymatlar `--dart-define` orqali beriladi:
///
/// ```sh
/// flutter run --dart-define=API_BASE_URL=https://api.zukkor.uz --dart-define=USE_MOCK_AUTH=false
/// ```
///
/// Hech qanday qiymat berilmasa, lokal rivojlanish rejimi ishlaydi:
/// mock auth yoqilgan, API manzili Android emulator'ning host loopback'iga
/// qaraydi (10.0.2.2 = emulator ichidan kompyuterning localhost'i).
abstract final class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  /// True bo'lsa auth real API o'rniga xotiradagi fake repository bilan
  /// ishlaydi — backend tayyor bo'lmaguncha UI oqimini to'liq sinash uchun.
  static const bool useMockAuth = bool.fromEnvironment(
    'USE_MOCK_AUTH',
    defaultValue: true,
  );

  /// Tarmoq so'rovlari uchun umumiy timeout.
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
