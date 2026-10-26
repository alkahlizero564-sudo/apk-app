// DESIGN: تطبيق حجز الخبز الذكي | حداثة وسرعة | #10B981 أخضر ذكي | بطاقات عائمة دائرية الزوايا وتدرجات فاخرة

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

import 'dart:async' as apkas;
import 'dart:convert' as apkjs;
import 'dart:io' as apkio;
import 'package:flutter/widgets.dart' as apkw;
import 'package:url_launcher/url_launcher.dart' as apkul;

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
    fontFamily: null,
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
      fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
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
            color: Colors.black.withOpacity(0.04),
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
              color: kPrimary.withOpacity(0.1),
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
            decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
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
  runApp(const BreadCustomerApp());
}

class BreadCustomerApp extends StatelessWidget {
  const BreadCustomerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'حجز الخبز السودان',
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
      home: const AuthCheckScreen(),
    );
  }
}

// --- شاشة التحقق من التسجيل (محلية فقط) ---
class AuthCheckScreen extends StatefulWidget {
  const AuthCheckScreen({super.key});

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  bool _loading = true;
  Map<String, dynamic>? _customer;

  @override
  void initState() {
    super.initState();
    _checkCustomer();
  }

  Future<void> _checkCustomer() async {
    try {
      final file = File('${Directory.systemTemp.path}/s2evsm_customer_id.txt');
      if (await file.exists()) {
        final customerId = await file.readAsString();
        if (customerId.isNotEmpty) {
          final res = await supabaseGet('s2evsm_customers', query: 'customer_id=eq.$customerId');
          if (res is List && res.isNotEmpty) {
            if (mounted) {
              setState(() {
                _customer = res.first;
                _loading = false;
              });
              return;
            }
          }
        }
      }
    } catch (_) {}

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_customer == null) {
      return const RegisterScreen();
    }
    return MainNavigation(customer: _customer!);
  }
}

// --- شاشة التسجيل الخفيفة ---
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _profileImage;
  bool _submitting = false;

  bool _validateSudanPhone(String phone) {
    final clean = phone.trim();
    return clean.startsWith('09') ||
        clean.startsWith('01') ||
        clean.startsWith('2499') ||
        clean.startsWith('2491');
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final customerId = 'cust_${DateTime.now().millisecondsSinceEpoch}';
    final data = {
      'customer_id': customerId,
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'profile_image': _profileImage ?? '',
    };

    final res = await supabasePost('s2evsm_customers', data);
    if (res != null) {
      try {
        final file = File('${Directory.systemTemp.path}/s2evsm_customer_id.txt');
        await file.writeAsString(customerId);
      } catch (_) {}

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainNavigation(customer: res)),
        );
      }
    } else {
      if (mounted) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('حدث خطأ أثناء التسجيل، تأكد من الاتصال بالإنترنت')),
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
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: kPrimary.withOpacity(0.1), shape: BoxShape.circle),
                    child: const Icon(Icons.bakery_dining_rounded, size: 64, color: kPrimary),
                  ),
                  const SizedBox(height: 24),
                  const Text('مرحباً بك في تطبيق الخبز', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  Text('سجل بياناتك للبدء في حجز حصتك اليومية بكل سهولة',
                      style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor), textAlign: TextAlign.center),
                  const SizedBox(height: 32),

                  GestureDetector(
                    onTap: () async {
                      setState(() {
                        _profileImage = 'https://api.dicebear.com/7.x/avataaars/svg?seed=${DateTime.now()}';
                      });
                    },
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: kPrimary.withOpacity(0.2),
                          backgroundImage: _profileImage != null ? NetworkImage(_profileImage!) : null,
                          child: _profileImage == null
                              ? const Icon(Icons.person, size: 50, color: kPrimary)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(color: kPrimary, shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'الاسم الكامل', prefixIcon: Icon(Icons.person_outline)),
                    validator: (v) => v == null || v.trim().isEmpty ? 'الرجاء إدخال الاسم' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'رقم الهاتف السوداني',
                      hintText: '09xxxxxxxx أو 2499xxxxxxxx',
                      prefixIcon: Icon(Icons.phone_iphone),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'الرجاء إدخال رقم الهاتف';
                      if (!_validateSudanPhone(v)) return 'رقم الهاتف غير صحيح (يجب أن يبدأ بـ 09, 01, 2499, 2491)';
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: _submitting
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('دخول مباشر'),
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

// --- التنقل الرئيسي ---
class MainNavigation extends StatefulWidget {
  final Map<String, dynamic> customer;
  const MainNavigation({super.key, required this.customer});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  late Map<String, dynamic> _currentCustomer;

  @override
  void initState() {
    super.initState();
    _currentCustomer = widget.customer;
  }

  void _updateCustomer(Map<String, dynamic> updated) {
    setState(() => _currentCustomer = updated);
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(customer: _currentCustomer),
      MyBookingsScreen(customer: _currentCustomer),
      ProfileScreen(customer: _currentCustomer, onUpdate: _updateCustomer),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: screens[_currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'الرئيسية'),
          NavigationDestination(icon: Icon(Icons.bookmark_border), selectedIcon: Icon(Icons.bookmark), label: 'حجوزاتي'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'البروفايل'),
        ],
      ),
    );
  }
}

