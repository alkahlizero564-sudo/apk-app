// DESIGN: تطبيق إدارة المخبز | الهوية السودانية العصرية | اللون الرئيسي: البرتقالي التراثي (#E65100) | العنصر المميز: لوحة تحكم متكاملة وتحديث حي للطلبات
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

// --- الثوابت والألوان ---
const String kSupabaseUrl = 'https://qlvmxnoewxzykgbneadv.supabase.co';
const String kAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFsdm14bm9ld3h6eWtnYm5lYWR2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE2NDAwMjIsImV4cCI6MjEwNzIxNjAyMn0.WtsiO0PrUrwxKjpcyB3949kXSZeijtlJYySSbh0ieRk';

const Color kPrimaryColor = Color(0xFFE65100);
const Color kSecondaryColor = Color(0xFFFF8F00);
const Color kScaffoldLight = Color(0xFFF8F9FA);
const Color kScaffoldDark = Color(0xFF121212);
const Color kSurfaceLight = Colors.white;
const Color kSurfaceDark = Color(0xFF1E1E1E);

void main() {
  runApp(const BreadAdminApp());
}

// --- طبقة الاتصال بـ Supabase (REST API) ---
class SupabaseService {
  static Future<Map<String, String>> _headers() async {
    return {
      'apikey': kAnonKey,
      'Authorization': 'Bearer $kAnonKey',
      'Content-Type': 'application/json',
      'Prefer': 'return=representation',
    };
  }

  static Future<List<dynamic>> getTable(String table, {String? queryParams}) async {
    try {
      final url = Uri.parse('$kSupabaseUrl/rest/v1/$table${queryParams != null ? '?$queryParams' : ''}');
      final client = HttpClient();
      final request = await client.getUrl(url);
      final headers = await _headers();
      headers.forEach((key, value) => request.headers.add(key, value));
      final response = await request.close();
      if (response.statusCode == HttpStatus.ok) {
        final responseBody = await response.transform(utf8.decoder).join();
        return json.decode(responseBody) as List<dynamic>;
      }
    } catch (_) {}
    return [];
  }

  static Future<Map<String, dynamic>?> insertRecord(String table, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$kSupabaseUrl/rest/v1/$table');
      final client = HttpClient();
      final request = await client.postUrl(url);
      final headers = await _headers();
      headers.forEach((key, value) => request.headers.add(key, value));
      request.write(json.encode(data));
      final response = await request.close();
      if (response.statusCode == HttpStatus.created || response.statusCode == HttpStatus.ok) {
        final responseBody = await response.transform(utf8.decoder).join();
        final decoded = json.decode(responseBody);
        if (decoded is List && decoded.isNotEmpty) {
          return decoded[0] as Map<String, dynamic>;
        } else if (decoded is Map<String, dynamic>) {
          return decoded;
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> updateRecord(String table, int id, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$kSupabaseUrl/rest/v1/$table?id=eq.$id');
      final client = HttpClient();
      final request = await client.patchUrl(url);
      final headers = await _headers();
      headers.forEach((key, value) => request.headers.add(key, value));
      request.write(json.encode(data));
      final response = await request.close();
      return response.statusCode == HttpStatus.ok || response.statusCode == HttpStatus.noContent;
    } catch (_) {}
    return false;
  }
}

// --- التطبيق الرئيسي ---
class BreadAdminApp extends StatelessWidget {
  const BreadAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تطبيق الإدارة - العيش',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryColor,
          brightness: Brightness.light,
          primary: kPrimaryColor,
          secondary: kSecondaryColor,
          surface: kSurfaceLight,
        ),
        scaffoldBackgroundColor: kScaffoldLight,
        cardTheme: CardThemeData(
          color: kSurfaceLight,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            backgroundColor: kPrimaryColor,
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.withValues(alpha: 0.08),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: kPrimaryColor, width: 1.5)),
        ),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0, centerTitle: true),
        fontFamily: 'Cairo',
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryColor,
          brightness: Brightness.dark,
          primary: kPrimaryColor,
          secondary: kSecondaryColor,
          surface: kSurfaceDark,
        ),
        scaffoldBackgroundColor: kScaffoldDark,
        cardTheme: CardThemeData(
          color: kSurfaceDark,
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(52),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            backgroundColor: kPrimaryColor,
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Cairo'),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withValues(alpha: 0.05),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: kPrimaryColor, width: 1.5)),
        ),
        appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0, centerTitle: true),
        fontFamily: 'Cairo',
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox(),
        );
      },
      home: const AdminHomeScreen(),
    );
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
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
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          if (actionText != null && onAction != null)
            TextButton(
              onPressed: onAction,
              child: Text(actionText!, style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
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
  const EmptyState({super.key, required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: kPrimaryColor.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 56, color: kPrimaryColor),
            ),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 14), textAlign: TextAlign.center),
          ],
        ),
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
      duration: Duration(milliseconds: 300 + (index * 80)),
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

