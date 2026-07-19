import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/discovered_user_model.dart';
import '../models/friend_model.dart';
import '../models/friend_request_model.dart';

/// `/friends*` endpoint'lariga xom (Dio) so'rovlar. Xatolikni ushlamaydi
/// — [DioException] to'g'ridan-to'g'ri tashqariga chiqadi, uni [Failure]ga
/// aylantirish [FriendsRepositoryImpl]ning ishi.
class FriendsRemoteDataSource {
  const FriendsRemoteDataSource(this._dio);

  final Dio _dio;

  Future<List<FriendModel>> getFriends() async {
    final Response<dynamic> response = await _dio.get(ApiEndpoints.friends);
    final Map<String, dynamic> data = response.data as Map<String, dynamic>;
    return (data['friends'] as List<dynamic>)
        .map((json) => FriendModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<DiscoveredUserModel>> searchUsers(String query) async {
    final Response<dynamic> response = await _dio.get(ApiEndpoints.friendsSearch(query));
    final Map<String, dynamic> data = response.data as Map<String, dynamic>;
    return (data['results'] as List<dynamic>)
        .map((json) => DiscoveredUserModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> sendFriendRequest(String userId) =>
      _dio.post<void>(ApiEndpoints.friendRequests, data: {'to_user_id': userId});

  Future<List<FriendRequestModel>> getIncomingRequests() async {
    final Response<dynamic> response = await _dio.get(ApiEndpoints.incomingFriendRequests);
    final Map<String, dynamic> data = response.data as Map<String, dynamic>;
    return (data['requests'] as List<dynamic>)
        .map((json) => FriendRequestModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> acceptFriendRequest(String requestId) =>
      _dio.post<void>(ApiEndpoints.acceptFriendRequest(requestId));

  Future<void> declineFriendRequest(String requestId) =>
      _dio.post<void>(ApiEndpoints.declineFriendRequest(requestId));
}

final Provider<FriendsRemoteDataSource> friendsRemoteDataSourceProvider = Provider<FriendsRemoteDataSource>(
  (ref) => FriendsRemoteDataSource(ref.watch(dioProvider)),
);
