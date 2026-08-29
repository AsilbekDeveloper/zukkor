import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zukkor/app.dart';
import 'package:zukkor/core/constants/app_strings.dart';
import 'package:zukkor/core/notifications/push_notification_service.dart';
import 'package:zukkor/core/router/app_routes.dart';
import 'package:zukkor/core/storage/app_preferences.dart';
import 'package:zukkor/core/storage/token_storage.dart';
import 'package:zukkor/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:zukkor/features/auth/domain/entities/user.dart';
import 'package:zukkor/features/auth/domain/repositories/auth_repository.dart';

/// Saqlangan token yo'q — SplashScreen'ni "kirilmagan" holatga
/// (Login/Introduction) deterministik yo'naltiradi, real secure storage'ga
/// (test muhitida platforma kanali yo'q) tegmasdan.
class _FakeTokenStorage implements TokenStorage {
  @override
  Future<String?> readAccessToken() async => null;

  @override
  Future<String?> readRefreshToken() async => null;

  @override
  Future<void> saveTokens({required String access, String? refresh}) async {}

  @override
  Future<void> clear() async {}

  @override
  Future<String?> activeAccountId() async => null;

  @override
  Future<List<StoredAccountInfo>> listAccounts() async => const [];

  @override
  Future<void> registerActiveSession({
    required String userId,
    required StoredAccountInfo info,
  }) async {}

  @override
  Future<void> setActiveAccount(String userId) async {}

  @override
  Future<void> removeAccount(String userId) async {}

  @override
  Future<void> savePendingLoginTokens({required String access, String? refresh}) async {}
}

/// Backendga murojaat qilmaydigan soxta auth repository — bu smoke testlar
/// faqat forma va navigatsiyani tekshiradi, haqiqiy tarmoqqa bog'liq
/// bo'lmasligi kerak.
class _FakeAuthRepository implements AuthRepository {
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
        username: 'aziz',
        isActive: true,
        createdAt: DateTime(2026),
        onboardingCompleted: false,
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
  }) async =>
      User(
        id: '1',
        email: 'aziz@example.com',
        username: username,
        firstName: firstName,
        lastName: lastName,
        avatarColor: avatarColor,
        direction: direction,
        isActive: true,
        createdAt: DateTime(2026),
        onboardingCompleted: true,
        authProvider: 'email',
      );

  @override
  Future<bool> isUsernameAvailable(String username) async => true;

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
}

class _FakePushNotificationService implements PushNotificationService {
  @override
  Future<String?> requestTokenOrNull() async => 'fake-token';

  @override
  void listenTokenRefresh(void Function(String token) onToken) {}

  @override
  void listenForeground() {}
}

