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
    required String password,
  }) async {
    final Response<dynamic> response = await _dio.post(
      ApiEndpoints.register,
      data: {'email': email, 'password': password},
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

  Future<UserModel> updateProfile({
    required String username,
    required String firstName,
    required String lastName,
    required String avatarColor,
    required String direction,
    List<String>? interests,
    String? studyPlace,
    String? quizLiking,
  }) async {
    final Response<dynamic> response = await _dio.patch(
      ApiEndpoints.profileSetup,
      data: {
        'username': username,
        'first_name': firstName,
        'last_name': lastName,
        'avatar_color': avatarColor,
        'direction': direction,
        'interests': ?interests,
        'study_place': ?studyPlace,
        'quiz_liking': ?quizLiking,
      },
    );
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<UserModel> uploadAvatarImage(String filePath) async {
    final FormData formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(filePath),
    });
    final Response<dynamic> response = await _dio.post(
      ApiEndpoints.avatarUpload,
      data: formData,
    );
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _dio.post<void>(
      ApiEndpoints.changePassword,
      data: {'current_password': currentPassword, 'new_password': newPassword},
    );
  }

  Future<void> deleteAccount(String password) async {
    await _dio.delete<void>(
      ApiEndpoints.deleteAccount,
      data: {'password': password},
    );
  }

  Future<bool> isUsernameAvailable(String username) async {
    final Response<dynamic> response = await _dio.get(
      ApiEndpoints.usernameAvailable,
      queryParameters: {'username': username},
    );
    return (response.data as Map<String, dynamic>)['available'] as bool;
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
