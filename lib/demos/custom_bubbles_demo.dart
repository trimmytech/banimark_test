import 'package:banimark_flutter/banimark_flutter.dart';
import 'package:flutter/material.dart';

import '../core/demo_page.dart';
import '../core/settings.dart';

/// bubbleBuilder: every message drawn your way - here, a messenger style with
/// a name and a time on each bubble. Return null-free widgets; the SDK still
/// handles the thread, typing dots, files and retries around them.
class CustomBubblesDemo extends StatelessWidget {
  const CustomBubblesDemo({super.key});

  static Widget bubble(BuildContext context, BanimarkMessage m, BanimarkTheme t) {
    final mine = m.sender == BanimarkSender.user;
    final who = switch (m.sender) { BanimarkSender.user => 'You', BanimarkSender.agent => 'Support team', _ => 'Assistant' };
    final time = '${m.at.hour.toString().padLeft(2, '0')}:${m.at.minute.toString().padLeft(2, '0')}';
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .78),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
        decoration: BoxDecoration(
          color: mine ? t.primary : (m.sender == BanimarkSender.agent ? const Color(0xFFFFF4D6) : t.surface),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14), topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(mine ? 14 : 2), bottomRight: Radius.circular(mine ? 2 : 14),
          ),
          border: mine ? null : Border.all(color: t.border),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (!mine) Text(who, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: m.sender == BanimarkSender.agent ? const Color(0xFFB7791F) : t.primary)),
          BanimarkMarkdown(
            text: m.text.isEmpty && m.files.isNotEmpty ? '📎 ${m.files.map((f) => f.name).join(', ')}' : m.text,
            style: TextStyle(color: mine ? t.onPrimary : t.text, fontSize: 14.5, height: 1.35),
            linkColor: mine ? t.onPrimary : t.primary,
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Text(m.failed ? 'Not sent - tap to retry' : (m.pending ? 'Sending…' : time),
                style: TextStyle(fontSize: 10.5, color: mine ? t.onPrimary.withValues(alpha: .75) : t.muted)),
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = Demo.of(context);
    return DemoPage(
      title: 'Custom bubbles',
      code: _code,
      body: BanimarkChat(config: s.config, visitor: s.visitor, showHeader: false, bubbleBuilder: bubble),
    );
  }
}

const _code = '''
BanimarkChat(
  config: BanimarkConfig.laravel('https://banimark.com'),
  bubbleBuilder: (context, message, theme) {
    final mine = message.sender == BanimarkSender.user;
    final who = switch (message.sender) {
      BanimarkSender.user => 'You',
      BanimarkSender.agent => 'Support team',   // a human from the desk
      _ => 'Assistant',                          // the AI
    };
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: mine ? theme.primary : theme.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (!mine) Text(who, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
          // links, **bold**, lists - the same markdown the SDK uses
          BanimarkMarkdown(
            text: message.text,
            style: TextStyle(color: mine ? theme.onPrimary : theme.text),
            linkColor: mine ? theme.onPrimary : theme.primary,
          ),
          if (message.failed) const Text('Not sent - tap to retry', style: TextStyle(fontSize: 11)),
        ]),
      ),
    );
  },
)
''';
