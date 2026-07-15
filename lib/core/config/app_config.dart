/// Build-time konfiguratsiya. Qiymat `--dart-define` orqali beriladi:
///
/// ```sh
/// flutter run --dart-define=API_BASE_URL=https://api.zukkor.uz
/// ```
///
/// Hech qanday qiymat berilmasa, lokal rivojlanish rejimi ishlaydi: API
/// manzili Android emulator'ning host loopback'iga qaraydi (10.0.2.2 =
/// emulator ichidan kompyuterning localhost'i).
abstract final class AppConfig {
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000',
  );

  /// Tarmoq so'rovlari uchun umumiy timeout.
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 20);
}
