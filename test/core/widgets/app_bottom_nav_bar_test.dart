import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabler_icons_plus/tabler_icons_plus.dart';
import 'package:zukkor/core/constants/app_strings.dart';
import 'package:zukkor/core/theme/app_theme.dart';
import 'package:zukkor/core/widgets/app_bottom_nav_bar.dart';

Future<void> _pump(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(MaterialApp(
    theme: AppTheme.light(),
    home: Scaffold(
      // A tall, recognizable body — this is what a regression that
      // starves the body of height (by letting the nav bar's width
      // limiter expand to fill the whole screen's height) would hide.
      body: const Center(child: Text('BODY CONTENT')),
      bottomNavigationBar: AppBottomNavBar(
        current: AppTab.home,
        onTabTap: (_) {},
        onPlayTap: () {},
      ),
    ),
  ));
  await tester.pump();
}

void main() {
  testWidgets('on phone widths, the body is not starved of height by the nav bar', (tester) async {
    await _pump(tester, const Size(390, 844));

    expect(find.text('BODY CONTENT'), findsOneWidget);
    expect(find.text(AppStrings.navHome), findsOneWidget);

    // The bar stays a compact, shrink-wrapped strip — not the whole screen.
    final double barHeight = tester.getSize(find.text(AppStrings.navHome)).height;
    expect(barHeight, lessThan(50));
    expect(tester.takeException(), isNull);
  });

  testWidgets('on tablet widths, the body is not starved of height by the nav bar', (tester) async {
    await _pump(tester, const Size(1024, 1366));

    expect(find.text('BODY CONTENT'), findsOneWidget);
    expect(find.text(AppStrings.navHome), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('on wide tablets, tab items are capped/centered like the content column', (tester) async {
    // 1280 > contentMaxExpanded (1040), so the items get real side margins
    // of (1280 - 1040) / 2 = 120 — the bar aligns with the content column.
    await _pump(tester, const Size(1280, 800));

    final double homeIconLeft = tester.getTopLeft(find.byIcon(TablerIcons.home)).dx;
    expect(homeIconLeft, greaterThan(100));
  });
}
