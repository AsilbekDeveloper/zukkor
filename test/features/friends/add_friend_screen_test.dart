import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:zukkor/core/constants/app_strings.dart';
import 'package:zukkor/core/router/app_routes.dart';
import 'package:zukkor/core/theme/app_theme.dart';
import 'package:zukkor/features/friends/presentation/screens/add_friend_screen.dart';
import 'package:zukkor/features/friends/presentation/screens/friends_screen.dart';

Future<GoRouter> _pumpAddFriend(WidgetTester tester, {Size size = const Size(390, 844)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.addFriend,
    routes: [
      GoRoute(path: AppRoutes.friends, builder: (context, state) => const FriendsScreen()),
      GoRoute(path: AppRoutes.addFriend, builder: (context, state) => const AddFriendScreen()),
    ],
  );

  await tester.pumpWidget(
    MaterialApp.router(theme: AppTheme.light(), routerConfig: router),
  );
  await tester.pumpAndSettle();
  return router;
}

void main() {
  testWidgets('renders title, search bar and invite code with no overflow', (tester) async {
    await _pumpAddFriend(tester);

    expect(find.text(AppStrings.addFriend), findsOneWidget);
    expect(find.text(AppStrings.searchByUsername), findsOneWidget);
    expect(find.text(AppStrings.orViaInviteLink), findsOneWidget);
    expect(find.text(AppStrings.yourInviteCode), findsOneWidget);
    expect(find.text('ZKR-AZ312'), findsOneWidget);
    expect(find.text(AppStrings.shareLink), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('fits on the smallest supported phone width', (tester) async {
    await _pumpAddFriend(tester, size: const Size(360, 780));

    expect(find.text(AppStrings.addFriend), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('typing in the search bar shows matching users and hides the invite section', (tester) async {
    await _pumpAddFriend(tester);

    await tester.enterText(find.byType(TextField), 'sardor');
    await tester.pump();

    expect(find.text('Sardor Aliyev'), findsOneWidget);
    expect(find.text('@sardor_aliyev'), findsOneWidget);
    expect(find.text(AppStrings.orViaInviteLink), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a search with no matches shows the empty state', (tester) async {
    await _pumpAddFriend(tester);

    await tester.enterText(find.byType(TextField), 'zzz-no-such-user');
    await tester.pump();

    expect(find.text(AppStrings.noUsersFound), findsOneWidget);
  });

  testWidgets('tapping Add on a result turns it into a disabled Sent state', (tester) async {
    await _pumpAddFriend(tester);

    await tester.enterText(find.byType(TextField), 'sardor');
    await tester.pump();

    await tester.tap(find.text(AppStrings.addButton));
    await tester.pump();

    expect(find.text(AppStrings.friendRequestSentLabel), findsOneWidget);
    expect(find.text(AppStrings.addButton), findsNothing);
  });

  testWidgets('clearing the search restores the invite section', (tester) async {
    await _pumpAddFriend(tester);

    await tester.enterText(find.byType(TextField), 'sardor');
    await tester.pump();
    await tester.tap(find.byIcon(TablerIcons.x));
    await tester.pump();

    expect(find.text(AppStrings.orViaInviteLink), findsOneWidget);
    expect(find.text('Sardor Aliyev'), findsNothing);
  });

  testWidgets('tapping "Share the link" shows a coming-soon snackbar', (tester) async {
    await _pumpAddFriend(tester);

    await tester.tap(find.text(AppStrings.shareLink));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text(AppStrings.comingSoon), findsOneWidget);
  });

  testWidgets('the back button returns to Friends when pushed on top of it', (tester) async {
    final GoRouter router = await _pumpAddFriend(tester);
    router.go(AppRoutes.friends);
    unawaited(router.push(AppRoutes.addFriend));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.addFriend), findsOneWidget);

    await tester.tap(find.byIcon(TablerIcons.arrowLeft));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.orViaInviteLink), findsNothing);
  });
}
