import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:zukkor/core/constants/app_strings.dart';
import 'package:zukkor/core/error/failures.dart';
import 'package:zukkor/core/router/app_routes.dart';
import 'package:zukkor/core/storage/app_preferences.dart';
import 'package:zukkor/core/theme/app_theme.dart';
import 'package:zukkor/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:zukkor/features/auth/domain/entities/user.dart';
import 'package:zukkor/features/auth/domain/repositories/auth_repository.dart';
import 'package:zukkor/features/auth/presentation/screens/login_screen.dart';
import 'package:zukkor/features/home/presentation/screens/home_screen.dart';
import 'package:zukkor/features/settings/data/repositories/notification_preferences_repository_impl.dart';
import 'package:zukkor/features/settings/domain/entities/notification_preferences.dart';
import 'package:zukkor/features/settings/domain/repositories/notification_preferences_repository.dart';
import 'package:zukkor/features/settings/presentation/screens/change_password_screen.dart';
import 'package:zukkor/features/settings/presentation/screens/help_center_screen.dart';
import 'package:zukkor/features/settings/presentation/screens/language_screen.dart';
import 'package:zukkor/features/settings/presentation/screens/notification_settings_screen.dart';
import 'package:zukkor/features/settings/presentation/screens/privacy_policy_screen.dart';
import 'package:zukkor/features/settings/presentation/screens/settings_screen.dart';
import 'package:zukkor/features/settings/presentation/screens/terms_of_use_screen.dart';
import 'package:zukkor/i18n/strings.g.dart';

/// Backendga murojaat qilmaydigan soxta auth repository — Log out,
/// Change password va Delete account testlari haqiqiy tarmoqqa bog'liq
/// bo'lmasligi kerak.
class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.deleteAccountFails = false});

  /// Noto'g'ri parol kiritilgan holatni simulyatsiya qilish uchun.
  final bool deleteAccountFails;

  /// Delete account testida chaqirilganini tekshirish uchun.
  String? deletedWithPassword;

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
  Future<void> deleteAccount(String? password) async {
    if (deleteAccountFails) throw AuthFailure('Wrong password');
    deletedWithPassword = password;
  }
}

/// Backendga murojaat qilmaydigan soxta repository — Notifications testi
/// (tapping Notifications) haqiqiy tarmoqqa bog'liq bo'lmasligi kerak.
class _FakeNotificationPreferencesRepository implements NotificationPreferencesRepository {
  @override
  Future<NotificationPreferences> getPreferences() async => const NotificationPreferences(
        duelInvites: true,
        streakReminders: true,
        leaderboardUpdates: true,
        friendRequests: true,
        productUpdates: true,
      );

  @override
  Future<NotificationPreferences> updatePreferences(NotificationPreferences preferences) async => preferences;
}

