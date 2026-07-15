import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/auth_tokens_model.dart';
import '../models/user_model.dart';

/// `/auth/*` endpoint'lariga xom (Dio) so'rovlar. Xatolikni ushlamaydi —
/// [DioException] to'g'ridan-to'g'ri tashqariga chiqadi, uni [Failure]ga
/// aylantirish [AuthRepositoryImpl]ning ishi.
class AuthRemoteDataSource {
  const AuthRemoteDataSource(this._dio);

  final Dio _dio;

  Future<AuthTokensModel> register({
    required String email,
    required String username,
    required String password,
  }) async {
    final Response<dynamic> response = await _dio.post(
      ApiEndpoints.register,
      data: {'email': email, 'username': username, 'password': password},
    );
    return AuthTokensModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AuthTokensModel> login({
    required String email,
    required String password,
  }) async {
    final Response<dynamic> response = await _dio.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );
    return AuthTokensModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> getCurrentUser() async {
    final Response<dynamic> response = await _dio.get(ApiEndpoints.me);
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> logout(String refreshToken) async {
    await _dio.post<void>(
      ApiEndpoints.logout,
      data: {'refresh_token': refreshToken},
    );
  }
}

final Provider<AuthRemoteDataSource> authRemoteDataSourceProvider =
    Provider<AuthRemoteDataSource>(
  (ref) => AuthRemoteDataSource(ref.watch(dioProvider)),
);
