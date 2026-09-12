import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zukkor/core/storage/token_storage.dart';

class _FakeFlutterSecureStorage extends Fake implements FlutterSecureStorage {
  final Map<String, String> _data = {};

  @override
  Future<void> write({
    required String key,
    required String? value,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      _data.remove(key);
    } else {
      _data[key] = value;
    }
  }

  @override
  Future<String?> read({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _data[key];
  }

  @override
  Future<void> delete({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _data.remove(key);
  }
}

void main() {
  late _FakeFlutterSecureStorage fakeStorage;
  late SecureTokenStorage tokenStorage;

  setUp(() {
    fakeStorage = _FakeFlutterSecureStorage();
    tokenStorage = SecureTokenStorage(fakeStorage);
  });

  test(
    'readAccessToken/readRefreshToken return null when nothing is stored',
    () async {
      expect(await tokenStorage.readAccessToken(), isNull);
      expect(await tokenStorage.readRefreshToken(), isNull);
    },
  );

  test('saveTokens saves both access and refresh', () async {
    await tokenStorage.saveTokens(access: 'acc', refresh: 'ref');

    expect(await tokenStorage.readAccessToken(), 'acc');
    expect(await tokenStorage.readRefreshToken(), 'ref');
    expect(await fakeStorage.read(key: 'zukkor.access_token'), 'acc');
    expect(await fakeStorage.read(key: 'zukkor.refresh_token'), 'ref');
  });

  test(
    'saveTokens with no refresh leaves an existing refresh token untouched',
    () async {
      await tokenStorage.saveTokens(access: 'acc1', refresh: 'ref1');
      await tokenStorage.saveTokens(access: 'acc2');

      expect(await tokenStorage.readAccessToken(), 'acc2');
      expect(await tokenStorage.readRefreshToken(), 'ref1');
    },
  );

  test('clear() removes both tokens', () async {
    await tokenStorage.saveTokens(access: 'acc', refresh: 'ref');

    await tokenStorage.clear();

    expect(await tokenStorage.readAccessToken(), isNull);
    expect(await tokenStorage.readRefreshToken(), isNull);
  });
}
