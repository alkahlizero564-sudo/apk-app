import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzd;

final FlutterLocalNotificationsPlugin notif = FlutterLocalNotificationsPlugin();
Future<void> setup() async {
  tzd.initializeTimeZones();
  const init = InitializationSettings(android: AndroidInitializationSettings('@mipmap/ic_launcher'));
  await notif.initialize(settings: init);
  await notif.show(id: 1, title: 'Price \$5', body: "Total ${3 + 4} \$", notificationDetails: NotificationDetails(android: AndroidNotificationDetails('c', 'n', importance: Importance.max)));
  await notif.zonedSchedule(id: 2, title: 'a', body: 'b', scheduledDate: tz.TZDateTime.now(tz.local).add(Duration(minutes: 1)), notificationDetails: NotificationDetails(), androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle);
  await notif.cancel(id: 1);
  final FilePickerResult? res = await FilePicker.platform.pickFiles(type: FileType.image);
  final doc = pw.Document();
  doc.addPage(pw.Page(build: (c) => pw.Text('USD (\$)')));
  await Printing.layoutPdf(onLayout: (f) async => doc.save());
  debugPrint('${res?.files.length}');
}
void main() => runApp(SizedBox());