/// Butun ilova ulanishining smoke testi: ProviderScope + tema + router
/// birgalikda ishga tushadi, ilova to'g'ridan-to'g'ri Login ekranida ochiladi
/// (auth qatlami hali qurilmagani uchun sessiya tiklash yo'q).
/// Bu test o'tsa — ilova real qurilmada ham "ochilmay qolish" darajasida
/// buzilmagani kafolatlanadi.
void main() {
  testWidgets('ilova Login ekranida ochiladi', (tester) async {
    // These tests exercise the post-Introduction Login/Register/Onboarding
    // flow directly, so the walkthrough gate is pre-cleared here.
    SharedPreferences.setMockInitialValues(<String, Object>{'zukkor.has_seen_introduction': true});
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesProvider.overrideWithValue(AppPreferences(prefs)),
          tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
          pushNotificationServiceProvider.overrideWithValue(_FakePushNotificationService()),
        ],
        child: const ZukkorApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.loginTitle), findsOneWidget);
    expect(find.text(AppStrings.emailLabel), findsOneWidget);
    expect(find.text(AppStrings.passwordLabel), findsOneWidget);
    expect(find.text(AppStrings.loginButton), findsWidgets);
    expect(find.text(AppStrings.continueWithGoogle), findsOneWidget);
  });

  testWidgets('Login → Register sahifasiga o\'tish va orqaga qaytish', (tester) async {
    // Standart test oynasi (800x600) telefon ekranidan torroq — pastdagi
    // havola ko'rinmay qolib, tap() xato beradi. Haqiqiy telefon o'lchamiga
    // moslashtiramiz.
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // These tests exercise the post-Introduction Login/Register/Onboarding
    // flow directly, so the walkthrough gate is pre-cleared here.
    SharedPreferences.setMockInitialValues(<String, Object>{'zukkor.has_seen_introduction': true});
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesProvider.overrideWithValue(AppPreferences(prefs)),
          tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
          pushNotificationServiceProvider.overrideWithValue(_FakePushNotificationService()),
        ],
        child: const ZukkorApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.loginTitle), findsOneWidget);

    // Login → Register (alohida sahifaga push qilinadi).
    await tester.tap(find.text(AppStrings.switchToRegister));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.registerTitle), findsOneWidget);
    expect(find.text(AppStrings.registerButton), findsWidgets);
    expect(find.text(AppStrings.confirmPasswordLabel), findsOneWidget);
    expect(find.text(AppStrings.loginTitle), findsNothing);

    // Parollar mos kelmasa xato ko'rsatiladi.
    await tester.enterText(find.byType(TextFormField).at(1), 'Parol12345');
    await tester.enterText(find.byType(TextFormField).at(2), 'boshqaParol');
    await tester.tap(find.text(AppStrings.registerButton));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.passwordMismatch), findsOneWidget);

    // Register → Login (orqaga qaytish havolasi). Mismatch xatosi qo'shimcha
    // joy egallagani uchun havola scroll ko'rinishidan tashqarida bo'lishi
    // mumkin — avval uni ko'rinadigan qilamiz.
    await tester.ensureVisible(find.text(AppStrings.switchToLogin));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.switchToLogin));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.loginTitle), findsOneWidget);
    expect(find.text(AppStrings.registerTitle), findsNothing);
  });

  testWidgets('Register with a valid form navigates to Onboarding', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // These tests exercise the post-Introduction Login/Register/Onboarding
    // flow directly, so the walkthrough gate is pre-cleared here.
    SharedPreferences.setMockInitialValues(<String, Object>{'zukkor.has_seen_introduction': true});
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesProvider.overrideWithValue(AppPreferences(prefs)),
          tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
          pushNotificationServiceProvider.overrideWithValue(_FakePushNotificationService()),
        ],
        child: const ZukkorApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Reach Register directly — robust to whichever screen the router
    // currently opens on.
    final BuildContext context = tester.element(find.byType(Scaffold).first);
    unawaited(context.push(AppRoutes.register));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'aziz@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'Parol12345');
    await tester.enterText(find.byType(TextFormField).at(2), 'Parol12345');
    await tester.tap(find.text(AppStrings.registerButton));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.avatarStepTitle), findsOneWidget);
    expect(find.text(AppStrings.registerTitle), findsNothing);
  });

  testWidgets('Login with a valid form navigates to Home', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // These tests exercise the post-Introduction Login/Register/Onboarding
    // flow directly, so the walkthrough gate is pre-cleared here.
    SharedPreferences.setMockInitialValues(<String, Object>{'zukkor.has_seen_introduction': true});
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesProvider.overrideWithValue(AppPreferences(prefs)),
          tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
          authRepositoryProvider.overrideWithValue(_FakeAuthRepository()),
          pushNotificationServiceProvider.overrideWithValue(_FakePushNotificationService()),
        ],
        child: const ZukkorApp(),
      ),
    );
    await tester.pumpAndSettle();

    final BuildContext context = tester.element(find.byType(Scaffold).first);
    unawaited(context.push(AppRoutes.login));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'aziz@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'Parol12345');
    await tester.tap(find.text(AppStrings.loginButton).first);
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.duelHeroTitle), findsOneWidget);
    expect(find.text(AppStrings.loginTitle), findsNothing);
  });

  testWidgets('first launch shows the Introduction walkthrough before Login', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    // No `hasSeenIntroduction` flag set — this is a brand-new install.
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // The Introduction explainer pages run a continuous "breathing"/orbit
    // animation for as long as they're mounted, so `pumpAndSettle()`
    // would never return here — bounded pumps only.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appPreferencesProvider.overrideWithValue(AppPreferences(prefs)),
          tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
          pushNotificationServiceProvider.overrideWithValue(_FakePushNotificationService()),
        ],
        child: const ZukkorApp(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text(AppStrings.introWelcomeTitle), findsOneWidget);
    expect(find.text(AppStrings.loginTitle), findsNothing);

    // Skip jumps straight to Login and persists the flag.
    await tester.tap(find.text(AppStrings.introSkip));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text(AppStrings.loginTitle), findsOneWidget);
    expect(prefs.getBool('zukkor.has_seen_introduction'), isTrue);
  });
}
