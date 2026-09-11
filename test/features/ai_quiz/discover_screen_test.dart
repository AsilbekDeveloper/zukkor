import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zukkor/core/constants/app_strings.dart';
import 'package:zukkor/core/storage/app_preferences.dart';
import 'package:zukkor/core/theme/app_theme.dart';
import 'package:zukkor/features/ai_quiz/data/repositories/ai_quiz_repository_impl.dart';
import 'package:zukkor/features/ai_quiz/domain/entities/discover_quiz.dart';
import 'package:zukkor/features/ai_quiz/domain/repositories/ai_quiz_repository.dart';
import 'package:zukkor/features/ai_quiz/presentation/screens/discover_screen.dart';
import 'package:zukkor/features/friends/data/repositories/friends_repository_impl.dart';
import 'package:zukkor/features/friends/domain/entities/discovered_user.dart';
import 'package:zukkor/features/friends/domain/repositories/friends_repository.dart';
import 'package:zukkor/features/quiz/presentation/controllers/categories_controller.dart';
import 'package:zukkor/i18n/strings.g.dart';

class _FakeAiQuizRepository extends Fake implements AiQuizRepository {
  List<DiscoverQuiz> feed = [
    DiscoverQuiz(
      id: 1,
      name: 'Flutter asoslari',
      questionCount: 10,
      createdAt: DateTime(2026),
      source: 'manual',
      visibility: 'public',
      ownerUserId: 'owner1',
      ownerUsername: 'aziz',
    ),
  ];

  @override
  Future<List<DiscoverQuiz>> discover({int? categoryId}) async => feed;

  @override
  Future<List<DiscoverQuiz>> searchDiscover(
    String query, {
    int? categoryId,
  }) async => const [];
}

class _FakeFriendsRepository extends Fake implements FriendsRepository {
  final List<String> sentRequestUserIds = [];
  List<DiscoveredUser> searchResults = const [];

  @override
  Future<List<DiscoveredUser>> searchUsers(String query) async => searchResults;

  @override
  Future<void> sendFriendRequest(String userId) async =>
      sentRequestUserIds.add(userId);
}

class _FakeCategoriesController extends CategoriesController {
  @override
  Future<void> load() async {}
}

Future<
  ({
    GoRouter router,
    _FakeAiQuizRepository aiQuiz,
    _FakeFriendsRepository friends,
  })
>
_pumpDiscover(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final _FakeAiQuizRepository aiQuizRepository = _FakeAiQuizRepository();
  final _FakeFriendsRepository friendsRepository = _FakeFriendsRepository();

  final GoRouter router = GoRouter(
    initialLocation: '/discover',
    routes: [
      GoRoute(
        path: '/discover',
        builder: (context, state) => const DiscoverScreen(),
      ),
      GoRoute(
        path: '/player/:id',
        builder: (context, state) =>
            const Scaffold(body: Text('PLAYER_DETAIL')),
      ),
    ],
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        aiQuizRepositoryProvider.overrideWithValue(aiQuizRepository),
        friendsRepositoryProvider.overrideWithValue(friendsRepository),
        categoriesControllerProvider.overrideWith(
          () => _FakeCategoriesController(),
        ),
      ],
      child: TranslationProvider(
        child: MaterialApp.router(
          theme: AppTheme.light(),
          routerConfig: router,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return (router: router, aiQuiz: aiQuizRepository, friends: friendsRepository);
}

void main() {
  testWidgets('defaults to the quiz feed with the mode switch visible', (
    tester,
  ) async {
    await _pumpDiscover(tester);

    expect(find.text('Flutter asoslari'), findsOneWidget);
    expect(find.text(AppStrings.discoverModeQuizzes), findsOneWidget);
    expect(find.text(AppStrings.discoverModePeople), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'switching to People mode hides the quiz feed and shows the search prompt',
    (tester) async {
      await _pumpDiscover(tester);

      await tester.tap(find.text(AppStrings.discoverModePeople));
      await tester.pumpAndSettle();

      expect(find.text('Flutter asoslari'), findsNothing);
      expect(find.text(AppStrings.discoverPeopleSearchPrompt), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('typing in People mode searches users, not quizzes', (
    tester,
  ) async {
    final result = await _pumpDiscover(tester);
    result.friends.searchResults = const [
      DiscoveredUser(
        id: 'u2',
        username: 'malika',
        firstName: 'Malika',
        lastName: 'Yusupova',
        avatarColor: 'a-teal',
        avatarImagePath: null,
        requestPending: false,
      ),
    ];

    await tester.tap(find.text(AppStrings.discoverModePeople));
    await tester.pumpAndSettle();
    expect(find.text(AppStrings.discoverPeopleSearchPrompt), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'mali');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('Malika Yusupova'), findsOneWidget);
    expect(find.text('Flutter asoslari'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping "Add" on a person sends a real friend request', (
    tester,
  ) async {
    final result = await _pumpDiscover(tester);
    result.friends.searchResults = const [
      DiscoveredUser(
        id: 'u2',
        username: 'malika',
        firstName: 'Malika',
        lastName: 'Yusupova',
        avatarColor: 'a-teal',
        avatarImagePath: null,
        requestPending: false,
      ),
    ];

    await tester.tap(find.text(AppStrings.discoverModePeople));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'mali');
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.addButton));
    await tester.pump();
    await tester.pump();

    expect(result.friends.sentRequestUserIds, ['u2']);
  });
}
