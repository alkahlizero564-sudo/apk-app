import 'dart:convert';
import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class APKPush {
  static const String _fn = 'https://qlvmxnoewxzykgbneadv.supabase.co/functions/v1/apk-push';
  static const String _key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFsdm14bm9ld3h6eWtnYm5lYWR2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE2NDAwMjIsImV4cCI6MjEwNzIxNjAyMn0.WtsiO0PrUrwxKjpcyB3949kXSZeijtlJYySSbh0ieRk';
  static const String _grp = 'bakerycustom0ovz';
  static const String role = 'admin';
  static String? _token;
  static String? _uid;

  static Future<Map> _call(Map<String, dynamic> o) async {
    o['grp'] = _grp;
    try {
      final c = HttpClient();
      final rq = await c.postUrl(Uri.parse(_fn));
      rq.headers.set('content-type', 'application/json');
      rq.headers.set('apikey', _key);
      rq.headers.set('Authorization', 'Bearer ' + _key);
      rq.add(utf8.encode(jsonEncode(o)));
      final rs = await rq.close();
      final t = await rs.transform(utf8.decoder).join();
      c.close();
      return jsonDecode(t) as Map;
    } catch (e) {
      return {'ok': false, 'error': e.toString()};
    }
  }

  static Future<void> start() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp();
      final m = FirebaseMessaging.instance;
      await m.requestPermission();
      _token = await m.getToken();
      m.onTokenRefresh.listen((t) { _token = t; _reg(); });
      _reg();
    } catch (e) {
      debugPrint('APKPush: ' + e.toString());
    }
  }

  static void _reg() {
    if (_token != null) _call({'action': 'register', 'token': _token, 'role': role, 'uid': _uid});
  }

  static void setUser(String? u) { _uid = u; _reg(); }
  static Future<Map> toAdmin(String title, String body) => _call({'to': 'admin', 'title': title, 'body': body});
  static Future<Map> toUser(String uid, String title, String body) => _call({'to': 'user', 'uid': uid, 'title': title, 'body': body});
  static Future<Map> toAll(String title, String body) => _call({'to': 'customer', 'title': title, 'body': body});
}
