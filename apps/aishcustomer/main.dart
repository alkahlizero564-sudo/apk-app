// DESIGN: تطبيق المصنع الذكي | الهوية العمالية الرقمية | لون رئيسي أخضر زمردي (#059669) | بطاقات زجاجية وعناصر تفاعلية ثلاثية الأبعاد

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'dart:async' as apkas;
import 'dart:convert' as apkjs;
import 'dart:io' as apkio;
import 'package:flutter/widgets.dart' as apkw;
import 'package:url_launcher/url_launcher.dart' as apkul;

// --- الثوابت اللونية والتصميمية ---
const Color kPrimaryColor = Color(0xFF059669);
const Color kSecondaryColor = Color(0xFF10B981);
const Color kAccentColor = Color(0xFF34D399);
const Color kDarkBg = Color(0xFF0F172A);
const Color kLightBg = Color(0xFFF8FAFC);
const Color kCardLight = Colors.white;
const Color kCardDark = Color(0xFF1E293B);

void main() {
  runApp(const FactoryCustomerApp());
}

class FactoryCustomerApp extends StatelessWidget {
  const FactoryCustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'بوابة زبائن المصنع',
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
      home: const MainGateScreen(),
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

// --- شاشة البوابة الرئيسية وإدارة الحالة والتوجيه ---
class MainGateScreen extends StatefulWidget {
  const MainGateScreen({super.key});

  @override
  State<MainGateScreen> createState() => _MainGateScreenState();
}

class _MainGateScreenState extends State<MainGateScreen> {
  Map<String, dynamic>? currentUser;
  bool isLoadingUser = true;
  int _currentIndex = 0;
  Timer? _syncTimer;

  List<dynamic> myOrders = [];
  bool isBookingOpen = true;
  bool isOrdersLoading = false;

  @override
  void initState() {
    super.initState();
    _checkSavedUser();
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkSavedUser() async {
    setState(() {
      isLoadingUser = false;
    });
  }

  void _onUserRegistered(Map<String, dynamic> user) {
    setState(() {
      currentUser = user;
    });
    _startRealtimeSync();
    _fetchAllData();
  }

  void _startRealtimeSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (currentUser != null && mounted) {
        _fetchAllData(silent: true);
      }
    });
  }

  Future<void> _fetchAllData({bool silent = false}) async {
    if (!silent) setState(() => isOrdersLoading = true);
    
    final ordersRes = await SupabaseService.fetchTable(
      'sbxn6t_orders',
      queryParams: 'customer_id=eq.${currentUser!['user_id']}&order=created_at.desc',
    );

    final settingsRes = await SupabaseService.fetchTable('sbxn6t_system_settings');
    bool bookingOpen = true;
    if (settingsRes.isNotEmpty) {
      bookingOpen = settingsRes.first['is_booking_open'] ?? true;
    }

    if (mounted) {
      setState(() {
        myOrders = ordersRes;
        isBookingOpen = bookingOpen;
        isOrdersLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingUser) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: kPrimaryColor)),
      );
    }

    if (currentUser == null) {
      return RegistrationScreen(onRegistered: _onUserRegistered);
    }

    final screens = [
      CustomerHomeScreen(
        currentUser: currentUser!,
        myOrders: myOrders,
        isBookingOpen: isBookingOpen,
        isLoading: isOrdersLoading,
        onRefresh: () => _fetchAllData(),
        onNewOrder: () => _showAddOrderSheet(context),
      ),
      CustomerOrdersScreen(
        myOrders: myOrders,
        onRefresh: () => _fetchAllData(),
      ),
      CustomerProfileScreen(
        currentUser: currentUser!,
        onLogout: () {
          setState(() {
            currentUser = null;
            myOrders = [];
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
      floatingActionButton: _currentIndex == 0 && isBookingOpen
          ? FloatingActionButton.extended(
              onPressed: () => _showAddOrderSheet(context),
              backgroundColor: kPrimaryColor,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('حجز جديد', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home, color: kPrimaryColor),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long, color: kPrimaryColor),
            label: 'الحجوزات',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: kPrimaryColor),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }

  void _showAddOrderSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => AddOrderSheet(
        customerId: currentUser!['user_id'],
        onOrderCreated: () {
          _fetchAllData();
        },
      ),
    );
  }
}

