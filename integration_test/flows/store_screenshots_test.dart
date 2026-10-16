// pirichat: walks the review account through its demo community and pauses on
// each screen so tool/store_screenshots.sh can capture it with simctl/adb.
// Run only through that script; it needs TEST_LAB_* dart-defines.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../support/app_launcher.dart';
import '../support/scroll_utils.dart';
import '../support/test_config.dart';

Future<void> _shot(WidgetTester tester, String name) async {
  await tester.pump(const Duration(seconds: 3));
  // ignore: avoid_print
  print('STORE_SHOT:$name');
  for (var i = 0; i < 8; i++) {
    await tester.pump(const Duration(seconds: 1));
  }
}

Future<void> _tapText(WidgetTester tester, String text) async {
  final Finder target = find.text(text).hitTestable();
  await pumpUntil(tester, target);
  await tester.tap(target.first);
  await tester.pump();
  await tester.pump(const Duration(seconds: 3));
}

Future<void> _login(WidgetTester tester) async {
  await launchFluxerApp(tester);
  final Finder fields = find.byType(EditableText);
  await pumpUntil(tester, fields, timeout: const Duration(minutes: 2));
  await tester.enterText(fields.at(0), IntegrationTestConfig.email);
  await tester.enterText(fields.at(1), IntegrationTestConfig.password);
  await tester.pump();
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await tester.pump(const Duration(seconds: 1));
  final Finder button = find.byWidgetPredicate(
    (Widget w) => w is Text && RegExp(r'^(Giriş [Yy]ap|Log in)$').hasMatch(w.data ?? ''),
  );
  await tester.tap(button.hitTestable().last);
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(seconds: 1));
    if (find.byKey(ValueKey<String>('guild-${IntegrationTestConfig.guildId}')).evaluate().isNotEmpty) {
      return;
    }
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('store screenshots', (WidgetTester tester) async {
    await _login(tester);
    final Finder guild = find
        .byKey(ValueKey<String>('guild-${IntegrationTestConfig.guildId}'))
        .hitTestable();
    await pumpUntil(tester, guild);
    await tester.tap(guild.first);
    await tester.pump(const Duration(seconds: 3));
    await _shot(tester, 'channels');
    for (final String channel in <String>['duyurular', 'proje-takibi', 'toplantı-notları']) {
      await _tapText(tester, channel);
      await _shot(tester, channel);
      await returnToShell(tester);
      await tester.pump(const Duration(seconds: 2));
      if (find.text('duyurular').hitTestable().evaluate().isEmpty) {
        await tester.tap(guild.first);
        await tester.pump(const Duration(seconds: 2));
      }
    }
  }, timeout: const Timeout(Duration(minutes: 15)));
}
