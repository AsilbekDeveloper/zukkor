import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:zukkor/core/storage/app_preferences.dart';
import 'package:zukkor/core/theme/app_theme.dart';
import 'package:zukkor/features/quiz/presentation/models/quiz_category.dart';
import 'package:zukkor/features/quiz/presentation/screens/quiz_setup_screen.dart';
import 'package:zukkor/i18n/strings.g.dart';

/// A fast double-tap on "Start" (before the push transition to Duel
/// Waiting/Lobby actually happens) used to fire `onStart` twice - for
/// Duel that meant two separate invites sent to the same friend from
/// one tap (2026-09-13 real-device-testing prep audit).
const QuizCategory _math = QuizCategory(
  id: 1,
  name: 'Math',
  questionCount: 20,
  icon: TablerIcons.mathSymbols,
  colorKey: CategoryColorKey.coral,
);

Future<int> _pumpAndCountStarts(WidgetTester tester) async {
  int callCount = 0;
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: TranslationProvider(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: QuizSetupScreen(
            category: _math,
            onStart: (context, ref, count) => callCount++,
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();

  final Finder startButton = find.byType(ElevatedButton);
  await tester.tap(startButton);
  // No pump() here on purpose - simulates a second tap arriving before
  // the widget has rebuilt to visually reflect the first one, which is
  // exactly the race a fast double-tap creates on a real device.
  await tester.tap(startButton);
  await tester.pump();

  return callCount;
}

void main() {
  testWidgets('a fast double-tap on Start only fires onStart once', (
    tester,
  ) async {
    final int callCount = await _pumpAndCountStarts(tester);
    expect(callCount, 1);
  });

  testWidgets(
    'Start re-enables after the guard window so a later tap still works',
    (tester) async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      int callCount = 0;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: TranslationProvider(
            child: MaterialApp(
              theme: AppTheme.light(),
              home: QuizSetupScreen(
                category: _math,
                onStart: (context, ref, count) => callCount++,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final Finder startButton = find.byType(ElevatedButton);
      await tester.tap(startButton);
      await tester.pump(const Duration(milliseconds: 900));
      await tester.tap(startButton);
      await tester.pump();

      // Confirms the guard is a brief anti-double-tap window, not a
      // permanent lock - popping back to this screen later (e.g.
      // cancelling from Duel Waiting) must not leave Start stuck disabled.
      expect(callCount, 2);
    },
  );
}
