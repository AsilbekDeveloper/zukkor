import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:zukkor/app.dart';
import 'package:zukkor/core/constants/app_strings.dart';
import 'package:zukkor/core/router/app_routes.dart';
import 'package:zukkor/core/storage/app_preferences.dart';
import 'package:zukkor/core/storage/token_storage.dart';
import 'package:zukkor/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:zukkor/features/auth/domain/entities/user.dart';
import 'package:zukkor/features/auth/domain/repositories/auth_repository.dart';

/// Saqlangan token yo'q — [SplashScreen]'ni (ilova endi shu bilan
/// boshlanadi) "kirilmagan" holatga deterministik yo'naltiradi. Real
/// secure storage'ni ishlatsa, test muhitida platforma kanaliga javob
/// kelmagani uchun `pumpAndSettle()` cheksiz kutib qolardi.
class _FakeTokenStorage implements TokenStorage {
  @override
  Future<String?> readAccessToken() async => null;

  @override
  Future<String?> readRefreshToken() async => null;

  @override
  Future<void> saveTokens({required String access, String? refresh}) async {}

  @override
  Future<void> clear() async {}
}

/// Backendga murojaat qilmaydigan soxta auth repository — "happy path"
/// testi `completeOnboarding()`ni chaqiradi, haqiqiy tarmoqqa bog'liq
/// bo'lmasligi kerak.
class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository({this.usernameAvailable = true});

  final bool usernameAvailable;
  List<String>? receivedInterests;
  String? receivedStudyPlace;
  String? receivedQuizLiking;

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
  }) async {
    receivedInterests = interests;
    receivedStudyPlace = studyPlace;
    receivedQuizLiking = quizLiking;
    return User(
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
}

/// The onboarding wizard has no entry point wired up yet (login/register
/// submit are still TODO stubs), so tests reach it the same way a future
/// "registration succeeded" redirect will: by pushing the route directly.
Future<SharedPreferences> _pumpAppOnOnboarding(
  WidgetTester tester, {
  AuthRepository? authRepository,
  Map<String, Object>? extraPrefs,
}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  // Skips the Introduction walkthrough (its explainer pages run a
  // continuous animation that would make the pumpAndSettle below hang) —
  // this file only cares about the Onboarding wizard itself.
  SharedPreferences.setMockInitialValues(<String, Object>{
    'zukkor.has_seen_introduction': true,
    ...?extraPrefs,
  });
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appPreferencesProvider.overrideWithValue(AppPreferences(prefs)),
        authRepositoryProvider.overrideWithValue(authRepository ?? _FakeAuthRepository()),
        tokenStorageProvider.overrideWithValue(_FakeTokenStorage()),
      ],
      child: const ZukkorApp(),
    ),
  );
  await tester.pumpAndSettle();

  final BuildContext context = tester.element(find.byType(Scaffold).first);
  unawaited(context.push(AppRoutes.onboarding));
  await tester.pumpAndSettle();
  return prefs;
}

