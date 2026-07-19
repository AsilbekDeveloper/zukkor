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
import 'package:zukkor/core/theme/app_theme.dart';
import 'package:zukkor/features/friends/data/repositories/friends_repository_impl.dart';
import 'package:zukkor/features/friends/domain/entities/discovered_user.dart';
import 'package:zukkor/features/friends/domain/entities/friend.dart';
import 'package:zukkor/features/friends/domain/entities/friend_request.dart';
import 'package:zukkor/features/friends/domain/repositories/friends_repository.dart';
import 'package:zukkor/features/friends/presentation/models/friend_entry.dart';
import 'package:zukkor/features/friends/presentation/screens/duel_screen.dart';
import 'package:zukkor/features/home/presentation/screens/home_screen.dart';
import 'package:zukkor/features/quiz/data/repositories/quiz_repository_impl.dart';
import 'package:zukkor/features/quiz/domain/entities/answer_result.dart';
import 'package:zukkor/features/quiz/domain/entities/category.dart';
import 'package:zukkor/features/quiz/domain/entities/quiz_start_result.dart';
import 'package:zukkor/features/quiz/domain/repositories/quiz_repository.dart';
import 'package:zukkor/features/quiz/presentation/screens/categories_screen.dart';
import 'package:zukkor/i18n/strings.g.dart';

/// Backendga murojaat qilmaydigan soxta quiz repository — Categories
/// ekrani (Duel'ning kategoriya tanlagichi) `GET /categories`ni chaqiradi,
/// haqiqiy tarmoqqa bog'liq bo'lmasligi kerak.
class _FakeQuizRepository implements QuizRepository {
  @override
  Future<List<Category>> getCategories() async => const [
        Category(id: 1, name: 'Math', iconName: 'math-symbols', colorKey: 'coral', questionCount: 120),
        Category(id: 2, name: 'History', iconName: 'book', colorKey: 'terra', questionCount: 98),
      ];

  @override
  Future<QuizStartResult> startQuiz({required int categoryId, required int questionCount}) =>
      throw UnimplementedError();

  @override
  Future<AnswerResult> submitAnswer({
    required String sessionId,
    required int sessionQuestionId,
    required int? selectedOption,
  }) =>
      throw UnimplementedError();
}

/// Backendga murojaat qilmaydigan soxta friends repository — real
/// `GET /friends` javobiga mos (endi onlayn/oflayn cheklovi yo'q,
/// istalgan do'stni tanlash mumkin).
class _FakeFriendsRepository implements FriendsRepository {
  @override
  Future<List<Friend>> getFriends() async => const [
        Friend(
          id: '1',
          username: 'malika_yusupova',
          firstName: 'Malika',
          lastName: 'Yusupova',
          avatarColor: 'a-teal',
          avatarImagePath: null,
        ),
        Friend(
          id: '2',
          username: 'shohruh_toshpulatov',
          firstName: 'Shohruh',
          lastName: 'Toshpulatov',
          avatarColor: 'a-terra',
          avatarImagePath: null,
        ),
        Friend(
          id: '3',
          username: 'dilnoza_rustamova',
          firstName: 'Dilnoza',
          lastName: 'Rustamova',
          avatarColor: 'a-pink',
          avatarImagePath: null,
        ),
      ];

  @override
  Future<List<DiscoveredUser>> searchUsers(String query) => throw UnimplementedError();

  @override
  Future<void> sendFriendRequest(String userId) => throw UnimplementedError();

  @override
  Future<List<FriendRequest>> getIncomingRequests() async => const [];

  @override
  Future<void> acceptFriendRequest(String requestId) => throw UnimplementedError();

  @override
  Future<void> declineFriendRequest(String requestId) => throw UnimplementedError();
}

Future<GoRouter> _pumpDuel(WidgetTester tester, {Size size = const Size(390, 844)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.duel,
    routes: [
      GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen()),
      GoRoute(path: AppRoutes.duel, builder: (context, state) => const DuelScreen()),
      GoRoute(
        path: AppRoutes.categories,
        builder: (context, state) => CategoriesScreen(duelOpponent: state.extra as FriendEntry?),
      ),
    ],
  );

  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        appPreferencesProvider.overrideWithValue(AppPreferences(prefs)),
        quizRepositoryProvider.overrideWithValue(_FakeQuizRepository()),
        friendsRepositoryProvider.overrideWithValue(_FakeFriendsRepository()),
      ],
      child: TranslationProvider(
        child: MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets('renders title and every friend, no overflow', (tester) async {
    await _pumpDuel(tester);

    expect(find.text(AppStrings.duelScreenTitle), findsOneWidget);
    expect(find.text(AppStrings.chooseYourFriend), findsOneWidget);

    expect(find.text('Malika Yusupova'), findsOneWidget);
    expect(find.text('Shohruh Toshpulatov'), findsOneWidget);
    expect(find.text('Dilnoza Rustamova'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets('fits on the smallest supported phone width', (tester) async {
    await _pumpDuel(tester, size: const Size(360, 780));

    expect(find.text(AppStrings.duelScreenTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping a duel button opens Categories as the duel category picker', (tester) async {
    await _pumpDuel(tester);

    await tester.tap(find.byIcon(TablerIcons.swords).first);
    await tester.pumpAndSettle();

    expect(find.byType(CategoriesScreen), findsOneWidget);
  });

  testWidgets('the back button returns to Home when pushed on top of it', (tester) async {
    final GoRouter router = await _pumpDuel(tester);
    router.go(AppRoutes.home);
    unawaited(router.push(AppRoutes.duel));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.duelScreenTitle), findsOneWidget);

    await tester.tap(find.byIcon(TablerIcons.arrowLeft));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.duelHeroTitle), findsOneWidget);
    expect(find.text(AppStrings.duelScreenTitle), findsNothing);
  });
}
