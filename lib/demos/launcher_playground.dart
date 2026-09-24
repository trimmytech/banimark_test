import 'package:banimark_flutter/banimark_flutter.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/demo_page.dart';
import '../core/settings.dart';

/// Every BanimarkLauncher option, then a pretend shop screen to try it on.
class LauncherPlayground extends StatefulWidget {
  const LauncherPlayground({super.key});
  @override
  State<LauncherPlayground> createState() => _LauncherPlaygroundState();
}

class _LauncherPlaygroundState extends State<LauncherPlayground> {
  static const _key = 'banimark_launcher_demo';
  Alignment _start = Alignment.bottomRight;
  double _size = 56;
  bool _dismissible = true;
  int? _reappear; // minutes; null = the desk's setting
  int? _idle; // seconds; null = the desk's setting
  bool _customBubble = false;
  bool _followAdmin = true;

  static const _corners = {
    'Bottom right': Alignment.bottomRight,
    'Bottom left': Alignment.bottomLeft,
    'Top right': Alignment.topRight,
    'Middle left': Alignment.centerLeft,
  };

  Future<void> _resetSaved() async {
    final p = await SharedPreferences.getInstance();
    for (final k in p.getKeys().where((k) => k.startsWith(_key))) {
      await p.remove(k);
    }
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved position and "hidden until" cleared')));
  }

  String get _code {
    final corner = _corners.entries.firstWhere((e) => e.value == _start).key;
    return '''
// Wrap one screen...
BanimarkLauncher(
  config: BanimarkConfig.laravel('https://banimark.com'),
  followAdminAppearance: $_followAdmin,${_start != Alignment.bottomRight ? '\n  initialAlignment: Alignment.${_alignName(_start)}, // $corner' : ''}${_size != 56 ? '\n  size: ${_size.round()},' : ''}${!_dismissible ? '\n  dismissible: false,' : ''}${_reappear != null ? '\n  reappearAfter: ${_reappear == 0 ? 'Duration.zero, // back when the app is opened again' : 'const Duration(minutes: $_reappear),'}' : ''}${_idle != null ? '\n  idlePollEvery: const Duration(seconds: $_idle),' : ''}${_customBubble ? '''
  bubbleBuilder: (context, unread) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(30)),
    child: const Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.support_agent_rounded, color: Colors.white, size: 20),
      SizedBox(width: 8),
      Text('Help', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
    ]),
  ),''' : ''}
  child: const MyShopScreen(),
)

// ...or every screen of the app. MaterialApp.builder is ABOVE the Navigator,
// so give both the same navigatorKey:
final nav = GlobalKey<NavigatorState>();
MaterialApp(
  navigatorKey: nav,
  builder: (context, child) => BanimarkLauncher(
    config: BanimarkConfig.laravel('https://banimark.com'),
    navigatorKey: nav,
    child: child!,
  ),
  home: const HomeScreen(),
);

// Unread count (9+), drag anywhere (remembered), the x to hide it, and when it
// comes back are all built in. The desk owner sets the polling interval and
// the "bring it back after" minutes on the Widget page.
''';
  }

  static String _alignName(Alignment a) => a == Alignment.bottomLeft ? 'bottomLeft' : a == Alignment.topRight ? 'topRight' : a == Alignment.centerLeft ? 'centerLeft' : 'bottomRight';

  @override
  Widget build(BuildContext context) => DemoPage(
        title: 'Floating bubble',
        code: _code,
        body: ListView(padding: const EdgeInsets.only(bottom: 40), children: [
          Section('Where it starts', hint: 'Drag it anywhere once it is on screen - the spot is remembered on the device.', children: [
            Wrap(spacing: 8, children: [
              for (final e in _corners.entries)
                ChoiceChip(label: Text(e.key), selected: _start == e.value, onSelected: (_) => setState(() => _start = e.value)),
            ]),
          ]),
          Section('Size', children: [
            Slider(value: _size, min: 44, max: 76, divisions: 8, label: '${_size.round()}', onChanged: (v) => setState(() => _size = v)),
          ]),
          Section('Closing it', children: [
            SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Show the small ×'), value: _dismissible, onChanged: (v) => setState(() => _dismissible = v)),
            DropdownButtonFormField<int?>(
              isExpanded: true, // long choices wrap instead of overflowing on a phone
              initialValue: _reappear,
              decoration: const InputDecoration(labelText: 'Comes back after', border: OutlineInputBorder(), isDense: true),
              items: const [
                DropdownMenuItem(value: null, child: Text("The desk's setting (Widget page)")),
                DropdownMenuItem(value: 1, child: Text('1 minute (to test)')),
                DropdownMenuItem(value: 10, child: Text('10 minutes')),
                DropdownMenuItem(value: 60, child: Text('1 hour')),
                DropdownMenuItem(value: 0, child: Text('Not until the app is opened again')),
              ],
              onChanged: (v) => setState(() => _reappear = v),
            ),
            const Padding(padding: EdgeInsets.only(top: 6), child: Text('A reply from your team always brings it back at once.', style: TextStyle(fontSize: 12))),
          ]),
          Section('Unread count', hint: 'While the chat is closed the bubble still checks for replies, and shows how many (9+ past nine).', children: [
            DropdownButtonFormField<int?>(
              isExpanded: true, // long choices wrap instead of overflowing on a phone
              initialValue: _idle,
              decoration: const InputDecoration(labelText: 'Check while closed every', border: OutlineInputBorder(), isDense: true),
              items: const [
                DropdownMenuItem(value: null, child: Text("The desk's setting (default 30 s)")),
                DropdownMenuItem(value: 10, child: Text('10 seconds (to test)')),
                DropdownMenuItem(value: 60, child: Text('1 minute')),
              ],
              onChanged: (v) => setState(() => _idle = v),
            ),
          ]),
          Section('Look', children: [
            SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Your own bubble (bubbleBuilder)'), subtitle: const Text('A black "Help" pill instead of the round icon'), value: _customBubble, onChanged: (v) => setState(() => _customBubble = v)),
            SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text("Follow the desk's look"), subtitle: const Text('Accent colour, and hide the bubble if the desk is not activated'), value: _followAdmin, onChanged: (v) => setState(() => _followAdmin = v)),
          ]),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              FilledButton.icon(
                icon: const Icon(Icons.storefront_rounded),
                label: const Text('Try it on a shop screen'),
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => _ShopScreen(options: this))),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(icon: const Icon(Icons.restart_alt_rounded), label: const Text('Reset saved position / "hidden until"'), onPressed: _resetSaved),
            ]),
          ),
        ]),
      );
}

