import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/failure_mapper.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/get_current_user_use_case.dart';
import '../../domain/usecases/login_use_case.dart';
import '../../domain/usecases/logout_use_case.dart';
import '../../domain/usecases/register_use_case.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/auth_tokens_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required TokenStorage tokenStorage,
  })  : _remoteDataSource = remoteDataSource,
        _tokenStorage = tokenStorage;

  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  @override
  Future<void> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final AuthTokensModel tokens = await _remoteDataSource.register(
        email: email,
        username: username,
        password: password,
      );
      await _saveTokens(tokens);
    } on DioException catch (e) {
      throw FailureMapper.fromDio(e);
    }
  }

  @override
  Future<void> login({required String email, required String password}) async {
    try {
      final AuthTokensModel tokens = await _remoteDataSource.login(
        email: email,
        password: password,
      );
      await _saveTokens(tokens);
    } on DioException catch (e) {
      throw FailureMapper.fromDio(e);
    }
  }

  @override
  Future<User> getCurrentUser() async {
    try {
      return (await _remoteDataSource.getCurrentUser()).toEntity();
    } on DioException catch (e) {
      throw FailureMapper.fromDio(e);
    }
  }

  @override
  Future<void> logout() async {
    final String? refreshToken = await _tokenStorage.readRefreshToken();
    try {
      if (refreshToken != null) {
        await _remoteDataSource.logout(refreshToken);
      }
    } on DioException catch (e) {
      throw FailureMapper.fromDio(e);
    } finally {
      // Backend so'rovi muvaffaqiyatsiz bo'lsa ham lokal tokenlar
      // tozalanadi — foydalanuvchi qurilmada baribir chiqqan hisoblanadi.
      await _tokenStorage.clear();
    }
  }

  Future<void> _saveTokens(AuthTokensModel tokens) => _tokenStorage.saveTokens(
        access: tokens.accessToken,
        refresh: tokens.refreshToken,
      );
}

final Provider<AuthRepository> authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(
    remoteDataSource: ref.watch(authRemoteDataSourceProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
  ),
);

// Use case provider'lari shu yerda jamlangan — domain/usecases/*.dart
// Riverpod'dan butunlay bexabar (sof Dart) qolishi uchun.
final Provider<RegisterUseCase> registerUseCaseProvider = Provider<RegisterUseCase>(
  (ref) => RegisterUseCase(ref.watch(authRepositoryProvider)),
);

final Provider<LoginUseCase> loginUseCaseProvider = Provider<LoginUseCase>(
  (ref) => LoginUseCase(ref.watch(authRepositoryProvider)),
);

final Provider<GetCurrentUserUseCase> getCurrentUserUseCaseProvider =
    Provider<GetCurrentUserUseCase>(
  (ref) => GetCurrentUserUseCase(ref.watch(authRepositoryProvider)),
);

final Provider<LogoutUseCase> logoutUseCaseProvider = Provider<LogoutUseCase>(
  (ref) => LogoutUseCase(ref.watch(authRepositoryProvider)),
);
