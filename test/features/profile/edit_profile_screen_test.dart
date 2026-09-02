import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:zukkor/core/constants/app_strings.dart';
import 'package:zukkor/core/router/app_routes.dart';
import 'package:zukkor/core/storage/app_preferences.dart';
import 'package:zukkor/core/storage/token_storage.dart';
import 'package:zukkor/core/theme/app_theme.dart';
import 'package:zukkor/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:zukkor/features/auth/domain/entities/user.dart';
import 'package:zukkor/features/auth/domain/repositories/auth_repository.dart';
import 'package:zukkor/features/home/presentation/screens/home_screen.dart';
import 'package:zukkor/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:zukkor/i18n/strings.g.dart';

/// Backendga murojaat qilmaydigan soxta auth repository — Edit Profile
/// haqiqiy foydalanuvchini yuklaydi va saqlaydi, haqiqiy tarmoqqa bog'liq
/// bo'lmasligi kerak.
class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.usernameAvailable = true, this.hasUploadedAvatar = false});

  final bool usernameAvailable;

  /// When true, the seeded user already has an uploaded avatar image
  /// (not a color) — for the regression test below: saving other
  /// profile fields must not wipe it out by resending `avatar_color`.
  final bool hasUploadedAvatar;

  /// The `avatarColor` argument [updateProfile] was last called with —
  /// `notCalled` marks "never called" so a test can tell that apart
  /// from an actual `null` argument.
  static const String notCalled = '<not called>';
  String? lastUpdateProfileAvatarColor = notCalled;

  @override
  Future<void> register({required String email, required String password}) async {}

  @override
  Future<void> login({required String email, required String password}) async {}

  @override
  Future<User?> signInWithGoogle() => throw UnimplementedError();

  @override
  Future<User> getCurrentUser() async => User(
        id: '1',
        email: 'aziz@example.com',
        username: 'aziz_karimov',
        firstName: 'Aziz',
        lastName: 'Karimov',
        avatarColor: hasUploadedAvatar ? null : 'a-coral',
        avatarImagePath: hasUploadedAvatar ? '/uploads/avatars/aziz.jpg' : null,
        direction: 'casual',
        isActive: true,
        createdAt: DateTime(2026),
        onboardingCompleted: true,
        authProvider: 'email',
      );

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
    lastUpdateProfileAvatarColor = avatarColor;
    return User(
      id: '1',
      email: 'aziz@example.com',
      username: username,
      firstName: firstName,
      lastName: lastName,
      avatarColor: avatarColor,
      avatarImagePath: hasUploadedAvatar ? '/uploads/avatars/aziz.jpg' : null,
      direction: direction,
      isActive: true,
      createdAt: DateTime(2026),
      onboardingCompleted: true,
      authProvider: 'email',
    );
  }

  @override
  Future<bool> isUsernameAvailable(String username) async => usernameAvailable;

  @override
  Future<void> logout() async {}

  @override
  Future<void> registerPushToken(String token) async {}

  @override
  Future<User> uploadAvatarImage(String filePath) => throw UnimplementedError();

  @override
  Future<void> changePassword({required String currentPassword, required String newPassword}) =>
      throw UnimplementedError();

  @override
  Future<void> deleteAccount(String? password) => throw UnimplementedError();

  @override
  Future<void> forgotPassword(String email) async {}

  @override
  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {}

  @override
  Future<List<StoredAccountInfo>> listAccounts() async => const [];

  @override
  Future<String?> activeAccountId() async => null;

  @override
  Future<void> switchAccount(String userId) async {}

  @override
  Future<void> removeAccount(String userId) async {}

  @override
  Future<User> addAccount({required String email, required String password}) => throw UnimplementedError();

  @override
  Future<User> addAccountViaRegister({required String email, required String password}) =>
      throw UnimplementedError();

  @override
  Future<User?> addAccountWithGoogle() => throw UnimplementedError();
}

