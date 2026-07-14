import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// JWT tokenlar ombori. Interfeys sifatida yozilgan — testlarda
/// in-memory fake bilan almashtiriladi.
abstract interface class TokenStorage {
  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();
  Future<void> saveTokens({required String access, String? refresh});
  Future<void> clear();
}

/// Ishlab chiqarish implementatsiyasi — platformaning xavfsiz omboridan
/// foydalanadi (Android Keystore / iOS Keychain). Tokenlar HECH QACHON
/// SharedPreferences kabi ochiq joyda saqlanmaydi.
class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );

  final FlutterSecureStorage _storage;

  static const String _accessKey = 'zukkor.access_token';
  static const String _refreshKey = 'zukkor.refresh_token';

  @override
  Future<String?> readAccessToken() => _storage.read(key: _accessKey);

  @override
  Future<String?> readRefreshToken() => _storage.read(key: _refreshKey);

  @override
  Future<void> saveTokens({required String access, String? refresh}) async {
    await _storage.write(key: _accessKey, value: access);
    // Backend ROTATE_REFRESH_TOKENS ishlatadi — refresh har safar
    // yangilanishi mumkin; berilgan bo'lsagina ustidan yozamiz.
    if (refresh != null) {
      await _storage.write(key: _refreshKey, value: refresh);
    }
  }

  @override
  Future<void> clear() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }
}

final Provider<TokenStorage> tokenStorageProvider = Provider<TokenStorage>(
  (ref) => SecureTokenStorage(),
);
