// DESIGN: تطبيق العشاء | تنظيم وجبات العشاء الجماعية والفردية | أخضر زمردي (#0D9488) | تدرجات بطاقات ناعمة مع أيقونات دائرية

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import 'dart:async' as apkas;
import 'dart:convert' as apkjs;
import 'dart:io' as apkio;
import 'package:flutter/widgets.dart' as apkw;
import 'package:url_launcher/url_launcher.dart' as apkul;

// --- الثوابت اللونية والتصميمية ---
const Color kPrimaryColor = Color(0xFF0D9488);
const Color kSecondaryColor = Color(0xFF14B8A6);
const Color kDarkBg = Color(0xFF0F172A);
const Color kLightBg = Color(0xFFF8FAFC);
const Color kDarkSurface = Color(0xFF1E293B);
const Color kLightSurface = Color(0xFFFFFFFF);
const Color kTextDark = Color(0xFF0F172A);
const Color kTextLight = Color(0xFFF8FAFC);
const Color kSubTextDark = Color(0xFF64748B);
const Color kSubTextLight = Color(0xFF94A3B8);

void main() {
  runApp(const DinnerApp());
}

class DinnerApp extends StatelessWidget {
  const DinnerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تطبيق العشاء',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryColor,
          brightness: Brightness.light,
          primary: kPrimaryColor,
          secondary: kSecondaryColor,
          surface: kLightSurface,
        ),
        scaffoldBackgroundColor: kLightBg,
        cardTheme: CardThemeData(
          color: kLightSurface,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.withValues(alpha: 0.08),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: kPrimaryColor, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryColor,
          brightness: Brightness.dark,
          primary: kPrimaryColor,
          secondary: kSecondaryColor,
          surface: kDarkSurface,
        ),
        scaffoldBackgroundColor: kDarkBg,
        cardTheme: CardThemeData(
          color: kDarkSurface,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            backgroundColor: kPrimaryColor,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: kPrimaryColor, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: const DinnerAuthGate(),
      ),
    );
  }
}

// --- خدمات الاتصال بقاعدة البيانات (REST API) ---
class ApiService {
  static const String baseUrl = 'https://myapk-fd83a-default-rtdb.firebaseio.com/sc0l7m';

