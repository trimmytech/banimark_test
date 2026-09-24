import 'package:banimark_flutter/banimark_flutter.dart';
import 'package:flutter/material.dart';

import '../core/demo_page.dart';
import '../core/settings.dart';

class BottomSheetDemo extends StatelessWidget {
  const BottomSheetDemo({super.key});

  void _open(BuildContext context, double height) {
    final s = Demo.of(context);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => FractionallySizedBox(
        heightFactor: height,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          child: BanimarkChat(
            config: s.config,
            visitor: s.visitor,
            followAdminAppearance: true,
            onClose: () => Navigator.of(ctx).pop(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => DemoPage(
        title: 'Bottom sheet',
        code: _code,
        body: ListView(padding: const EdgeInsets.all(16), children: [
          const Text('The chat slides up over the current screen. The conversation continues each time - it is kept on the device.'),
          const SizedBox(height: 16),
          FilledButton.icon(icon: const Icon(Icons.support_agent_rounded), label: const Text('Tall sheet (92%)'), onPressed: () => _open(context, .92)),
          const SizedBox(height: 10),
          FilledButton.tonalIcon(icon: const Icon(Icons.expand_less_rounded), label: const Text('Half sheet (60%)'), onPressed: () => _open(context, .6)),
        ]),
      );
}

const _code = '''
FloatingActionButton.extended(
  icon: const Icon(Icons.support_agent_rounded),
  label: const Text('Support'),
  onPressed: () => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => FractionallySizedBox(
      heightFactor: .92,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        child: BanimarkChat(
          config: BanimarkConfig.laravel('https://banimark.com'),
          followAdminAppearance: true,
          onClose: () => Navigator.of(ctx).pop(),
        ),
      ),
    ),
  ),
)
''';
