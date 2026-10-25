// DESIGN: تطبيق عيش جوال | الهوية السودانية العصرية | اللون الرئيسي: البرتقالي التراثي (#E65100) | العنصر المميز: تدرجات البطاقات وحركات الظهور السلسة
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import 'dart:async' as apkas;
import 'dart:convert' as apkjs;
import 'dart:io' as apkio;
import 'package:flutter/widgets.dart' as apkw;
import 'package:url_launcher/url_launcher.dart' as apkul;

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
  runApp(const BreadCustomerApp());
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

  static Future<bool> deleteRecord(String table, int id) async {
    try {
      final url = Uri.parse('$kSupabaseUrl/rest/v1/$table?id=eq.$id');
      final client = HttpClient();
      final request = await client.deleteUrl(url);
      final headers = await _headers();
      headers.forEach((key, value) => request.headers.add(key, value));
      final response = await request.close();
      return response.statusCode == HttpStatus.ok || response.statusCode == HttpStatus.noContent;
    } catch (_) {}
    return false;
  }
}

// --- التطبيق الرئيسي ---
class BreadCustomerApp extends StatelessWidget {
  const BreadCustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تطبيق الزبائن - العيش',
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
      home: const MainGate(),
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
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
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
    return Center(
      child: Padding(
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
              child: Icon(icon, size: 56, color: kPrimaryColor),
            ),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(subtitle, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 14), textAlign: TextAlign.center),
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

// --- البوابة الرئيسية (التحقق من التسجيل) ---
class MainGate extends StatefulWidget {
  const MainGate({super.key});

  @override
  State<MainGate> createState() => _MainGateState();
}

class _MainGateState extends State<MainGate> {
  bool _isLoading = true;
  Map<String, dynamic>? _currentUser;

  @override
  void initState() {
    super.initState();
    _checkRegistration();
  }

  Future<void> _checkRegistration() async {
    final users = await SupabaseService.getTable('sni79b_users', queryParams: 'order=id.desc&limit=1');
    if (!mounted) return;
    setState(() {
      if (users.isNotEmpty) {
        _currentUser = users[0];
      }
      _isLoading = false;
    });
  }

  void _onRegistered(Map<String, dynamic> user) {
    setState(() {
      _currentUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: kPrimaryColor)),
      );
    }

    if (_currentUser == null) {
      return RegistrationScreen(onRegistered: _onRegistered);
    }

    return HomeScreen(currentUser: _currentUser!);
  }
}

// --- شاشة التسجيل ---
class RegistrationScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onRegistered;
  const RegistrationScreen({super.key, required this.onRegistered});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _workplaceController = TextEditingController();
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final data = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'workplace': _workplaceController.text.trim(),
    };

    final result = await SupabaseService.insertRecord('sni79b_users', data);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result != null) {
      widget.onRegistered(result);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدث خطأ أثناء التسجيل، تأكد من الاتصال بالإنترنت')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [kPrimaryColor, kSecondaryColor]),
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Column(
                      children: [
                        Icon(Icons.bakery_dining_rounded, size: 64, color: Colors.white),
                        SizedBox(height: 12),
                        Text('تسجيل زبون جديد', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white)),
                        SizedBox(height: 4),
                        Text('أدخل بياناتك للبدء في طلب وعرض العيش', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'الاسم الكامل', prefixIcon: Icon(Icons.person_outline)),
                    validator: (v) => v == null || v.isEmpty ? 'الرجاء إدخال الاسم' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(labelText: 'رقم الهاتف', prefixIcon: Icon(Icons.phone_outlined)),
                    validator: (v) => v == null || v.isEmpty ? 'الرجاء إدخال رقم الهاتف' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _workplaceController,
                    decoration: const InputDecoration(labelText: 'مكان العمل / السكن', prefixIcon: Icon(Icons.work_outline)),
                    validator: (v) => v == null || v.isEmpty ? 'الرجاء إدخال مكان العمل' : null,
                  ),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('حفظ والانتقال'),
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

// --- الشاشة الرئيسية ونظام التبويبات ---
class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  const HomeScreen({super.key, required this.currentUser});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<dynamic> _orders = [];
  bool _isOrderingLocked = false;
  bool _isLoading = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchData(silent: true));
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    final userId = widget.currentUser['id'];
    
    final ordersFuture = SupabaseService.getTable('sni79b_orders', queryParams: 'user_id=eq.$userId&order=id.desc');
    final settingsFuture = SupabaseService.getTable('sni79b_settings', queryParams: 'order=id.desc&limit=1');

    final results = await Future.wait([ordersFuture, settingsFuture]);

    if (!mounted) return;
    setState(() {
      _orders = results[0];
      final settingsList = results[1];
      if (settingsList.isNotEmpty) {
        _isOrderingLocked = settingsList[0]['is_ordering_locked'] ?? false;
      }
      _isLoading = false;
    });
  }

  void _showAddOrderModal() {
    if (_isOrderingLocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('عذراً، الحجوزات مقفلة حالياً من قبل الإدارة')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: AddOrderSheet(
          currentUser: widget.currentUser,
          onOrderAdded: () {
            _fetchData();
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeOrders = _orders.where((o) => o['status'] != 'جاهز').toList();
    final archivedOrders = _orders.where((o) => o['status'] == 'جاهز').toList();

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          OrdersListTab(
            currentUser: widget.currentUser,
            orders: _orders,
            isLocked: _isOrderingLocked,
            isLoading: _isLoading,
            onRefresh: _fetchData,
          ),
          CurrentMonitorTab(
            orders: activeOrders,
            isLoading: _isLoading,
          ),
          ArchiveTab(
            orders: archivedOrders,
            isLoading: _isLoading,
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _isOrderingLocked ? null : _showAddOrderModal,
              backgroundColor: _isOrderingLocked ? Colors.grey : kPrimaryColor,
              icon: const Icon(Icons.add, color: Colors.white),
              label: Text(_isOrderingLocked ? 'الحجوزات مقفلة' : 'حجز عيش جديد', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.list_alt_rounded),
            label: 'الطلبات',
          ),
          NavigationDestination(
            icon: Icon(Icons.monitor_heart_outlined),
            label: 'المراقبة',
          ),
          NavigationDestination(
            icon: Icon(Icons.archive_outlined),
            label: 'الأرشيف',
          ),
        ],
      ),
    );
  }
}

