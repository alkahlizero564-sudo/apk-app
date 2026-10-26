// DESIGN: لوحة إدارة المخبز الذكي | الفخامة والتحكم التام | #10B981 أخضر ذكي | بطاقات عائمة دائرية الزوايا وتدرجات فاخرة

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

// --- إعدادات Supabase والاتصال عبر HTTP المباشر ---
const String kSupabaseUrl = 'https://qlvmxnoewxzykgbneadv.supabase.co';
const String kAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFsdm14bm9ld3h6eWtnYm5lYWR2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE2NDAwMjIsImV4cCI6MjEwNzIxNjAyMn0.WtsiO0PrUrwxKjpcyB3949kXSZeijtlJYySSbh0ieRk';

Map<String, String> _headers({bool withReturn = false}) {
  final h = {
    'apikey': kAnonKey,
    'Authorization': 'Bearer $kAnonKey',
    'Content-Type': 'application/json',
  };
  if (withReturn) {
    h['Prefer'] = 'return=representation';
  }
  return h;
}

Future<dynamic> supabaseGet(String endpoint, {String? query}) async {
  try {
    final uri = Uri.parse('$kSupabaseUrl/rest/v1/$endpoint${query != null ? '?$query' : ''}');
    final request = await HttpClient().getUrl(uri);
    _headers().forEach((k, v) => request.headers.set(k, v));
    final response = await request.close();
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonStr = await response.transform(utf8.decoder).join();
      return jsonDecode(jsonStr);
    }
  } catch (_) {}
  return null;
}

Future<dynamic> supabasePost(String endpoint, Map<String, dynamic> data) async {
  try {
    final uri = Uri.parse('$kSupabaseUrl/rest/v1/$endpoint');
    final request = await HttpClient().postUrl(uri);
    _headers(withReturn: true).forEach((k, v) => request.headers.set(k, v));
    request.add(utf8.encode(jsonEncode(data)));
    final response = await request.close();
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final jsonStr = await response.transform(utf8.decoder).join();
      final decoded = jsonDecode(jsonStr);
      if (decoded is List && decoded.isNotEmpty) return decoded.first;
      return decoded;
    }
  } catch (_) {}
  return null;
}

Future<bool> supabasePatch(String endpoint, String query, Map<String, dynamic> data) async {
  try {
    final uri = Uri.parse('$kSupabaseUrl/rest/v1/$endpoint?$query');
    final request = await HttpClient().patchUrl(uri);
    _headers().forEach((k, v) => request.headers.set(k, v));
    request.add(utf8.encode(jsonEncode(data)));
    final response = await request.close();
    return response.statusCode >= 200 && response.statusCode < 300;
  } catch (_) {}
  return false;
}

// --- الألوان والثيم ---
const Color kPrimary = Color(0xFF10B981);
const Color kPrimaryDark = Color(0xFF059669);
const Color kSecondary = Color(0xFF3B82F6);
const Color kAccent = Color(0xFFF59E0B);
const Color kBgLight = Color(0xFFF8FAFC);
const Color kSurfaceLight = Color(0xFFFFFFFF);
const Color kBgDark = Color(0xFF0F172A);
const Color kSurfaceDark = Color(0xFF1E293B);

ThemeData buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: ColorScheme.fromSeed(
      seedColor: kPrimary,
      brightness: brightness,
      primary: kPrimary,
      secondary: kSecondary,
      surface: isDark ? kSurfaceDark : kSurfaceLight,
    ),
    scaffoldBackgroundColor: isDark ? kBgDark : kBgLight,
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: isDark ? kSurfaceDark : kSurfaceLight,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: kPrimary, width: 2),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
    ),
  );
}

