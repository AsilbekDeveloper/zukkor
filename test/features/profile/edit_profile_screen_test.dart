import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:zukkor/core/constants/app_strings.dart';
import 'package:zukkor/core/router/app_routes.dart';
import 'package:zukkor/core/theme/app_theme.dart';
import 'package:zukkor/features/home/presentation/screens/home_screen.dart';
import 'package:zukkor/features/profile/presentation/screens/edit_profile_screen.dart';

Future<GoRouter> _pumpEditProfile(WidgetTester tester, {Size size = const Size(390, 844)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final GoRouter router = GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(path: AppRoutes.home, builder: (context, state) => const HomeScreen()),
      GoRoute(path: AppRoutes.editProfile, builder: (context, state) => const EditProfileScreen()),
    ],
  );

  await tester.pumpWidget(MaterialApp.router(theme: AppTheme.light(), routerConfig: router));
  unawaited(router.push(AppRoutes.editProfile));
  await tester.pumpAndSettle();
  return router;
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
    await tester.tap(find.text(AppStrings.saveButton));
    await tester.pump();

    expect(find.text(AppStrings.nameRequired), findsOneWidget);
    expect(find.byType(EditProfileScreen), findsOneWidget);
  });

  testWidgets('saving with valid data confirms and returns to Home', (tester) async {
    await _pumpEditProfile(tester);

    await tester.tap(find.text(AppStrings.saveButton));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.profileUpdatedMessage), findsOneWidget);
    expect(find.byType(EditProfileScreen), findsNothing);
  });

  testWidgets('the back button returns to Home when pushed on top of it', (tester) async {
    await _pumpEditProfile(tester);

    await tester.tap(find.byIcon(TablerIcons.arrowLeft));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.duelHeroTitle), findsOneWidget);
    expect(find.byType(EditProfileScreen), findsNothing);
  });
}