// --- تبويب قائمة الحجوزات (الشاشة الأولى الفخمة) ---
class OrdersListTab extends StatelessWidget {
  final Map<String, dynamic> currentUser;
  final List<dynamic> orders;
  final bool isLocked;
  final bool isLoading;
  final VoidCallback onRefresh;

  const OrdersListTab({
    super.key,
    required this.currentUser,
    required this.orders,
    required this.isLocked,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final totalSpent = orders.fold<double>(0.0, (sum, item) => sum + ((item['amount'] as num?)?.toDouble() ?? 0.0));

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: kPrimaryColor,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('أهلاً، ${currentUser['name']}', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Text(currentUser['workplace'], style: const TextStyle(color: Colors.white70, fontSize: 14)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                      ],
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
                  if (isLocked)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.lock_outline, color: Colors.red),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'تنبيه: تم قفل استقبال الحجوزات مؤقتاً من قبل الإدارة.',
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                              const Text('المبلغ الكلي (ج.س)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                              const SizedBox(height: 8),
                              Text('$totalSpent', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kPrimaryColor)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SectionTitle(title: 'سجل حجوزات العيش'),
                ],
              ),
            ),
          ),
          isLoading
              ? const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator(color: kPrimaryColor)),
                )
              : orders.isEmpty
                  ? SliverFillRemaining(
                      child: EmptyState(
                        icon: Icons.bakery_dining_outlined,
                        title: 'لا توجد حجوزات حالية',
                        subtitle: 'اضغط على زر الحجز بالأسفل لطلب عيش جديد',
                      ),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final order = orders[index];
                            return FadeIn(
                              index: index,
                              child: OrderCard(order: order, onDeleted: onRefresh),
                            );
                          },
                          childCount: orders.length,
                        ),
                      ),
                    ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }
}

