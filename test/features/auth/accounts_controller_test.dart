import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zukkor/core/storage/token_storage.dart';
import 'package:zukkor/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:zukkor/features/auth/domain/repositories/auth_repository.dart';
import 'package:zukkor/features/auth/presentation/controllers/accounts_controller.dart';

class _FakeAuthRepository extends Fake implements AuthRepository {
  List<StoredAccountInfo> accounts = [];
  String? activeId;
  String? switchedTo;
  String? removedId;

  @override
  Future<List<StoredAccountInfo>> listAccounts() async => accounts;

  @override
  Future<String?> activeAccountId() async => activeId;

  @override
  Future<void> switchAccount(String userId) async {
    switchedTo = userId;
    activeId = userId;
  }

  @override
  Future<void> removeAccount(String userId) async {
    removedId = userId;
    accounts.removeWhere((a) => a.userId == userId);
    if (activeId == userId) activeId = null;
  }
}

void main() {
  late _FakeAuthRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = _FakeAuthRepository();
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(repository),
      ],
    );
  });

  tearDown(() => container.dispose());

  const info1 = StoredAccountInfo(userId: 'u1', email: 'u1@t.co');
  const info2 = StoredAccountInfo(userId: 'u2', email: 'u2@t.co');

  test('build: returns mapped AccountEntry list', () async {
    repository.accounts = [info1, info2];
    repository.activeId = 'u1';

    final result = await container.read(accountsControllerProvider.future);

    expect(result, hasLength(2));
    expect(result[0].info.userId, 'u1');
    expect(result[0].isActive, isTrue);
    expect(result[1].info.userId, 'u2');
    expect(result[1].isActive, isFalse);
  });

  test('switchTo: updates active account and returns true', () async {
    repository.accounts = [info1, info2];
    repository.activeId = 'u1';

    final success = await container.read(accountsControllerProvider.notifier).switchTo('u2');

    expect(success, isTrue);
    expect(repository.switchedTo, 'u2');
    expect(repository.activeId, 'u2');
  });

  test('remove: inactive account returns true and updates list', () async {
    repository.accounts = [info1, info2];
    repository.activeId = 'u2';

    final result = await container.read(accountsControllerProvider.notifier).remove('u1');

    expect(result, isTrue);
    expect(repository.removedId, 'u1');
    expect(repository.accounts, [info2]);
    expect(repository.activeId, 'u2');
  });

  test('remove: active account with others remaining switches and returns true', () async {
    repository.accounts = [info1, info2];
    repository.activeId = 'u1';

    final result = await container.read(accountsControllerProvider.notifier).remove('u1');

    expect(result, isTrue);
    expect(repository.removedId, 'u1');
    expect(repository.activeId, 'u2'); // switched to remaining
  });

  test('remove: active account with none remaining returns null', () async {
    repository.accounts = [info1];
    repository.activeId = 'u1';

    final result = await container.read(accountsControllerProvider.notifier).remove('u1');

    expect(result, isNull);
    expect(repository.activeId, isNull);
    expect(repository.accounts, isEmpty);
  });
}
