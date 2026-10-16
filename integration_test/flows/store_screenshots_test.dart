// pirichat: walks the review account through its demo community and pauses on
// each screen so tool/store_screenshots.sh can capture it with simctl/adb.
// Run only through that script; it needs TEST_LAB_* dart-defines.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:fluxer_app/features/chat/presentation/widgets/channel/chat_back_button.dart';

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
  final Finder guild = find.byKey(ValueKey<String>('guild-${IntegrationTestConfig.guildId}'));
  final Finder fields = find.byType(EditableText);
  for (var i = 0; i < 120; i++) {
    await tester.pump(const Duration(seconds: 1));
    if (guild.evaluate().isNotEmpty || find.byType(ChatBackButton).evaluate().isNotEmpty) return;
    if (fields.evaluate().length >= 2) break;
  }
  await tester.enterText(fields.at(0), IntegrationTestConfig.email);
  await tester.enterText(fields.at(1), IntegrationTestConfig.password);
  await tester.pump();
  // The password field's done action submits the form.
  await tester.testTextInput.receiveAction(TextInputAction.done);
  await pumpUntil(tester, guild, timeout: const Duration(minutes: 2));
}

Future<void> _dismissSheet(WidgetTester tester) async {
  final Finder sheet = find.textContaining('Kurtarma kiti');
  for (var i = 0; i < 3 && sheet.evaluate().isNotEmpty; i++) {
    await tester.tapAt(const Offset(200, 150));
    await tester.pump(const Duration(seconds: 2));
    if (sheet.evaluate().isNotEmpty) {
      await tester.binding.handlePopRoute();
      await tester.pump(const Duration(seconds: 2));
    }
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('store screenshots', (WidgetTester tester) async {
    // Keep the native notification prompt from covering the screenshots.
    final TestDefaultBinaryMessenger messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(
      const MethodChannel('fluxer_app/apple_push'),
      (MethodCall call) async => null,
    );
    messenger.setMockMethodCallHandler(
      const MethodChannel('flutter.baseflow.com/permissions/methods'),
      (MethodCall call) async => call.method == 'requestPermissions'
          ? <int, int>{for (final int p in (call.arguments as List<Object?>).cast<int>()) p: 1}
          : 1,
    );
    await _login(tester);
    await tester.pump(const Duration(seconds: 3));
    await returnToShell(tester);
    await tester.pump(const Duration(seconds: 2));
    await _dismissSheet(tester);
    final Finder guild = find
        .byKey(ValueKey<String>('guild-${IntegrationTestConfig.guildId}'))
        .hitTestable();
    await pumpUntil(tester, guild);
    await tester.tap(guild.first);
    await tester.pump(const Duration(seconds: 3));
    await _dismissSheet(tester);
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