/// A pretend shop screen, wrapped in the launcher with the chosen options.
class _ShopScreen extends StatelessWidget {
  const _ShopScreen({required this.options});
  final _LauncherPlaygroundState options;

  @override
  Widget build(BuildContext context) {
    final s = Demo.of(context);
    final o = options;
    return Scaffold(
      appBar: AppBar(title: const Text('Acme Shop')),
      body: BanimarkLauncher(
        config: s.config,
        visitor: s.visitor,
        storageKey: _LauncherPlaygroundState._key,
        initialAlignment: o._start,
        size: o._size,
        dismissible: o._dismissible,
        reappearAfter: o._reappear == null ? null : Duration(minutes: o._reappear!),
        idlePollEvery: o._idle == null ? null : Duration(seconds: o._idle!),
        followAdminAppearance: o._followAdmin,
        bubbleBuilder: !o._customBubble
            ? null
            : (context, unread) => Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(30)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.support_agent_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('Help', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  ]),
                ),
        child: GridView.count(
          padding: const EdgeInsets.all(12),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: .8,
          children: [
            for (final (name, price, icon) in const [
              ('Running shoes', '₦45,000', Icons.directions_run_rounded),
              ('Headphones', '₦32,500', Icons.headphones_rounded),
              ('Backpack', '₦18,000', Icons.backpack_rounded),
              ('Smart watch', '₦61,000', Icons.watch_rounded),
              ('Sunglasses', '₦12,000', Icons.wb_sunny_rounded),
              ('Water bottle', '₦6,500', Icons.local_drink_rounded),
            ])
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: Center(child: Icon(icon, size: 56, color: Theme.of(context).colorScheme.primary))),
                    Text(name, style: const TextStyle(fontWeight: FontWeight.w600)),
                    Text(price),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