// SettingsScreen's theme switch reads/writes themeControllerProvider,
// which depends on appPreferencesProvider — needs a real ProviderScope
// (with a mocked SharedPreferences override) rather than a bare
// MaterialApp.router.
Future<GoRouter> _pumpSettings(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  AuthRepository? repository,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen()),
      GoRoute(path: AppRoutes.login, builder: (context, state) => const LoginScreen()),
      GoRoute(path: AppRoutes.settings, builder: (context, state) => const SettingsScreen()),
      GoRoute(
        path: AppRoutes.languageSettings,
        builder: (context, state) => const LanguageScreen(),
      ),
      GoRoute(
        path: AppRoutes.notificationSettings,
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(path: AppRoutes.privacyPolicy, builder: (context, state) => const PrivacyPolicyScreen()),
      GoRoute(path: AppRoutes.helpCenter, builder: (context, state) => const HelpCenterScreen()),
      GoRoute(path: AppRoutes.termsOfUse, builder: (context, state) => const TermsOfUseScreen()),
      GoRoute(path: AppRoutes.changePassword, builder: (context, state) => const ChangePasswordScreen()),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appPreferencesProvider.overrideWithValue(AppPreferences(prefs)),
        authRepositoryProvider.overrideWithValue(repository ?? _FakeAuthRepository()),
        notificationPreferencesRepositoryProvider.overrideWithValue(_FakeNotificationPreferencesRepository()),
      ],
      child: TranslationProvider(
        child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
      ),
    ),
  );
  unawaited(router.push(AppRoutes.settings));
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets('renders both groups, all rows, and Log out, no overflow', (tester) async {
    await _pumpSettings(tester);

    expect(find.text(AppStrings.settings), findsOneWidget);
    expect(find.text(AppStrings.settingsLanguage), findsOneWidget);
    expect(find.text(AppStrings.settingsLanguageValue), findsOneWidget);
    expect(find.text(AppStrings.settingsNotifications), findsOneWidget);
    expect(find.text(AppStrings.settingsTheme), findsOneWidget);
    expect(find.text(AppStrings.settingsThemeLight), findsOneWidget);
    expect(find.text(AppStrings.settingsSoundEffects), findsOneWidget);
    expect(find.text(AppStrings.settingsPrivacy), findsOneWidget);
    expect(find.text(AppStrings.settingsHelpCenter), findsOneWidget);
    expect(find.text(AppStrings.settingsTermsOfUse), findsOneWidget);
    expect(find.text(AppStrings.settingsChangePassword), findsOneWidget);
    expect(find.text(AppStrings.settingsLogOut), findsOneWidget);
    expect(find.text(AppStrings.settingsDeleteAccount), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits on the smallest supported phone width', (tester) async {
    await _pumpSettings(tester, size: const Size(360, 780));

    expect(find.text(AppStrings.settingsLogOut), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping the theme row toggles the label from Light to Dark', (tester) async {
    await _pumpSettings(tester);

    expect(find.text(AppStrings.settingsThemeLight), findsOneWidget);

    await tester.tap(find.text(AppStrings.settingsTheme));
    await tester.pump();

    expect(find.text(AppStrings.settingsThemeDark), findsOneWidget);
    expect(find.text(AppStrings.settingsThemeLight), findsNothing);
  });

  testWidgets('tapping the sound effects row toggles it on', (tester) async {
    await _pumpSettings(tester);

    // Off by default for now — see AppPreferences.soundEffectsEnabled.
    expect(tester.widget<Switch>(find.byType(Switch).last).value, isFalse);

    await tester.tap(find.text(AppStrings.settingsSoundEffects));
    await tester.pump();

    expect(tester.widget<Switch>(find.byType(Switch).last).value, isTrue);
  });

  testWidgets('tapping Language opens the Language picker, and picking one updates the row', (tester) async {
    await _pumpSettings(tester);

    await tester.tap(find.text(AppStrings.settingsLanguage));
    await tester.pumpAndSettle();

    expect(find.byType(LanguageScreen), findsOneWidget);
    expect(find.text(AppStrings.languageUzbek), findsOneWidget);

    await tester.tap(find.text(AppStrings.languageUzbek));
    await tester.pumpAndSettle();

    expect(find.byType(LanguageScreen), findsNothing);
    expect(find.text(AppStrings.languageUzbek), findsOneWidget);
  });

  testWidgets('tapping Notifications opens Notification preferences', (tester) async {
    await _pumpSettings(tester);

    await tester.tap(find.text(AppStrings.settingsNotifications));
    await tester.pumpAndSettle();

    expect(find.byType(NotificationSettingsScreen), findsOneWidget);
  });

  testWidgets('tapping Privacy opens the Privacy Policy', (tester) async {
    await _pumpSettings(tester);

    await tester.tap(find.text(AppStrings.settingsPrivacy));
    await tester.pumpAndSettle();

    expect(find.byType(PrivacyPolicyScreen), findsOneWidget);
  });

  testWidgets('tapping Help center opens the Help Center', (tester) async {
    await _pumpSettings(tester);

    await tester.tap(find.text(AppStrings.settingsHelpCenter));
    await tester.pumpAndSettle();

    expect(find.byType(HelpCenterScreen), findsOneWidget);
  });

  testWidgets('tapping Terms of use opens the Terms of Use', (tester) async {
    await _pumpSettings(tester);

    await tester.tap(find.text(AppStrings.settingsTermsOfUse));
    await tester.pumpAndSettle();

    expect(find.byType(TermsOfUseScreen), findsOneWidget);
  });

  testWidgets('tapping Log out navigates to Login', (tester) async {
    await _pumpSettings(tester);

    await tester.tap(find.text(AppStrings.settingsLogOut));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(SettingsScreen), findsNothing);
  });

  testWidgets('tapping Change password opens the Change Password screen', (tester) async {
    await _pumpSettings(tester);

    await tester.tap(find.text(AppStrings.settingsChangePassword));
    await tester.pumpAndSettle();

    expect(find.byType(ChangePasswordScreen), findsOneWidget);
    expect(find.text(AppStrings.changePasswordTitle), findsWidgets);
  });

  testWidgets('tapping Delete account opens a confirmation dialog, cancel dismisses it', (tester) async {
    final _FakeAuthRepository repository = _FakeAuthRepository();
    await _pumpSettings(tester, repository: repository);

    await tester.tap(find.text(AppStrings.settingsDeleteAccount));
    await tester.pumpAndSettle();

    // "Delete account" appears both as the settings row label and the
    // dialog title while the dialog is open — scope to the dialog itself.
    expect(find.byType(AlertDialog), findsOneWidget);

    await tester.tap(find.text(AppStrings.cancel));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(SettingsScreen), findsOneWidget);
    expect(repository.deletedWithPassword, isNull);
  });

  testWidgets('deleting the account with a wrong password shows an inline error and stays open', (tester) async {
    final _FakeAuthRepository repository = _FakeAuthRepository(deleteAccountFails: true);
    await _pumpSettings(tester, repository: repository);

    await tester.tap(find.text(AppStrings.settingsDeleteAccount));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'wrong-password');
    await tester.tap(find.text(AppStrings.deleteAccountConfirmButton));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Wrong password'), findsOneWidget);
    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  testWidgets('confirming account deletion with the correct password navigates to Login', (tester) async {
    final _FakeAuthRepository repository = _FakeAuthRepository();
    await _pumpSettings(tester, repository: repository);

    await tester.tap(find.text(AppStrings.settingsDeleteAccount));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField), 'correct-password');
    await tester.tap(find.text(AppStrings.deleteAccountConfirmButton));
    await tester.pumpAndSettle();

    expect(repository.deletedWithPassword, 'correct-password');
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(SettingsScreen), findsNothing);
  });

  testWidgets('the back button returns to Home when pushed on top of it', (tester) async {
    await _pumpSettings(tester);

    await tester.tap(find.byIcon(TablerIcons.arrowLeft));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.duelHeroTitle), findsOneWidget);
    expect(find.byType(SettingsScreen), findsNothing);
  });
}
