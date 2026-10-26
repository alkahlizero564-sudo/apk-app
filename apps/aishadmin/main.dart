// DESIGN: تطبيق الإدارة الذكي | التحكم الشامل بالمصنع | لون رئيسي أخضر زمردي (#059669) | بطاقات زجاجية وعناصر تفاعلية متطورة

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

// --- الثوابت اللونية والتصميمية ---
const Color kPrimaryColor = Color(0xFF059669);
const Color kSecondaryColor = Color(0xFF10B981);
const Color kAccentColor = Color(0xFF34D399);
const Color kDarkBg = Color(0xFF0F172A);
const Color kLightBg = Color(0xFFF8FAFC);
const Color kCardLight = Colors.white;
const Color kCardDark = Color(0xFF1E293B);

void main() {
  runApp(const FactoryAdminApp());
}

class FactoryAdminApp extends StatelessWidget {
  const FactoryAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'إدارة المصنع الذكي',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: kLightBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryColor,
          brightness: Brightness.light,
          primary: kPrimaryColor,
          secondary: kSecondaryColor,
          surface: kCardLight,
        ),
        cardTheme: CardThemeData(
          color: kCardLight,
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.05),
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
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: kDarkBg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: kPrimaryColor,
          brightness: Brightness.dark,
          primary: kPrimaryColor,
          secondary: kSecondaryColor,
          surface: kCardDark,
        ),
        cardTheme: CardThemeData(
          color: kCardDark,
          elevation: 4,
          shadowColor: Colors.black.withValues(alpha: 0.3),
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
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const AdminMainGateScreen(),
    );
  }
}

// --- طبقة الاتصال بـ Supabase (REST API) ---
class SupabaseService {
  static const String _baseUrl = 'https://qlvmxnoewxzykgbneadv.supabase.co/rest/v1';
  static const String _apiKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFsdm14bm9ld3h6eWtnYm5lYWR2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE2NDAwMjIsImV4cCI6MjEwNzIxNjAyMn0.WtsiO0PrUrwxKjpcyB3949kXSZeijtlJYySSbh0ieRk';

  static Map<String, String> get _headers => {
        'apikey': _apiKey,
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
        'Prefer': 'return=representation',
      };

