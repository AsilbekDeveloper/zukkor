import '../entities/friend.dart';
import '../repositories/friends_repository.dart';

class GetFriendsUseCase {
  const GetFriendsUseCase(this._repository);

  final FriendsRepository _repository;

  Future<List<Friend>> call() => _repository.getFriends();
}
