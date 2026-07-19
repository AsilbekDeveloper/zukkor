import '../repositories/friends_repository.dart';

class SendFriendRequestUseCase {
  const SendFriendRequestUseCase(this._repository);

  final FriendsRepository _repository;

  Future<void> call(String userId) => _repository.sendFriendRequest(userId);
}
