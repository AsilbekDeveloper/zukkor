import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/friends_repository_impl.dart';

/// Do'stlik so'rovi yuborish — `POST /friends/requests`. Holati — shunchaki
/// `isLoading` bayrog'i; xatolikni chaqiruvchi ekranning o'zi `try/catch`
/// bilan ushlaydi (Quiz'dagi kabi).
class SendFriendRequestController extends Notifier<bool> {
  @override
  bool build() => false;

  Future<void> sendRequest(String userId) async {
    state = true;
    try {
      await ref.read(sendFriendRequestUseCaseProvider).call(userId);
    } finally {
      state = false;
    }
  }
}

final NotifierProvider<SendFriendRequestController, bool> sendFriendRequestControllerProvider =
    NotifierProvider<SendFriendRequestController, bool>(SendFriendRequestController.new);
