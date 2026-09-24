import 'package:banimark_flutter/banimark_flutter.dart';
import 'package:flutter/material.dart';

import '../core/demo_page.dart';
import '../core/settings.dart';

/// What your app can do with a conversation from code.
class ConversationToolsDemo extends StatefulWidget {
  const ConversationToolsDemo({super.key});
  @override
  State<ConversationToolsDemo> createState() => _ConversationToolsDemoState();
}

class _ConversationToolsDemoState extends State<ConversationToolsDemo> {
  BanimarkController? _c;
  bool _showChat = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_c != null) return;
    final s = Demo.of(context);
    _c = BanimarkController(config: s.config, visitor: s.visitor ?? const BanimarkVisitor(name: 'Test app user'))
      ..active = false
      ..addListener(() { if (mounted) setState(() {}); })
      ..init();
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  void _say(String t) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));

  @override
  Widget build(BuildContext context) {
    final c = _c!;
    final s = Demo.of(context);
    return DemoPage(
      title: 'Conversation tools',
      code: _code,
      body: ListView(padding: const EdgeInsets.only(bottom: 30), children: [
        Section('Right now', children: [
          ListTile(contentPadding: EdgeInsets.zero, title: const Text('Conversation id'), subtitle: SelectableText(c.sessionId.isEmpty ? '(none yet - send a message)' : c.sessionId)),
          ListTile(contentPadding: EdgeInsets.zero, title: const Text('Messages'), trailing: Text('${c.messages.length}')),
          ListTile(contentPadding: EdgeInsets.zero, title: const Text('Who answers'), trailing: Text(c.mode.name)),
          ListTile(contentPadding: EdgeInsets.zero, title: const Text('Unread replies from the team'), trailing: Text('${c.unread}')),
        ]),
        Section('Do something', children: [
          FilledButton.tonalIcon(
            icon: const Icon(Icons.send_rounded),
            label: const Text('Send "Hello from the test app"'),
            onPressed: () async { await c.send('Hello from the Banimark test app'); _say('Sent - the AI answer is in the thread'); },
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(icon: const Icon(Icons.mark_email_read_rounded), label: const Text('Mark as read'), onPressed: c.markRead),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Forget on this device (logout)'),
            onPressed: () async { await c.reset(); _say('Forgotten here only - the desk still has it, and a signed-in user gets it back'); },
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error, foregroundColor: Theme.of(context).colorScheme.onError),
            icon: const Icon(Icons.delete_forever_rounded),
            label: const Text('Delete the conversation (visitor)'),
            onPressed: c.sessionId.isEmpty
                ? null
                : () async {
                    final ok = await c.deleteConversation();
                    _say(ok ? 'Deleted: gone for the visitor; the team keeps it until it is erased (30 days)' : (c.error ?? 'Could not delete'));
                  },
          ),
        ]),
        Section('See it', children: [
          SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Show the chat below'), value: _showChat, onChanged: (v) { setState(() => _showChat = v); c.setActive(v); }),
          if (_showChat) SizedBox(height: 460, child: BanimarkChat(config: s.config, controller: c, followAdminAppearance: true)),
        ]),
      ]),
    );
  }
}

const _code = '''
final c = BanimarkController(config: BanimarkConfig.laravel('https://banimark.com'));
await c.init();                    // restore + start polling

await c.send('Hello');             // send from code (e.g. "Ask about order #123")
c.markRead();                      // the visitor has seen the replies (unread -> 0)

// Visitor deletes the conversation (the bin in the chat header does this too).
// On the desk it is SOFT: gone for the visitor, kept for the team until it is
// erased - 30 days by default, or never if the team keeps it.
final ok = await c.deleteConversation();

// Logout: forget it on THIS device only. The desk keeps it; a signed-in user
// gets it back on their next login.
await c.reset();

// Pace of the poll: on screen = the desk's "check every" seconds;
// off screen = its "while closed" seconds (for the unread count).
c.setActive(false);
''';
