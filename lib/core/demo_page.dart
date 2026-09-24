import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Every demo page: a title, what it shows, and a "Code" button with the
/// exact snippet to paste into an app.
class DemoPage extends StatelessWidget {
  const DemoPage({super.key, required this.title, required this.body, this.code, this.actions = const [], this.bottom});
  final String title;
  final Widget body;
  final String? code;
  final List<Widget> actions;
  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(title),
          bottom: bottom,
          actions: [
            ...actions,
            if (code != null) IconButton(tooltip: 'Show the code', icon: const Icon(Icons.code_rounded), onPressed: () => showCode(context, title, code!)),
          ],
        ),
        body: body,
      );
}

void showCode(BuildContext context, String title, String code) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: .75,
      maxChildSize: .95,
      builder: (ctx, scroll) => Column(children: [
        ListTile(
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: const Text('Copy and paste into your app'),
          trailing: FilledButton.tonalIcon(
            icon: const Icon(Icons.copy_rounded, size: 18),
            label: const Text('Copy'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: code.trim()));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code copied')));
              Navigator.of(ctx).pop();
            },
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: SingleChildScrollView(
            controller: scroll,
            padding: const EdgeInsets.all(16),
            scrollDirection: Axis.vertical,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SelectableText(code.trim(), style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5, height: 1.45)),
            ),
          ),
        ),
      ]),
    ),
  );
}

/// A labelled section in a controls list.
class Section extends StatelessWidget {
  const Section(this.title, {super.key, required this.children, this.hint});
  final String title;
  final String? hint;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 4),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title.toUpperCase(), style: TextStyle(fontSize: 11.5, letterSpacing: .8, fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.primary)),
          if (hint != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(hint!, style: Theme.of(context).textTheme.bodySmall)),
          const SizedBox(height: 6),
          ...children,
        ]),
      );
}
