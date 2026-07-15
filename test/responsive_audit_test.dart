import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zukkor/core/constants/app_strings.dart';
import 'package:zukkor/core/models/avatar_color_option.dart';
import 'package:zukkor/core/storage/app_preferences.dart';
import 'package:zukkor/core/theme/app_theme.dart';
import 'package:zukkor/features/auth/presentation/screens/login_screen.dart';
import 'package:zukkor/features/auth/presentation/screens/register_screen.dart';
import 'package:zukkor/features/friends/presentation/models/duel_match.dart';
import 'package:zukkor/features/friends/presentation/models/friend_entry.dart';
import 'package:zukkor/features/friends/presentation/screens/add_friend_screen.dart';
import 'package:zukkor/features/friends/presentation/screens/duel_invite_screen.dart';
import 'package:zukkor/features/friends/presentation/screens/duel_screen.dart';
import 'package:zukkor/features/friends/presentation/screens/duel_waiting_screen.dart';
import 'package:zukkor/features/friends/presentation/screens/friends_screen.dart';
import 'package:zukkor/features/history/presentation/screens/history_screen.dart';
import 'package:zukkor/features/home/presentation/screens/home_screen.dart';
import 'package:zukkor/features/introduction/presentation/screens/introduction_screen.dart';
import 'package:zukkor/features/leaderboard/presentation/models/leaderboard_entry.dart';
import 'package:zukkor/features/leaderboard/presentation/screens/full_leaderboard_screen.dart';
import 'package:zukkor/features/leaderboard/presentation/screens/leaderboard_screen.dart';
import 'package:zukkor/features/leaderboard/presentation/screens/player_detail_screen.dart';
import 'package:zukkor/features/leaderboard/presentation/screens/rank_filter_screen.dart';
import 'package:zukkor/features/lobby/presentation/screens/join_code_screen.dart';
import 'package:zukkor/features/lobby/presentation/screens/lobby_result_screen.dart';
import 'package:zukkor/features/lobby/presentation/screens/lobby_screen.dart';
import 'package:zukkor/features/notifications/presentation/screens/notifications_screen.dart';
import 'package:zukkor/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'package:zukkor/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:zukkor/features/profile/presentation/screens/profile_screen.dart';
import 'package:zukkor/features/quiz/presentation/models/quiz_category.dart';
import 'package:zukkor/features/quiz/presentation/models/quiz_result.dart';
import 'package:zukkor/features/quiz/presentation/screens/categories_screen.dart';
import 'package:zukkor/features/quiz/presentation/screens/quiz_intro_screen.dart';
import 'package:zukkor/features/quiz/presentation/screens/quiz_screen.dart';
import 'package:zukkor/features/quiz/presentation/screens/result_screen.dart';
import 'package:zukkor/features/settings/presentation/screens/help_center_screen.dart';
import 'package:zukkor/features/settings/presentation/screens/language_screen.dart';
import 'package:zukkor/features/settings/presentation/screens/notification_settings_screen.dart';
import 'package:zukkor/features/settings/presentation/screens/privacy_policy_screen.dart';
import 'package:zukkor/features/settings/presentation/screens/settings_screen.dart';
import 'package:zukkor/features/settings/presentation/screens/terms_of_use_screen.dart';
import 'package:zukkor/features/splash/splash_screen.dart';
import 'package:zukkor/i18n/strings.g.dart';

/// RESPONSIVE AUDIT — the project's overflow safety net.
///
/// Every screen is laid out at every size in [_sizes] (real device
/// dimensions: small/large phones, portrait/landscape tablets, and a
/// landscape phone as the harshest height) and additionally at the app's
/// maximum clamped text scale (1.3) on the narrowest and widest devices.
/// Any RenderFlex overflow or other layout exception fails the matching
/// test case by name, e.g. `Leaderboard @ 320x568`.
///
/// RULE FOR NEW SCREENS: add the screen to [_screens] in the same change
/// that creates it — this file is what keeps "no overflow anywhere" true
/// as the app grows.
const List<Size> _sizes = [
  // Phones (portrait).
  Size(320, 568), // iPhone SE 1 / smallest realistic device
  Size(360, 640), // small Android
  Size(375, 667), // iPhone SE 2/3
  Size(390, 844), // iPhone 14
  Size(412, 915), // Pixel 7
  Size(480, 800), // large/wide phone
  // Phone (landscape) — the harshest height any screen must survive.
  Size(844, 390),
  // Tablets (portrait).
  Size(600, 960), // exactly at the tablet breakpoint
  Size(768, 1024), // iPad
  Size(834, 1194), // iPad Air
  Size(1024, 1366), // iPad Pro 12.9"
  // Tablets (landscape).
  Size(1024, 768),
  Size(1280, 800),
];

