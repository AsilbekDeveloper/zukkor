import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Akkauntlar ro'yxatida saqlanadigan yengil metama'lumot (parol/token yo'q).
class StoredAccountInfo {
  const StoredAccountInfo({
    required this.userId,
    required this.email,
    this.username,
    this.avatarUrl,
  });

  final String userId;
  final String email;
  final String? username;
  final String? avatarUrl;

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'email': email,
        'username': username,
        'avatarUrl': avatarUrl,
      };

  factory StoredAccountInfo.fromJson(Map<String, dynamic> json) => StoredAccountInfo(
        userId: json['userId'] as String,
        email: json['email'] as String,
        username: json['username'] as String?,
        avatarUrl: json['avatarUrl'] as String?,
      );
}

/// JWT tokenlar ombori. Interfeys sifatida yozilgan — testlarda
/// in-memory fake bilan almashtiriladi.
abstract interface class TokenStorage {
  Future<String?> readAccessToken();
  Future<String?> readRefreshToken();
  Future<void> saveTokens({required String access, String? refresh});
  Future<void> clear();

  /// Hozir faol akkauntning user_id'si (agar birortasi "ro'yxatga
  /// o'tkazilgan" bo'lsa). Eski (hali migratsiya qilinmagan) sessiya uchun
  /// `null` qaytaradi.
  Future<String?> activeAccountId();

  /// Lokalda saqlangan barcha akkauntlarning yengil metama'lumoti.
  Future<List<StoredAccountInfo>> listAccounts();

  /// Foydalanuvchi identifikatsiyasi ANIQLANGANDAN KEYIN (masalan
  /// getCurrentUser() muvaffaqiyatli bo'lgach) chaqiriladi — tokenlarni shu
  /// userId'ga "ro'yxatga o'tkazadi": agar [savePendingLoginTokens] orqali
  /// saqlangan "kutilayotgan" tokenlar bo'lsa O'SHALARDAN foydalanadi (va
  /// ularni tozalaydi) — bu "akkaunt qo'shish" oqimi uchun, joriy faol
  /// akkauntga TEGMAYDI. Aks holda (bitta-akkaunt/eski sessiya oqimi uchun
  /// orqaga moslik) joriy faol/eski tokenlardan foydalanadi. Ro'yxatga
  /// o'tkazilgan tokenlar 'zukkor.tokens.{userId}' ostiga yoziladi, accounts
  /// ro'yxatiga qo'shiladi, va faol akkaunt ko'rsatkichi shu userId'ga
  /// o'rnatiladi.
  Future<void> registerActiveSession({
    required String userId,
    required StoredAccountInfo info,
  });

  /// Yangi login/register/google-signin MUVAFFAQIYATLI bo'lgach, lekin
  /// foydalanuvchi identifikatsiyasi hali ANIQLANMAGAN bosqichda (masalan
  /// getCurrentUser() hali chaqirilmagan) chaqiriladi — tokenlarni HALI
  /// FAOL AKKAUNT DEB BELGILAMASDAN vaqtinchalik alohida joyga saqlaydi.
  ///
  /// MUHIM: bu "akkaunt qo'shish" oqimi UCHUN MAXSUS — joriy faol akkaunt
  /// (agar bor bo'lsa) tasodifan ustidan yozilib ketmasligi shu orqali
  /// kafolatlanadi. Oddiy (bitta akkaunt) login/refresh oqimi bundan
  /// FOYDALANMAYDI — ular hamon [saveTokens]ni ishlatadi.
  Future<void> savePendingLoginTokens({required String access, String? refresh});

  /// Berilgan userId uchun SAQLANGAN tokenlarni faol qiladi.
  Future<void> setActiveAccount(String userId);

  /// Berilgan akkauntning tokenlari + metama'lumotini butunlay o'chiradi.
  Future<void> removeAccount(String userId);

  /// Berilgan akkauntning (albatta FAOL bo'lishi shart emas) refresh tokenini
  /// o'qiydi — uni serverdan chiqarish (logout) uchun kerak.
  Future<String?> readRefreshTokenFor(String userId);
}

/// Ishlab chiqarish implementatsiyasi — platformaning xavfsiz omboridan
/// foydalanadi (Android Keystore / iOS Keychain).
class SecureTokenStorage implements TokenStorage {
  SecureTokenStorage([FlutterSecureStorage? storage])
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _storage;

  static const String _oldAccessKey = 'zukkor.access_token';
  static const String _oldRefreshKey = 'zukkor.refresh_token';
  static const String _activeAccountIdKey = 'zukkor.active_account_id';
  static const String _accountsRegistryKey = 'zukkor.accounts_registry';
  static const String _pendingLoginTokensKey = 'zukkor.pending_login_tokens';

  String _tokenKey(String userId) => 'zukkor.tokens.$userId';

  @override
  Future<String?> readAccessToken() async {
    final String? activeId = await _storage.read(key: _activeAccountIdKey);
    if (activeId != null) {
      final String? json = await _storage.read(key: _tokenKey(activeId));
      if (json != null) {
        return (jsonDecode(json) as Map<String, dynamic>)['access'] as String?;
      }
    }
    return _storage.read(key: _oldAccessKey);
  }

