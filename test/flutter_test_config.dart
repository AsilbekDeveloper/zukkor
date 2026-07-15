import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:zukkor/i18n/strings.g.dart';

/// [LocaleSettings] is a slang-managed singleton, not a Riverpod provider —
/// it survives across tests in the same process. Reset it to English before
/// every test so locale-driven widgets (Settings language row, Introduction
/// WelcomeStep, LanguageScreen) don't leak state between test cases.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  setUp(() => LocaleSettings.setLocaleSync(AppLocale.en));
  await testMain();
}