// --- لوحة التحكم الرئيسية للإدارة ---
class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _currentIndex = 0;
  List<dynamic> _orders = [];
  List<dynamic> _users = [];
  bool _isOrderingLocked = false;
  bool _isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchAllData(silent: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchAllData({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    
    final ordersFuture = SupabaseService.getTable('sni79b_orders', queryParams: 'order=id.desc');
    final usersFuture = SupabaseService.getTable('sni79b_users');
    final settingsFuture = SupabaseService.getTable('sni79b_settings', queryParams: 'order=id.desc&limit=1');

    final results = await Future.wait([ordersFuture, usersFuture, settingsFuture]);
    
    if (!mounted) return;
    setState(() {
      _orders = results[0];
      _users = results[1];
      final settingsList = results[2];
      if (settingsList.isNotEmpty) {
        _isOrderingLocked = settingsList[0]['is_ordering_locked'] ?? false;
      }
      _isLoading = false;
    });
  }

  Future<void> _toggleLock() async {
    final newState = !_isOrderingLocked;
    setState(() => _isOrderingLocked = newState);
    
    // حفظ حالة القفل في السحابة مع إنشاء الجدول تلقائياً إن لم يكن موجوداً
    final settingsList = await SupabaseService.getTable('sni79b_settings', queryParams: 'order=id.desc&limit=1');
    if (settingsList.isNotEmpty) {
      final id = settingsList[0]['id'];
      await SupabaseService.updateRecord('sni79b_settings', id, {'is_ordering_locked': newState});
    } else {
      await SupabaseService.insertRecord('sni79b_settings', {'is_ordering_locked': newState});
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(newState ? 'تم قفل الحجوزات مؤقتاً' : 'تم فتح الحجوزات بنجاح')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      MainDashboardTab(
        orders: _orders,
        usersCount: _users.length,
        isLocked: _isOrderingLocked,
        onToggleLock: _toggleLock,
        isLoading: _isLoading,
        onRefresh: _fetchAllData,
      ),
      OrdersManagementTab(
        orders: _orders,
        isLoading: _isLoading,
        onRefresh: _fetchAllData,
      ),
      ReportsTab(
        orders: _orders,
        isLoading: _isLoading,
      ),
      SettingsTab(
        usersCount: _users.length,
        isLoading: _isLoading,
      ),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.list_alt_rounded), label: 'الطلبات'),
          NavigationDestination(icon: Icon(Icons.bar_chart_rounded), label: 'التقارير'),
          NavigationDestination(icon: Icon(Icons.settings_rounded), label: 'الإعدادات'),
        ],
      ),
    );
  }
}

// --- الشاشة الرئيسية (زر القفل والفتح + الملخص) ---
class MainDashboardTab extends StatelessWidget {
  final List<dynamic> orders;
  final int usersCount;
  final bool isLocked;
  final VoidCallback onToggleLock;
  final bool isLoading;
  final VoidCallback onRefresh;

