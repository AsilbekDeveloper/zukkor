import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/token_storage.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../user_session.dart';

class AccountEntry {
  const AccountEntry({required this.info, required this.isActive});
  final StoredAccountInfo info;
  final bool isActive;
}

class AccountsController extends AsyncNotifier<List<AccountEntry>> {
  @override
  Future<List<AccountEntry>> build() async {
    final AuthRepository repo = ref.watch(authRepositoryProvider);
    final List<StoredAccountInfo> accounts = await repo.listAccounts();
    final String? activeId = await repo.activeAccountId();
    return accounts.map((a) => AccountEntry(info: a, isActive: a.userId == activeId)).toList();
  }

  /// Muvaffaqiyatli bo'lsa true qaytaradi. Chaqiruvchi (ekran) shundan keyin
  /// Home'ga o'tishi kerak.
  Future<bool> switchTo(String userId) async {
    try {
      await ref.read(authRepositoryProvider).switchAccount(userId);
      resetUserScopedState(ref);
      ref.invalidateSelf();
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Muvaffaqiyatli bo'lgach:
  ///  - agar o'chirilgan akkaunt FAOL bo'lmasa: shunchaki ro'yxatni yangilaydi,
  ///    ekran o'zgarishsiz qoladi.
  ///  - agar FAOL akkaunt o'chirilsa VA boshqa akkaunt(lar) qolsa: birinchisiga
  ///    avtomatik o'tadi (`switchTo` bilan bir xil invalidation), ekran Home'da
  ///    qoladi.
  ///  - agar FAOL akkaunt o'chirilsa VA boshqa hech kim qolmasa: chaqiruvchiga
  ///    "endi hech kim faol emas" holatini bildirish uchun `null` qaytaradi —
  ///    chaqiruvchi Login ekraniga o'tishi kerak.
  Future<bool?> remove(String userId) async {
    final String? wasActiveId = await ref.read(authRepositoryProvider).activeAccountId();
    final bool wasActive = wasActiveId == userId;
    await ref.read(authRepositoryProvider).removeAccount(userId);

    if (!wasActive) {
      ref.invalidateSelf();
      return true; // ekranda qolinadi
    }

    final List<StoredAccountInfo> remaining = await ref.read(authRepositoryProvider).listAccounts();
    if (remaining.isEmpty) {
      return null; // Login'ga o'tish kerak
    }
    await switchTo(remaining.first.userId);
    return true; // Home'da qolinadi (yangi akkaunt bilan)
  }
}

final AsyncNotifierProvider<AccountsController, List<AccountEntry>> accountsControllerProvider =
    AsyncNotifierProvider<AccountsController, List<AccountEntry>>(AccountsController.new);
