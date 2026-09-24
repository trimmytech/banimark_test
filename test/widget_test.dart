import 'package:banimark_flutter/banimark_flutter.dart';
import 'package:banimark_test/core/settings.dart';
import 'package:banimark_test/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Every demo opens without an error and shows its chat (no network in tests:
/// the SDK treats the refused requests as "desk unreachable").
void main() {
  Future<void> boot(WidgetTester tester, [Map<String, Object> prefs = const {}]) async {
    // a phone-sized screen (the default test surface is 800x600)
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues(prefs);
    final s = await DemoSettings.load();
    await tester.pumpWidget(Demo(settings: s, child: const TestApp()));
    await tester.pump();
  }

  Future<void> open(WidgetTester tester, String title) async {
    await tester.scrollUntilVisible(find.text(title), 200, scrollable: find.byType(Scrollable).first);
    await tester.ensureVisible(find.text(title));
    await tester.pump();
    await tester.tap(find.text(title));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
  }

  testWidgets('home lists every demo and the desk it points at', (tester) async {
    await boot(tester);
    expect(find.text('https://banimark.com'), findsOneWidget);
    for (final t in ['Full screen', 'Bottom sheet', 'Floating bubble', 'In a tab', 'Theme playground', 'Conversation tools']) {
      await tester.scrollUntilVisible(find.text(t), 200, scrollable: find.byType(Scrollable).first);
      expect(find.text(t), findsOneWidget);
    }
  });

  final demos = {
    'Full screen': null,
    'Bottom sheet': null,
    'Floating bubble': null,
    'In a tab': null,
    'Theme playground': BanimarkChat,
    'Custom message bubbles': BanimarkChat,
    'Your own chat UI': null,
    'Guest, known visitor, signed-in user': null,
    'Events and links': BanimarkChat,
    'Conversation tools': null,
  };
  for (final e in demos.entries) {
    testWidgets('opens: ${e.key}', (tester) async {
      await boot(tester);
      await open(tester, e.key);
      expect(tester.takeException(), isNull);
      if (e.value != null) expect(find.byType(e.value!), findsOneWidget);
      // every demo offers its code
      await tester.tap(find.byIcon(Icons.code_rounded));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Copy'), findsOneWidget);
    });
  }

  testWidgets('the floating bubble opens the chat from a shop screen', (tester) async {
    await boot(tester);
    await open(tester, 'Floating bubble');
    final tryIt = find.widgetWithText(FilledButton, 'Try it on a shop screen');
    await tester.dragUntilVisible(tryIt, find.byType(ListView).last, const Offset(0, -300));
    await tester.pump();
    await tester.tap(tryIt);
    await tester.pump(); // the route starts on this frame...
    await tester.pump(const Duration(milliseconds: 600)); // ...and has finished by this one
    expect(find.text('Acme Shop'), findsOneWidget);
    await tester.tap(find.byKey(BanimarkLauncher.bubbleKey));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(tester.takeException(), isNull);
    expect(find.byType(BanimarkChat), findsOneWidget);
  });

  testWidgets('the bubble on EVERY screen (MaterialApp.builder) opens the chat', (tester) async {
    await boot(tester, {'demo_global_launcher': true});
    expect(find.byKey(BanimarkLauncher.bubbleKey), findsOneWidget);
    await tester.tap(find.byKey(BanimarkLauncher.bubbleKey));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(tester.takeException(), isNull, reason: 'above the Navigator: works only through navigatorKey');
    expect(find.byType(BanimarkChat), findsOneWidget);
  });
}
