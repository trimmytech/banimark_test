import 'package:banimark_flutter/banimark_flutter.dart';
import 'package:flutter/material.dart';

import '../core/demo_page.dart';
import '../core/settings.dart';

/// The three ways a visitor can be known. Each keeps its OWN conversation on
/// the device (a separate storageKey), so you can compare them side by side.
class IdentityDemo extends StatelessWidget {
  const IdentityDemo({super.key});

  void _open(BuildContext context, String title, BanimarkController c, {bool askGuest = true}) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => _Chat(title: title, controller: c, askGuest: askGuest)));
  }

  @override
  Widget build(BuildContext context) {
    final s = Demo.of(context);
    Widget card(IconData icon, String title, String body, VoidCallback? go, {String? why}) => Card(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Icon(icon), const SizedBox(width: 10), Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)))]),
              const SizedBox(height: 6),
              Text(body),
              if (why != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text(why, style: const TextStyle(color: Colors.orange))),
              const SizedBox(height: 10),
              FilledButton.tonal(onPressed: go, child: const Text('Open this chat')),
            ]),
          ),
        );
    return DemoPage(
      title: 'Who is chatting',
      code: _code,
      body: ListView(padding: const EdgeInsets.only(bottom: 30), children: [
        card(Icons.person_outline_rounded, 'Guest',
            'Nobody is known. The chat asks for the details the desk owner chose (name, email, phone - each off, optional or required) before the first message.',
            () => _open(context, 'Guest', BanimarkController(config: s.configWith(withToken: false), storageKey: 'demo_chat_guest'))),
        card(Icons.badge_outlined, 'Known visitor',
            'Your app already knows their name and email, so there is no form. The team sees who it is and can email them if they leave.',
            s.visitor == null ? null : () => _open(context, 'Known visitor', BanimarkController(config: s.configWith(withToken: false), visitor: s.visitor, storageKey: 'demo_chat_known')),
            why: s.visitor == null ? 'Add a name or email on the Server screen first.' : null),
        card(Icons.verified_user_outlined, 'Signed-in user (token)',
            'Your server signs who they are (VisitorToken). The AI\'s lookups are then scoped to THIS user - "where is my order?" only ever finds their orders. The same person on another phone continues the same conversation.',
            s.token.isEmpty ? null : () => _open(context, 'Signed-in user', BanimarkController(config: s.config, storageKey: 'demo_chat_token'), askGuest: false),
            why: s.token.isEmpty ? 'Paste a token on the Server screen first (see the code for how your server makes one).' : null),
      ]),
    );
  }
}

class _Chat extends StatefulWidget {
  const _Chat({required this.title, required this.controller, required this.askGuest});
  final String title;
  final BanimarkController controller;
  final bool askGuest;
  @override
  State<_Chat> createState() => _ChatState();
}

class _ChatState extends State<_Chat> {
  @override
  void initState() {
    super.initState();
    widget.controller.init();
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: BanimarkChat(config: widget.controller.config, controller: widget.controller, showHeader: false, askGuestDetails: widget.askGuest, followAdminAppearance: true),
      );
}

const _code = r'''
// 1. Guest - the chat asks who they are (fields set on the desk's Widget page)
BanimarkChat(config: BanimarkConfig.laravel('https://banimark.com'))

// 2. Known visitor - no form
BanimarkChat(
  config: BanimarkConfig.laravel('https://banimark.com'),
  visitor: BanimarkVisitor(name: user.name, email: user.email, phone: user.phone),
)

// 3. Signed-in user - YOUR server signs the identity; the AI's tools scope
//    every lookup to it (the app can never widen it).
//
//    Laravel (e.g. in your login response or GET /me/banimark-token):
//      use Banimark\Identity\VisitorToken;
//      return ['banimark_token' => VisitorToken::mint(
//          ['user_id' => $user->id, 'name' => $user->name, 'email' => $user->email],
//          config('banimark.identity_secret'),
//          86400,                         // lifetime in seconds
//      )];
//
//    Flutter:
BanimarkChat(
  config: BanimarkConfig.laravel('https://banimark.com', token: me.banimarkToken),
)

// Different users on one phone? Give each its own storageKey, and call
// controller.reset() on logout so the next person starts fresh.
BanimarkController(config: config, storageKey: 'banimark_${user.id}')
''';
