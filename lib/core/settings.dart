import 'package:banimark_flutter/banimark_flutter.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Where the test app points, and who it pretends to be. Saved on the
/// device, so it survives restarts. Every demo reads from here.
class DemoSettings extends ChangeNotifier {
  DemoSettings._(this._p);
  final SharedPreferences _p;

  static const defaultUrl = 'https://banimark.com';

  static Future<DemoSettings> load() async => DemoSettings._(await SharedPreferences.getInstance());

  /// Laravel host (`https://yourapp.com`) or the standalone entry point
  /// (`https://yourapp.com/banimark.php`).
  String get baseUrl => _p.getString('demo_url') ?? defaultUrl;
  /// 'laravel' or 'standalone'
  String get runtime => _p.getString('demo_runtime') ?? 'laravel';
  /// A signed VisitorToken minted by the host's server (optional).
  String get token => _p.getString('demo_token') ?? '';
  String get name => _p.getString('demo_name') ?? '';
  String get email => _p.getString('demo_email') ?? '';
  String get phone => _p.getString('demo_phone') ?? '';
  /// Put the floating bubble over EVERY screen of this app (MaterialApp.builder).
  bool get globalLauncher => _p.getBool('demo_global_launcher') ?? false;

  BanimarkConfig get config => configWith();

  BanimarkConfig configWith({bool withToken = true}) {
    final t = withToken && token.isNotEmpty ? token : null;
    return runtime == 'standalone'
        ? BanimarkConfig.standalone(baseUrl, token: t)
        : BanimarkConfig.laravel(baseUrl, token: t);
  }

  BanimarkVisitor? get visitor {
    final v = BanimarkVisitor(name: name, email: email, phone: phone);
    return v.isEmpty ? null : v;
  }

  Future<void> save({String? baseUrl, String? runtime, String? token, String? name, String? email, String? phone, bool? globalLauncher}) async {
    if (baseUrl != null) await _p.setString('demo_url', baseUrl.trim().replaceAll(RegExp(r'/+$'), ''));
    if (runtime != null) await _p.setString('demo_runtime', runtime);
    if (token != null) await _p.setString('demo_token', token.trim());
    if (name != null) await _p.setString('demo_name', name.trim());
    if (email != null) await _p.setString('demo_email', email.trim());
    if (phone != null) await _p.setString('demo_phone', phone.trim());
    if (globalLauncher != null) await _p.setBool('demo_global_launcher', globalLauncher);
    notifyListeners();
  }

  /// Forget every conversation, launcher spot and "hidden until" on this device.
  Future<void> forgetEverything() async {
    for (final k in _p.getKeys().where((k) => k.startsWith('banimark') || k.startsWith('demo_chat'))) {
      await _p.remove(k);
    }
    notifyListeners();
  }
}

/// `Demo.of(context)` anywhere below the app.
class Demo extends InheritedNotifier<DemoSettings> {
  const Demo({super.key, required DemoSettings settings, required super.child}) : super(notifier: settings);

  static DemoSettings of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<Demo>()!.notifier!;
}
