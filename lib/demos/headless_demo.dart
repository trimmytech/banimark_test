import 'package:banimark_flutter/banimark_flutter.dart';
import 'package:flutter/material.dart';

import '../core/demo_page.dart';
import '../core/settings.dart';

/// No Banimark widgets at all: BanimarkController drives a chat UI you build
/// yourself. It restores the conversation, sends, polls for your team's
/// replies, and tells you when something changed.
class HeadlessDemo extends StatefulWidget {
  const HeadlessDemo({super.key});
  @override
  State<HeadlessDemo> createState() => _HeadlessDemoState();
}

class _HeadlessDemoState extends State<HeadlessDemo> {
  BanimarkController? _c;
  final _input = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_c != null) return;
    final s = Demo.of(context);
    _c = BanimarkController(config: s.config, visitor: s.visitor ?? const BanimarkVisitor(name: 'Test app user'))
      ..addListener(() { if (mounted) setState(() {}); })
      ..init();
  }

  @override
  void dispose() {
    _c?.dispose();
    _input.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final t = _input.text;
    _input.clear();
    await _c!.send(t);
  }

  @override
  Widget build(BuildContext context) {
    final c = _c!;
    final scheme = Theme.of(context).colorScheme;
    return DemoPage(
      title: 'Your own chat UI',
      code: _code,
      body: Column(children: [
        Material(
          color: scheme.surfaceContainerHighest,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Wrap(spacing: 8, runSpacing: 4, children: [
              Chip(label: Text('mode: ${c.mode.name}')),
              if (c.thinking) const Chip(label: Text('AI is thinking…')),
              if (c.agentTyping) const Chip(label: Text('a person is typing…')),
              Chip(label: Text('unread: ${c.unread}')),
              if (c.hasMore) ActionChip(label: const Text('load earlier'), onPressed: c.loadEarlier),
            ]),
          ),
        ),
        if (c.error != null) MaterialBanner(content: Text(c.error!), actions: [TextButton(onPressed: () => setState(() => c.error = null), child: const Text('OK'))]),
        Expanded(
          child: c.loading
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: c.messages.length,
                  itemBuilder: (_, i) {
                    final m = c.messages[i];
                    final mine = m.sender == BanimarkSender.user;
                    return ListTile(
                      dense: true,
                      leading: Icon(mine ? Icons.person_rounded : (m.sender == BanimarkSender.agent ? Icons.support_agent_rounded : Icons.smart_toy_rounded)),
                      title: Text(m.text.isEmpty ? '(${m.files.length} file)' : m.text),
                      subtitle: Text('${m.sender.name}${m.pending ? ' · sending' : ''}${m.failed ? ' · failed' : ''}'),
                      trailing: m.failed ? IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: () => c.retry(m)) : null,
                    );
                  },
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(children: [
              Expanded(child: TextField(controller: _input, onChanged: (_) => c.typing(), onSubmitted: (_) => _send(), decoration: const InputDecoration(hintText: 'Message', border: OutlineInputBorder(), isDense: true))),
              const SizedBox(width: 8),
              IconButton.filled(onPressed: _send, icon: const Icon(Icons.send_rounded)),
            ]),
          ),
        ),
      ]),
    );
  }
}

const _code = '''
class MySupportScreen extends StatefulWidget { ... }

class _MySupportScreenState extends State<MySupportScreen> {
  late final BanimarkController c = BanimarkController(
    config: BanimarkConfig.laravel('https://banimark.com'),
    visitor: const BanimarkVisitor(name: 'Ada', email: 'ada@example.com'),
  );

  @override
  void initState() {
    super.initState();
    c.addListener(() => setState(() {}));   // redraw on every change
    c.onStaffMessage = (m) => showMyNotification(m.text);
    c.init();                               // restore the conversation + start polling
  }

  @override
  void dispose() { c.dispose(); super.dispose(); }

  // c.messages        - the thread (sender: user / assistant / agent)
  // c.send(text)      - send (attach files first with c.attach(...))
  // c.typing()        - call from onChanged: staff see "typing…"
  // c.thinking        - the AI is answering        c.agentTyping - a person is typing
  // c.mode            - ai / agent / closed        c.unread      - replies not yet seen
  // c.hasMore + c.loadEarlier()                    c.retry(failedMessage)
  // c.deleteConversation()                         c.reset()  (forget on logout)
}
''';
