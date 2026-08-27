import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/failure_mapper.dart';
import '../../../../core/storage/token_storage.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/change_password_use_case.dart';
import '../../domain/usecases/check_username_available_use_case.dart';
import '../../domain/usecases/delete_account_use_case.dart';
import '../../domain/usecases/forgot_password_use_case.dart';
import '../../domain/usecases/get_current_user_use_case.dart';
import '../../domain/usecases/login_use_case.dart';
import '../../domain/usecases/logout_use_case.dart';
import '../../domain/usecases/register_push_token_use_case.dart';
import '../../domain/usecases/register_use_case.dart';
import '../../domain/usecases/reset_password_use_case.dart';
import '../../domain/usecases/sign_in_with_google_use_case.dart';
import '../../domain/usecases/update_profile_use_case.dart';
import '../../domain/usecases/upload_avatar_image_use_case.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/google_auth_data_source.dart';
import '../models/auth_tokens_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required GoogleAuthDataSource googleAuthDataSource,
    required TokenStorage tokenStorage,
  })  : _remoteDataSource = remoteDataSource,
        _googleAuthDataSource = googleAuthDataSource,
        _tokenStorage = tokenStorage;

  final AuthRemoteDataSource _remoteDataSource;
  final GoogleAuthDataSource _googleAuthDataSource;
  final TokenStorage _tokenStorage;

  @override
  Future<void> register({
    required String email,
    required String password,
  }) async {
    try {
      final AuthTokensModel tokens = await _remoteDataSource.register(
        email: email,
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
  Future<User?> signInWithGoogle() async {
    final String? idToken;
    try {
      idToken = await _googleAuthDataSource.signIn();
    } on GoogleSignInException {
      throw UnknownFailure();
    }
    if (idToken == null) return null;

    try {
      final AuthTokensModel tokens = await _remoteDataSource.signInWithGoogle(idToken);
      await _saveTokens(tokens);
      return (await _remoteDataSource.getCurrentUser()).toEntity();
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
  Future<User> updateProfile({
    required String username,
    required String firstName,
    required String lastName,
    String? avatarColor,
    required String direction,
    List<String>? interests,
    String? studyPlace,
    String? quizLiking,
  }) async {
    try {
      return (await _remoteDataSource.updateProfile(
        username: username,
        firstName: firstName,
        lastName: lastName,
        avatarColor: avatarColor,
        direction: direction,
        interests: interests,
        studyPlace: studyPlace,
        quizLiking: quizLiking,
      ))
          .toEntity();
    } on DioException catch (e) {
      throw FailureMapper.fromDio(e);
    }
  }

  @override
  Future<User> uploadAvatarImage(String filePath) async {
    try {
      return (await _remoteDataSource.uploadAvatarImage(filePath)).toEntity();
    } on DioException catch (e) {
      throw FailureMapper.fromDio(e);
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } on DioException catch (e) {
      throw FailureMapper.fromDio(e);
    }
  }

  @override
  Future<void> deleteAccount(String? password) async {
    try {
      await _remoteDataSource.deleteAccount(password);
    } on DioException catch (e) {
      throw FailureMapper.fromDio(e);
    }
    // Faqat muvaffaqiyatli o'chirilgandan keyin tozalanadi — logout'dagi
    // "baribir tozalash"dan farqli, chunki bu yerda so'rov muvaffaqiyatsiz
    // bo'lsa yuqoridagi throw ishlaydi va bu qatorga yetib kelinmaydi.
    await _tokenStorage.clear();
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    try {
      return await _remoteDataSource.isUsernameAvailable(username);
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

  @override
  Future<void> registerPushToken(String token) async {
    try {
      await _remoteDataSource.registerPushToken(token);
    } on DioException {
      // Best-effort — bildirishnoma ishlamasligi kirish/ilovadan
      // foydalanishni to'sib qo'ymasligi kerak.
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _remoteDataSource.forgotPassword(email);
    } on DioException catch (e) {
      throw FailureMapper.fromDio(e);
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      await _remoteDataSource.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      );
    } on DioException catch (e) {
      throw FailureMapper.fromDio(e);
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
    googleAuthDataSource: ref.watch(googleAuthDataSourceProvider),
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

final Provider<SignInWithGoogleUseCase> signInWithGoogleUseCaseProvider = Provider<SignInWithGoogleUseCase>(
  (ref) => SignInWithGoogleUseCase(ref.watch(authRepositoryProvider)),
);

final Provider<GetCurrentUserUseCase> getCurrentUserUseCaseProvider =
    Provider<GetCurrentUserUseCase>(
  (ref) => GetCurrentUserUseCase(ref.watch(authRepositoryProvider)),
);

final Provider<LogoutUseCase> logoutUseCaseProvider = Provider<LogoutUseCase>(
  (ref) => LogoutUseCase(ref.watch(authRepositoryProvider)),
);

final Provider<UpdateProfileUseCase> updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>(
  (ref) => UpdateProfileUseCase(ref.watch(authRepositoryProvider)),
);

final Provider<CheckUsernameAvailableUseCase> checkUsernameAvailableUseCaseProvider =
    Provider<CheckUsernameAvailableUseCase>(
  (ref) => CheckUsernameAvailableUseCase(ref.watch(authRepositoryProvider)),
);

final Provider<UploadAvatarImageUseCase> uploadAvatarImageUseCaseProvider =
    Provider<UploadAvatarImageUseCase>(
  (ref) => UploadAvatarImageUseCase(ref.watch(authRepositoryProvider)),
);

final Provider<ChangePasswordUseCase> changePasswordUseCaseProvider = Provider<ChangePasswordUseCase>(
  (ref) => ChangePasswordUseCase(ref.watch(authRepositoryProvider)),
);

final Provider<DeleteAccountUseCase> deleteAccountUseCaseProvider = Provider<DeleteAccountUseCase>(
  (ref) => DeleteAccountUseCase(ref.watch(authRepositoryProvider)),
);

final Provider<ForgotPasswordUseCase> forgotPasswordUseCaseProvider = Provider<ForgotPasswordUseCase>(
  (ref) => ForgotPasswordUseCase(ref.watch(authRepositoryProvider)),
);

final Provider<ResetPasswordUseCase> resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>(
  (ref) => ResetPasswordUseCase(ref.watch(authRepositoryProvider)),
);

final Provider<RegisterPushTokenUseCase> registerPushTokenUseCaseProvider =
    Provider<RegisterPushTokenUseCase>(
  (ref) => RegisterPushTokenUseCase(ref.watch(authRepositoryProvider)),
);