// --- بطاقة الطلب الفردية مع إمكانية السحب للحذف ---
class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onDeleted;

  const OrderCard({super.key, required this.order, required this.onDeleted});

  Future<void> _delete(BuildContext context) async {
    final success = await SupabaseService.deleteRecord('sni79b_orders', order['id']);
    if (success) {
      onDeleted();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الطلب بنجاح')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = order['status'] ?? 'لم يجهز';
    Color statusColor = Colors.orange;
    if (status == 'قيد التنفيذ') statusColor = Colors.blue;
    if (status == 'جاهز') statusColor = Colors.green;

    return Dismissible(
      key: Key(order['id'].toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(22)),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (_) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('تأكيد الحذف'),
            content: const Text('هل أنت متأكد من حذف هذا الحجز؟'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('حذف', style: TextStyle(color: Colors.red))),
            ],
          ),
        );
      },
      onDismissed: (_) => _delete(context),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                Text('طلب #${order['id']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(status, style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ],
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                Text('المبلغ: ${order['amount']} ج.س', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(order['payment_method'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- شاشة مراقبة الحجز الحالي ---
class CurrentMonitorTab extends StatelessWidget {
  final List<dynamic> orders;
  final bool isLoading;

  const CurrentMonitorTab({super.key, required this.orders, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('مراقبة الحجز الحالي', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : orders.isEmpty
              ? EmptyState(
                  icon: Icons.monitor_heart_outlined,
                  title: 'لا توجد حجوزات نشطة',
                  subtitle: 'حجوزاتك التي لم تكتمل ستظهر هنا لمتابعة حالتها',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final status = order['status'] ?? 'لم يجهز';
                    
                    int stepIndex = 0;
                    if (status == 'قيد التنفيذ') stepIndex = 1;
                    if (status == 'جاهز') stepIndex = 2;

                    return FadeIn(
                      index: index,
                      child: AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.between,
                              children: [
                                Text('طلب رقم #${order['id']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                Text('${order['amount']} ج.س', style: const TextStyle(color: kPrimaryColor, fontWeight: FontWeight.bold)),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                _buildStepIndicator('لم يجهز', 0, stepIndex),
                                _buildStepLine(stepIndex >= 1),
                                _buildStepIndicator('قيد التنفيذ', 1, stepIndex),
                                _buildStepLine(stepIndex >= 2),
                                _buildStepIndicator('جاهز', 2, stepIndex),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildStepIndicator(String title, int index, int currentIndex) {
    final isActive = index <= currentIndex;
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive ? kPrimaryColor : Colors.grey.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isActive
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : Text('${index + 1}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(height: 6),
          Text(title, style: TextStyle(fontSize: 11, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }

  Widget _buildStepLine(bool isActive) {
    return Container(
      height: 2,
      width: 20,
      color: isActive ? kPrimaryColor : Colors.grey.withValues(alpha: 0.3),
    );
  }
}

// --- شاشة أرشيف الطلبات السابقة ---
class ArchiveTab extends StatelessWidget {
  final List<dynamic> orders;
  final bool isLoading;

  const ArchiveTab({super.key, required this.orders, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('أرشيف الطلبات', style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : orders.isEmpty
              ? EmptyState(
                  icon: Icons.archive_outlined,
                  title: 'الأرشيف فارغ',
                  subtitle: 'الطلبات المكتملة (جاهزة) تظهر هنا تلقائياً',
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return FadeIn(
                      index: index,
                      child: AppCard(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.between,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('طلب رقم #${order['id']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text('طريقة الدفع: ${order['payment_method']}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('${order['amount']} ج.س', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: kPrimaryColor)),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                  child: const Text('مكتمل', style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

// --- نموذج إضافة طلب جديد (Bottom Sheet) ---
class AddOrderSheet extends StatefulWidget {
  final Map<String, dynamic> currentUser;
  final VoidCallback onOrderAdded;

  const AddOrderSheet({super.key, required this.currentUser, required this.onOrderAdded});

  @override
  State<AddOrderSheet> createState() => _AddOrderSheetState();
}

class _AddOrderSheetState extends State<AddOrderSheet> {
  final _amountController = TextEditingController();
  String _paymentMethod = 'نقدي';
  bool _isSubmitting = false;

  Future<void> _submit() async {
    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) return;
    final amount = double.tryParse(amountText) ?? 0;
    if (amount <= 0) return;

    setState(() => _isSubmitting = true);

    final data = {
      'user_id': widget.currentUser['id'],
      'customer_name': widget.currentUser['name'],
      'workplace': widget.currentUser['workplace'],
      'amount': amount,
      'payment_method': _paymentMethod,
      'status': 'لم يجهز',
    };

    final result = await SupabaseService.insertRecord('sni79b_orders', data);
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result != null) {
      widget.onOrderAdded();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل إرسال الطلب، تأكد من الاتصال')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('حجز عيش جديد', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'المبلغ بالجنيه السوداني',
              prefixIcon: Icon(Icons.money_outlined),
            ),
          ),
          const SizedBox(height: 16),
          const Text('طريقة الدفع', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('نقدي'),
                  value: 'نقدي',
                  groupValue: _paymentMethod,
                  onChanged: (v) => setState(() => _paymentMethod = v!),
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('أجل'),
                  value: 'أجل',
                  groupValue: _paymentMethod,
                  onChanged: (v) => setState(() => _paymentMethod = v!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isSubmitting ? null : _submit,
            child: _isSubmitting
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('تأكيد الطلب'),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

// ===== تحديث التطبيق (يُضاف تلقائياً) =====
const int _apkCur = 2;
const String _apkUrl = 'https://raw.githubusercontent.com/alkahlizero564-sudo/apk-app/main/apps/breadcustomer/update.json';

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
