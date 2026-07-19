import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/friends_repository_impl.dart';
import '../../domain/entities/friend.dart';

/// Do'stlar ro'yxati — `GET /friends`. Ekran ochilganda [load] chaqirilishi
/// kerak (avtomatik yuklanmaydi); muvaffaqiyatsiz bo'lsa `state` eskicha
/// (yoki `null`) qoladi.
class FriendsController extends Notifier<List<Friend>?> {
  @override
  List<Friend>? build() => null;

  Future<void> load() async {
    try {
      state = await ref.read(getFriendsUseCaseProvider).call();
    } catch (_) {
      // e'tiborsiz qoldiriladi — chaqiruvchi ekran `null`ni "yuklanmoqda
      // yoki xato" sifatida ko'rsatadi.
    }
  }
}

final NotifierProvider<FriendsController, List<Friend>?> friendsControllerProvider =
    NotifierProvider<FriendsController, List<Friend>?>(FriendsController.new);