void main() {
  testWidgets('step 1: avatar step renders and Continue advances to step 2', (tester) async {
    await _pumpAppOnOnboarding(tester);

    expect(find.text(AppStrings.avatarStepTitle), findsOneWidget);
    expect(find.text('1/3'), findsOneWidget);

    await tester.tap(find.text(AppStrings.onboardingContinue));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.profileStepTitle), findsOneWidget);
    expect(find.text('2/3'), findsOneWidget);
  });

  testWidgets('step 2: empty form blocks advancing and shows errors', (tester) async {
    await _pumpAppOnOnboarding(tester);
    await tester.tap(find.text(AppStrings.onboardingContinue));
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.onboardingContinue));
    await tester.pumpAndSettle();

    // Still on step 2 — nothing progressed.
    expect(find.text(AppStrings.profileStepTitle), findsOneWidget);
    expect(find.text(AppStrings.nameRequired), findsNWidgets(2));
    expect(find.text(AppStrings.usernameRequired), findsOneWidget);
  });

  testWidgets('step 2: taken username blocks advancing and shows an inline error', (tester) async {
    await _pumpAppOnOnboarding(tester, authRepository: _FakeAuthRepository(usernameAvailable: false));

    await tester.tap(find.text(AppStrings.onboardingContinue));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, AppStrings.firstNameHint),
      'Aziz',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, AppStrings.lastNameHint),
      'Karimov',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, AppStrings.usernameHint),
      'aziz_karimov',
    );
    await tester.tap(find.text(AppStrings.onboardingContinue));
    await tester.pumpAndSettle();

    // Still on step 2 — the username is reported as taken.
    expect(find.text(AppStrings.profileStepTitle), findsOneWidget);
    expect(find.text(AppStrings.usernameTaken), findsOneWidget);
  });

  testWidgets('step 3: no direction selected blocks Start and shows a hint', (tester) async {
    await _pumpAppOnOnboarding(tester);

    // Step 1 → 2.
    await tester.tap(find.text(AppStrings.onboardingContinue));
    await tester.pumpAndSettle();

    // Fill step 2 and advance to 3.
    await tester.enterText(
      find.widgetWithText(TextFormField, AppStrings.firstNameHint),
      'Aziz',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, AppStrings.lastNameHint),
      'Karimov',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, AppStrings.usernameHint),
      'aziz_karimov',
    );
    await tester.tap(find.text(AppStrings.onboardingContinue));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.directionStepTitle), findsOneWidget);
    expect(find.text(AppStrings.onboardingStart), findsWidgets);

    await tester.tap(find.text(AppStrings.onboardingStart));
    await tester.pumpAndSettle();

    // Still on step 3 — direction is required.
    expect(find.text(AppStrings.directionStepTitle), findsOneWidget);
    expect(find.text(AppStrings.directionRequired), findsOneWidget);
  });

  testWidgets('happy path: all 3 steps completed lands on Home', (tester) async {
    await _pumpAppOnOnboarding(tester);

    // Step 1 → 2.
    await tester.tap(find.text(AppStrings.onboardingContinue));
    await tester.pumpAndSettle();

    // Step 2 → 3.
    await tester.enterText(
      find.widgetWithText(TextFormField, AppStrings.firstNameHint),
      'Aziz',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, AppStrings.lastNameHint),
      'Karimov',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, AppStrings.usernameHint),
      'aziz_karimov',
    );
    await tester.tap(find.text(AppStrings.onboardingContinue));
    await tester.pumpAndSettle();

    // Step 3: pick a direction, then Start.
    await tester.tap(find.text(AppStrings.directionStudentUniTitle));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.onboardingStart));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.duelHeroTitle), findsOneWidget);
  });

  testWidgets('folds in Introduction survey answers saved before registration, then clears them',
      (tester) async {
    final _FakeAuthRepository repository = _FakeAuthRepository();
    final SharedPreferences prefs = await _pumpAppOnOnboarding(
      tester,
      authRepository: repository,
      extraPrefs: {
        'zukkor.intro_interests': ['Math', 'Movies'],
        'zukkor.intro_study_place': 'school',
        'zukkor.intro_quiz_liking': 'love_it',
      },
    );

    // Step 1 → 2.
    await tester.tap(find.text(AppStrings.onboardingContinue));
    await tester.pumpAndSettle();

    // Step 2 → 3.
    await tester.enterText(find.widgetWithText(TextFormField, AppStrings.firstNameHint), 'Aziz');
    await tester.enterText(find.widgetWithText(TextFormField, AppStrings.lastNameHint), 'Karimov');
    await tester.enterText(find.widgetWithText(TextFormField, AppStrings.usernameHint), 'aziz_karimov');
    await tester.tap(find.text(AppStrings.onboardingContinue));
    await tester.pumpAndSettle();

    // Step 3: pick a direction, then Start.
    await tester.tap(find.text(AppStrings.directionStudentUniTitle));
    await tester.pumpAndSettle();
    await tester.tap(find.text(AppStrings.onboardingStart));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.duelHeroTitle), findsOneWidget);
    expect(repository.receivedInterests, ['Math', 'Movies']);
    expect(repository.receivedStudyPlace, 'school');
    expect(repository.receivedQuizLiking, 'love_it');
    // Cleared afterward — never resent on a future profile update.
    expect(prefs.getStringList('zukkor.intro_interests'), isNull);
    expect(prefs.getString('zukkor.intro_study_place'), isNull);
    expect(prefs.getString('zukkor.intro_quiz_liking'), isNull);
  });

  testWidgets('back button steps back through the wizard', (tester) async {
    await _pumpAppOnOnboarding(tester);

    await tester.tap(find.text(AppStrings.onboardingContinue));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.profileStepTitle), findsOneWidget);

    await tester.tap(find.byIcon(TablerIcons.arrowLeft));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.avatarStepTitle), findsOneWidget);
    expect(find.text('1/3'), findsOneWidget);
  });
}
