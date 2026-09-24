import 'package:banimark_flutter/banimark_flutter.dart';
import 'package:flutter/material.dart';

import 'core/settings.dart';
import 'home.dart';

/// The Banimark Flutter test app: every way to put the Banimark chat in an
/// app, each with the code to copy. Points at https://banimark.com by
/// default - change it on the Server screen.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = await DemoSettings.load();
  runApp(Demo(settings: settings, child: const TestApp()));
}

/// Needed only for the "bubble on every screen" option: MaterialApp.builder
/// sits ABOVE the Navigator, so the launcher opens the chat through this key.
final appNavigator = GlobalKey<NavigatorState>();

class TestApp extends StatelessWidget {
  const TestApp({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Demo.of(context);
    return MaterialApp(
      title: 'Banimark Test',
      debugShowCheckedModeBanner: false,
      navigatorKey: appNavigator,
      theme: ThemeData(colorSchemeSeed: const Color(0xFF22B2A2), useMaterial3: true),
      darkTheme: ThemeData(colorSchemeSeed: const Color(0xFF22B2A2), brightness: Brightness.dark, useMaterial3: true),
      home: const HomeScreen(),
      // Option on the Server screen: the floating bubble over every screen.
      builder: (context, child) => !s.globalLauncher
          ? child!
          : BanimarkLauncher(
              key: ValueKey('global-${s.baseUrl}-${s.runtime}-${s.token}'),
              config: s.config,
              visitor: s.visitor,
              navigatorKey: appNavigator,
              storageKey: 'banimark_global_launcher',
              child: child!,
            ),
    );
  }
}
