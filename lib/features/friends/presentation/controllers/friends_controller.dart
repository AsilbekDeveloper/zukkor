import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/state/load_state.dart';
import '../../data/repositories/friends_repository_impl.dart';
import '../../domain/entities/friend.dart';

/// Do'stlar ro'yxati — `GET /friends`. Ekran ochilganda [load] chaqirilishi
/// kerak (avtomatik yuklanmaydi); muvaffaqiyatsiz bo'lsa `state.hasError`
/// `true` bo'ladi — chaqiruvchi ekran qayta urinish tugmasini ko'rsatadi.
class FriendsController extends Notifier<LoadState<List<Friend>>> {
  @override
  LoadState<List<Friend>> build() => const LoadState();

  Future<void> load() async {
    state = const LoadState();
    try {
      state = LoadState(data: await ref.read(getFriendsUseCaseProvider).call());
    } catch (_) {
      state = const LoadState(hasError: true);
    }
  }
}

final NotifierProvider<FriendsController, LoadState<List<Friend>>> friendsControllerProvider =
    NotifierProvider<FriendsController, LoadState<List<Friend>>>(FriendsController.new);
