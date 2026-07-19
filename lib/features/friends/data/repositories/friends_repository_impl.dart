import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/failure_mapper.dart';
import '../../domain/entities/discovered_user.dart';
import '../../domain/entities/friend.dart';
import '../../domain/entities/friend_request.dart';
import '../../domain/repositories/friends_repository.dart';
import '../../domain/usecases/accept_friend_request_use_case.dart';
import '../../domain/usecases/decline_friend_request_use_case.dart';
import '../../domain/usecases/get_friends_use_case.dart';
import '../../domain/usecases/get_incoming_friend_requests_use_case.dart';
import '../../domain/usecases/search_users_use_case.dart';
import '../../domain/usecases/send_friend_request_use_case.dart';
import '../datasources/friends_remote_data_source.dart';

class FriendsRepositoryImpl implements FriendsRepository {
  const FriendsRepositoryImpl({required FriendsRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final FriendsRemoteDataSource _remoteDataSource;

  @override
  Future<List<Friend>> getFriends() async {
    try {
      final models = await _remoteDataSource.getFriends();
      return models.map((model) => model.toEntity()).toList();
    } on DioException catch (e) {
      throw FailureMapper.fromDio(e);
    }
  }

  @override
  Future<List<DiscoveredUser>> searchUsers(String query) async {
    try {
      final models = await _remoteDataSource.searchUsers(query);
      return models.map((model) => model.toEntity()).toList();
    } on DioException catch (e) {
      throw FailureMapper.fromDio(e);
    }
  }

  @override
  Future<void> sendFriendRequest(String userId) async {
    try {
      await _remoteDataSource.sendFriendRequest(userId);
    } on DioException catch (e) {
      throw FailureMapper.fromDio(e);
    }
  }

  @override
  Future<List<FriendRequest>> getIncomingRequests() async {
    try {
      final models = await _remoteDataSource.getIncomingRequests();
      return models.map((model) => model.toEntity()).toList();
    } on DioException catch (e) {
      throw FailureMapper.fromDio(e);
    }
  }

  @override
  Future<void> acceptFriendRequest(String requestId) async {
    try {
      await _remoteDataSource.acceptFriendRequest(requestId);
    } on DioException catch (e) {
      throw FailureMapper.fromDio(e);
    }
  }

  @override
  Future<void> declineFriendRequest(String requestId) async {
    try {
      await _remoteDataSource.declineFriendRequest(requestId);
    } on DioException catch (e) {
      throw FailureMapper.fromDio(e);
    }
  }
}

final Provider<FriendsRepository> friendsRepositoryProvider = Provider<FriendsRepository>(
  (ref) => FriendsRepositoryImpl(remoteDataSource: ref.watch(friendsRemoteDataSourceProvider)),
);

final Provider<GetFriendsUseCase> getFriendsUseCaseProvider = Provider<GetFriendsUseCase>(
  (ref) => GetFriendsUseCase(ref.watch(friendsRepositoryProvider)),
);

final Provider<SearchUsersUseCase> searchUsersUseCaseProvider = Provider<SearchUsersUseCase>(
  (ref) => SearchUsersUseCase(ref.watch(friendsRepositoryProvider)),
);

final Provider<SendFriendRequestUseCase> sendFriendRequestUseCaseProvider = Provider<SendFriendRequestUseCase>(
  (ref) => SendFriendRequestUseCase(ref.watch(friendsRepositoryProvider)),
);

final Provider<GetIncomingFriendRequestsUseCase> getIncomingFriendRequestsUseCaseProvider =
    Provider<GetIncomingFriendRequestsUseCase>(
  (ref) => GetIncomingFriendRequestsUseCase(ref.watch(friendsRepositoryProvider)),
);

final Provider<AcceptFriendRequestUseCase> acceptFriendRequestUseCaseProvider =
    Provider<AcceptFriendRequestUseCase>(
  (ref) => AcceptFriendRequestUseCase(ref.watch(friendsRepositoryProvider)),
);

final Provider<DeclineFriendRequestUseCase> declineFriendRequestUseCaseProvider =
    Provider<DeclineFriendRequestUseCase>(
  (ref) => DeclineFriendRequestUseCase(ref.watch(friendsRepositoryProvider)),
);