  const MainDashboardTab({
    super.key,
    required this.orders,
    required this.usersCount,
    required this.isLocked,
    required this.onToggleLock,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final totalAmount = orders.fold<double>(0.0, (sum, item) => sum + ((item['amount'] as num?)?.toDouble() ?? 0.0));

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: kPrimaryColor,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('إدارة مخبز العيش', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                    SizedBox(height: 4),
                    Text('لوحة التحكم الخاصة بصاحب النشاط', style: TextStyle(color: Colors.white70, fontSize: 14)),
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
                  // زر قفل وفتح الحجز
                  AppCard(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(isLocked ? 'الحجوزات مقفلة حالياً' : 'الحجوزات مفتوحة للزبائن',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isLocked ? Colors.red : Colors.green)),
                            const SizedBox(height: 4),
                            const Text('اضغط للتحكم في استقبال الطلبات', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        Switch(
                          value: !isLocked,
                          activeColor: Colors.green,
                          inactiveThumbColor: Colors.red,
                          onChanged: (_) => onToggleLock(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: AppCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('إجمالي الطلبات', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              const SizedBox(height: 8),
                              Text('${orders.length}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('إجمالي المبالغ', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              const SizedBox(height: 8),
                              Text('$totalAmount ج.س', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: kPrimaryColor)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SectionTitle(title: 'أحدث الطلبات الواردة'),
                ],
              ),
            ),
          ),
          isLoading
              ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: kPrimaryColor)))
              : orders.isEmpty
                  ? const SliverFillRemaining(child: EmptyState(icon: Icons.list_alt, title: 'لا توجد طلبات', subtitle: 'لم يقم أي زبون بطلب عيش حتى الآن'))
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final order = orders[index];
                            return FadeIn(
                              index: index,
                              child: AdminOrderCard(order: order, onStatusChanged: onRefresh),
                            );
                          },
                          childCount: orders.length > 5 ? 5 : orders.length,
                        ),
                      ),
                    ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

// --- شاشة قائمة الطلبات الواردة ---
class OrdersManagementTab extends StatelessWidget {
  final List<dynamic> orders;
  final bool isLoading;
  final VoidCallback onRefresh;

  const OrdersManagementTab({super.key, required this.orders, required this.isLoading, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('قائمة الطلبات الواردة', style: TextStyle(fontWeight: FontWeight.w800))),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : orders.isEmpty
              ? const EmptyState(icon: Icons.inbox_outlined, title: 'لا توجد طلبات', subtitle: 'ستظهر طلبات الزبائن هنا فور إرسالها')
              : RefreshIndicator(
                  onRefresh: () async => onRefresh(),
                  color: kPrimaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return FadeIn(
                        index: index,
                        child: AdminOrderCard(order: order, onStatusChanged: onRefresh),
                      );
                    },
                  ),
                ),
    );
  }
}

