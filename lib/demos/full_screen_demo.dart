import 'package:banimark_flutter/banimark_flutter.dart';
import 'package:flutter/material.dart';

import '../core/demo_page.dart';
import '../core/settings.dart';

/// BanimarkChat as a whole page: with its own header, or inside your AppBar.
class FullScreenDemo extends StatelessWidget {
  const FullScreenDemo({super.key});

  @override
  Widget build(BuildContext context) => DemoPage(
        title: 'Full screen',
        code: _code,
        body: ListView(padding: const EdgeInsets.all(16), children: [
          const Text('Two ways to give the chat a whole page.'),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Icons.open_in_full_rounded),
            label: const Text('With the chat\'s own header'),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const _OwnHeader())),
          ),
          const SizedBox(height: 10),
          FilledButton.tonalIcon(
            icon: const Icon(Icons.web_asset_rounded),
            label: const Text('Inside your own AppBar (showHeader: false)'),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const _InAppBar())),
          ),
        ]),
      );
}

class _OwnHeader extends StatelessWidget {
  const _OwnHeader();
  @override
  Widget build(BuildContext context) {
    final s = Demo.of(context);
    return Scaffold(
      body: BanimarkChat(
        config: s.config,
        visitor: s.visitor,
        followAdminAppearance: true, // colour, title, greeting... from the desk's Widget page
        onClose: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class _InAppBar extends StatelessWidget {
  const _InAppBar();
  @override
  Widget build(BuildContext context) {
    final s = Demo.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Help & support')),
      body: BanimarkChat(
        config: s.config,
        visitor: s.visitor,
        showHeader: false,
        theme: BanimarkTheme.fromScheme(Theme.of(context).colorScheme),
      ),
    );
  }
}

const _code = '''
// 1. The chat's own header (title, status, close button)
Navigator.of(context).push(MaterialPageRoute(
  builder: (_) => Scaffold(
    body: BanimarkChat(
      config: BanimarkConfig.laravel('https://banimark.com'),
      followAdminAppearance: true,   // look set on the desk's Widget page
      onClose: () => Navigator.of(context).pop(),
    ),
  ),
));

// 2. Inside your own AppBar, in your app's colours
Scaffold(
  appBar: AppBar(title: const Text('Help & support')),
  body: BanimarkChat(
    config: BanimarkConfig.laravel('https://banimark.com'),
    showHeader: false,
    theme: BanimarkTheme.fromScheme(Theme.of(context).colorScheme),
  ),
);
''';
