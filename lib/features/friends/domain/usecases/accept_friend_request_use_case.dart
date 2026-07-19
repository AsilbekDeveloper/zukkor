import '../repositories/friends_repository.dart';

class AcceptFriendRequestUseCase {
  const AcceptFriendRequestUseCase(this._repository);

  final FriendsRepository _repository;

  Future<void> call(String requestId) => _repository.acceptFriendRequest(requestId);
}
