import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/friends_repository_impl.dart';
import '../../domain/entities/discovered_user.dart';

/// Foydalanuvchi qidiruvi natijalari — `GET /friends/search`. Ekranning
/// o'zi [search] chaqirishi kerak (masalan qidiruv maydoni o'zgarganda);
/// muvaffaqiyatsiz bo'lsa `state` eskicha (yoki `null`) qoladi.
class UserSearchController extends Notifier<List<DiscoveredUser>?> {
  @override
  List<DiscoveredUser>? build() => null;

  Future<void> search(String query) async {
    try {
      state = await ref.read(searchUsersUseCaseProvider).call(query);
    } catch (_) {
      // e'tiborsiz qoldiriladi — chaqiruvchi ekran `null`ni "yuklanmoqda
      // yoki xato" sifatida ko'rsatadi.
    }
  }

  void clear() => state = null;
}

final NotifierProvider<UserSearchController, List<DiscoveredUser>?> userSearchControllerProvider =
    NotifierProvider<UserSearchController, List<DiscoveredUser>?>(UserSearchController.new);
