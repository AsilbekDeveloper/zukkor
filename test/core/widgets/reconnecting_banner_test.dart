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
Future<void> _pump(WidgetTester tester, bool isConnected) async {
  await tester.pumpWidget(
    TranslationProvider(
      child: MaterialApp(
        theme: AppTheme.light(),
        home: Scaffold(body: ReconnectingBanner(isConnected: isConnected)),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets('renders nothing while connected', (tester) async {
    await _pump(tester, true);

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text(AppStrings.reconnecting), findsNothing);
  });

  testWidgets('shows a reconnecting indicator once disconnected', (
    tester,
  ) async {
    await _pump(tester, false);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text(AppStrings.reconnecting), findsOneWidget);
  });
}