// --- الشاشة الرئيسية ---
class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> customer;
  const HomeScreen({super.key, required this.customer});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Timer? _timer;
  bool _loading = true;
  String _bookingStatus = 'closed';
  Map<String, dynamic>? _activeBooking;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchData());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    final settingsRes = await supabaseGet('s2evsm_settings');
    if (settingsRes is List && settingsRes.isNotEmpty) {
      _bookingStatus = settingsRes.first['booking_status'] ?? 'closed';
    }

    final bookingsRes = await supabaseGet(
      's2evsm_bookings',
      query: 'customer_id=eq.${widget.customer['customer_id']}&order=created_at.desc&limit=1',
    );
    if (bookingsRes is List && bookingsRes.isNotEmpty) {
      _activeBooking = bookingsRes.first;
      if (_activeBooking!['status'] != 'booked') {
        _activeBooking = null;
      }
    } else {
      _activeBooking = null;
    }

    if (mounted) {
      setState(() => _loading = false);
    }
  }

  void _showBookingBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => BookingFormSheet(
        customer: widget.customer,
        existingBooking: _activeBooking,
        onSuccess: _fetchData,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOpen = _bookingStatus == 'open';

    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          title: const Text('حجز الخبز', style: TextStyle(fontWeight: FontWeight.w900)),
          actions: [
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: CircleAvatar(
                backgroundImage: widget.customer['profile_image'] != null && widget.customer['profile_image'].toString().isNotEmpty
                    ? NetworkImage(widget.customer['profile_image'])
                    : null,
                child: widget.customer['profile_image'] == null || widget.customer['profile_image'].toString().isEmpty
                    ? const Icon(Icons.person)
                    : null,
              ),
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              FadeIn(
                index: 0,
                child: AppCard(
                  color: isOpen ? kPrimary.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  child: Row(
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
                              isOpen ? 'الحجز مفتوح الآن' : 'الحجز مغلق الآن',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: isOpen ? kPrimaryDark : Colors.red[700],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isOpen ? 'يمكنك تقديم طلب حجز أو تعديل طلبك الحالي' : 'نأسف، تم إيقاف استقبال الطلبات حالياً',
                              style: TextStyle(fontSize: 13, color: Theme.of(context).hintColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const SectionTitle(title: 'حجزك الحالي'),
              if (_loading)
                const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
              else if (_activeBooking != null)
                FadeIn(
                  index: 1,
                  child: AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('طلب قروش نشط', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: kSecondary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text('قيد الانتظار', style: TextStyle(color: kSecondary, fontWeight: FontWeight.bold, fontSize: 12)),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: StatTile(
                                title: 'عدد القروش',
                                value: '${_activeBooking!['qorosh_count']}',
                                icon: Icons.bakery_dining,
                                color: kPrimary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatTile(
                                title: 'المبلغ (جنيه)',
                                value: '${_activeBooking!['amount_ssp']}',
                                icon: Icons.money,
                                color: kAccent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 16, color: Theme.of(context).hintColor),
                            const SizedBox(width: 8),
                            Text('التاريخ: ${_activeBooking!['booking_date']}', style: TextStyle(color: Theme.of(context).hintColor)),
                            const Spacer(),
                            Text(
                              'الدفع: ${_activeBooking!['payment_method'] == 'cash' ? 'نقدي' : 'أجل'}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        if (isOpen) ...[
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () async {
                                    await supabasePatch(
                                      's2evsm_bookings',
                                      'booking_id=eq.${_activeBooking!['booking_id']}',
                                      {'status': 'cancelled'},
                                    );
                                    _fetchData();
                                  },
                                  icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                                  label: const Text('إلغاء', style: TextStyle(color: Colors.red)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: _showBookingBottomSheet,
                                  icon: const Icon(Icons.edit),
                                  label: const Text('تعديل'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                )
              else
                FadeIn(
                  index: 1,
                  child: EmptyState(
                    icon: Icons.bookmark_add_outlined,
                    title: 'لا يوجد حجز نشط',
                    subtitle: isOpen ? 'اضغط أدناه لإنشاء حجز جديد ليومك' : 'الحجز مغلق حالياً، انتظر فتحه من الإدارة',
                    buttonText: isOpen ? 'إضافة حجز جديد' : null,
                    onAction: isOpen ? _showBookingBottomSheet : null,
                  ),
                ),
            ]),
          ),
        ),
      ],
    );
  }
}

// --- نموذج الحجز السفلي ---
class BookingFormSheet extends StatefulWidget {
  final Map<String, dynamic> customer;
  final Map<String, dynamic>? existingBooking;
  final VoidCallback onSuccess;
  const BookingFormSheet({super.key, required this.customer, this.existingBooking, required this.onSuccess});

  @override
  State<BookingFormSheet> createState() => _BookingFormSheetState();
}

class _BookingFormSheetState extends State<BookingFormSheet> {
  double _qoroshCount = 5;
  final double _pricePerQorosh = 100.0;
  String _paymentMethod = 'cash';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.existingBooking != null) {
      _qoroshCount = double.tryParse(widget.existingBooking!['qorosh_count'].toString()) ?? 5;
      _paymentMethod = widget.existingBooking!['payment_method'] ?? 'cash';
    }
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    final amount = _qoroshCount * _pricePerQorosh;
    final todayStr = DateTime.now().toIso8601String().split('T').first;

    if (widget.existingBooking != null) {
      await supabasePatch(
        's2evsm_bookings',
        'booking_id=eq.${widget.existingBooking!['booking_id']}',
        {
          'qorosh_count': _qoroshCount,
          'amount_ssp': amount,
          'payment_method': _paymentMethod,
        },
      );
    } else {
      final bookingId = 'bk_${DateTime.now().millisecondsSinceEpoch}';
      await supabasePost('s2evsm_bookings', {
        'booking_id': bookingId,
        'customer_id': widget.customer['customer_id'],
        'booking_date': todayStr,
        'qorosh_count': _qoroshCount,
        'amount_ssp': amount,
        'payment_method': _paymentMethod,
        'status': 'booked',
      });
    }

    if (mounted) {
      Navigator.pop(context);
      widget.onSuccess();
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalAmount = _qoroshCount * _pricePerQorosh;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.existingBooking != null ? 'تعديل الحجز' : 'حجز خبز جديد',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 20),
            Text('عدد القروش: ${_qoroshCount.toInt()}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Slider(
              value: _qoroshCount,
              min: 1,
              max: 30,
              divisions: 29,
              activeColor: kPrimary,
              label: '${_qoroshCount.toInt()} قروش',
              onChanged: (v) => setState(() => _qoroshCount = v),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: kPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('المبلغ الإجمالي:', style: TextStyle(fontWeight: FontWeight.bold)),
                  Text('$totalAmount جنيه سوداني', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: kPrimaryDark)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('طريقة الدفع', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('نقدي'),
                    selected: _paymentMethod == 'cash',
                    onSelected: (s) => setState(() => _paymentMethod = 'cash'),
                    selectedColor: kPrimary.withOpacity(0.2),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('أجل'),
                    selected: _paymentMethod == 'deferred',
                    onSelected: (s) => setState(() => _paymentMethod = 'deferred'),
                    selectedColor: kPrimary.withOpacity(0.2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _loading ? null : _save,
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(widget.existingBooking != null ? 'تحديث الحجز' : 'تأكيد الحجز'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// --- شاشة حجوزاتي السابقة ---
class MyBookingsScreen extends StatefulWidget {
  final Map<String, dynamic> customer;
  const MyBookingsScreen({super.key, required this.customer});

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  bool _loading = true;
  List<dynamic> _bookings = [];

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    final res = await supabaseGet(
      's2evsm_bookings',
      query: 'customer_id=eq.${widget.customer['customer_id']}&order=created_at.desc',
    );
    if (res is List) {
      if (mounted) {
        setState(() {
          _bookings = res;
          _loading = false;
        });
      }
    } else {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'booked':
        return 'محجوز';
      case 'delivered':
        return 'تم الاستلام';
      case 'cancelled':
        return 'ملغي';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'booked':
        return kSecondary;
      case 'delivered':
        return kPrimary;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('سجل حجوزاتي', style: TextStyle(fontWeight: FontWeight.w900))),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? const EmptyState(
                  icon: Icons.history,
                  title: 'لا توجد حجوزات سابقة',
                  subtitle: 'كل حجوزاتك السابقة ستظهر هنا بالتفصيل',
                )
              : RefreshIndicator(
                  onRefresh: _fetchBookings,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: _bookings.length,
                    itemBuilder: (context, index) {
                      final b = _bookings[index];
                      final status = b['status'];
                      final color = _getStatusColor(status);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: FadeIn(
                          index: index,
                          child: AppCard(
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: color.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(Icons.bakery_dining, color: color, size: 28),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('تاريخ: ${b['booking_date']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: color.withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(_getStatusText(status), style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text('الكمية: ${b['qorosh_count']} قروش | المبلغ: ${b['amount_ssp']} ج.س',
                                          style: TextStyle(fontSize: 13, color: Theme.of(context).hintColor)),
                                      const SizedBox(height: 4),
                                      Text('الدفع: ${b['payment_method'] == 'cash' ? 'نقدي' : 'أجل'}',
                                          style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
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
    );
  }
}

// --- شاشة البروفايل ---
class ProfileScreen extends StatefulWidget {
  final Map<String, dynamic> customer;
  final Function(Map<String, dynamic>) onUpdate;
  const ProfileScreen({super.key, required this.customer, required this.onUpdate});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late String _profileImage;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.customer['name']);
    _phoneController = TextEditingController(text: widget.customer['phone']);
    _profileImage = widget.customer['profile_image'] ?? '';
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    final updatedData = {
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'profile_image': _profileImage,
    };

    final success = await supabasePatch(
      's2evsm_customers',
      'customer_id=eq.${widget.customer['customer_id']}',
      updatedData,
    );

    if (success) {
      final newCustomer = {...widget.customer, ...updatedData};
      widget.onUpdate(newCustomer);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تحديث البروفايل بنجاح')));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل التحديث، تأكد من الاتصال')));
      }
    }
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الملف الشخصي', style: TextStyle(fontWeight: FontWeight.w900))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: kPrimary.withOpacity(0.2),
                    backgroundImage: _profileImage.isNotEmpty ? NetworkImage(_profileImage) : null,
                    child: _profileImage.isEmpty ? const Icon(Icons.person, size: 50, color: kPrimary) : null,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _profileImage = 'https://api.dicebear.com/7.x/avataaars/svg?seed=${DateTime.now()}';
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: kPrimary, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'الاسم الكامل', prefixIcon: Icon(Icons.person_outline)),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'رقم الهاتف السوداني', prefixIcon: Icon(Icons.phone_iphone)),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _saving ? null : _saveProfile,
              child: _saving ? const CircularProgressIndicator(color: Colors.white) : const Text('حفظ التعديلات'),
            ),
          ],
        ),
      ),
    );
  }
}

// ===== تحديث التطبيق (يُضاف تلقائياً) =====
const int _apkCur = 4;
const String _apkUrl = 'https://raw.githubusercontent.com/alkahlizero564-sudo/apk-app/main/apps/sudanbreadcu0cw3/update.json';

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