  @override
  Future<String?> readRefreshToken() async {
    final String? activeId = await _storage.read(key: _activeAccountIdKey);
    if (activeId != null) {
      final String? json = await _storage.read(key: _tokenKey(activeId));
      if (json != null) {
        return (jsonDecode(json) as Map<String, dynamic>)['refresh'] as String?;
      }
    }
    return _storage.read(key: _oldRefreshKey);
  }

  @override
  Future<void> saveTokens({required String access, String? refresh}) async {
    final String? activeId = await _storage.read(key: _activeAccountIdKey);
    if (activeId != null) {
      final String key = _tokenKey(activeId);
      final String? existingJson = await _storage.read(key: key);
      final Map<String, dynamic> data = existingJson != null
          ? jsonDecode(existingJson) as Map<String, dynamic>
          : {};

      data['access'] = access;
      if (refresh != null) {
        data['refresh'] = refresh;
      }
      await _storage.write(key: key, value: jsonEncode(data));
    } else {
      await _storage.write(key: _oldAccessKey, value: access);
      if (refresh != null) {
        await _storage.write(key: _oldRefreshKey, value: refresh);
      }
    }
  }

  @override
  Future<void> clear() async {
    final String? activeId = await _storage.read(key: _activeAccountIdKey);
    if (activeId != null) {
      await _storage.delete(key: _tokenKey(activeId));
      await _storage.delete(key: _activeAccountIdKey);
    } else {
      await _storage.delete(key: _oldAccessKey);
      await _storage.delete(key: _oldRefreshKey);
    }
  }

  @override
  Future<String?> activeAccountId() => _storage.read(key: _activeAccountIdKey);

  @override
  Future<List<StoredAccountInfo>> listAccounts() async {
    final String? json = await _storage.read(key: _accountsRegistryKey);
    if (json == null) return [];
    try {
      final List<dynamic> list = jsonDecode(json) as List<dynamic>;
      return list
          .map((item) => StoredAccountInfo.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> savePendingLoginTokens({required String access, String? refresh}) async {
    await _storage.write(
      key: _pendingLoginTokensKey,
      value: jsonEncode({'access': access, 'refresh': refresh}),
    );
  }

  @override
  Future<void> registerActiveSession({
    required String userId,
    required StoredAccountInfo info,
  }) async {
    // 1. Tokenlarni aniqlash — avval "kutilayotgan" (akkaunt qo'shish oqimi)
    //    tokenlar bormi tekshiramiz, joriy FAOL akkauntga tegmasdan. Bo'lmasa
    //    (bitta-akkaunt/eski sessiya oqimi) joriy faol/eski tokenlardan
    //    foydalanamiz — bu holatda registerActiveSession joriy sessiyaning
    //    O'ZINI ro'yxatga o'tkazadi, boshqa akkauntni emas.
    final String? pendingJson = await _storage.read(key: _pendingLoginTokensKey);
    String? access;
    String? refresh;
    if (pendingJson != null) {
      final Map<String, dynamic> pending = jsonDecode(pendingJson) as Map<String, dynamic>;
      access = pending['access'] as String?;
      refresh = pending['refresh'] as String?;
      await _storage.delete(key: _pendingLoginTokensKey);
    } else {
      access = await readAccessToken();
      refresh = await readRefreshToken();
    }

    // 2. Yangi userId ostiga saqlash
    if (access != null) {
      await _storage.write(
        key: _tokenKey(userId),
        value: jsonEncode({'access': access, 'refresh': refresh}),
      );
    }

    // 3. Registry'ni yangilash
    final List<StoredAccountInfo> accounts = await listAccounts();
    final int index = accounts.indexWhere((a) => a.userId == userId);
    if (index != -1) {
      accounts[index] = info;
    } else {
      accounts.add(info);
    }
    await _storage.write(
      key: _accountsRegistryKey,
      value: jsonEncode(accounts.map((a) => a.toJson()).toList()),
    );

    // 4. Faol akkaunt qilib belgilash
    await _storage.write(key: _activeAccountIdKey, value: userId);

    // 5. Migratsiya tugadi — eski kalitlarni tozalash (agar bor bo'lsa)
    await _storage.delete(key: _oldAccessKey);
    await _storage.delete(key: _oldRefreshKey);
  }

  @override
  Future<void> setActiveAccount(String userId) async {
    final List<StoredAccountInfo> accounts = await listAccounts();
    if (!accounts.any((a) => a.userId == userId)) {
      throw StateError('Account $userId not found in registry');
    }
    await _storage.write(key: _activeAccountIdKey, value: userId);
  }

  @override
  Future<void> removeAccount(String userId) async {
    await _storage.delete(key: _tokenKey(userId));

    final List<StoredAccountInfo> accounts = await listAccounts();
    accounts.removeWhere((a) => a.userId == userId);
    await _storage.write(
      key: _accountsRegistryKey,
      value: jsonEncode(accounts.map((a) => a.toJson()).toList()),
    );

    final String? activeId = await _storage.read(key: _activeAccountIdKey);
    if (activeId == userId) {
      await _storage.delete(key: _activeAccountIdKey);
    }
  }

  @override
  Future<String?> readRefreshTokenFor(String userId) async {
    final String? json = await _storage.read(key: _tokenKey(userId));
    if (json == null) return null;
    try {
      return (jsonDecode(json) as Map<String, dynamic>)['refresh'] as String?;
    } catch (_) {
      return null;
    }
  }
}

final Provider<TokenStorage> tokenStorageProvider = Provider<TokenStorage>(
  (ref) => SecureTokenStorage(),
);