// --- ويدجتات قابلة لإعادة الاستخدام ---
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  const AppCard({super.key, required this.child, this.padding, this.onTap, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          if (actionText != null)
            TextButton(
              onPressed: onAction,
              child: Text(actionText!, style: const TextStyle(color: kPrimary, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onAction;
  const EmptyState({super.key, required this.icon, required this.title, required this.subtitle, this.buttonText, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: kPrimary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 56, color: kPrimary),
          ),
          const SizedBox(height: 24),
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor), textAlign: TextAlign.center),
          if (buttonText != null && onAction != null) ...[
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add),
              label: Text(buttonText!),
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
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13, color: Theme.of(context).hintColor, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
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
      builder: (context, value, childWidget) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: childWidget),
        );
      },
      child: child,
    );
  }
}

// --- نقطة الدخول الرئيسية ---
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BreadAdminApp());
}

class BreadAdminApp extends StatelessWidget {
  const BreadAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'إدارة مخبز السودان',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: ThemeMode.system,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const AdminMainNavigation(),
    );
  }
}

// --- التنقل الرئيسي للإدارة ---
class AdminMainNavigation extends StatefulWidget {
  const AdminMainNavigation({super.key});

  @override
  State<AdminMainNavigation> createState() => _AdminMainNavigationState();
}

class _AdminMainNavigationState extends State<AdminMainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    AdminDashboardScreen(),
    AdminCustomersScreen(),
    AdminTodayBookingsScreen(),
    AdminReportsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), selectedIcon: Icon(Icons.dashboard), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.people_outlined), selectedIcon: Icon(Icons.people), label: 'المسجلون'),
          NavigationDestination(icon: Icon(Icons.today_outlined), selectedIcon: Icon(Icons.today), label: 'حجوزات اليوم'),
          NavigationDestination(icon: Icon(Icons.bar_chart_outlined), selectedIcon: Icon(Icons.bar_chart), label: 'التقارير'),
        ],
      ),
    );
  }
}

