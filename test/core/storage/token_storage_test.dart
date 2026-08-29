import 'dart:convert';

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

  @override
  Future<bool> containsKey({
    required String key,
    IOSOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    MacOsOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return _data.containsKey(key);
  }
}

void main() {
  late _FakeFlutterSecureStorage fakeStorage;
  late SecureTokenStorage tokenStorage;

  setUp(() {
    fakeStorage = _FakeFlutterSecureStorage();
    tokenStorage = SecureTokenStorage(fakeStorage);
  });

  test('readAccessToken returns null when nothing is stored', () async {
    expect(await tokenStorage.readAccessToken(), isNull);
  });

  test('Legacy session migration: saves and reads from old keys', () async {
    // Stage (a) requirement: existing logic shouldn't break.
    await tokenStorage.saveTokens(access: 'acc', refresh: 'ref');

    expect(await tokenStorage.readAccessToken(), 'acc');
    expect(await tokenStorage.readRefreshToken(), 'ref');
    expect(await tokenStorage.activeAccountId(), isNull);

    expect(await fakeStorage.read(key: 'zukkor.access_token'), 'acc');
    expect(await fakeStorage.read(key: 'zukkor.refresh_token'), 'ref');
  });

  test('registerActiveSession migrates from legacy and sets active', () async {
    await tokenStorage.saveTokens(access: 'acc', refresh: 'ref');

    const info = StoredAccountInfo(userId: 'u1', email: 'u1@test.com');
    await tokenStorage.registerActiveSession(userId: 'u1', info: info);

    expect(await tokenStorage.activeAccountId(), 'u1');
    expect(await tokenStorage.readAccessToken(), 'acc');
    expect(await tokenStorage.readRefreshToken(), 'ref');

    final accounts = await tokenStorage.listAccounts();
    expect(accounts, hasLength(1));
    expect(accounts[0].userId, 'u1');

    // Check old keys are deleted after migration
    expect(await fakeStorage.containsKey(key: 'zukkor.access_token'), isFalse);
    expect(await fakeStorage.containsKey(key: 'zukkor.refresh_token'), isFalse);

    // Check new structure
    final tokensJson = await fakeStorage.read(key: 'zukkor.tokens.u1');
    expect(tokensJson, isNotNull);
    final tokens = jsonDecode(tokensJson!) as Map<String, dynamic>;
    expect(tokens['access'], 'acc');
    expect(tokens['refresh'], 'ref');
  });

  test('Second account addition (via pending tokens) keeps both and allows switching', () async {
    const info1 = StoredAccountInfo(userId: 'u1', email: 'u1@test.com');
    await tokenStorage.saveTokens(access: 'acc1', refresh: 'ref1');
    await tokenStorage.registerActiveSession(userId: 'u1', info: info1);

    // Real "add account" flow: u1 stays active/parked the whole time - the
    // new login goes through savePendingLoginTokens, NOT plain saveTokens,
    // so it never touches u1's slot.
    const info2 = StoredAccountInfo(userId: 'u2', email: 'u2@test.com');
    await tokenStorage.savePendingLoginTokens(access: 'acc2', refresh: 'ref2');
    await tokenStorage.registerActiveSession(userId: 'u2', info: info2);

    expect(await tokenStorage.activeAccountId(), 'u2');
    expect(await tokenStorage.readAccessToken(), 'acc2');

    final accounts = await tokenStorage.listAccounts();
    expect(accounts, hasLength(2));

    await tokenStorage.setActiveAccount('u1');
    expect(await tokenStorage.activeAccountId(), 'u1');
    // The whole point: u1's own tokens must survive u2 being added while u1
    // was active - not silently overwritten by u2's login.
    expect(await tokenStorage.readAccessToken(), 'acc1');
    expect(await tokenStorage.readRefreshToken(), 'ref1');
  });

  test('savePendingLoginTokens is consumed once and does not touch the active account', () async {
    const info1 = StoredAccountInfo(userId: 'u1', email: 'u1@test.com');
    await tokenStorage.saveTokens(access: 'acc1', refresh: 'ref1');
    await tokenStorage.registerActiveSession(userId: 'u1', info: info1);

    await tokenStorage.savePendingLoginTokens(access: 'pending-acc', refresh: 'pending-ref');

    // Pending tokens sit aside - u1 (still active) is untouched.
    expect(await tokenStorage.activeAccountId(), 'u1');
    expect(await tokenStorage.readAccessToken(), 'acc1');
    expect(await fakeStorage.containsKey(key: 'zukkor.pending_login_tokens'), isTrue);

    await tokenStorage.registerActiveSession(
      userId: 'u2',
      info: const StoredAccountInfo(userId: 'u2', email: 'u2@test.com'),
    );

    expect(await tokenStorage.activeAccountId(), 'u2');
    expect(await tokenStorage.readAccessToken(), 'pending-acc');
    // Pending key is consumed - a second registerActiveSession call
    // shouldn't be able to reuse it.
    expect(await fakeStorage.containsKey(key: 'zukkor.pending_login_tokens'), isFalse);
  });

  test('setActiveAccount throws StateError for unknown id', () async {
    expect(() => tokenStorage.setActiveAccount('none'), throwsStateError);
  });

  test('removeAccount (inactive) removes from registry but active remains', () async {
    await tokenStorage.saveTokens(access: 'acc1', refresh: 'ref1');
    await tokenStorage.registerActiveSession(
      userId: 'u1',
      info: const StoredAccountInfo(userId: 'u1', email: 'u1@t.co'),
    );

    // Real "add account" flow - u1 stays active/parked while u2 is added.
    await tokenStorage.savePendingLoginTokens(access: 'acc2', refresh: 'ref2');
    await tokenStorage.registerActiveSession(
      userId: 'u2',
      info: const StoredAccountInfo(userId: 'u2', email: 'u2@t.co'),
    );

    await tokenStorage.removeAccount('u1');

    final accounts = await tokenStorage.listAccounts();
    expect(accounts, hasLength(1));
    expect(accounts[0].userId, 'u2');
    expect(await tokenStorage.activeAccountId(), 'u2');
    expect(await fakeStorage.containsKey(key: 'zukkor.tokens.u1'), isFalse);
  });

  test('removeAccount (active) unsets activeAccountId', () async {
    await tokenStorage.saveTokens(access: 'acc1', refresh: 'ref1');
    await tokenStorage.registerActiveSession(
      userId: 'u1',
      info: const StoredAccountInfo(userId: 'u1', email: 'u1@t.co'),
    );

    await tokenStorage.removeAccount('u1');

    expect(await tokenStorage.activeAccountId(), isNull);
    expect(await tokenStorage.listAccounts(), isEmpty);
  });

  test('clear() with active account deletes tokens and activeAccountId but keeps registry', () async {
    const info = StoredAccountInfo(userId: 'u1', email: 'u1@test.com');
    await tokenStorage.saveTokens(access: 'acc', refresh: 'ref');
    await tokenStorage.registerActiveSession(userId: 'u1', info: info);

    await tokenStorage.clear();

    expect(await tokenStorage.activeAccountId(), isNull);
    expect(await tokenStorage.readAccessToken(), isNull);

    final accounts = await tokenStorage.listAccounts();
    expect(accounts, hasLength(1));
    expect(accounts[0].userId, 'u1');
    
    // Tokens for u1 should be gone
    expect(await fakeStorage.containsKey(key: 'zukkor.tokens.u1'), isFalse);
  });
}
