import '../repositories/friends_repository.dart';

class DeclineFriendRequestUseCase {
  const DeclineFriendRequestUseCase(this._repository);

  final FriendsRepository _repository;

  Future<void> call(String requestId) => _repository.declineFriendRequest(requestId);
}