// --- بطاقة الطلب الخاصة بالإدارة (مع إمكانية تغيير الحالة) ---
class AdminOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onStatusChanged;

  const AdminOrderCard({super.key, required this.order, required this.onStatusChanged});

  Future<void> _updateStatus(String newStatus, BuildContext context) async {
    final success = await SupabaseService.updateRecord('sni79b_orders', order['id'], {'status': newStatus});
    if (success) {
      onStatusChanged();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تحديث حالة الطلب إلى: $newStatus')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = order['status'] ?? 'لم يجهز';
    Color statusColor = Colors.orange;
    if (status == 'قيد التنفيذ') statusColor = Colors.blue;
    if (status == 'جاهز') statusColor = Colors.green;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('طلب #${order['id']} - ${order['customer_name']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('مكان العمل: ${order['workplace']}', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${order['amount']} ج.س (${order['payment_method']})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: kPrimaryColor)),
              DropdownButton<String>(
                value: ['لم يجهز', 'قيد التنفيذ', 'جاهز'].contains(status) ? status : 'لم يجهز',
                items: const [
                  DropdownMenuItem(value: 'لم يجهز', child: Text('لم يجهز', style: TextStyle(fontSize: 12))),
                  DropdownMenuItem(value: 'قيد التنفيذ', child: Text('قيد التنفيذ', style: TextStyle(fontSize: 12))),
                  DropdownMenuItem(value: 'جاهز', child: Text('جاهز', style: TextStyle(fontSize: 12))),
                ],
                onChanged: (val) {
                  if (val != null && val != status) {
                    _updateStatus(val, context);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// --- شاشة التقارير الشهرية والأسبوعية ---
class ReportsTab extends StatelessWidget {
  final List<dynamic> orders;
  final bool isLoading;

  const ReportsTab({super.key, required this.orders, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final totalAmount = orders.fold<double>(0.0, (sum, item) => sum + ((item['amount'] as num?)?.toDouble() ?? 0.0));

    final now = DateTime.now();
    final weekOrders = orders.where((o) {
      if (o['created_at'] == null) return false;
      final date = DateTime.tryParse(o['created_at']) ?? now;
      return now.difference(date).inDays <= 7;
    }).toList();

    final monthOrders = orders.where((o) {
      if (o['created_at'] == null) return false;
      final date = DateTime.tryParse(o['created_at']) ?? now;
      return now.difference(date).inDays <= 30;
    }).toList();

    final weekAmount = weekOrders.fold<double>(0.0, (sum, item) => sum + ((item['amount'] as num?)?.toDouble() ?? 0.0));
    final monthAmount = monthOrders.fold<double>(0.0, (sum, item) => sum + ((item['amount'] as num?)?.toDouble() ?? 0.0));

    return Scaffold(
      appBar: AppBar(title: const Text('التقارير المالية وإجمالي الطلبات', style: TextStyle(fontWeight: FontWeight.w800))),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SectionTitle(title: 'تقرير الأسبوع الأخير'),
                Row(
                  children: [
                    Expanded(child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('طلبات الأسبوع', style: TextStyle(color: Colors.grey, fontSize: 12)), const SizedBox(height: 8), Text('${weekOrders.length}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))]))),
                    const SizedBox(width: 12),
                    Expanded(child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('مبالغ الأسبوع', style: TextStyle(color: Colors.grey, fontSize: 12)), const SizedBox(height: 8), Text('$weekAmount ج.س', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kPrimaryColor))]))),
                  ],
                ),
                const SizedBox(height: 16),
                const SectionTitle(title: 'تقرير الشهر الأخير'),
                Row(
                  children: [
                    Expanded(child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('طلبات الشهر', style: TextStyle(color: Colors.grey, fontSize: 12)), const SizedBox(height: 8), Text('${monthOrders.length}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))]))),
                    const SizedBox(width: 12),
                    Expanded(child: AppCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('مبالغ الشهر', style: TextStyle(color: Colors.grey, fontSize: 12)), const SizedBox(height: 8), Text('$monthAmount ج.س', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kPrimaryColor))]))),
                  ],
                ),
                const SizedBox(height: 16),
                const SectionTitle(title: 'الملخص الإجمالي الكلي'),
                AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('إجمالي عدد الطلبات الكلي:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('${orders.length}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('إجمالي المبالغ الكلي:', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('$totalAmount ج.س', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: kPrimaryColor)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// --- شاشة الإعدادات لمعرفة عدد المسجلين ---
class SettingsTab extends StatelessWidget {
  final int usersCount;
  final bool isLoading;

  const SettingsTab({super.key, required this.usersCount, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات ومعلومات التطبيق', style: TextStyle(fontWeight: FontWeight.w800))),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                AppCard(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('إجمالي الزبائن المسجلين', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          SizedBox(height: 4),
                          Text('عدد المستخدمين المسجلين في النظام', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(color: kPrimaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
                        child: Text('$usersCount', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: kPrimaryColor)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('معلومات النظام', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(height: 8),
                      Text('تطبيق الإدارة - متصل بالسحابة عبر Supabase', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      SizedBox(height: 4),
                      Text('الإصدار: 1.0.0 (الهوية السودانية العصرية)', style: TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}