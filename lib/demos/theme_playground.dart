import 'package:banimark_flutter/banimark_flutter.dart';
import 'package:flutter/material.dart';

import '../core/demo_page.dart';
import '../core/settings.dart';

/// Every look option on BanimarkChat, live, with the matching code.
class ThemePlayground extends StatefulWidget {
  const ThemePlayground({super.key});
  @override
  State<ThemePlayground> createState() => _ThemePlaygroundState();
}

class _ThemePlaygroundState extends State<ThemePlayground> {
  BanimarkController? _c;
  String _base = 'light'; // light | dark | app
  Color? _accent;
  bool _compact = false;
  double _bubble = 18, _input = 24;
  bool _header = true, _emoji = true, _files = true, _guestForm = true, _followAdmin = false;
  final _title = TextEditingController(text: 'Acme Support');
  final _subtitle = TextEditingController(text: 'We usually reply in minutes');
  final _greeting = TextEditingController(text: 'Hi! 👋 Ask me about orders, delivery or refunds.');
  final _placeholder = TextEditingController(text: 'Type your question…');

  static const _accents = [Color(0xFF22B2A2), Color(0xFF6F04D9), Color(0xFF2A78D6), Color(0xFFE5484D), Color(0xFFF59E0B), Color(0xFF111827)];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_c != null) return;
    final s = Demo.of(context);
    // one controller for the playground: changing the look never loses the conversation
    _c = BanimarkController(config: s.config, visitor: s.visitor)..init();
  }

  @override
  void dispose() {
    _c?.dispose();
    for (final t in [_title, _subtitle, _greeting, _placeholder]) {
      t.dispose();
    }
    super.dispose();
  }

  BanimarkTheme _theme(BuildContext context) {
    final base = switch (_base) {
      'dark' => BanimarkTheme.dark,
      'app' => BanimarkTheme.fromScheme(Theme.of(context).colorScheme),
      _ => BanimarkTheme.light,
    };
    final a = _accent;
    final on = a == null ? null : (ThemeData.estimateBrightnessForColor(a) == Brightness.dark ? Colors.white : Colors.black);
    return base.copyWith(
      primary: a, onPrimary: on, userBubble: a, userBubbleText: on,
      compact: _compact, bubbleRadius: _bubble, inputRadius: _input,
      title: _title.text, subtitle: _subtitle.text, greeting: _greeting.text, placeholder: _placeholder.text,
    );
  }

  String get _code {
    String hex(Color c) => '0x${c.toARGB32().toRadixString(16).toUpperCase().padLeft(8, '0')}';
    final base = switch (_base) { 'dark' => 'BanimarkTheme.dark', 'app' => 'BanimarkTheme.fromScheme(Theme.of(context).colorScheme)', _ => 'BanimarkTheme.light' };
    final a = _accent;
    return '''
BanimarkChat(
  config: BanimarkConfig.laravel('https://banimark.com'),
  theme: $base.copyWith(${a == null ? '' : '''
    primary: const Color(${hex(a)}),
    userBubble: const Color(${hex(a)}),
    onPrimary: ${ThemeData.estimateBrightnessForColor(a) == Brightness.dark ? 'Colors.white' : 'Colors.black'},
    userBubbleText: ${ThemeData.estimateBrightnessForColor(a) == Brightness.dark ? 'Colors.white' : 'Colors.black'},'''}
    compact: $_compact,
    bubbleRadius: ${_bubble.round()},
    inputRadius: ${_input.round()},
    title: '${_title.text.replaceAll("'", "\\'")}',
    subtitle: '${_subtitle.text.replaceAll("'", "\\'")}',
    greeting: '${_greeting.text.replaceAll("'", "\\'")}',
    placeholder: '${_placeholder.text.replaceAll("'", "\\'")}',
    // every other string is here too: agentSubtitle, handoverLabel, guestTitle,
    // guestButton, retryLabel, deleteTitle, deleteButton, deletedNotice...
  ),
  showHeader: $_header,
  emoji: $_emoji,
  attachments: $_files,
  askGuestDetails: $_guestForm,
  followAdminAppearance: $_followAdmin, // true: the desk's colour/title/greeting win over the theme
)
''';
  }

  @override
  Widget build(BuildContext context) {
    final s = Demo.of(context);
    return DefaultTabController(
      length: 2,
      child: DemoPage(
        title: 'Theme playground',
        code: _code,
        bottom: const TabBar(tabs: [Tab(text: 'Preview'), Tab(text: 'Controls')]),
        body: TabBarView(physics: const NeverScrollableScrollPhysics(), children: [
          // structural toggles (header, emoji, files, form, follow) rebuild the chat;
          // colours and words just repaint it. The conversation lives in _c either way.
          BanimarkChat(
            key: ValueKey('$_header$_emoji$_files$_guestForm$_followAdmin'),
            config: s.config,
            visitor: s.visitor,
            controller: _c,
            theme: _theme(context),
            showHeader: _header,
            emoji: _emoji,
            attachments: _files,
            askGuestDetails: _guestForm,
            followAdminAppearance: _followAdmin,
          ),
          ListView(padding: const EdgeInsets.only(bottom: 40), children: [
            Section('Starting point', children: [
              SegmentedButton<String>(
                segments: const [ButtonSegment(value: 'light', label: Text('Light')), ButtonSegment(value: 'dark', label: Text('Dark')), ButtonSegment(value: 'app', label: Text('Your app'))],
                selected: {_base},
                onSelectionChanged: (v) => setState(() => _base = v.first),
              ),
            ]),
            Section('Accent colour', children: [
              Wrap(spacing: 10, runSpacing: 10, children: [
                ChoiceChip(label: const Text('Theme\'s own'), selected: _accent == null, onSelected: (_) => setState(() => _accent = null)),
                for (final c in _accents)
                  GestureDetector(
                    onTap: () => setState(() => _accent = c),
                    child: CircleAvatar(radius: 17, backgroundColor: c, child: _accent == c ? const Icon(Icons.check_rounded, color: Colors.white, size: 18) : null),
                  ),
              ]),
            ]),
            Section('Shape and spacing', children: [
              Text('Bubble corners: ${_bubble.round()}'),
              Slider(value: _bubble, min: 0, max: 26, divisions: 13, onChanged: (v) => setState(() => _bubble = v)),
              Text('Input corners: ${_input.round()}'),
              Slider(value: _input, min: 0, max: 30, divisions: 15, onChanged: (v) => setState(() => _input = v)),
              SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Compact spacing'), value: _compact, onChanged: (v) => setState(() => _compact = v)),
            ]),
            Section('Words', children: [
              for (final (label, ctl) in [('Title', _title), ('Subtitle', _subtitle), ('Greeting', _greeting), ('Placeholder', _placeholder)])
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(controller: ctl, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true), onChanged: (_) => setState(() {})),
                ),
            ]),
            Section('Parts', children: [
              SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Header'), value: _header, onChanged: (v) => setState(() => _header = v)),
              SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Emoji button'), value: _emoji, onChanged: (v) => setState(() => _emoji = v)),
              SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Attach files'), subtitle: const Text('The desk can also switch files off for everyone'), value: _files, onChanged: (v) => setState(() => _files = v)),
              SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Ask guests who they are'), subtitle: const Text('Only for guests - a token or a known visitor skips it'), value: _guestForm, onChanged: (v) => setState(() => _guestForm = v)),
              SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text("Follow the desk's look"), subtitle: const Text('The owner\'s colour, title, greeting and logo win over the choices above'), value: _followAdmin, onChanged: (v) => setState(() => _followAdmin = v)),
            ]),
          ]),
        ]),
      ),
    );
  }
}
