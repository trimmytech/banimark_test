import 'package:flutter/material.dart';

import 'core/settings.dart';
import 'demos/bottom_sheet_demo.dart';
import 'demos/conversation_tools_demo.dart';
import 'demos/custom_bubbles_demo.dart';
import 'demos/events_demo.dart';
import 'demos/full_screen_demo.dart';
import 'demos/headless_demo.dart';
import 'demos/identity_demo.dart';
import 'demos/launcher_playground.dart';
import 'demos/tabs_demo.dart';
import 'demos/theme_playground.dart';
import 'server_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = Demo.of(context);
    Widget tile(IconData icon, String title, String sub, Widget Function() page) => Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: ListTile(
            leading: CircleAvatar(child: Icon(icon, size: 20)),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text(sub),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => page())),
          ),
        );
    Widget head(String t) => Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 6),
          child: Text(t.toUpperCase(), style: TextStyle(fontSize: 12, letterSpacing: .8, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary)),
        );
    return Scaffold(
      appBar: AppBar(title: const Text('Banimark Test')),
      body: ListView(padding: const EdgeInsets.only(bottom: 32), children: [
        Card(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: ListTile(
            leading: const Icon(Icons.dns_rounded),
            title: Text(s.baseUrl, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text('${s.runtime == 'standalone' ? 'Standalone' : 'Laravel'} desk'
                '${s.token.isNotEmpty ? ' · signed-in token' : s.visitor != null ? ' · as ${s.name.isNotEmpty ? s.name : s.email}' : ' · guest'}'
                '${s.globalLauncher ? ' · bubble on every screen' : ''}'),
            trailing: const Icon(Icons.settings_rounded),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ServerScreen())),
          ),
        ),
        head('Put the chat in your app'),
        tile(Icons.fullscreen_rounded, 'Full screen', 'BanimarkChat as its own page - with its header, or inside your AppBar', () => const FullScreenDemo()),
        tile(Icons.vertical_align_top_rounded, 'Bottom sheet', 'Slide up from a button, the most common set-up', () => const BottomSheetDemo()),
        tile(Icons.chat_bubble_rounded, 'Floating bubble', 'BanimarkLauncher: unread count, drag, close, comes back - every option', () => const LauncherPlayground()),
        tile(Icons.tab_rounded, 'In a tab', 'A "Support" tab with an unread badge, one conversation across tabs', () => const TabsDemo()),
        head('Make it yours'),
        tile(Icons.palette_rounded, 'Theme playground', 'Colours, dark mode, corners, spacing, every text - live, with the code', () => const ThemePlayground()),
        tile(Icons.forum_rounded, 'Custom message bubbles', 'bubbleBuilder: draw each message your way', () => const CustomBubblesDemo()),
        tile(Icons.build_rounded, 'Your own chat UI', 'BanimarkController only - no Banimark widgets at all', () => const HeadlessDemo()),
        head('Who is chatting'),
        tile(Icons.badge_rounded, 'Guest, known visitor, signed-in user', 'The three identities and what each one gets', () => const IdentityDemo()),
        head('Behaviour'),
        tile(Icons.notifications_active_rounded, 'Events and links', 'onStaffMessage, onOpenLink, the unread count', () => const EventsDemo()),
        tile(Icons.delete_sweep_rounded, 'Conversation tools', 'Delete (visitor), forget on logout, mark read, send from code', () => const ConversationToolsDemo()),
      ]),
    );
  }
}