  static Future<List<dynamic>> fetchTable(String table, {String? queryParams}) async {
    try {
      final url = Uri.parse('$_baseUrl/$table${queryParams != null ? '?$queryParams' : ''}');
      final request = await HttpClient().getUrl(url);
      _headers.forEach((key, value) => request.headers.set(key, value));
      final response = await request.close();
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        return jsonDecode(body) as List<dynamic>;
      }
    } catch (_) {}
    return [];
  }

  static Future<bool> insertRecord(String table, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$_baseUrl/$table');
      final request = await HttpClient().postUrl(url);
      _headers.forEach((key, value) => request.headers.set(key, value));
      request.add(utf8.encode(jsonEncode(data)));
      final response = await request.close();
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> updateRecord(String table, String idCol, String idVal, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$_baseUrl/$table?$idCol=eq.$idVal');
      final request = await HttpClient().patchUrl(url);
      _headers.forEach((key, value) => request.headers.set(key, value));
      request.add(utf8.encode(jsonEncode(data)));
      final response = await request.close();
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deleteRecord(String table, String idCol, String idVal) async {
    try {
      final url = Uri.parse('$_baseUrl/$table?$idCol=eq.$idVal');
      final request = await HttpClient().deleteUrl(url);
      _headers.forEach((key, value) => request.headers.set(key, value));
      final response = await request.close();
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      return false;
    }
  }
}

// --- الويدجتات المساعدة العامة ---
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const AppCard({super.key, required this.child, this.padding, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: Theme.of(context).cardTheme.color,
        elevation: Theme.of(context).cardTheme.elevation ?? 4,
        shadowColor: Theme.of(context).cardTheme.shadowColor,
        shape: Theme.of(context).cardTheme.shape,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
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
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          if (actionText != null)
            TextButton(
              onPressed: onAction,
              child: Text(actionText!, style: const TextStyle(color: kPrimaryColor)),
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
              child: Icon(icon, size: 64, color: kPrimaryColor),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(color: Theme.of(context).hintColor, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 24),
              FilledButton(
                onPressed: onButtonPressed,
                child: Text(buttonText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class StatTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatTile({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
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
                Text(title, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 13)),
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
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: childWidget,
          ),
        );
      },
      child: child,
    );
  }
}

// --- شاشة البوابة الرئيسية للإدارة ---
class AdminMainGateScreen extends StatefulWidget {
  const AdminMainGateScreen({super.key});

  @override
  State<AdminMainGateScreen> createState() => _AdminMainGateScreenState();
}

class _AdminMainGateScreenState extends State<AdminMainGateScreen> {
  Map<String, dynamic>? currentAdmin;
  bool isLoadingAdmin = true;
  int _currentIndex = 0;
  Timer? _syncTimer;

  List<dynamic> allOrders = [];
  List<dynamic> allUsers = [];
  bool isBookingOpen = true;
  bool isLoadingData = false;

  @override
  void initState() {
    super.initState();
    _checkAdminSession();
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkAdminSession() async {
    setState(() => isLoadingAdmin = false);
  }

  void _onAdminLoggedIn(Map<String, dynamic> admin) {
    setState(() => currentAdmin = admin);
    _startRealtimeSync();
    _fetchAllData();
  }

  void _startRealtimeSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (currentAdmin != null && mounted) {
        _fetchAllData(silent: true);
      }
    });
  }

  Future<void> _fetchAllData({bool silent = false}) async {
    if (!silent) setState(() => isLoadingData = true);

    final ordersRes = await SupabaseService.fetchTable(
      'sbxn6t_orders',
      queryParams: 'order=created_at.desc',
    );

    final usersRes = await SupabaseService.fetchTable(
      'sbxn6t_users',
      queryParams: 'order=created_at.desc',
    );

    final settingsRes = await SupabaseService.fetchTable('sbxn6t_system_settings');
    bool bookingOpen = true;
    if (settingsRes.isNotEmpty) {
      bookingOpen = settingsRes.first['is_booking_open'] ?? true;
    }

    if (mounted) {
      setState(() {
        allOrders = ordersRes;
        allUsers = usersRes;
        isBookingOpen = bookingOpen;
        isLoadingData = false;
      });
    }
  }

  Future<void> _toggleBookingState() async {
    final newState = !isBookingOpen;
    final settingsRes = await SupabaseService.fetchTable('sbxn6t_system_settings');

    bool success = false;
    if (settingsRes.isEmpty) {
      success = await SupabaseService.insertRecord('sbxn6t_system_settings', {
        'setting_id': 'main_setting',
        'is_booking_open': newState,
      });
    } else {
      final idVal = settingsRes.first['id']?.toString() ?? settingsRes.first['setting_id'];
      success = await SupabaseService.updateRecord(
        'sbxn6t_system_settings',
        settingsRes.first.containsKey('id') ? 'id' : 'setting_id',
        idVal.toString(),
        {'is_booking_open': newState},
      );
    }

    if (success) {
      setState(() => isBookingOpen = newState);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(newState ? 'تم فتح الحجز بالكامل' : 'تم قفل الحجز بالكامل')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل تحديث حالة الحجز')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingAdmin) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: kPrimaryColor)),
      );
    }

    if (currentAdmin == null) {
      return AdminLoginScreen(onLoggedIn: _onAdminLoggedIn);
    }

    final screens = [
      AdminDashboardScreen(
        currentAdmin: currentAdmin!,
        allOrders: allOrders,
        isBookingOpen: isBookingOpen,
        isLoading: isLoadingData,
        onRefresh: () => _fetchAllData(),
        onToggleBooking: _toggleBookingState,
      ),
      AdminOrdersScreen(
        allOrders: allOrders,
        onRefresh: () => _fetchAllData(),
      ),
      AdminUsersScreen(
        allUsers: allUsers,
        onRefresh: () => _fetchAllData(),
      ),
      AdminReportsScreen(
        allOrders: allOrders,
        onRefresh: () => _fetchAllData(),
      ),
      AdminProfileScreen(
        currentAdmin: currentAdmin!,
        onLogout: () {
          setState(() {
            currentAdmin = null;
            allOrders = [];
            allUsers = [];
          });
          _syncTimer?.cancel();
        },
      ),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: screens[_currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: kPrimaryColor),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long, color: kPrimaryColor),
            label: 'الطلبات',
          ),
          NavigationDestination(
            icon: Icon(Icons.group_outlined),
            selectedIcon: Icon(Icons.group, color: kPrimaryColor),
            label: 'المستخدمون',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart, color: kPrimaryColor),
            label: 'التقارير',
          ),
          NavigationDestination(
            icon: Icon(Icons.admin_panel_settings_outlined),
            selectedIcon: Icon(Icons.admin_panel_settings, color: kPrimaryColor),
            label: 'الإدارة',
          ),
        ],
      ),
    );
  }
}

