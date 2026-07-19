import '../entities/discovered_user.dart';
import '../repositories/friends_repository.dart';

class SearchUsersUseCase {
  const SearchUsersUseCase(this._repository);

  final FriendsRepository _repository;

  Future<List<DiscoveredUser>> call(String query) => _repository.searchUsers(query);
}