/// Narrowest + widest devices re-run at the max clamped font scale.
const List<Size> _textScaleSizes = [Size(320, 568), Size(360, 640), Size(1024, 1366)];

typedef _ScreenCase = ({String name, WidgetBuilder builder});

final List<_ScreenCase> _screens = [
  (name: 'Splash', builder: (_) => const SplashScreen()),
  (name: 'Introduction', builder: (_) => const IntroductionScreen()),
  (name: 'Login', builder: (_) => const LoginScreen()),
  (name: 'Register', builder: (_) => const RegisterScreen()),
  (name: 'Onboarding', builder: (_) => const OnboardingScreen()),
  (name: 'Home', builder: (_) => const HomeScreen()),
  (name: 'Categories', builder: (_) => const CategoriesScreen()),
  (name: 'QuizIntro', builder: (_) => QuizIntroScreen(category: QuizCategory.sample.first)),
  (name: 'Quiz', builder: (_) => QuizScreen(category: QuizCategory.sample.first)),
  (
    name: 'Result',
    builder: (_) => ResultScreen(
      result: QuizResult(category: QuizCategory.sample.first, correctCount: 4, totalCount: 5, xpEarned: 60),
    ),
  ),
  (name: 'Leaderboard', builder: (_) => const LeaderboardScreen()),
  (name: 'Friends', builder: (_) => const FriendsScreen()),
  (name: 'AddFriend', builder: (_) => const AddFriendScreen()),
  (name: 'Duel', builder: (_) => const DuelScreen()),
  (name: 'Profile', builder: (_) => const ProfileScreen()),
  (name: 'JoinCode', builder: (_) => const JoinCodeScreen()),
  (name: 'LobbyHost', builder: (_) => const LobbyScreen(role: LobbyRole.host)),
  (name: 'LobbyGuest', builder: (_) => const LobbyScreen(role: LobbyRole.guest)),
  (
    name: 'LobbyResult',
    builder: (_) => LobbyResultScreen(
      result: QuizResult(category: QuizCategory.sample.first, correctCount: 4, totalCount: 5, xpEarned: 58),
    ),
  ),
  (name: 'FullLeaderboard', builder: (_) => const FullLeaderboardScreen()),
  (name: 'PlayerDetail', builder: (_) => PlayerDetailScreen(entry: LeaderboardEntry.sampleFull.first)),
  (name: 'RankFilter', builder: (_) => const RankFilterScreen(currentFilter: null)),
  (name: 'Settings', builder: (_) => const SettingsScreen()),
  (name: 'History', builder: (_) => const HistoryScreen()),
  (
    name: 'DuelWaiting',
    builder: (_) => DuelWaitingScreen(
      match: DuelMatch(
        opponent: const FriendEntry(
          name: 'Malika Yusupova',
          initials: 'MR',
          avatarColor: AvatarColorOption.teal,
          isOnline: true,
          statusLabel: 'Online',
        ),
        category: QuizCategory.sample.first,
      ),
    ),
  ),
  (name: 'DuelInvite', builder: (_) => const DuelInviteScreen()),
  (name: 'Notifications', builder: (_) => const NotificationsScreen()),
  (name: 'EditProfile', builder: (_) => const EditProfileScreen()),
  (name: 'Language', builder: (_) => const LanguageScreen()),
  (name: 'NotificationSettings', builder: (_) => const NotificationSettingsScreen()),
  (name: 'PrivacyPolicy', builder: (_) => const PrivacyPolicyScreen()),
  (name: 'HelpCenter', builder: (_) => const HelpCenterScreen()),
  (name: 'TermsOfUse', builder: (_) => const TermsOfUseScreen()),
];