// --- شاشة التسجيل برقم الهاتف السوداني ---
class RegistrationScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onRegistered;

  const RegistrationScreen({super.key, required this.onRegistered});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedAvatar = '👷‍♂️';
  bool _isLoading = false;

  final List<String> _avatars = ['👷‍♂️', '👷‍♀️', '👨‍🏭', '👩‍🏭', '🧑‍💼', '🛠️'];

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

    // البحث أولاً عما إذا كان المستخدم مسجلاً مسبقاً برقم الهاتف هذا لتفادي قيود الـ Unique وتسهيل الدخول الفوري
    final existingUsers = await SupabaseService.fetchTable(
      'sbxn6t_users',
      queryParams: 'phone=eq.$phone',
    );

    if (existingUsers.isNotEmpty) {
      setState(() => _isLoading = false);
      widget.onRegistered(existingUsers.first);
      return;
    }

    final userId = 'cust_${DateTime.now().millisecondsSinceEpoch}';
    final userData = {
      'user_id': userId,
      'phone': phone,
      'name': name,
      'avatar': _selectedAvatar,
      'role': 'customer',
      'is_blocked': false,
    };

    final success = await SupabaseService.insertRecord('sbxn6t_users', userData);
    setState(() => _isLoading = false);

    if (success) {
      widget.onRegistered(userData);
    } else {
      // محاولة أخيرة لجلب المستخدم في حال تم التسجيل مسبقاً وتزامن الطلب
      final retryUsers = await SupabaseService.fetchTable(
        'sbxn6t_users',
        queryParams: 'phone=eq.$phone',
      );
      if (retryUsers.isNotEmpty) {
        widget.onRegistered(retryUsers.first);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('فشل التسجيل، حاول مرة أخرى')),
        );
      }
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
                  child: const Icon(Icons.factory, size: 64, color: kPrimaryColor),
                ),
                const SizedBox(height: 24),
                const Text(
                  'أهلاً بك في بوابة الزبائن',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'سجل بياناتك للدخول الفوري لطلبات المصنع',
                  style: TextStyle(color: Theme.of(context).hintColor, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                const Text('اختر صورة البروفايل', style: TextStyle(fontWeight: FontWeight.bold)),
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
                    labelText: 'الاسم الكامل',
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
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('دخول المنصة'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- الشاشة الرئيسية للزبون (CustomScrollView فخمة) ---
class CustomerHomeScreen extends StatelessWidget {
  final Map<String, dynamic> currentUser;
  final List<dynamic> myOrders;
  final bool isBookingOpen;
  final bool isLoading;
  final VoidCallback onRefresh;
  final VoidCallback onNewOrder;

  const CustomerHomeScreen({
    super.key,
    required this.currentUser,
    required this.myOrders,
    required this.isBookingOpen,
    required this.isLoading,
    required this.onRefresh,
    required this.onNewOrder,
  });

  @override
  Widget build(BuildContext context) {
    final activeOrders = myOrders.where((o) => o['status'] != 'تم الاستلام' && o['status'] != 'ملغي' && o['status'] != 'مرفوض').toList();
    final completedOrders = myOrders.where((o) => o['status'] == 'تم الاستلام').length;

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
                          child: Text(currentUser['avatar'] ?? '👷‍♂️', style: const TextStyle(fontSize: 28)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('مرحباً بك،', style: TextStyle(color: Colors.white70, fontSize: 14)),
                              Text(
                                currentUser['name'],
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
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isBookingOpen ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isBookingOpen ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          isBookingOpen ? Icons.check_circle : Icons.cancel,
                          color: isBookingOpen ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            isBookingOpen ? 'حالة المصنع: استقبال الحجوزات متاح حالياً' : 'حالة المصنع: الحجوزات متوقفة مؤقتاً من الإدارة',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isBookingOpen ? Colors.green[800] : Colors.red[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: StatTile(
                          title: 'الطلبات النشطة',
                          value: '${activeOrders.length}',
                          icon: Icons.hourglass_top,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: StatTile(
                          title: 'الطلبات المكتملة',
                          value: '$completedOrders',
                          icon: Icons.task_alt,
                          color: kPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const SectionTitle(title: 'الطلبات الجارية الحالية'),
                  if (isLoading && myOrders.isEmpty)
                    const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
                  else if (activeOrders.isEmpty)
                    EmptyState(
                      icon: Icons.inbox_outlined,
                      title: 'لا توجد طلبات نشطة',
                      subtitle: 'اضغط على زر الحجز الجديد لإنشاء طلبك الأول في المصنع',
                      buttonText: isBookingOpen ? 'إنشاء حجز جديد' : null,
                      onButtonPressed: isBookingOpen ? onNewOrder : null,
                    )
                  else
                    ...activeOrders.asMap().entries.map((entry) {
                      return FadeIn(
                        index: entry.key,
                        child: OrderCard(order: entry.value, onUpdate: onRefresh),
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

// --- شاشة عرض الحجوزات والسجل الكامل ---
class CustomerOrdersScreen extends StatelessWidget {
  final List<dynamic> myOrders;
  final VoidCallback onRefresh;

  const CustomerOrdersScreen({super.key, required this.myOrders, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سجل الحجوزات الكامل')),
      body: RefreshIndicator(
        onRefresh: () async => onRefresh(),
        color: kPrimaryColor,
        child: myOrders.isEmpty
            ? const EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'لا يوجد سجل حجوزات',
                subtitle: 'ستظهر جميع طلباتك السابقة والجديدة هنا فور إنشائها',
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: myOrders.length,
                itemBuilder: (context, index) {
                  return FadeIn(
                    index: index,
                    child: OrderCard(order: myOrders[index], onUpdate: onRefresh),
                  );
                },
              ),
      ),
    );
  }
}

// --- بطاقة الطلب الفردية مع إمكانية الإلغاء ---
class OrderCard extends StatelessWidget {
  final Map<String, dynamic> order;
  final VoidCallback onUpdate;

  const OrderCard({super.key, required this.order, required this.onUpdate});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'جديد':
        return Colors.blue;
      case 'مقبول':
        return Colors.amber;
      case 'جاهز للاستلاستلام':
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

  Future<void> _cancelOrder(BuildContext context) async {
    final success = await SupabaseService.updateRecord(
      'sbxn6t_orders',
      'order_id',
      order['order_id'],
      {'status': 'ملغي'},
    );

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إلغاء الحجز بنجاح')),
      );
      onUpdate();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل إلغاء الحجز')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = order['status'] ?? 'جديد';
    final statusColor = _getStatusColor(status);
    final canCancel = status == 'جديد';

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
          if (canCancel) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _cancelOrder(context),
                icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                label: const Text('إلغاء الحجز', style: TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// --- شاشة الحساب الشخصي للزبون ---
class CustomerProfileScreen extends StatelessWidget {
  final Map<String, dynamic> currentUser;
  final VoidCallback onLogout;

  const CustomerProfileScreen({super.key, required this.currentUser, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حساب الزبون')),
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
                  child: Text(currentUser['avatar'] ?? '👷‍♂️', style: const TextStyle(fontSize: 48)),
                ),
                const SizedBox(height: 16),
                Text(
                  currentUser['name'],
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 4),
                Text(
                  currentUser['phone'],
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
                  title: const Text('معرف المستخدم الرقمي'),
                  subtitle: Text(currentUser['user_id']),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.verified_user_outlined, color: kPrimaryColor),
                  title: const Text('نوع الحساب'),
                  subtitle: const Text('زبون معتمد بالمصنع'),
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

// --- نافذة إضافة طلب جديد (BottomSheet) ---
class AddOrderSheet extends StatefulWidget {
  final String customerId;
  final VoidCallback onOrderCreated;

  const AddOrderSheet({super.key, required this.customerId, required this.onOrderCreated});

  @override
  State<AddOrderSheet> createState() => _AddOrderSheetState();
}

class _AddOrderSheetState extends State<AddOrderSheet> {
  final _amountController = TextEditingController();
  final _locationController = TextEditingController();
  String _paymentType = 'cash';
  bool _isLoading = false;

  Future<void> _submitOrder() async {
    final amountText = _amountController.text.trim();
    final location = _locationController.text.trim();

    if (amountText.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال المبلغ ومكان العمل')),
      );
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء إدخال مبلغ صحيح')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final orderId = 'ord_${DateTime.now().millisecondsSinceEpoch}';
    final orderData = {
      'order_id': orderId,
      'customer_id': widget.customerId,
      'amount': amount,
      'payment_type': _paymentType,
      'work_location': location,
      'status': 'جديد',
    };

    final success = await SupabaseService.insertRecord('sbxn6t_orders', orderData);
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context);
      widget.onOrderCreated();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إنشاء الحجز بنجاح')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('فشل إنشاء الحجز، تحقق من الاتصال')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'إنشاء حجز جديد بالمصنع',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'المبلغ المراد (بالجنيه السوداني)',
                prefixIcon: Icon(Icons.money, color: kPrimaryColor),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'مكان العمل داخل المصنع (مثال: الخط الأول - القسم B)',
                prefixIcon: Icon(Icons.location_on_outlined, color: kPrimaryColor),
              ),
            ),
            const SizedBox(height: 20),
            const Text('طريقة الدفع', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('نقدي 💵'),
                    value: 'cash',
                    groupValue: _paymentType,
                    activeColor: kPrimaryColor,
                    onChanged: (val) => setState(() => _paymentType = val!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('آجل 📝'),
                    value: 'deferred',
                    groupValue: _paymentType,
                    activeColor: kPrimaryColor,
                    onChanged: (val) => setState(() => _paymentType = val!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _isLoading ? null : _submitOrder,
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('تأكيد وإرسال الحجز'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ===== تحديث التطبيق (يُضاف تلقائياً) =====
const int _apkCur = 3;
const String _apkUrl = 'https://raw.githubusercontent.com/alkahlizero564-sudo/apk-app/main/apps/aishcustomer/update.json';

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