  static Future<Map<String, dynamic>?> get(String path) async {
    try {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      final request = await client.getUrl(Uri.parse('$baseUrl/$path.json'));
      final response = await request.close();
      if (response.statusCode == 200) {
        final content = await response.transform(utf8.decoder).join();
        if (content.isNotEmpty && content != 'null') {
          final decoded = json.decode(content);
          if (decoded is Map<String, dynamic>) {
            return decoded;
          } else if (decoded is List) {
            Map<String, dynamic> map = {};
            for (int i = 0; i < decoded.length; i++) {
              if (decoded[i] != null) {
                map[i.toString()] = decoded[i];
              }
            }
            return map;
          }
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<String?> post(String path, Map<String, dynamic> data) async {
    try {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      final request = await client.postUrl(Uri.parse('$baseUrl/$path.json'));
      request.headers.set('content-type', 'application/json');
      request.add(utf8.encode(json.encode(data)));
      final response = await request.close();
      if (response.statusCode == 200) {
        final content = await response.transform(utf8.decoder).join();
        final decoded = json.decode(content);
        if (decoded is Map && decoded.containsKey('name')) {
          return decoded['name'].toString();
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> patch(String path, String id, Map<String, dynamic> data) async {
    try {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      final request = await client.patchUrl(Uri.parse('$baseUrl/$path/$id.json'));
      request.headers.set('content-type', 'application/json');
      request.add(utf8.encode(json.encode(data)));
      final response = await request.close();
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  static Future<bool> delete(String path, String id) async {
    try {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      final request = await client.deleteUrl(Uri.parse('$baseUrl/$path/$id.json'));
      final response = await request.close();
      return response.statusCode == 200;
    } catch (_) {}
    return false;
  }
}

// --- ويدجتات قابلة لإعادة الاستخدام ---
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const AppCard({super.key, required this.child, this.padding, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: padding ?? const EdgeInsets.all(20),
            child: child,
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const SectionTitle({super.key, required this.title, this.actionText, this.onAction});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDark ? kTextLight : kTextDark,
          ),
        ),
        if (actionText != null && onAction != null)
          TextButton(
            onPressed: onAction,
            child: Text(actionText!, style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
          ),
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: kPrimaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: kPrimaryColor),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? kTextLight : kTextDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? kSubTextLight : kSubTextDark,
            ),
            textAlign: TextAlign.center,
          ),
          if (buttonText != null && onButtonPressed != null) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: 200,
              child: FilledButton(
                onPressed: onButtonPressed,
                child: Text(buttonText!),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class StatTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatTile({super.key, required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? kSubTextLight : kSubTextDark,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: isDark ? kTextLight : kTextDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FadeIn extends StatelessWidget {
  final int index;
  final Widget child;

  const FadeIn({super.key, required this.index, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100)),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// --- شاشة تسجيل دخول المسؤول لتطبيق العشاء ---
class DinnerAuthGate extends StatefulWidget {
  const DinnerAuthGate({super.key});

  @override
  State<DinnerAuthGate> createState() => _DinnerAuthGateState();
}

class _DinnerAuthGateState extends State<DinnerAuthGate> {
  final _usernameController = TextEditingController(text: 'admin');
  final _passwordController = TextEditingController(text: '123456');
  bool isLoading = false;
  String? errorMessage;

  void _login() {
    final user = _usernameController.text.trim();
    final pass = _passwordController.text.trim();

    if (user.isEmpty || pass.isEmpty) {
      setState(() => errorMessage = 'الرجاء إدخال اسم المستخدم وكلمة المرور');
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      if (user == 'admin' && pass == '123456') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const Directionality(textDirection: TextDirection.rtl, child: DinnerDashboard())),
        );
      } else {
        setState(() {
          isLoading = false;
          errorMessage = 'بيانات الدخول غير صحيحة (admin / 123456)';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: kPrimaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.dinner_dining_rounded, size: 64, color: kPrimaryColor),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'بوابة إدارة وجبات العشاء',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: isDark ? kTextLight : kTextDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'تسجيل الدخول لإدارة الحجوزات، قوائم الطعام، والوجبات',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? kSubTextLight : kSubTextDark,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'اسم المستخدم',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'كلمة المرور',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: isLoading ? null : _login,
                    child: isLoading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('تسجيل الدخول للإدارة'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// --- لوحة التحكم الرئيسية لإدارة العشاء ---
class DinnerDashboard extends StatefulWidget {
  const DinnerDashboard({super.key});

  @override
  State<DinnerDashboard> createState() => _DinnerDashboardState();
}

class _DinnerDashboardState extends State<DinnerDashboard> {
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      const DinnerOverviewTab(),
      const DinnerReservationsTab(),
      const DinnerMenusTab(),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: screens[currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (idx) => setState(() => currentIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'لوحة التحكم',
          ),
          NavigationDestination(
            icon: Icon(Icons.fact_check_outlined),
            selectedIcon: Icon(Icons.fact_check_rounded),
            label: 'مراجعة الحجوزات',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_menu_outlined),
            selectedIcon: Icon(Icons.restaurant_menu_rounded),
            label: 'إدارة الوجبات',
          ),
        ],
      ),
    );
  }
}

// --- تبويب نظرة عامة وإحصائيات العشاء ---
class DinnerOverviewTab extends StatefulWidget {
  const DinnerOverviewTab({super.key});

  @override
  State<DinnerOverviewTab> createState() => _DinnerOverviewTabState();
}

class _DinnerOverviewTabState extends State<DinnerOverviewTab> {
  List<Map<String, dynamic>> appointments = [];
  List<Map<String, dynamic>> doctors = [];
  bool isLoading = true;
  Timer? pollTimer;

  @override
  void initState() {
    super.initState();
    _fetchData();
    pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchData(silent: true));
  }

  @override
  void dispose() {
    pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData({bool silent = false}) async {
    if (!silent) setState(() => isLoading = true);

    final apptsMap = await ApiService.get('appointments');
    final docsMap = await ApiService.get('doctors');

    if (!mounted) return;

    List<Map<String, dynamic>> loadedAppts = [];
    if (apptsMap != null) {
      apptsMap.forEach((key, val) {
        if (val is Map) {
          final item = Map<String, dynamic>.from(val);
          item['appKey'] = key;
          loadedAppts.add(item);
        }
      });
    }

    List<Map<String, dynamic>> loadedDocs = [];
    if (docsMap != null) {
      docsMap.forEach((key, val) {
        if (val is Map) {
          final item = Map<String, dynamic>.from(val);
          item['docKey'] = key;
          loadedDocs.add(item);
        }
      });
    }

    setState(() {
      appointments = loadedAppts;
      doctors = loadedDocs;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pendingCount = appointments.where((a) => a['status'] == 'بانتظار التأكيد').length;
    final confirmedCount = appointments.where((a) => a['status'] == 'مؤكد').length;
    final completedCount = appointments.where((a) => a['status'] == 'مكتمل').length;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 220,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [kPrimaryColor, kSecondaryColor],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              alignment: Alignment.bottomRight,
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'لوحة إدارة العشاء',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'متابعة الحجوزات، تعديل الأسعار وإدارة الوجبات',
                    style: TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        title: 'بانتظار التأكيد',
                        value: pendingCount.toString(),
                        icon: Icons.hourglass_top_rounded,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatTile(
                        title: 'الحجوزات المؤكدة',
                        value: confirmedCount.toString(),
                        icon: Icons.check_circle_outline,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: StatTile(
                        title: 'المواعيد المكتملة',
                        value: completedCount.toString(),
                        icon: Icons.done_all_rounded,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatTile(
                        title: 'عدد الوجبات',
                        value: doctors.length.toString(),
                        icon: Icons.restaurant_menu_outlined,
                        color: kPrimaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const SectionTitle(title: 'الطلبات المعلقة الحديثة'),
                const SizedBox(height: 12),
                isLoading
                    ? const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
                    : appointments.where((a) => a['status'] == 'بانتظار التأكيد').isEmpty
                        ? const EmptyState(
                            icon: Icons.fact_check_outlined,
                            title: 'لا توجد طلبات معلقة',
                            subtitle: 'جميع حجوزات العشاء الواردة تم التعامل معها',
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: appointments.where((a) => a['status'] == 'بانتظار التأكيد').length,
                            separatorBuilder: (_, __) => const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              final pendingList = appointments.where((a) => a['status'] == 'بانتظار التأكيد').toList();
                              final app = pendingList[index];
                              return FadeIn(
                                index: index,
                                child: AppCard(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.between,
                                        children: [
                                          Text(
                                            app['doctor_name'] ?? 'وجبة عشاء',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                              color: isDark ? kTextLight : kTextDark,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: Colors.orange.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: const Text(
                                              'بانتظار التأكيد',
                                              style: TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'التصنيف: ${app['specialization'] ?? ''} | التاريخ: ${app['date']} - ${app['time']}',
                                        style: TextStyle(fontSize: 13, color: isDark ? kSubTextLight : kSubTextDark),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// --- تبويب مراجعة حجوزات العشاء ---
class DinnerReservationsTab extends StatefulWidget {
  const DinnerReservationsTab({super.key});

  @override
  State<DinnerReservationsTab> createState() => _DinnerReservationsTabState();
}

class _DinnerReservationsTabState extends State<DinnerReservationsTab> {
  List<Map<String, dynamic>> appointments = [];
  bool isLoading = true;
  Timer? pollTimer;

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
    pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchAppointments(silent: true));
  }

  @override
  void dispose() {
    pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchAppointments({bool silent = false}) async {
    if (!silent) setState(() => isLoading = true);

    final apptsMap = await ApiService.get('appointments');
    if (!mounted) return;

    List<Map<String, dynamic>> loaded = [];
    if (apptsMap != null) {
      apptsMap.forEach((key, val) {
        if (val is Map) {
          final item = Map<String, dynamic>.from(val);
          item['appKey'] = key;
          loaded.add(item);
        }
      });
    }

    setState(() {
      appointments = loaded;
      isLoading = false;
    });
  }

  Future<void> _updateStatus(String appKey, String newStatus) async {
    final success = await ApiService.patch('appointments', appKey, {'status': newStatus});
    if (success) {
      _fetchAppointments();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تحديث حالة الحجز إلى: $newStatus')),
      );
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'مؤكد':
        return Colors.green;
      case 'مرفوض':
        return Colors.red;
      case 'مكتمل':
        return Colors.blue;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('مراجعة حجوزات العشاء', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : appointments.isEmpty
              ? const EmptyState(
                  icon: Icons.calendar_today_outlined,
                  title: 'لا توجد حجوزات واردة',
                  subtitle: 'ستظهر حجوزات الوجبات هنا فور إرسالها',
                )
              : RefreshIndicator(
                  onRefresh: _fetchAppointments,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: appointments.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final app = appointments[index];
                      final status = app['status'] ?? 'بانتظار التأكيد';
                      final statusColor = _getStatusColor(status);
                      final appKey = app['appKey'];

                      return FadeIn(
                        index: index,
                        child: AppCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.between,
                                children: [
                                  Text(
                                    app['doctor_name'] ?? 'وجبة عشاء',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? kTextLight : kTextDark,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      status,
                                      style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'التصنيف: ${app['specialization'] ?? ''}',
                                style: TextStyle(fontSize: 13, color: isDark ? kSubTextLight : kSubTextDark),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'التاريخ: ${app['date']} | الوقت: ${app['time']}',
                                style: TextStyle(fontSize: 13, color: isDark ? kSubTextLight : kSubTextDark),
                              ),
                              const Divider(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  if (status == 'بانتظار التأكيد') ...[
                                    OutlinedButton.icon(
                                      onPressed: () => _updateStatus(appKey, 'مرفوض'),
                                      icon: const Icon(Icons.close, color: Colors.red, size: 18),
                                      label: const Text('رفض', style: TextStyle(color: Colors.red)),
                                      style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
                                    ),
                                    const SizedBox(width: 8),
                                    FilledButton.icon(
                                      onPressed: () => _updateStatus(appKey, 'مؤكد'),
                                      icon: const Icon(Icons.check, size: 18),
                                      label: const Text('قبول وتأكيد'),
                                      style: FilledButton.styleFrom(backgroundColor: Colors.green),
                                    ),
                                  ] else if (status == 'مؤكد') ...[
                                    FilledButton.icon(
                                      onPressed: () => _updateStatus(appKey, 'مكتمل'),
                                      icon: const Icon(Icons.done_all, size: 18),
                                      label: const Text('تحديد كمكتمل'),
                                      style: FilledButton.styleFrom(backgroundColor: Colors.blue),
                                    ),
                                  ] else ...[
                                    Text(
                                      'الحجز منتهي (${status})',
                                      style: TextStyle(fontSize: 13, color: isDark ? kSubTextLight : kSubTextDark, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

// --- تبويب إدارة الوجبات والأسعار ---
class DinnerMenusTab extends StatefulWidget {
  const DinnerMenusTab({super.key});

  @override
  State<DinnerMenusTab> createState() => _DinnerMenusTabState();
}

class _DinnerMenusTabState extends State<DinnerMenusTab> {
  List<Map<String, dynamic>> doctors = [];
  bool isLoading = true;
  Timer? pollTimer;

  @override
  void initState() {
    super.initState();
    _fetchDoctors();
    pollTimer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchDoctors(silent: true));
  }

  @override
  void dispose() {
    pollTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchDoctors({bool silent = false}) async {
    if (!silent) setState(() => isLoading = true);

    final docsMap = await ApiService.get('doctors');
    if (!mounted) return;

    List<Map<String, dynamic>> loaded = [];
    if (docsMap != null) {
      docsMap.forEach((key, val) {
        if (val is Map) {
          final item = Map<String, dynamic>.from(val);
          item['docKey'] = key;
          loaded.add(item);
        }
      });
    }

    setState(() {
      doctors = loaded;
      isLoading = false;
    });
  }

  void _showAddOrEditDoctorDialog({Map<String, dynamic>? doctor}) {
    final nameController = TextEditingController(text: doctor?['name'] ?? '');
    final specController = TextEditingController(text: doctor?['specialization'] ?? '');
    final feeController = TextEditingController(text: doctor?['fee']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Text(doctor == null ? 'إضافة وجبة عشاء جديدة' : 'تعديل بيانات الوجبة والأسعار'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'اسم الوجبة'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: specController,
                  decoration: const InputDecoration(labelText: 'تصنيف الوجبة (مشاوي، بحري، شرقي...)'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: feeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'سعر الوجبة (ر.س)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء', style: TextStyle(color: Colors.grey)),
            ),
            FilledButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final spec = specController.text.trim();
                final fee = double.tryParse(feeController.text.trim()) ?? 75.0;

                if (name.isEmpty || spec.isEmpty) return;

                Navigator.pop(context);

                if (doctor == null) {
                  final newDocId = DateTime.now().millisecondsSinceEpoch;
                  final data = {
                    'id': newDocId,
                    'name': name,
                    'specialization': spec,
                    'fee': fee,
                  };
                  await ApiService.post('doctors', data);
                } else {
                  final docKey = doctor['docKey'];
                  final data = {
                    'id': doctor['id'] ?? 1,
                    'name': name,
                    'specialization': spec,
                    'fee': fee,
                  };
                  await ApiService.patch('doctors', docKey, data);
                }
                _fetchDoctors();
              },
              child: Text(doctor == null ? 'إضافة' : 'حفظ التعديلات'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteDoctor(String docKey) async {
    final success = await ApiService.delete('doctors', docKey);
    if (success) {
      _fetchDoctors();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الوجبة بنجاح')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة الوجبات والأسعار', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : doctors.isEmpty
              ? const EmptyState(
                  icon: Icons.restaurant_menu_outlined,
                  title: 'لا توجد وجبات مسجلة',
                  subtitle: 'قم بإضافة وجبات عشاء جديدة لتظهر للمستخدمين',
                  buttonText: 'إضافة وجبة جديدة',
                  onButtonPressed: null,
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: doctors.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final doc = doctors[index];
                    return FadeIn(
                      index: index,
                      child: AppCard(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: kPrimaryColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(Icons.dinner_dining_rounded, color: kPrimaryColor, size: 32),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    doc['name'] ?? 'وجبة',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: isDark ? kTextLight : kTextDark,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    doc['specialization'] ?? 'تصنيف عام',
                                    style: TextStyle(fontSize: 13, color: isDark ? kSubTextLight : kSubTextDark),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'السعر: ${doc['fee']} ر.س',
                                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: kPrimaryColor),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              onPressed: () => _showAddOrEditDoctorDialog(doctor: doc),
                              icon: const Icon(Icons.edit_outlined, color: kPrimaryColor),
                            ),
                            IconButton(
                              onPressed: () => _deleteDoctor(doc['docKey']),
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOrEditDoctorDialog(),
        backgroundColor: kPrimaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('إضافة وجبة جديدة', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }
}

// ===== تحديث التطبيق (يُضاف تلقائياً) =====
const int _apkCur = 1;
const String _apkUrl = 'https://raw.githubusercontent.com/alkahlizero564-sudo/apk-app/main/apps/dentalpatient/update.json';

void runApp(apkw.Widget app) => apkw.runApp(ApkUpdateGate(child: app));

class ApkUpdateGate extends apkw.StatefulWidget {
  final apkw.Widget child;
  const ApkUpdateGate({super.key, required this.child});

  @override
  apkw.State<ApkUpdateGate> createState() => _ApkUpdateGateState();
}

class _ApkUpdateGateState extends apkw.State<ApkUpdateGate> {
  Map<String, dynamic>? _u;

  @override
  void initState() {
    super.initState();
    apkas.Timer(const Duration(seconds: 3), _check);
  }

  apkio.File _skipFile() => apkio.File(apkio.Directory.systemTemp.path + '/apk_upd_skip.txt');

  Future<bool> _skipped(int code) async {
    try {
      final s = await _skipFile().readAsString();
      final p = s.split('|');
      if (p.length == 2 && p[0] == code.toString()) {
        final t = int.tryParse(p[1]) ?? 0;
        return DateTime.now().millisecondsSinceEpoch - t < 86400000;
      }
    } catch (_) {}
    return false;
  }

  Future<void> _later(int code) async {
    try {
      await _skipFile().writeAsString(code.toString() + '|' + DateTime.now().millisecondsSinceEpoch.toString());
    } catch (_) {}
  }

  Future<void> _check() async {
    try {
      final c = apkio.HttpClient();
      c.connectionTimeout = const Duration(seconds: 8);
      final req = await c.getUrl(Uri.parse(_apkUrl + '?t=' + DateTime.now().millisecondsSinceEpoch.toString()));
      final res = await req.close();
      if (res.statusCode != 200) return;
      final body = await res.transform(apkjs.utf8.decoder).join();
      final j = apkjs.jsonDecode(body);
      if (j is! Map<String, dynamic>) return;
      final code = (j['code'] is num) ? (j['code'] as num).toInt() : 0;
      if (code <= _apkCur || j['url'] is! String) return;
      if (j['force'] != true && await _skipped(code)) return;
      if (mounted) setState(() => _u = j);
    } catch (_) {}
  }

  @override
  apkw.Widget build(apkw.BuildContext context) {
    final u = _u;
    return apkw.Directionality(
      textDirection: apkw.TextDirection.rtl,
      child: apkw.Stack(
        textDirection: apkw.TextDirection.rtl,
        fit: apkw.StackFit.expand,
        children: [
          widget.child,
          if (u != null) _overlay(u),
        ],
      ),
    );
  }

  apkw.Widget _overlay(Map<String, dynamic> u) {
    final force = u['force'] == true;
    final name = (u['name'] ?? u['code']).toString();
    final notes = (u['notes'] ?? '').toString();
    final code = (u['code'] is num) ? (u['code'] as num).toInt() : 0;
    return apkw.Container(
      color: const apkw.Color(0xA3020617),
      alignment: apkw.Alignment.bottomCenter,
      child: apkw.Container(
        width: double.infinity,
        padding: const apkw.EdgeInsets.fromLTRB(20, 22, 20, 34),
        decoration: const apkw.BoxDecoration(
          color: apkw.Color(0xFFFFFFFF),
          borderRadius: apkw.BorderRadius.only(
            topLeft: apkw.Radius.circular(28),
            topRight: apkw.Radius.circular(28),
          ),
        ),
        child: apkw.DefaultTextStyle(
          style: const apkw.TextStyle(
            color: apkw.Color(0xFF0F172A),
            fontSize: 14,
            fontWeight: apkw.FontWeight.normal,
            decoration: apkw.TextDecoration.none,
          ),
          child: apkw.Column(
            mainAxisSize: apkw.MainAxisSize.min,
            crossAxisAlignment: apkw.CrossAxisAlignment.start,
            children: [
              apkw.Text(
                force ? 'تحديث مطلوب' : 'يتوفر إصدار جديد',
                style: const apkw.TextStyle(fontSize: 19, fontWeight: apkw.FontWeight.w800),
              ),
              const apkw.SizedBox(height: 8),
              apkw.Text(
                'الإصدار ' + name + (notes.isEmpty ? '' : '\n\n' + notes),
                style: const apkw.TextStyle(color: apkw.Color(0xFF475569), height: 1.7),
              ),
              const apkw.SizedBox(height: 16),
              _btn('⬇ تحميل التحديث', const apkw.Color(0xFF2563EB), const apkw.Color(0xFFFFFFFF), () {
                apkul.launchUrl(Uri.parse(u['url'] as String), mode: apkul.LaunchMode.externalApplication);
              }),
              if (!force) ...[
                const apkw.SizedBox(height: 10),
                _btn('لاحقاً', const apkw.Color(0xFFE2E8F0), const apkw.Color(0xFF0F172A), () {
                  _later(code);
                  setState(() => _u = null);
                }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  apkw.Widget _btn(String t, apkw.Color bg, apkw.Color fg, void Function() f) {
    return apkw.GestureDetector(
      onTap: f,
      child: apkw.Container(
        width: double.infinity,
        padding: const apkw.EdgeInsets.symmetric(vertical: 14),
        decoration: apkw.BoxDecoration(color: bg, borderRadius: apkw.BorderRadius.circular(16)),
        child: apkw.Text(
          t,
          textAlign: apkw.TextAlign.center,
          style: apkw.TextStyle(color: fg, fontSize: 16, fontWeight: apkw.FontWeight.w700),
        ),
      ),
    );
  }
}
