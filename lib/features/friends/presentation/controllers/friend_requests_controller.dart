import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/state/load_state.dart';
import '../../data/repositories/friends_repository_impl.dart';
import '../../domain/entities/friend_request.dart';
import 'friends_controller.dart';

/// Kelayotgan do'stlik so'rovlari — `GET /friends/requests/incoming`.
/// Ekran ochilganda [load] chaqirilishi kerak (avtomatik yuklanmaydi);
/// muvaffaqiyatsiz bo'lsa `state.hasError` `true` bo'ladi.
class FriendRequestsController extends Notifier<LoadState<List<FriendRequest>>> {
  @override
  LoadState<List<FriendRequest>> build() => const LoadState();

  Future<void> load() async {
    state = const LoadState();
    try {
      state = LoadState(data: await ref.read(getIncomingFriendRequestsUseCaseProvider).call());
    } catch (_) {
      state = const LoadState(hasError: true);
    }
  }

  Future<void> accept(String requestId) async {
    await ref.read(acceptFriendRequestUseCaseProvider).call(requestId);
    state = LoadState(data: state.data?.where((r) => r.id != requestId).toList());
    // Yangi do'st ro'yxatga qo'shildi — Friends ekrani qayta ochilganda
    // eskirgan ro'yxatni ko'rsatmasligi uchun uni ham yangilaymiz.
    await ref.read(friendsControllerProvider.notifier).load();
  }

  Future<void> decline(String requestId) async {
    await ref.read(declineFriendRequestUseCaseProvider).call(requestId);
    state = LoadState(data: state.data?.where((r) => r.id != requestId).toList());
  }
}

final NotifierProvider<FriendRequestsController, LoadState<List<FriendRequest>>>
    friendRequestsControllerProvider =
    NotifierProvider<FriendRequestsController, LoadState<List<FriendRequest>>>(
        FriendRequestsController.new);
