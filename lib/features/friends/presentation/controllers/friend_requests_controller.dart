import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/friends_repository_impl.dart';
import '../../domain/entities/friend_request.dart';
import 'friends_controller.dart';

/// Kelayotgan do'stlik so'rovlari — `GET /friends/requests/incoming`.
/// Ekran ochilganda [load] chaqirilishi kerak (avtomatik yuklanmaydi);
/// muvaffaqiyatsiz bo'lsa `state` eskicha (yoki `null`) qoladi.
class FriendRequestsController extends Notifier<List<FriendRequest>?> {
  @override
  List<FriendRequest>? build() => null;

  Future<void> load() async {
    try {
      state = await ref.read(getIncomingFriendRequestsUseCaseProvider).call();
    } catch (_) {
      // e'tiborsiz qoldiriladi — chaqiruvchi ekran `null`ni "yuklanmoqda
      // yoki xato" sifatida ko'rsatadi.
    }
  }

  Future<void> accept(String requestId) async {
    await ref.read(acceptFriendRequestUseCaseProvider).call(requestId);
    state = state?.where((r) => r.id != requestId).toList();
    // Yangi do'st ro'yxatga qo'shildi — Friends ekrani qayta ochilganda
    // eskirgan ro'yxatni ko'rsatmasligi uchun uni ham yangilaymiz.
    await ref.read(friendsControllerProvider.notifier).load();
  }

  Future<void> decline(String requestId) async {
    await ref.read(declineFriendRequestUseCaseProvider).call(requestId);
    state = state?.where((r) => r.id != requestId).toList();
  }
}

final NotifierProvider<FriendRequestsController, List<FriendRequest>?> friendRequestsControllerProvider =
    NotifierProvider<FriendRequestsController, List<FriendRequest>?>(FriendRequestsController.new);
