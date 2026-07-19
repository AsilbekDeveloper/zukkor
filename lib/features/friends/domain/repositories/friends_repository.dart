import '../entities/discovered_user.dart';
import '../entities/friend.dart';
import '../entities/friend_request.dart';

abstract interface class FriendsRepository {
  Future<List<Friend>> getFriends();

  Future<List<DiscoveredUser>> searchUsers(String query);

  Future<void> sendFriendRequest(String userId);

  Future<List<FriendRequest>> getIncomingRequests();

  Future<void> acceptFriendRequest(String requestId);

  Future<void> declineFriendRequest(String requestId);
}
