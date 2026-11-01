import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:local_auth/local_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      supportedLocales: const [Locale('ar')],
      locale: const Locale('ar'),
      theme: ThemeData(textTheme: GoogleFonts.cairoTextTheme()),
      home: const Home(),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  Future<void> _run() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('d', DateFormat('yyyy-MM-dd').format(DateTime.now()));
    await launchUrl(Uri.parse('tel:123'));
    await Geolocator.requestPermission();
    await ImagePicker().pickImage(source: ImageSource.camera);
    debugPrint(FlutterLocalNotificationsPlugin().toString());
    debugPrint(LocalAuthentication().toString());
    final db = await openDatabase((await getDatabasesPath()) + '/t.db');
    await db.close();
    debugPrint((await getApplicationDocumentsDirectory()).path);
    await http.get(Uri.parse('https://example.com'));
    debugPrint(MobileScannerController().toString());
    debugPrint(WebViewController().toString());
    final doc = pw.Document();
    doc.addPage(pw.Page(build: (c) => pw.Text('x')));
    await Printing.layoutPdf(onLayout: (_) => doc.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اختبار المكتبات')),
      body: Column(children: [
        SizedBox(
          height: 200,
          child: LineChart(LineChartData(lineBarsData: [
            LineChartBarData(spots: const [FlSpot(0, 1), FlSpot(1, 3), FlSpot(2, 2)]),
          ])),
        ),
        ElevatedButton(onPressed: _run, child: const Text('تشغيل')),
      ]),
    );
  }
}
