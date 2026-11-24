import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:file_picker/file_picker.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzd;

final FlutterLocalNotificationsPlugin notif = FlutterLocalNotificationsPlugin();

Future<void> setup() async {
  tzd.initializeTimeZones();
  const init = InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher'));
  await notif.initialize(init, onDidReceiveNotificationResponse: (r) {});
  await notif.show(1, 'Price \$5 or \$5', "Total: ${3 + 4} \$ and r", const NotificationDetails());
  await notif.zonedSchedule(2, 'a', 'b', tz.TZDateTime.now(tz.local).add(const Duration(minutes: 1)), const NotificationDetails(), androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle);
  await notif.cancel(1);
  final FilePickerResult? res = await FilePicker.platform.pickFiles();
  final m = {'k': 'v'};
  final s1 = r'raw $ stays';
  final s2 = '''multi \$ line ${m['k']} $s1''';
  final s3 = "nested ${m.isEmpty ? 'x \$' : 'y'} ok";
  debugPrint('$res $s2 $s3 \$ ');
}
void main() => runApp(const SizedBox());