// --- شاشة تسجيل دخول الإدارة ---
class AdminLoginScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onLoggedIn;

  const AdminLoginScreen({super.key, required this.onLoggedIn});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedAvatar = '👨‍💼';
  bool _isLoading = false;

  final List<String> _avatars = ['👨‍💼', '👩‍💼', '🧑‍💻', '⭐', '🛡️'];

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال الاسم ورقم الهاتف')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final adminId = 'admin_${DateTime.now().millisecondsSinceEpoch}';
    final adminData = {
      'user_id': adminId,
      'phone': phone,
      'name': name,
      'avatar': _selectedAvatar,
      'role': 'admin',
      'is_blocked': false,
    };

    final success = await SupabaseService.insertRecord('sbxn6t_users', adminData);
    setState(() => _isLoading = false);

    if (success) {
      widget.onLoggedIn(adminData);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل تسجيل الدخول، حاول مرة أخرى')),
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
                  child: const Icon(Icons.admin_panel_settings, size: 64, color: kPrimaryColor),
                ),
                const SizedBox(height: 24),
                const Text(
                  'تطبيق إدارة المصنع الذكي',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'لوحة تحكم صاحب النشاط والإدارة العليا',
                  style: TextStyle(color: Theme.of(context).hintColor, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                const Text('اختر شارة الإدارة', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _avatars.map((av) {
                    final isSelected = _selectedAvatar == av;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedAvatar = av),
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected ? kPrimaryColor.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.1),
                          border: Border.all(
                            color: isSelected ? kPrimaryColor : Colors.transparent,
                            width: 2,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Text(av, style: const TextStyle(fontSize: 24)),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'اسم المدير الكامل',
                    prefixIcon: Icon(Icons.person_outline, color: kPrimaryColor),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف السوداني (مثال: 0912345678)',
                    prefixIcon: Icon(Icons.phone_outlined, color: kPrimaryColor),
                  ),
                ),
                const SizedBox(height: 32),
                FilledButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('دخول لوحة الإدارة'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- لوحة التحكم الرئيسية للإدارة ---
class AdminDashboardScreen extends StatelessWidget {
  final Map<String, dynamic> currentAdmin;
  final List<dynamic> allOrders;
  final bool isBookingOpen;
  final bool isLoading;
  final VoidCallback onRefresh;
  final VoidCallback onToggleBooking;

  const AdminDashboardScreen({
    super.key,
    required this.currentAdmin,
    required this.allOrders,
    required this.isBookingOpen,
    required this.isLoading,
    required this.onRefresh,
    required this.onToggleBooking,
  });

  @override
  Widget build(BuildContext context) {
    final newOrders = allOrders.where((o) => o['status'] == 'جديد').toList();
    final activeOrders = allOrders.where((o) => o['status'] != 'تم الاستلام' && o['status'] != 'ملغي' && o['status'] != 'مرفوض').toList();
    
    double totalCash = 0;
    double totalDeferred = 0;
    for (var o in allOrders) {
      if (o['status'] == 'تم الاستلام') {
        final amount = double.tryParse(o['amount'].toString()) ?? 0;
        if (o['payment_type'] == 'cash') {
          totalCash += amount;
        } else {
          totalDeferred += amount;
        }
      }
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: kPrimaryColor,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
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
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Text(currentAdmin['avatar'] ?? '👨‍💼', style: const TextStyle(fontSize: 28)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('مرحباً بالمدير،', style: TextStyle(color: Colors.white70, fontSize: 14)),
                              Text(
                                currentAdmin['name'],
                                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
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
                  // زارين قفل وفتح الحجز بالكامل
                  AppCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          isBookingOpen ? Icons.lock_open : Icons.lock,
                          color: isBookingOpen ? Colors.green : Colors.red,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('التحكم بحالة الحجز العام', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(
                                isBookingOpen ? 'الحجز مفتوح حالياً للزبائن' : 'الحجز مقفل بالكامل حالياً',
                                style: TextStyle(color: Theme.of(context).hintColor, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: onToggleBooking,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isBookingOpen ? Colors.red : Colors.green,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: Text(isBookingOpen ? 'قفل الحجز' : 'فتح الحجز'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: StatTile(
                          title: 'الطلبات الجديدة',
                          value: '${newOrders.length}',
                          icon: Icons.notification_important,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatTile(
                          title: 'الطلبات النشطة',
                          value: '${activeOrders.length}',
                          icon: Icons.hourglass_top,
                          color: kPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: StatTile(
                          title: 'الحسابات النقدية',
                          value: '$totalCash ج.س',
                          icon: Icons.money,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatTile(
                          title: 'الحسابات الآجلة',
                          value: '$totalDeferred ج.س',
                          icon: Icons.schedule,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const SectionTitle(title: 'الطلبات الجديدة الواردة فوراً'),
                  if (isLoading && allOrders.isEmpty)
                    const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
                  else if (newOrders.isEmpty)
                    const EmptyState(
                      icon: Icons.check_circle_outline,
                      title: 'لا توجد طلبات جديدة',
                      subtitle: 'جميع الطلبات الواردة تمت معالجتها أو لا توجد طلبات جديدة حالياً',
                    )
                  else
                    ...newOrders.asMap().entries.map((entry) {
                      return FadeIn(
                        index: entry.key,
                        child: AdminOrderCard(order: entry.value, onUpdate: onRefresh),
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- شاشة إدارة الطلبات الكاملة ---
class AdminOrdersScreen extends StatefulWidget {
  final List<dynamic> allOrders;
  final VoidCallback onRefresh;

  const AdminOrdersScreen({super.key, required this.allOrders, required this.onRefresh});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  String _filter = 'الكل';

  @override
  Widget build(BuildContext context) {
    final filteredOrders = widget.allOrders.where((o) {
      if (_filter == 'الكل') return true;
      return o['status'] == _filter;
    }).toList();

    final statuses = ['الكل', 'جديد', 'مقبول', 'جاهز للاستلام', 'تم الاستلام', 'مرفوض', 'ملغي'];

    return Scaffold(
      appBar: AppBar(title: const Text('إدارة جميع الطلبات')),
      body: Column(
        children: [
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: statuses.map((st) {
                final isSelected = _filter == st;
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(st),
                    selected: isSelected,
                    onSelected: (val) => setState(() => _filter = st),
                    selectedColor: kPrimaryColor.withValues(alpha: 0.2),
                    labelStyle: TextStyle(
                      color: isSelected ? kPrimaryColor : Theme.of(context).textTheme.bodyLarge?.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => widget.onRefresh(),
              color: kPrimaryColor,
              child: filteredOrders.isEmpty
                  ? const EmptyState(
                      icon: Icons.receipt_long_outlined,
                      title: 'لا توجد طلبات مطابقة',
                      subtitle: 'ستظهر الطلبات هنا حسب التصنيف المختار',
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: filteredOrders.length,
                      itemBuilder: (context, index) {
                        return FadeIn(
                          index: index,
                          child: AdminOrderCard(order: filteredOrders[index], onUpdate: widget.onRefresh),
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

// --- بطاقة الطلب الخاصة بالإدارة مع أزرار تغيير الحالة ---
class AdminOrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onUpdate;

  const AdminOrderCard({super.key, required this.order, required this.onUpdate});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'جديد':
        return Colors.blue;
      case 'مقبول':
        return Colors.amber;
      case 'جاهز للاستلام':
        return kPrimaryColor;
      case 'تم الاستلام':
        return Colors.purple;
      case 'ملغي':
      case 'مرفوض':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateStatus(BuildContext context, String newStatus) async {
    final success = await SupabaseService.updateRecord(
      'sbxn6t_orders',
      'order_id',
      order['order_id'],
      {'status': newStatus},
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تغيير حالة الطلب إلى: $newStatus')),
      );
      onUpdate();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل تحديث حالة الطلب')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = order['status'] ?? 'جديد';
    final statusColor = _getStatusColor(status);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.between,
            children: [
              Text(
                'طلب #${order['order_id']?.toString().substring(order['order_id'].toString().length - 6) ?? ''}',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('معرف الزبون:', style: TextStyle(color: Colors.grey)),
              Text(order['customer_id'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('المبلغ:', style: TextStyle(color: Colors.grey)),
              Text('${order['amount']} جنيه سوداني', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('طريقة الدفع:', style: TextStyle(color: Colors.grey)),
              Text(
                order['payment_type'] == 'cash' ? 'نقدي 💵' : 'آجل 📝',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('مكان العمل:', style: TextStyle(color: Colors.grey)),
              Text(order['work_location'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 16),
          // أزرار تغيير الحالات
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (status == 'جديد') ...[
                ElevatedButton(
                  onPressed: () => _updateStatus(context, 'مقبول'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.amber, foregroundColor: Colors.black),
                  child: const Text('قبول الطلب'),
                ),
                ElevatedButton(
                  onPressed: () => _updateStatus(context, 'مرفوض'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                  child: const Text('رفض الطلب'),
                ),
              ],
              if (status == 'مقبول') ...[
                ElevatedButton(
                  onPressed: () => _updateStatus(context, 'جاهز للاستلام'),
                  style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor, foregroundColor: Colors.white),
                  child: const Text('جاهز للاستلام'),
                ),
              ],
              if (status == 'جاهز للاستلام') ...[
                ElevatedButton(
                  onPressed: () => _updateStatus(context, 'تم الاستلام'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                  child: const Text('تم الاستلام'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// --- شاشة إدارة المستخدمين وحظر المخالفين ---
class AdminUsersScreen extends StatelessWidget {
  final List<dynamic> allUsers;
  final VoidCallback onRefresh;

  const AdminUsersScreen({super.key, required this.allUsers, required this.onRefresh});

  Future<void> _toggleBlockUser(BuildContext context, Map<String, dynamic> user) async {
    final newBlockState = !(user['is_blocked'] ?? false);
    final userIdVal = user['user_id'];

    final success = await SupabaseService.updateRecord(
      'sbxn6t_users',
      'user_id',
      userIdVal,
      {'is_blocked': newBlockState},
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(newBlockState ? 'تم حظر المستخدم بنجاح' : 'تم إلغاء حظر المستخدم')),
      );
      onRefresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل تحديث حالة الحظر')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('إدارة المستخدمين والزبائن')),
      body: RefreshIndicator(
        onRefresh: () async => onRefresh(),
        color: kPrimaryColor,
        child: allUsers.isEmpty
            ? const EmptyState(
                icon: Icons.group_outlined,
                title: 'لا يوجد مستخدمون مسجلون',
                subtitle: 'سيظهر الزبائن والمسجلون هنا فور تسجيلهم في المنصة',
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: allUsers.length,
                itemBuilder: (context, index) {
                  final user = allUsers[index];
                  final isBlocked = user['is_blocked'] ?? false;
                  return FadeIn(
                    index: index,
                    child: AppCard(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: kPrimaryColor.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Text(user['avatar'] ?? '👤', style: const TextStyle(fontSize: 24)),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(user['name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: user['role'] == 'admin' ? Colors.purple.withValues(alpha: 0.15) : Colors.blue.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        user['role'] == 'admin' ? 'مدير' : 'زبون',
                                        style: TextStyle(
                                          color: user['role'] == 'admin' ? Colors.purple : Colors.blue,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(user['phone'] ?? '', style: TextStyle(color: Theme.of(context).hintColor)),
                              ],
                            ),
                          ),
                          if (user['role'] != 'admin')
                            IconButton(
                              onPressed: () => _toggleBlockUser(context, user),
                              icon: Icon(
                                isBlocked ? Icons.lock_open : Icons.block,
                                color: isBlocked ? Colors.green : Colors.red,
                              ),
                              tooltip: isBlocked ? 'إلغاء الحظر' : 'حظر المخالف',
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

// --- شاشة التقارير والكشوفات المالية (يومية، أسبوعية، شهرية) ---
class AdminReportsScreen extends StatefulWidget {
  final List<dynamic> allOrders;
  final VoidCallback onRefresh;

  const AdminReportsScreen({super.key, required this.allOrders, required this.onRefresh});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  String _reportType = 'اليومية';

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final filteredOrders = widget.allOrders.where((o) {
      if (o['status'] != 'تم الاستلام') return false;
      final createdAtStr = o['created_at'];
      if (createdAtStr == null) return false;
      final date = DateTime.tryParse(createdAtStr);
      if (date == null) return false;

      if (_reportType == 'اليومية') {
        return date.year == now.year && date.month == now.month && date.day == now.day;
      } else if (_reportType == 'الأسبوعية') {
        final difference = now.difference(date).inDays;
        return difference <= 7;
      } else {
        return date.year == now.year && date.month == now.month;
      }
    }).toList();

    double totalAmount = 0;
    double cashAmount = 0;
    double deferredAmount = 0;

    for (var o in filteredOrders) {
      final amount = double.tryParse(o['amount'].toString()) ?? 0;
      totalAmount += amount;
      if (o['payment_type'] == 'cash') {
        cashAmount += amount;
      } else {
        deferredAmount += amount;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('كشوفات الحساب والتقارير المالية')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: ['اليومية', 'الأسبوعية', 'الشهرية'].map((type) {
                final isSelected = _reportType == type;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _reportType = type),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? kPrimaryColor : Colors.grey.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        type,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async => widget.onRefresh(),
              color: kPrimaryColor,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  StatTile(
                    title: 'إجمالي المبالغ ($_reportType)',
                    value: '$totalAmount ج.س',
                    icon: Icons.account_balance_wallet,
                    color: kPrimaryColor,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: StatTile(
                          title: 'المبالغ النقدية',
                          value: '$cashAmount ج.س',
                          icon: Icons.money,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatTile(
                          title: 'المبالغ الآجلة',
                          value: '$deferredAmount ج.س',
                          icon: Icons.schedule,
                          color: Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SectionTitle(title: 'تفاصيل الحجوزات المكتملة ($_reportType)'),
                  if (filteredOrders.isEmpty)
                    const EmptyState(
                      icon: Icons.bar_chart,
                      title: 'لا توجد حجوزات مكتملة',
                      subtitle: 'لا توجد بيانات مالية مسجلة لهذه الفترة الزمنية',
                    )
                  else
                    ...filteredOrders.asMap().entries.map((entry) {
                      final order = entry.value;
                      return FadeIn(
                        index: entry.key,
                        child: AppCard(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.between,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'طلب #${order['order_id']?.toString().substring(order['order_id'].toString().length - 6) ?? ''}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    order['payment_type'] == 'cash' ? 'نقدي 💵' : 'آجل 📝',
                                    style: TextStyle(color: Theme.of(context).hintColor, fontSize: 13),
                                  ),
                                ],
                              ),
                              Text(
                                '${order['amount']} ج.س',
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: kPrimaryColor),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- شاشة حساب المدير ---
class AdminProfileScreen extends StatelessWidget {
  final Map<String, dynamic> currentAdmin;
  final VoidCallback onLogout;

  const AdminProfileScreen({super.key, required this.currentAdmin, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حساب الإدارة')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Text(currentAdmin['avatar'] ?? '👨‍💼', style: const TextStyle(fontSize: 48)),
                ),
                const SizedBox(height: 16),
                Text(
                  currentAdmin['name'],
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  currentAdmin['phone'],
                  style: TextStyle(color: Theme.of(context).hintColor, fontSize: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          AppCard(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.badge_outlined, color: kPrimaryColor),
                  title: const Text('معرف المدير الرقمي'),
                  subtitle: Text(currentAdmin['user_id']),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.admin_panel_settings_outlined, color: kPrimaryColor),
                  title: const Text('صلاحيات الحساب'),
                  subtitle: const Text('صاحب النشاط / صلاحيات كاملة'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onLogout,
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            icon: const Icon(Icons.logout),
            label: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}