Future<({GoRouter router, _FakeAuthRepository repository})> _pumpEditProfile(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  _FakeAuthRepository? repository,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final _FakeAuthRepository repo = repository ?? _FakeAuthRepository();

  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen()),
      GoRoute(path: AppRoutes.editProfile, builder: (context, state) => const EditProfileScreen()),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        authRepositoryProvider.overrideWithValue(repo),
      ],
      child: TranslationProvider(
        child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
      ),
    ),
  );
  unawaited(router.push(AppRoutes.editProfile));
  await tester.pumpAndSettle();
  return (router: router, repository: repo);
}

void main() {
  testWidgets('renders the title and pre-filled fields, no overflow', (tester) async {
    await _pumpEditProfile(tester);

    expect(find.text(AppStrings.editProfile), findsOneWidget);
    // Each prefilled value is identical to its hint text, so the
    // (invisible, opacity-0) hint widget stacks with the real one —
    // `findsWidgets` accounts for that without asserting an exact count.
    expect(find.text('Aziz'), findsWidgets);
    expect(find.text('Karimov'), findsWidgets);
    expect(find.text('aziz_karimov'), findsWidgets);
    expect(find.text(AppStrings.saveButton), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits on the smallest supported phone width', (tester) async {
    await _pumpEditProfile(tester, size: const Size(360, 780));

    expect(find.text(AppStrings.editProfile), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('clearing the first name and saving shows a validation error', (tester) async {
    await _pumpEditProfile(tester);

    await tester.enterText(find.widgetWithText(TextFormField, 'Aziz'), '');
    await tester.ensureVisible(find.text(AppStrings.saveButton));
    await tester.tap(find.text(AppStrings.saveButton));
    await tester.pump();

    expect(find.text(AppStrings.nameRequired), findsOneWidget);
    expect(find.byType(EditProfileScreen), findsOneWidget);
  });

  testWidgets("saving doesn't resend avatarColor for a user with an uploaded photo", (tester) async {
    // Regression test: previously _save() always sent avatarColor, and
    // the backend treats avatar_color/avatar_image as mutually
    // exclusive — so saving any other field (name, username, ...) after
    // uploading a photo silently wiped the photo back to a color.
    final result = await _pumpEditProfile(tester, repository: _FakeAuthRepository(hasUploadedAvatar: true));

    await tester.enterText(find.widgetWithText(TextFormField, 'Karimov'), 'Yusupov');
    await tester.ensureVisible(find.text(AppStrings.saveButton));
    await tester.tap(find.text(AppStrings.saveButton));
    await tester.pumpAndSettle();

    expect(result.repository.lastUpdateProfileAvatarColor, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('saving with valid data confirms and returns to Home', (tester) async {
    await _pumpEditProfile(tester);

    await tester.ensureVisible(find.text(AppStrings.saveButton));
    await tester.tap(find.text(AppStrings.saveButton));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.profileUpdatedMessage), findsOneWidget);
    expect(find.byType(EditProfileScreen), findsNothing);
  });

  testWidgets('changing to a taken username blocks saving and shows an inline error', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final GoRouter router = GoRouter(
      initialLocation: AppRoutes.home,
      routes: [
        GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen()),
        GoRoute(path: AppRoutes.editProfile, builder: (context, state) => const EditProfileScreen()),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository(usernameAvailable: false)),
        ],
        child: TranslationProvider(
          child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
        ),
      ),
    );
    unawaited(router.push(AppRoutes.editProfile));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextFormField, 'aziz_karimov'), 'someone_else');
    await tester.ensureVisible(find.text(AppStrings.saveButton));
    await tester.tap(find.text(AppStrings.saveButton));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.usernameTaken), findsOneWidget);
    expect(find.byType(EditProfileScreen), findsOneWidget);
  });

  testWidgets('the back button returns to Home when pushed on top of it', (tester) async {
    await _pumpEditProfile(tester);

    await tester.tap(find.byIcon(TablerIcons.arrowLeft));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.duelHeroTitle), findsOneWidget);
    expect(find.byType(EditProfileScreen), findsNothing);
  });
}
