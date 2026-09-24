import 'package:banimark_flutter/banimark_flutter.dart';
import 'package:flutter/material.dart';

import '../core/demo_page.dart';
import '../core/settings.dart';

/// Hooks for your app: a reply from the team arrives (show a notification,
/// vibrate), a link in a message is tapped (open it in-app, log it).
class EventsDemo extends StatefulWidget {
  const EventsDemo({super.key});
  @override
  State<EventsDemo> createState() => _EventsDemoState();
}

class _EventsDemoState extends State<EventsDemo> {
  BanimarkController? _c;
  final List<String> _log = [];

  void _add(String line) {
    final t = TimeOfDay.now().format(context);
    setState(() => _log.insert(0, '$t  $line'));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_c != null) return;
    final s = Demo.of(context);
    _c = BanimarkController(config: s.config, visitor: s.visitor)
      ..onStaffMessage = (m) {
        _add('onStaffMessage: ${m.sender.name} said "${m.text}"');
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('New reply: ${m.text}')));
      }
      ..init();
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  void _link(Uri uri) {
    _add('onOpenLink: $uri');
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('A link was tapped'),
        content: Text('$uri\n\nYour app decides: open it in a webview, route to a screen, or hand it to the browser.'),
        actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = Demo.of(context);
    return DemoPage(
      title: 'Events and links',
      code: _code,
      body: Column(children: [
        Container(
          width: double.infinity,
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          padding: const EdgeInsets.all(10),
          child: Text('Try: ask the assistant for a link (e.g. "send me your website"), or reply from the desk\'s inbox and watch the log.',
              style: Theme.of(context).textTheme.bodySmall),
        ),
        SizedBox(
          height: 110,
          child: _log.isEmpty
              ? const Center(child: Text('Events will appear here'))
              : ListView(padding: const EdgeInsets.all(8), children: [for (final l in _log) Text(l, style: const TextStyle(fontFamily: 'monospace', fontSize: 12))]),
        ),
        const Divider(height: 1),
        Expanded(child: BanimarkChat(config: s.config, controller: _c, showHeader: false, onOpenLink: _link)),
      ]),
    );
  }
}

const _code = '''
final c = BanimarkController(config: BanimarkConfig.laravel('https://banimark.com'));

// A reply from your TEAM (a human, not the AI) arrived over the poll:
c.onStaffMessage = (message) {
  showLocalNotification(title: 'Support', body: message.text);
  HapticFeedback.mediumImpact();
};

// c.unread counts those replies until the visitor looks (c.markRead()).
c.addListener(() => updateAppIconBadge(c.unread));

BanimarkChat(
  config: c.config,
  controller: c,
  // Default: the device browser. Take it over to open links in-app:
  onOpenLink: (uri) {
    if (uri.host == 'myshop.com') {
      Navigator.of(context).pushNamed(uri.path);   // a link to your own app
    } else {
      launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    }
  },
)
''';