Future<void> _pumpAt(
  WidgetTester tester,
  Size size,
  WidgetBuilder builder, {
  double textScale = 1.0,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  // Settings reads themeControllerProvider (dark-mode toggle), which
  // depends on appPreferencesProvider — every screen needs a
  // ProviderScope even though most don't touch it themselves.
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [appPreferencesProvider.overrideWithValue(AppPreferences(prefs))],
      child: TranslationProvider(
        child: MaterialApp(
          theme: AppTheme.light(),
          // Mirrors production: `clampTextScaling` caps the system scale at
          // 1.3, so 1.3 here is exactly the worst case a user can produce.
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: Builder(builder: builder),
        ),
      ),
    ),
  );
  // Bounded pumps (not pumpAndSettle — Splash has an indefinite spinner).
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  // Backs appPreferencesProvider (see _pumpAt) — must be set before any
  // SharedPreferences.getInstance() call or it hits a real platform
  // channel with no test handler and hangs forever instead of failing.
  SharedPreferences.setMockInitialValues(<String, Object>{});

  for (final _ScreenCase screen in _screens) {
    group(screen.name, () {
      for (final Size size in _sizes) {
        testWidgets('${screen.name} @ ${size.width.toInt()}x${size.height.toInt()}', (tester) async {
          await _pumpAt(tester, size, screen.builder);
          expect(tester.takeException(), isNull);
        });
      }

      for (final Size size in _textScaleSizes) {
        testWidgets(
            '${screen.name} @ ${size.width.toInt()}x${size.height.toInt()} (text scale 1.3)',
            (tester) async {
          await _pumpAt(tester, size, screen.builder, textScale: 1.3);
          expect(tester.takeException(), isNull);
        });
      }
    });
  }

  // The onboarding wizard's later steps only exist after interaction, so
  // walk the full flow at representative extremes of the size matrix.
  group('Onboarding wizard walk', () {
    const List<Size> walkSizes = [Size(320, 568), Size(390, 844), Size(844, 390), Size(1024, 768)];

    for (final Size size in walkSizes) {
      testWidgets('all 3 steps @ ${size.width.toInt()}x${size.height.toInt()}', (tester) async {
        await _pumpAt(tester, size, (_) => const OnboardingScreen());
        expect(tester.takeException(), isNull, reason: 'step 1 overflowed');

        // Step 1 → 2.
        await tester.tap(find.text(AppStrings.onboardingContinue));
        await tester.pump(const Duration(milliseconds: 400));
        expect(tester.takeException(), isNull, reason: 'step 2 overflowed');

        // Fill the profile form so step 2 can advance.
        await tester.enterText(find.byType(TextFormField).at(0), 'Aziz');
        await tester.enterText(find.byType(TextFormField).at(1), 'Karimov');
        await tester.enterText(find.byType(TextFormField).at(2), 'aziz_karimov');
        await tester.pump();

        // Step 2 → 3.
        await tester.tap(find.text(AppStrings.onboardingContinue));
        await tester.pump(const Duration(milliseconds: 400));
        expect(tester.takeException(), isNull, reason: 'step 3 overflowed');

        expect(find.text(AppStrings.directionStepTitle), findsOneWidget);
      });
    }
  });

  // Same idea for the Introduction walkthrough's 6 pages — walk to the
  // last page (survey inputs included) without tapping the final button,
  // since that calls `context.go` and this harness has no GoRouter.
  group('Introduction walkthrough', () {
    const List<Size> walkSizes = [Size(320, 568), Size(390, 844), Size(844, 390), Size(1024, 768)];

    for (final Size size in walkSizes) {
      testWidgets('all 6 pages @ ${size.width.toInt()}x${size.height.toInt()}', (tester) async {
        await _pumpAt(tester, size, (_) => const IntroductionScreen());
        expect(tester.takeException(), isNull, reason: 'page 1 overflowed');

        // Pages 1 → 5: plain explainer pages, just advance through them.
        for (int page = 2; page <= 5; page++) {
          await tester.tap(find.text(AppStrings.onboardingContinue));
          await tester.pump(const Duration(milliseconds: 400));
          expect(tester.takeException(), isNull, reason: 'page $page overflowed');
        }

        // Page 5: interests survey — select a couple of chips including
        // "Other", which reveals a text field. The chip grid can overflow
        // the shortest test viewports, so scroll each chip into view
        // before tapping it.
        await tester.ensureVisible(find.text('Math'));
        await tester.tap(find.text('Math'));
        await tester.ensureVisible(find.text(AppStrings.introOtherOption));
        await tester.tap(find.text(AppStrings.introOtherOption));
        await tester.pump();
        expect(tester.takeException(), isNull, reason: 'page 5 (interests) overflowed');

        await tester.enterText(find.byType(TextFormField), 'Chess');
        await tester.pump();

        await tester.tap(find.text(AppStrings.onboardingContinue));
        await tester.pump(const Duration(milliseconds: 400));

        // Page 6: study place + quiz liking — switch both segments to
        // their non-default option to exercise the wider labels.
        expect(tester.takeException(), isNull, reason: 'page 6 overflowed');
        await tester.ensureVisible(find.text(AppStrings.introStudyPlaceExamPrep));
        await tester.tap(find.text(AppStrings.introStudyPlaceExamPrep));
        await tester.ensureVisible(find.text(AppStrings.introQuizLikingNotReally));
        await tester.tap(find.text(AppStrings.introQuizLikingNotReally));
        await tester.pump();
        expect(tester.takeException(), isNull, reason: 'page 6 after selection overflowed');

        expect(find.text(AppStrings.introQuizLikingLabel), findsOneWidget);
      });
    }
  });
}
