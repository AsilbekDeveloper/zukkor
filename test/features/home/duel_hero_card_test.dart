import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zukkor/core/theme/app_theme.dart';
import 'package:zukkor/features/home/presentation/widgets/duel_hero_card.dart';
import 'package:zukkor/i18n/strings.g.dart';

/// Regression test for a real bug found in the 2026-09-11 streak audit:
/// the weekly-activity row's day labels used a FIXED Mon..Sun array
/// indexed by position, even though `weeklyActivity` is a rolling 7-day
/// window ending today (not a Monday-first calendar week) - so every
/// label except "Bugun" was wrong unless today happened to be a Sunday
/// (the one day the two orderings coincide). Each label must now be
/// derived from the actual calendar date it represents.
void main() {
  testWidgets('each non-today day is labelled with its OWN real weekday', (
    tester,
  ) async {
    await tester.pumpWidget(
      TranslationProvider(
        child: MaterialApp(
          theme: AppTheme.light(),
          home: Scaffold(
            body: DuelHeroCard(
              streakDays: 3,
              weeklyActivity: List.filled(7, false),
              onStartDuel: () {},
            ),
          ),
        ),
      ),
    );

    const List<String> weekdayLabels = [
      'Du',
      'Se',
      'Cho',
      'Pa',
      'Ju',
      'Sha',
      'Ya',
    ];
    final DateTime today = DateTime.now();

    // Position 6 is always "Bugun" (today); positions 0-5 are the 6
    // days before it, each with its own distinct real weekday - under
    // the old fixed-array bug, position 0 was hardcoded to 'Du' no
    // matter what day it actually fell on.
    for (int i = 0; i < 6; i++) {
      final DateTime date = today.subtract(Duration(days: 6 - i));
      final String expected = weekdayLabels[date.weekday - 1];
      expect(
        find.text(expected),
        findsOneWidget,
        reason: 'day $i (${date.toIso8601String()}) should show "$expected"',
      );
    }
    expect(find.text('Bugun'), findsOneWidget);
  });
}
