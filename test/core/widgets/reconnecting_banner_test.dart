import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zukkor/core/constants/app_strings.dart';
import 'package:zukkor/core/theme/app_theme.dart';
import 'package:zukkor/core/widgets/reconnecting_banner.dart';
import 'package:zukkor/i18n/strings.g.dart';

/// Without this banner, a dropped Duel/Lobby WebSocket looked identical
/// to the game just hanging - the underlying socket data sources already
/// tracked `isConnected` and retried on their own, but nothing ever
/// showed the user (2026-09-13 real-device-testing prep audit).
Future<void> _pump(
  WidgetTester tester, {
  required bool visible,
  String? message,
}) async {
  await tester.pumpWidget(
    TranslationProvider(
      child: MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(
          body: ReconnectingBanner(visible: visible, message: message),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('renders nothing while not visible', (tester) async {
    await _pump(tester, visible: false);

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text(AppStrings.reconnecting), findsNothing);
  });

  testWidgets('shows the default reconnecting message when visible', (
    tester,
  ) async {
    await _pump(tester, visible: true);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text(AppStrings.reconnecting), findsOneWidget);
  });

  testWidgets('shows a custom message when one is given', (tester) async {
    await _pump(tester, visible: true, message: 'Custom message');

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Custom message'), findsOneWidget);
    expect(find.text(AppStrings.reconnecting), findsNothing);
  });
}
