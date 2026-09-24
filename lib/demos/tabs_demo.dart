import 'package:banimark_flutter/banimark_flutter.dart';
import 'package:flutter/material.dart';

import '../core/demo_page.dart';
import '../core/settings.dart';

/// A "Support" tab in a bottom navigation bar: one controller for the whole
/// app shell, so the unread badge counts while the visitor is on another tab
/// and the conversation is still there when they come back.
class TabsDemo extends StatefulWidget {
  const TabsDemo({super.key});
  @override
  State<TabsDemo> createState() => _TabsDemoState();
}

class _TabsDemoState extends State<TabsDemo> {
  BanimarkController? _c;
  int _tab = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_c != null) return;
    final s = Demo.of(context);
    _c = BanimarkController(config: s.config, visitor: s.visitor)
      ..active = false // not on screen yet: poll slowly, only for the badge
      ..addListener(() { if (mounted) setState(() {}); })
      ..init();
  }

  @override
  void dispose() {
    _c?.dispose();
    super.dispose();
  }

  void _go(int i) {
    setState(() => _tab = i);
    _c!.setActive(i == 1); // on the Support tab: normal pace, the heartbeat staff see
    if (i == 1) _c!.markRead();
  }

  @override
  Widget build(BuildContext context) {
    final s = Demo.of(context);
    final unread = _c!.unread;
    return DemoPage(
      title: 'In a tab',
      code: _code,
      body: Scaffold(
        // NOT an IndexedStack: a chat built off screen would mark every reply as
        // read. The controller keeps the conversation; the page is rebuilt on return.
        body: switch (_tab) {
          1 => BanimarkChat(config: s.config, controller: _c, showHeader: false, followAdminAppearance: true),
          2 => const Center(child: Text('Profile')),
          _ => const Center(child: Text('Your app\'s home screen.\n\nWhen the team replies, the Support tab shows a badge.', textAlign: TextAlign.center)),
        },
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: _go,
          destinations: [
            const NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
            NavigationDestination(
              icon: Badge(isLabelVisible: unread > 0, label: Text(unread > 9 ? '9+' : '$unread'), child: const Icon(Icons.support_agent_outlined)),
              label: 'Support',
            ),
            const NavigationDestination(icon: Icon(Icons.person_outline_rounded), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}

const _code = '''
// One controller for the app shell (create it once, e.g. in your root State).
final support = BanimarkController(config: BanimarkConfig.laravel('https://banimark.com'))
  ..active = false      // chat not on screen: poll slowly, just for the badge
  ..init();

// Tab switch:
void onTab(int i) {
  support.setActive(i == supportTab);  // on screen: normal pace (staff see "online")
  if (i == supportTab) support.markRead();
}

// The tab:
NavigationDestination(
  icon: ListenableBuilder(
    listenable: support,
    builder: (_, __) => Badge(
      isLabelVisible: support.unread > 0,
      label: Text(support.unread > 9 ? '9+' : '\${support.unread}'),
      child: const Icon(Icons.support_agent_outlined),
    ),
  ),
  label: 'Support',
),

// The page - build it ONLY while its tab is showing (a chat on screen marks
// replies as read; an IndexedStack would build it off screen too). The
// controller keeps the conversation between visits.
if (tab == supportTab) BanimarkChat(config: support.config, controller: support, showHeader: false)
''';