// --- شاشة اللوحة الرئيسية (Dashboard) ---
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Timer? _timer;
  bool _loading = true;
  String _bookingStatus = 'closed';
  int _totalCustomers = 0;
  int _todayBookingsCount = 0;
  double _todayQoroshSum = 0;
  double _totalQoroshSum = 0;

  @override
  void initState() {
    super.initState();
    _fetchStats();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchStats());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchStats() async {
    // 1. جلب حالة الحجز من settings
    final settingsRes = await supabaseGet('s2evsm_settings');
    if (settingsRes is List && settingsRes.isNotEmpty) {
      _bookingStatus = settingsRes.first['booking_status'] ?? 'closed';
    }

    // 2. جلب عدد المسجلين
    final customersRes = await supabaseGet('s2evsm_customers');
    if (customersRes is List) {
      _totalCustomers = customersRes.length;
    }

    // 3. جلب جميع الحجوزات لحساب إحصائيات اليوم والبداية
    final bookingsRes = await supabaseGet('s2evsm_bookings');
    if (bookingsRes is List) {
      final todayStr = DateTime.now().toIso8601String().split('T').first;
      int todayCount = 0;
      double todayQorosh = 0;
      double totalQorosh = 0;

      for (var b in bookingsRes) {
        final qorosh = double.tryParse(b['qorosh_count'].toString()) ?? 0;
        final status = b['status'];
        if (status != 'cancelled') {
          totalQorosh += qorosh;
          if (b['booking_date'] == todayStr) {
            todayCount++;
            todayQorosh += qorosh;
          }
        }
      }

      _todayBookingsCount = todayCount;
      _todayQoroshSum = todayQorosh;
      _totalQoroshSum = totalQorosh;
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  Future<void> _toggleBookingStatus(bool open) async {
    final newStatus = open ? 'open' : 'closed';
    // نتحقق إن كان هناك سجل في settings أم لا
    final settingsRes = await supabaseGet('s2evsm_settings');
    bool success = false;
    if (settingsRes is List && settingsRes.isNotEmpty) {
      final id = settingsRes.first['id'];
      success = await supabasePatch('s2evsm_settings', 'id=eq.$id', {'booking_status': newStatus});
    } else {
      final res = await supabasePost('s2evsm_settings', {'booking_status': newStatus});
      success = res != null;
    }

    if (success) {
      setState(() => _bookingStatus = newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(open ? 'تم فتح الحجز للزبائن بنجاح' : 'تم قفل الحجز بنجاح')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isOpen = _bookingStatus == 'open';

    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: const Text('لوحة تحكم الإدارة', style: TextStyle(fontWeight: FontWeight.w900)),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // حالة الحجز وأزرار الفتح والقفل
              FadeIn(
                index: 0,
                child: AppCard(
                  color: isOpen ? kPrimary.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isOpen ? kPrimary : Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(isOpen ? Icons.lock_open : Icons.lock, color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isOpen ? 'الحجز مفتوح حالياً' : 'الحجز مقفل حالياً',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    color: isOpen ? kPrimaryDark : Colors.red[700],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  isOpen ? 'الزبائن يمكنهم إرسال وتعديل طلباتهم' : 'تم إيقاف استقبال الطلبات الجديدة',
                                  style: TextStyle(fontSize: 13, color: Theme.of(context).hintColor),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 32),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: isOpen ? null : () => _toggleBookingStatus(true),
                              icon: const Icon(Icons.lock_open, color: kPrimary),
                              label: const Text('فتح الحجز', style: TextStyle(color: kPrimary)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              style: FilledButton.styleFrom(backgroundColor: Colors.red),
                              onPressed: !isOpen ? null : () => _toggleBookingStatus(false),
                              icon: const Icon(Icons.lock),
                              label: const Text('قفل الحجز'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const SectionTitle(title: 'الإحصائيات العامة'),
              if (_loading)
                const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
              else ...[
                FadeIn(
                  index: 1,
                  child: StatTile(
                    title: 'عدد المسجلين الإجمالي',
                    value: '$_totalCustomers زبون',
                    icon: Icons.people,
                    color: kSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                FadeIn(
                  index: 2,
                  child: StatTile(
                    title: 'عدد حجوزات اليوم',
                    value: '$_todayBookingsCount حجز',
                    icon: Icons.today,
                    color: kPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                FadeIn(
                  index: 3,
                  child: StatTile(
                    title: 'إجمالي القروش المحجوزة اليوم',
                    value: '$_todayQoroshSum قروش',
                    icon: Icons.bakery_dining,
                    color: kAccent,
                  ),
                ),
                const SizedBox(height: 16),
                FadeIn(
                  index: 4,
                  child: StatTile(
                    title: 'إجمالي قروش المخبز (من البداية)',
                    value: '$_totalQoroshSum قروش',
                    icon: Icons.trending_up,
                    color: Colors.purple,
                  ),
                ),
              ],
            ]),
          ),
        ),
      ],
    );
  }
}

// --- شاشة المسجلون (Customers) ---
class AdminCustomersScreen extends StatefulWidget {
  const AdminCustomersScreen({super.key});

  @override
  State<AdminCustomersScreen> createState() => _AdminCustomersScreenState();
}

class _AdminCustomersScreenState extends State<AdminCustomersScreen> {
  bool _loading = true;
  List<dynamic> _customers = [];
  List<dynamic> _filteredCustomers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchCustomers();
  }

  Future<void> _fetchCustomers() async {
    final res = await supabaseGet('s2evsm_customers', query: 'order=created_at.desc');
    if (res is List) {
      if (mounted) {
        setState(() {
          _customers = res;
          _filteredCustomers = res;
          _loading = false;
        });
      }
    } else {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _filterSearch(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      if (q.isEmpty) {
        _filteredCustomers = _customers;
      } else {
        _filteredCustomers = _customers.where((c) {
          final name = (c['name'] ?? '').toLowerCase();
          final phone = (c['phone'] ?? '').toLowerCase();
          return name.contains(q) || phone.contains(q);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الزبائن المسجلون', style: TextStyle(fontWeight: FontWeight.w900))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _searchController,
              onChanged: _filterSearch,
              decoration: const InputDecoration(
                hintText: 'ابحث بالاسم أو رقم الهاتف...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('إجمالي المسجلين:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('${_filteredCustomers.length} زبون', style: const TextStyle(fontWeight: FontWeight.w900, color: kPrimary)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filteredCustomers.isEmpty
                    ? const EmptyState(
                        icon: Icons.person_off,
                        title: 'لا يوجد زبائن',
                        subtitle: 'لم يتم تسجيل أي زبائن مطابقين للبحث حالياً',
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchCustomers,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          itemCount: _filteredCustomers.length,
                          itemBuilder: (context, index) {
                            final c = _filteredCustomers[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: FadeIn(
                                index: index,
                                child: AppCard(
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundColor: kPrimary.withValues(alpha: 0.2),
                                        backgroundImage: c['profile_image'] != null && c['profile_image'].toString().isNotEmpty
                                            ? NetworkImage(c['profile_image'])
                                            : null,
                                        child: c['profile_image'] == null || c['profile_image'].toString().isEmpty
                                            ? const Icon(Icons.person, color: kPrimary, size: 28)
                                            : null,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(c['name'] ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.phone, size: 14, color: kSecondary),
                                                const SizedBox(width: 6),
                                                Text(c['phone'] ?? '', style: TextStyle(color: Theme.of(context).hintColor)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

// --- شاشة حجوزات اليوم (Today Bookings) ---
class AdminTodayBookingsScreen extends StatefulWidget {
  const AdminTodayBookingsScreen({super.key});

  @override
  State<AdminTodayBookingsScreen> createState() => _AdminTodayBookingsScreenState();
}

class _AdminTodayBookingsScreenState extends State<AdminTodayBookingsScreen> {
  bool _loading = true;
  List<dynamic> _todayBookings = [];
  Map<String, dynamic> _customersMap = {};

  @override
  void initState() {
    super.initState();
    _fetchTodayData();
  }

  Future<void> _fetchTodayData() async {
    // 1. جلب الزبائن لربط الأسماء وأرقام الهواتف
    final customersRes = await supabaseGet('s2evsm_customers');
    final Map<String, dynamic> cMap = {};
    if (customersRes is List) {
      for (var c in customersRes) {
        cMap[c['customer_id']] = c;
      }
    }

    // 2. جلب حجوزات اليوم فقط
    final todayStr = DateTime.now().toIso8601String().split('T').first;
    final bookingsRes = await supabaseGet('s2evsm_bookings', query: 'booking_date=eq.$todayStr');

    if (bookingsRes is List) {
      if (mounted) {
        setState(() {
          _customersMap = cMap;
          _todayBookings = bookingsRes;
          _loading = false;
        });
      }
    } else {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateBookingStatus(String bookingId, String newStatus) async {
    final success = await supabasePatch(
      's2evsm_bookings',
      'booking_id=eq.$bookingId',
      {'status': newStatus},
    );
    if (success) {
      _fetchTodayData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(newStatus == 'delivered' ? 'تم تسجيل الحجز كـ "تم الاستلام"' : 'تم إلغاء الحجز')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حجوزات اليوم', style: TextStyle(fontWeight: FontWeight.w900))),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _todayBookings.isEmpty
              ? const EmptyState(
                  icon: Icons.today,
                  title: 'لا توجد حجوزات اليوم',
                  subtitle: 'لم يقم أي زبون بتقديم طلب حجز ليومنا هذا بعد',
                )
              : RefreshIndicator(
                  onRefresh: _fetchTodayData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _todayBookings.length,
                    itemBuilder: (context, index) {
                      final b = _todayBookings[index];
                      final customer = _customersMap[b['customer_id']] ?? {};
                      final name = customer['name'] ?? 'زبون غير معروف';
                      final phone = customer['phone'] ?? 'بدون هاتف';
                      final status = b['status'];
                      final isDelivered = status == 'delivered';
                      final isCancelled = status == 'cancelled';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: FadeIn(
                          index: index,
                          child: AppCard(
                            color: isCancelled
                                ? Colors.red.withValues(alpha: 0.05)
                                : isDelivered
                                    ? kPrimary.withValues(alpha: 0.05)
                                    : null,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isCancelled
                                            ? Colors.red.withValues(alpha: 0.15)
                                            : isDelivered
                                                ? kPrimary.withValues(alpha: 0.15)
                                                : kSecondary.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        isCancelled
                                            ? 'ملغي'
                                            : isDelivered
                                                ? 'تم الاستلام'
                                                : 'محجوز',
                                        style: TextStyle(
                                          color: isCancelled
                                              ? Colors.red
                                              : isDelivered
                                                  ? kPrimaryDark
                                                  : kSecondary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.phone, size: 14, color: kSecondary),
                                    const SizedBox(width: 6),
                                    Text(phone, style: TextStyle(color: Theme.of(context).hintColor)),
                                  ],
                                ),
                                const Divider(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('عدد القروش: ${b['qorosh_count']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text('المبلغ: ${b['amount_ssp']} ج.س', style: const TextStyle(fontWeight: FontWeight.bold, color: kPrimaryDark)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text('الدفع: ${b['payment_method'] == 'cash' ? 'نقدي' : 'أجل'}',
                                    style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
                                if (!isCancelled) ...[
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () => _updateBookingStatus(b['booking_id'], 'cancelled'),
                                          icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                                          label: const Text('إلغاء الحجز', style: TextStyle(color: Colors.red)),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: FilledButton.icon(
                                          onPressed: isDelivered ? null : () => _updateBookingStatus(b['booking_id'], 'delivered'),
                                          icon: const Icon(Icons.check_circle_outline),
                                          label: Text(isDelivered ? 'تم التسليم' : 'تم الاستلام'),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}

// --- شاشة التقارير (Reports) ---
class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  String _selectedPeriod = 'this_week'; // this_week, last_week, this_month, last_month
  bool _loading = true;
  List<dynamic> _allBookings = [];

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    final res = await supabaseGet('s2evsm_bookings');
    if (res is List) {
      if (mounted) {
        setState(() {
          _allBookings = res;
          _loading = false;
        });
      }
    } else {
      if (mounted) setState(() => _loading = false);
    }
  }

  // حساب النطاق الزمني بناءً على الاختيار
  bool _isInSelectedPeriod(String dateStr) {
    final date = DateTime.tryParse(dateStr);
    if (date == null) return false;
    final now = DateTime.now();

    if (_selectedPeriod == 'this_week') {
      // الأسبوع الحالي (من السبت أو الأحد إلى اليوم)
      final startOfWeek = now.subtract(Duration(days: now.weekday % 7));
      final start = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      return date.isAfter(start.subtract(const Duration(seconds: 1))) && date.isBefore(now.add(const Duration(days: 1)));
    } else if (_selectedPeriod == 'last_week') {
      final startOfThisWeek = now.subtract(Duration(days: now.weekday % 7));
      final startOfLastWeek = startOfThisWeek.subtract(const Duration(days: 7));
      return date.isAfter(startOfLastWeek.subtract(const Duration(seconds: 1))) && date.isBefore(startOfThisWeek);
    } else if (_selectedPeriod == 'this_month') {
      return date.year == now.year && date.month == now.month;
    } else if (_selectedPeriod == 'last_month') {
      final lastMonth = now.month == 1 ? 12 : now.month - 1;
      final year = now.month == 1 ? now.year - 1 : now.year;
      return date.year == year && date.month == lastMonth;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    // تصفية الحجوزات للفترة المحددة
    final filtered = _allBookings.where((b) {
      if (b['status'] == 'cancelled') return false;
      return _isInSelectedPeriod(b['booking_date'] ?? '');
    }).toList();

    int totalBookings = filtered.length;
    double totalQorosh = 0;
    double totalAmount = 0;

    // تفصيل يومي للرسم البياني البسيط
    final Map<String, double> dailyQorosh = {};

    for (var b in filtered) {
      final q = double.tryParse(b['qorosh_count'].toString()) ?? 0;
      final a = double.tryParse(b['amount_ssp'].toString()) ?? 0;
      totalQorosh += q;
      totalAmount += a;

      final dateKey = b['booking_date'].toString();
      dailyQorosh[dateKey] = (dailyQorosh[dateKey] ?? 0) + q;
    }

    final sortedDates = dailyQorosh.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(title: const Text('التقارير والإحصائيات', style: TextStyle(fontWeight: FontWeight.w900))),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchBookings,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // خيارات اختيار الفترة
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: const Text('هذا الأسبوع'),
                            selected: _selectedPeriod == 'this_week',
                            onSelected: (_) => setState(() => _selectedPeriod = 'this_week'),
                            selectedColor: kPrimary.withValues(alpha: 0.2),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('الأسبوع الماضي'),
                            selected: _selectedPeriod == 'last_week',
                            onSelected: (_) => setState(() => _selectedPeriod = 'last_week'),
                            selectedColor: kPrimary.withValues(alpha: 0.2),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('هذا الشهر'),
                            selected: _selectedPeriod == 'this_month',
                            onSelected: (_) => setState(() => _selectedPeriod = 'this_month'),
                            selectedColor: kPrimary.withValues(alpha: 0.2),
                          ),
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: const Text('الشهر الماضي'),
                            selected: _selectedPeriod == 'last_month',
                            onSelected: (_) => setState(() => _selectedPeriod = 'last_month'),
                            selectedColor: kPrimary.withValues(alpha: 0.2),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ملخص الفترة
                    Row(
                      children: [
                        Expanded(
                          child: StatTile(
                            title: 'إجمالي الحجوزات',
                            value: '$totalBookings',
                            icon: Icons.bookmark,
                            color: kSecondary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatTile(
                            title: 'إجمالي القروش',
                            value: '$totalQorosh',
                            icon: Icons.bakery_dining,
                            color: kPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    StatTile(
                      title: 'إجمالي العائد (جنيه سوداني)',
                      value: '$totalAmount ج.س',
                      icon: Icons.money,
                      color: kAccent,
                    ),
                    const SizedBox(height: 32),

                    // الرسم البياني بالأعمدة البسيط
                    const SectionTitle(title: 'التفصيل اليومي للقروش'),
                    const SizedBox(height: 12),
                    AppCard(
                      child: sortedDates.isEmpty
                          ? const Padding(
                              padding: EdgeInsets.all(32),
                              child: Center(child: Text('لا توجد بيانات كافية لعرض الرسم البياني في هذه الفترة')),
                            )
                          : SizedBox(
                              height: 200,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: sortedDates.map((date) {
                                  final val = dailyQorosh[date] ?? 0;
                                  // حساب الارتفاع النسبي (افتراض الحد الأقصى 50 قروش كمقياس بسيط أو أعلى قيمة)
                                  final maxVal = dailyQorosh.values.fold<double>(1.0, (prev, element) => element > prev ? element : prev);
                                  final heightFactor = (val / (maxVal == 0 ? 1 : maxVal)).clamp(0.1, 1.0);

                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text('${val.toInt()}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 4),
                                      TweenAnimationBuilder<double>(
                                        tween: Tween(begin: 0, end: heightFactor),
                                        duration: const Duration(milliseconds: 600),
                                        builder: (context, animVal, _) {
                                          return Container(
                                            width: 24,
                                            height: 120 * animVal,
                                            decoration: BoxDecoration(
                                              color: kPrimary,
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 8),
                                      Text(date.substring(5), style: TextStyle(fontSize: 10, color: Theme.of(context).hintColor)),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }
}