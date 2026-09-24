import 'dart:convert';

import 'package:banimark_flutter/banimark_flutter.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'core/demo_page.dart';
import 'core/settings.dart';

/// Where the app points, who it pretends to be, and a live check of the desk:
/// is it reachable, activated, which version-features does it speak.
class ServerScreen extends StatefulWidget {
  const ServerScreen({super.key});
  @override
  State<ServerScreen> createState() => _ServerScreenState();
}

class _ServerScreenState extends State<ServerScreen> {
  late final TextEditingController _url, _token, _name, _email, _phone;
  String _runtime = 'laravel';
  bool _checking = false;
  List<(String, String, bool?)> _report = [];
  String _raw = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return; // fill the fields once, not on every settings change
    _ready = true;
    final s = Demo.of(context);
    _url = TextEditingController(text: s.baseUrl);
    _token = TextEditingController(text: s.token);
    _name = TextEditingController(text: s.name);
    _email = TextEditingController(text: s.email);
    _phone = TextEditingController(text: s.phone);
    _runtime = s.runtime;
  }

  bool _ready = false;

  Future<void> _save() async {
    await Demo.of(context).save(baseUrl: _url.text, runtime: _runtime, token: _token.text, name: _name.text, email: _email.text, phone: _phone.text);
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
  }

  Future<void> _check() async {
    await _save();
    if (!mounted) return;
    final cfg = Demo.of(context).config;
    setState(() { _checking = true; _report = []; _raw = ''; });
    final out = <(String, String, bool?)>[];
    final base = cfg.chat.toString().replaceFirst(RegExp(r'/chat$'), '');
    try {
      final res = await http.get(Uri.parse('$base/widget/appearance'), headers: {'Accept': 'application/json'}).timeout(const Duration(seconds: 12));
      out.add(('Appearance endpoint', 'HTTP ${res.statusCode}', res.statusCode == 200));
      if (res.statusCode == 200) {
        final j = jsonDecode(res.body) as Map<String, dynamic>;
        _raw = const JsonEncoder.withIndent('  ').convert(j);
        out.add(('Chat is live (activated)', j['enabled'] == false ? 'No - start a trial or enter a key on the desk' : 'Yes', j['enabled'] != false));
        out.add(('Title', '${j['title']}', null));
        out.add(('Accent colour', '${j['color']}', null));
        out.add(('Theme', '${j['theme']}', null));
        out.add(('File sharing', j['files'] == false ? 'off' : 'on', null));
        out.add(('Check for replies (open)', '${j['poll_seconds']} s', null));
        out.add(('Unread polling while closed', j['poll_idle_seconds'] == null ? 'not sent - desk older than 0.30.10 (the app uses 30 s)' : '${j['poll_idle_seconds']} s', j['poll_idle_seconds'] != null));
        out.add(('Bubble comes back after', j['launcher_reappear_minutes'] == null ? 'not sent - desk older than 0.30.10 (the app uses 10 min)' : '${j['launcher_reappear_minutes']} min', j['launcher_reappear_minutes'] != null));
      }
      // an unknown session id asks nothing of anyone: a new desk answers JSON, an old one 404s
      final del = await http.post(Uri.parse('${cfg.chat}/delete'), headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
          body: jsonEncode({'session_id': 'not-a-session'})).timeout(const Duration(seconds: 12));
      final speaks = del.statusCode != 404 && (del.headers['content-type'] ?? '').contains('json');
      out.add(('Visitor can delete a conversation', speaks ? 'Yes' : 'Not on this desk yet (needs 0.30.10) - HTTP ${del.statusCode}', speaks));
      final a = await BanimarkAppearance.fetch(cfg);
      out.add(('SDK read the look', a == null ? 'No' : 'Yes', a != null));
    } catch (e) {
      out.add(('Could not reach the desk', '$e', false));
    }
    if (mounted) setState(() { _checking = false; _report = out; });
  }

  @override
  Widget build(BuildContext context) {
    final s = Demo.of(context);
    InputDecoration dec(String l, [String? h]) => InputDecoration(labelText: l, helperText: h, border: const OutlineInputBorder(), isDense: true);
    return DemoPage(
      title: 'Server',
      code: _code(s),
      body: ListView(padding: const EdgeInsets.only(bottom: 40), children: [
        Section('The desk', hint: 'The site running Banimark. The web install is on banimark.com.', children: [
          TextField(controller: _url, decoration: dec('Address', 'https://banimark.com  ·  standalone: the banimark.php URL'), keyboardType: TextInputType.url),
          const SizedBox(height: 10),
          SegmentedButton<String>(
            segments: const [ButtonSegment(value: 'laravel', label: Text('Laravel')), ButtonSegment(value: 'standalone', label: Text('Standalone PHP'))],
            selected: {_runtime},
            onSelectionChanged: (v) => setState(() => _runtime = v.first),
          ),
        ]),
        Section('Who the app is', hint: 'Empty = a guest. A name/email = a known visitor. A token = a signed-in user (the AI can then look up THEIR data).', children: [
          TextField(controller: _name, decoration: dec('Name')),
          const SizedBox(height: 8),
          TextField(controller: _email, decoration: dec('Email'), keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 8),
          TextField(controller: _phone, decoration: dec('Phone'), keyboardType: TextInputType.phone),
          const SizedBox(height: 8),
          TextField(controller: _token, decoration: dec('Signed visitor token (optional)', 'Minted by the host server with VisitorToken::mint(...)'), maxLines: 2),
        ]),
        Section('Everywhere', children: [
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Floating bubble on every screen'),
            subtitle: const Text('BanimarkLauncher in MaterialApp.builder (needs navigatorKey)'),
            value: s.globalLauncher,
            onChanged: (v) => s.save(globalLauncher: v),
          ),
          OutlinedButton.icon(
            icon: const Icon(Icons.cleaning_services_rounded),
            label: const Text('Forget everything on this device'),
            onPressed: () async {
              await s.forgetEverything();
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Conversations, bubble position and "hidden until" cleared')));
            },
          ),
        ]),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
          child: Row(children: [
            Expanded(child: OutlinedButton(onPressed: _save, child: const Text('Save'))),
            const SizedBox(width: 10),
            Expanded(child: FilledButton.icon(onPressed: _checking ? null : _check, icon: _checking ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.wifi_tethering_rounded), label: const Text('Save & check'))),
          ]),
        ),
        if (_report.isNotEmpty)
          Section('What the desk says', children: [
            for (final r in _report)
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(r.$3 == null ? Icons.info_outline_rounded : (r.$3! ? Icons.check_circle_rounded : Icons.error_rounded),
                    color: r.$3 == null ? null : (r.$3! ? Colors.green : Colors.orange)),
                title: Text(r.$1),
                subtitle: Text(r.$2),
              ),
            if (_raw.isNotEmpty)
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text('Raw appearance JSON'),
                children: [SelectableText(_raw, style: const TextStyle(fontFamily: 'monospace', fontSize: 12))],
              ),
          ]),
      ]),
    );
  }

  String _code(DemoSettings s) => '''
// Laravel desk
final config = BanimarkConfig.laravel('${s.baseUrl}');

// Standalone desk (plain PHP, WordPress, CodeIgniter...): the banimark.php URL
final config2 = BanimarkConfig.standalone('https://yoursite.com/banimark.php');

// A signed-in user: YOUR server mints the token (PHP):
//   \\Banimark\\Identity\\VisitorToken::mint(['user_id' => \$user->id], config('banimark.identity_secret'));
// and the app passes it on - the AI then scopes every lookup to that user.
final config3 = BanimarkConfig.laravel('${s.baseUrl}', token: tokenFromYourLogin);

// A guest you already know (skips the "who are you" form)
const visitor = BanimarkVisitor(name: 'Ada', email: 'ada@example.com', phone: '+234...');
''';
}
