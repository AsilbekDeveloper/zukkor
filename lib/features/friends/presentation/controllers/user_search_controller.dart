import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/friends_repository_impl.dart';
import '../../domain/entities/discovered_user.dart';

/// Foydalanuvchi qidiruvi natijalari — `GET /friends/search`. Ekranning
/// o'zi [search] chaqirishi kerak (masalan qidiruv maydoni o'zgarganda);
/// muvaffaqiyatsiz bo'lsa `state` eskicha (yoki `null`) qoladi.
class UserSearchController extends Notifier<List<DiscoveredUser>?> {
  @override
  List<DiscoveredUser>? build() => null;

  /// Har [search] chaqiruvi o'zining raqamini oladi — javob kelganda shu
  /// raqam hali "so'nggisi"ligi tekshiriladi. Buning kerakligi: tarmoq
  /// kechikishi bir xilda bo'lmaydi (masalan foydalanuvchi tez-tez yozsa),
  /// shuning uchun ESKIROQ so'rovning javobi YANGI so'rovnikidan KEYIN
  /// kelib qolishi mumkin — bu tekshiruv bo'lmasa, eskirgan natija ekranda
  /// yangisining ustidan yozib qo'yardi.
  int _requestId = 0;

  Future<void> search(String query) async {
    final int requestId = ++_requestId;
    try {
      final List<DiscoveredUser> results = await ref.read(searchUsersUseCaseProvider).call(query);
      if (requestId != _requestId) return; // eskirgan — e'tiborsiz qoldiriladi
      state = results;
    } catch (_) {
      // e'tiborsiz qoldiriladi — chaqiruvchi ekran `null`ni "yuklanmoqda
      // yoki xato" sifatida ko'rsatadi.
    }
  }

  void clear() {
    // In-flight so'rovlarning javobini ham eskirtiradi — ular kelib
    // qolsa, tozalangan holatning ustidan yozib qo'ymasligi uchun.
    _requestId++;
    state = null;
  }
}

final NotifierProvider<UserSearchController, List<DiscoveredUser>?> userSearchControllerProvider =
    NotifierProvider<UserSearchController, List<DiscoveredUser>?>(UserSearchController.new);
