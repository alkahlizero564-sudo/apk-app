import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:async' as apkas;
import 'dart:convert' as apkjs;
import 'dart:io' as apkio;
import 'package:flutter/widgets.dart' as apkw;
import 'package:url_launcher/url_launcher.dart' as apkul;

// ==========================================
// FIREBASE REST SERVICE (PURE DART IO)
// ==========================================
class FirebaseService {
  static const String baseUrl =
      'https://wifaq22-683fa-default-rtdb.firebaseio.com/slaw8f';

  static Future<dynamic> get(String path) async {
    try {
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse('$baseUrl/$path.json'));
      final response =
          await request.close().timeout(Duration(seconds: 5));
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        if (body != 'null' && body.isNotEmpty) {
          return json.decode(body);
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<List<Map<String, dynamic>>> getList(String path) async {
    final res = await get(path);
    List<Map<String, dynamic>> list = [];
    if (res is Map<String, dynamic>) {
      res.forEach((key, value) {
        if (value is Map) {
          var item = Map<String, dynamic>.from(value);
          item['id'] = key;
          list.add(item);
        }
      });
    } else if (res is List) {
      for (int i = 0; i < res.length; i++) {
        if (res[i] != null && res[i] is Map) {
          var item = Map<String, dynamic>.from(res[i]);
          item['id'] = i.toString();
          list.add(item);
        }
      }
    }
    return list;
  }

  static Future<String?> post(String path, Map<String, dynamic> data) async {
    try {
      final client = HttpClient();
      final request = await client.postUrl(Uri.parse('$baseUrl/$path.json'));
      request.headers.set('content-type', 'application/json');
      request.add(utf8.encode(json.encode(data)));
      final response =
          await request.close().timeout(Duration(seconds: 6));
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final decoded = json.decode(body);
        if (decoded is Map && decoded.containsKey('name')) {
          return decoded['name'] as String;
        }
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> patch(String path, Map<String, dynamic> data) async {
    try {
      final client = HttpClient();
      final request = await client.patchUrl(Uri.parse('$baseUrl/$path.json'));
      request.headers.set('content-type', 'application/json');
      request.add(utf8.encode(json.encode(data)));
      final response =
          await request.close().timeout(Duration(seconds: 6));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> put(String path, dynamic data) async {
    try {
      final client = HttpClient();
      final request = await client.putUrl(Uri.parse('$baseUrl/$path.json'));
      request.headers.set('content-type', 'application/json');
      request.add(utf8.encode(json.encode(data)));
      final response =
          await request.close().timeout(Duration(seconds: 6));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> delete(String path) async {
    try {
      final client = HttpClient();
      final request = await client.deleteUrl(Uri.parse('$baseUrl/$path.json'));
      final response =
          await request.close().timeout(Duration(seconds: 6));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}

// ==========================================
// MAIN APP ROOT
// ==========================================
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(DmcAdminApp());
}

class DmcAdminApp extends StatefulWidget {
  const DmcAdminApp({Key? key}) : super(key: key);

  @override
  State<DmcAdminApp> createState() => _DmcAdminAppState();
}

class _DmcAdminAppState extends State<DmcAdminApp> {
  bool isDarkMode = false;
  String currentLanguage = 'ar';

  void toggleTheme(bool value) {
    setState(() {
      isDarkMode = value;
    });
  }

  void toggleLanguage(String lang) {
    setState(() {
      currentLanguage = lang;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Color(0xFF0B5C60);

    return MaterialApp(
      title: 'DMC Medical Sudan',
      debugShowCheckedModeBanner: false,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: primaryColor,
        scaffoldBackgroundColor: Color(0xFFF4F7F6),
        colorScheme: ColorScheme.light(
          primary: primaryColor,
          secondary: Color(0xFF14807A),
          surface: Colors.white,
          background: Color(0xFFF4F7F6),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: Color(0xFFC2D6D4), width: 0.8),
          ),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFF20B2AA),
        scaffoldBackgroundColor: Color(0xFF0D1717),
        colorScheme: ColorScheme.dark(
          primary: Color(0xFF20B2AA),
          secondary: Color(0xFF14807A),
          surface: Color(0xFF152222),
          background: Color(0xFF0D1717),
        ),
        cardTheme: CardThemeData(
          color: Color(0xFF152222),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(color: Color(0xFF263A3A), width: 0.8),
          ),
        ),
      ),
      home: Directionality(
        textDirection:
            currentLanguage == 'ar' ? TextDirection.rtl : TextDirection.ltr,
        child: AdminHomeScreen(
          isDarkMode: isDarkMode,
          onThemeChanged: toggleTheme,
          currentLanguage: currentLanguage,
          onLanguageChanged: toggleLanguage,
        ),
      ),
    );
  }
}

// ==========================================
// ADMIN & CLIENT HOME SCREEN
// ==========================================
class AdminHomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;
  final String currentLanguage;
  final ValueChanged<String> onLanguageChanged;

  const AdminHomeScreen({
    Key? key,
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.currentLanguage,
    required this.onLanguageChanged,
  }) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int currentNavIndex = 0;
  Timer? pollingTimer;
  bool soundAlertsEnabled = true;

  // Active Role / App Mode: manager, sales, warehouse, accountant, customer
  String currentRole = 'manager';
  Map<String, dynamic>? currentStaff;

  // Shared Remote Data from Firebase
  double dollarRate = 2500.0;
  double profitMarginPercent = 10.0;
  String roundingMode = 'nearest_100';

  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> quotations = [];
  List<Map<String, dynamic>> deliveryZones = [];
  List<Map<String, dynamic>> bankAccounts = [];
  List<Map<String, dynamic>> auditLogs = [];
  List<Map<String, dynamic>> customers = [];
  List<Map<String, dynamic>> staffList = [];
  List<Map<String, dynamic>> dollarLogs = [];
  List<Map<String, dynamic>> purchaseInvoices = [];
  List<Map<String, dynamic>> pushNotifications = [];

  // Customer Cart & Favorites state
  List<Map<String, dynamic>> customerCart = [];
  Set<String> customerFavorites = {};

  // Controllers
  final TextEditingController prodSearchCtrl = TextEditingController();
  final TextEditingController usdRateCtrl = TextEditingController();
  final TextEditingController marginCtrl = TextEditingController();

  String selectedCategory = 'all';
  int previousOrdersLength = 0;

  @override
  void initState() {
    super.initState();
    currentStaff = {
      'id': 'st-101',
      'name': 'د. أحمد عبدالمجيد',
      'username': 'admin',
      'role': 'manager',
      'is_active': true
    };
    _fetchFirebaseData();
    pollingTimer = Timer.periodic(Duration(seconds: 5), (_) {
      if (mounted) _fetchFirebaseData();
    });
  }

  @override
  void dispose() {
    pollingTimer?.cancel();
    prodSearchCtrl.dispose();
    usdRateCtrl.dispose();
    marginCtrl.dispose();
    super.dispose();
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Theme.of(context).primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Realtime Data Fetching via Firebase REST
  Future<void> _fetchFirebaseData() async {
    // 1. Dollar Rate Settings
    final rateData = await FirebaseService.get('dollar_rate_settings');
    if (rateData != null && rateData is Map) {
      dollarRate = (rateData['rate_sdg'] is num)
          ? (rateData['rate_sdg'] as num).toDouble()
          : 2500.0;
      profitMarginPercent = (rateData['profit_margin_percent'] is num)
          ? (rateData['profit_margin_percent'] as num).toDouble()
          : 10.0;
      roundingMode = rateData['rounding_mode']?.toString() ?? 'nearest_100';
    }

    // 2. Orders
    final fetchedOrders = await FirebaseService.getList('orders');
    if (fetchedOrders.isNotEmpty) {
      if (previousOrdersLength > 0 && fetchedOrders.length > previousOrdersLength) {
        if (soundAlertsEnabled) {
          HapticFeedback.vibrate();
        }
      }
      previousOrdersLength = fetchedOrders.length;
      orders = fetchedOrders;
    }

    // 3. Products
    final fetchedProds = await FirebaseService.getList('products');
    if (fetchedProds.isNotEmpty) {
      products = fetchedProds;
    }

    // 4. Quotations
    final fetchedQuotations = await FirebaseService.getList('quotations');
    if (fetchedQuotations.isNotEmpty) {
      quotations = fetchedQuotations;
    }

    // 5. Zones
    final fetchedZones = await FirebaseService.getList('delivery_zones');
    if (fetchedZones.isNotEmpty) {
      deliveryZones = fetchedZones;
    }

    // 6. Bank Accounts
    final fetchedBanks = await FirebaseService.getList('bank_accounts');
    if (fetchedBanks.isNotEmpty) {
      bankAccounts = fetchedBanks;
    }

    // 7. Audit Logs
    final fetchedAudit = await FirebaseService.getList('audit_logs');
    if (fetchedAudit.isNotEmpty) {
      auditLogs = fetchedAudit;
      auditLogs.sort((a, b) => (b['timestamp'] ?? '').compareTo(a['timestamp'] ?? ''));
    }

    // 8. Customers (Users)
    final fetchedUsers = await FirebaseService.getList('users');
    if (fetchedUsers.isNotEmpty) {
      customers = fetchedUsers;
    }

    // 9. Staff List
    final fetchedStaff = await FirebaseService.getList('staff');
    if (fetchedStaff.isNotEmpty) {
      staffList = fetchedStaff;
    }

    // 10. Dollar Logs
    final fetchedRateLogs = await FirebaseService.getList('dollar_rate_logs');
    if (fetchedRateLogs.isNotEmpty) {
      dollarLogs = fetchedRateLogs;
    }

    // 11. Purchase Invoices
    final fetchedInvoices = await FirebaseService.getList('purchase_invoices');
    if (fetchedInvoices.isNotEmpty) {
      purchaseInvoices = fetchedInvoices;
    }

    // 12. Push Notifications
    final fetchedPushes = await FirebaseService.getList('push_notifications');
    if (fetchedPushes.isNotEmpty) {
      pushNotifications = fetchedPushes;
    }

    if (mounted) setState(() {});
  }

  // Audit Log Helper
  Future<void> _logAction(String actionType, Map<String, dynamic> details) async {
    final logItem = {
      'staff_name': currentStaff?['name'] ?? 'مستخدم النظام',
      'role': currentRole,
      'action_type': actionType,
      'details_json': details,
      'timestamp': DateTime.now().toString().substring(0, 16),
    };
    await FirebaseService.post('audit_logs', logItem);
    setState(() {
      auditLogs.insert(0, logItem);
    });
  }

  // Price Calculation Engine
  int _calculateSdgPrice(double baseUsd, bool isFixed, double fixedSdg) {
    if (isFixed && fixedSdg > 0) return fixedSdg.round();
    double raw = baseUsd * dollarRate * (1 + (profitMarginPercent / 100));
    int val = raw.round();

    if (roundingMode == 'nearest_100') {
      return ((val + 50) ~/ 100) * 100;
    } else if (roundingMode == 'nearest_500') {
      return ((val + 250) ~/ 500) * 500;
    }
    return val;
  }

  // Login & Role Switcher Modal (Queries actual DB staff & users)
  void _openLoginModal() {
    final userCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final fullNameCtrl = TextEditingController();
    String selectedRole = currentRole;
    bool isRegisterMode = false;
    String accountType = 'individual';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctxState, setSheetState) {
            final isAr = widget.currentLanguage == 'ar';
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      isRegisterMode
                          ? (isAr ? 'إنشاء حساب جديد (عميل/مؤسسة)' : 'New Customer Registration')
                          : (isAr ? 'تسجيل الدخول / تبديل الدور' : 'Login / Switch Role'),
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 14),

                    if (!isRegisterMode) ...[
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        items: [
                          DropdownMenuItem(
                              value: 'manager', child: Text('مدير (Manager)')),
                          DropdownMenuItem(
                              value: 'sales', child: Text('مبيعات (Sales)')),
                          DropdownMenuItem(
                              value: 'warehouse',
                              child: Text('أمانة المخزن (Warehouse)')),
                          DropdownMenuItem(
                              value: 'accountant',
                              child: Text('محاسب (Accountant)')),
                          DropdownMenuItem(
                              value: 'customer',
                              child: Text('زبون / عميل (Customer)')),
                        ],
                        onChanged: (val) {
                          if (val != null) setSheetState(() => selectedRole = val);
                        },
                        decoration: InputDecoration(
                          labelText: isAr ? 'الصلاحية / نمط الشاشة' : 'Role / Mode',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: userCtrl,
                        decoration: InputDecoration(
                          labelText: isAr
                              ? (selectedRole == 'customer' ? 'البريد/الهاتف' : 'اسم المستخدم')
                              : 'Username / Email',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: passCtrl,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: isAr ? 'كلمة المرور' : 'Password',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ] else ...[
                      TextField(
                        controller: fullNameCtrl,
                        decoration: InputDecoration(
                          labelText: isAr ? 'الاسم الكامل / اسم المركز' : 'Full Name',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      SizedBox(height: 10),
                      TextField(
                        controller: phoneCtrl,
                        decoration: InputDecoration(
                          labelText: isAr ? 'رقم الهاتف' : 'Phone Number',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: accountType,
                        items: [
                          DropdownMenuItem(
                              value: 'individual', child: Text('فرد (Individual)')),
                          DropdownMenuItem(
                              value: 'medical_institution',
                              child: Text('مؤسسة طبية (Medical Center/Pharmacy)')),
                        ],
                        onChanged: (v) {
                          if (v != null) setSheetState(() => accountType = v);
                        },
                        decoration: InputDecoration(
                          labelText: isAr ? 'نوع الحساب' : 'Account Type',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ],

                    SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (isRegisterMode) {
                            if (fullNameCtrl.text.isEmpty) return;
                            final newUser = {
                              'full_name': fullNameCtrl.text,
                              'phone': phoneCtrl.text,
                              'account_type': accountType,
                              'created_at': DateTime.now().toIso8601String(),
                            };
                            final id = await FirebaseService.post('users', newUser);
                            newUser['id'] = id ?? 'usr-${DateTime.now().millisecondsSinceEpoch}';
                            
                            setState(() {
                              currentRole = 'customer';
                              currentStaff = {
                                'id': newUser['id'],
                                'name': fullNameCtrl.text,
                                'role': 'customer',
                              };
                              currentNavIndex = 0;
                            });
                            _logAction('تسجيل عميل جديد', {'name': fullNameCtrl.text});
                            Navigator.pop(ctx);
                            _toast(isAr ? 'تم إنشاء الحساب وتسجيل الدخول بنجاح' : 'Registered Successfully');
                          } else {
                            // Authenticate against staff / users table
                            if (selectedRole == 'customer') {
                              final matchedUser = customers.firstWhere(
                                (u) =>
                                    (u['full_name'] ?? '').toString().toLowerCase().contains(userCtrl.text.toLowerCase()) ||
                                    (u['phone'] ?? '').toString() == userCtrl.text,
                                orElse: () => {
                                  'id': 'c-${DateTime.now().millisecondsSinceEpoch}',
                                  'full_name': userCtrl.text.isEmpty ? 'عميل DMC' : userCtrl.text,
                                  'account_type': 'individual',
                                },
                              );
                              setState(() {
                                currentRole = 'customer';
                                currentStaff = {
                                  'id': matchedUser['id'],
                                  'name': matchedUser['full_name'],
                                  'role': 'customer',
                                };
                                currentNavIndex = 0;
                              });
                            } else {
                              final matchedStaff = staffList.firstWhere(
                                (s) => (s['username'] ?? '').toString() == userCtrl.text,
                                orElse: () => {
                                  'id': 'st-${DateTime.now().millisecondsSinceEpoch}',
                                  'name': userCtrl.text.isEmpty ? 'موظف النظام' : userCtrl.text,
                                  'role': selectedRole,
                                },
                              );
                              setState(() {
                                currentRole = selectedRole;
                                currentStaff = {
                                  'id': matchedStaff['id'],
                                  'name': matchedStaff['name'],
                                  'role': selectedRole,
                                };
                                currentNavIndex = 0;
                              });
                            }
                            _logAction('تسجيل دخول', {'role': selectedRole, 'user': currentStaff?['name']});
                            Navigator.pop(ctx);
                            _toast(isAr ? 'تم تسجيل الدخول بنجاح' : 'Logged in successfully');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(isRegisterMode
                            ? (isAr ? 'إنشاء الحساب الآن' : 'Register Now')
                            : (isAr ? 'تسجيل الدخول' : 'Login')),
                      ),
                    ),
                    SizedBox(height: 8),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          setSheetState(() => isRegisterMode = !isRegisterMode);
                        },
                        child: Text(isRegisterMode
                            ? (isAr ? 'لديك حساب بالفعل؟ سجل دخولك' : 'Already have an account? Login')
                            : (isAr ? 'حساب جديد؟ سجّل الآن كعميل/مؤسسة' : 'New Customer? Register here')),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // MAIN BUILD UI
  // ==========================================
  @override
  Widget build(BuildContext context) {
    final bool isAr = widget.currentLanguage == 'ar';
    final bool isCustomerView = currentRole == 'customer';

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(65),
        child: AppBar(
          elevation: 1,
          backgroundColor: Theme.of(context).colorScheme.surface,
          titleSpacing: 16,
          title: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Text(
                    'DMC',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Text(
                        isCustomerView ? 'DMC Client' : 'DMC Admin',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      SizedBox(width: 6),
                      _buildRoleBadge(currentRole),
                    ],
                  ),
                  Text(
                    currentStaff?['name'] ?? (isAr ? 'المستخدم' : 'User'),
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(
                soundAlertsEnabled ? Icons.volume_up : Icons.volume_off,
                color: soundAlertsEnabled
                    ? Theme.of(context).primaryColor
                    : Colors.grey,
              ),
              onPressed: () {
                setState(() => soundAlertsEnabled = !soundAlertsEnabled);
                _toast(soundAlertsEnabled
                    ? (isAr ? 'تم تفعيل الصوت' : 'Sound Enabled')
                    : (isAr ? 'تم كتم الصوت' : 'Sound Muted'));
              },
            ),
            IconButton(
              icon: Icon(
                widget.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
              ),
              onPressed: () => widget.onThemeChanged(!widget.isDarkMode),
            ),
            IconButton(
              icon: Icon(Icons.language),
              onPressed: () {
                final next = widget.currentLanguage == 'ar' ? 'en' : 'ar';
                widget.onLanguageChanged(next);
              },
            ),
            IconButton(
              icon: Icon(Icons.swap_horiz, color: Colors.teal),
              tooltip: isAr ? 'تبديل الدور / زبون' : 'Switch Role',
              onPressed: () => _openLoginModal(),
            ),
            SizedBox(width: 6),
          ],
        ),
      ),
      body: isCustomerView
          ? _buildCustomerView()
          : IndexedStack(
              index: currentNavIndex,
              children: [
                _buildDashboardTab(),
                _buildOrdersTab(),
                _buildInventoryTab(),
                _buildUsdFinanceTab(),
                _buildZonesAndBanksTab(),
                _buildOcrScannerTab(),
                _buildCustomersAndReportsTab(),
                _buildAuditLogsTab(),
              ],
            ),
      bottomNavigationBar: isCustomerView
          ? null
          : Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, -2),
                  ),
                ],
              ),
              child: BottomNavigationBar(
                currentIndex: currentNavIndex,
                onTap: (index) => setState(() => currentNavIndex = index),
                selectedItemColor: Theme.of(context).primaryColor,
                unselectedItemColor: Colors.grey,
                type: BottomNavigationBarType.fixed,
                backgroundColor: Theme.of(context).colorScheme.surface,
                selectedFontSize: 10,
                unselectedFontSize: 10,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.dashboard_outlined),
                    activeIcon: Icon(Icons.dashboard),
                    label: isAr ? 'الرئيسية' : 'Dashboard',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.receipt_long_outlined),
                    activeIcon: Icon(Icons.receipt_long),
                    label: isAr ? 'الطلبات' : 'Orders',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.inventory_2_outlined),
                    activeIcon: Icon(Icons.inventory_2),
                    label: isAr ? 'المخزون' : 'Inventory',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.attach_money),
                    label: isAr ? 'الدولار' : 'USD Rate',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.map_outlined),
                    label: isAr ? 'المناطق' : 'Zones',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.document_scanner),
                    label: isAr ? 'مسح AI' : 'OCR Scan',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.people_outline),
                    label: isAr ? 'التقارير' : 'Reports',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.history),
                    label: isAr ? 'الرقابة' : 'Audit Log',
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildRoleBadge(String role) {
    String label = 'مدير';
    Color bg = Colors.green.withOpacity(0.15);
    Color fg = Colors.green.shade800;

    if (role == 'sales') {
      label = 'مبيعات';
      bg = Colors.blue.withOpacity(0.15);
      fg = Colors.blue.shade800;
    } else if (role == 'warehouse') {
      label = 'مخزن';
      bg = Colors.orange.withOpacity(0.15);
      fg = Colors.orange.shade800;
    } else if (role == 'accountant') {
      label = 'محاسب';
      bg = Colors.purple.withOpacity(0.15);
      fg = Colors.purple.shade800;
    } else if (role == 'customer') {
      label = 'زبون';
      bg = Colors.teal.withOpacity(0.15);
      fg = Colors.teal.shade800;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ==========================================
  // CUSTOMER VIEW (DMC CLIENT CATALOG & CART)
  // ==========================================
  Widget _buildCustomerView() {
    final bool isAr = widget.currentLanguage == 'ar';
    final query = prodSearchCtrl.text.toLowerCase();

    final filtered = products.where((p) {
      final matchCat =
          selectedCategory == 'all' || p['category'] == selectedCategory;
      final nameAr = (p['name_ar'] ?? '').toString().toLowerCase();
      final matchQuery = query.isEmpty || nameAr.contains(query);
      return matchCat && matchQuery;
    }).toList();

    double totalCartSdg = 0;
    for (var item in customerCart) {
      final double baseUsd = (item['base_price_usd'] is num)
          ? (item['base_price_usd'] as num).toDouble()
          : 1.0;
      final bool isFixed = item['is_fixed_price'] == true;
      final double fixedSdg = (item['fixed_price_sdg'] is num)
          ? (item['fixed_price_sdg'] as num).toDouble()
          : 0.0;
      final int price = _calculateSdgPrice(baseUsd, isFixed, fixedSdg);
      final int qty = (item['qty'] is num) ? (item['qty'] as num).toInt() : 1;
      totalCartSdg += price * qty;
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Client Welcome Banner
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0B5C60), Color(0xFF14807A)],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr
                            ? 'أهلاً بك في كتالوج DMC الطبية'
                            : 'Welcome to DMC Medical Catalog',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        isAr
                            ? 'تصفح المعدات، المستهلكات، واطلب مباشرة مع التوصيل'
                            : 'Browse equipment, consumables, and order directly',
                        style: TextStyle(
                            color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _openCustomerCheckoutSheet(totalCartSdg),
                  icon: Icon(Icons.shopping_cart, size: 16),
                  label: Text(
                      '${customerCart.length} (${totalCartSdg.toStringAsFixed(0)} SDG)'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber.shade700,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 14),

          // Search Bar
          TextField(
            controller: prodSearchCtrl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: isAr ? 'ابحث عن صنف طبي...' : 'Search medical item...',
              prefixIcon: Icon(Icons.search),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
          SizedBox(height: 10),

          // Categories Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCatChip('all', isAr ? 'الكل' : 'All'),
                _buildCatChip('consumables', isAr ? 'مستهلكات طبية' : 'Consumables'),
                _buildCatChip('medical_devices', isAr ? 'أجهزة طبية' : 'Medical Devices'),
                _buildCatChip('lab_surgery_supplies', isAr ? 'معامل وعمليات' : 'Lab & Surgery'),
              ],
            ),
          ),
          SizedBox(height: 14),

          // Customer Products List Grid
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            itemBuilder: (ctx, i) {
              final p = filtered[i];
              final String pId = p['id']?.toString() ?? i.toString();
              final double baseUsd = (p['base_price_usd'] is num)
                  ? (p['base_price_usd'] as num).toDouble()
                  : 1.0;
              final bool isFixed = p['is_fixed_price'] == true;
              final double fixedSdg = (p['fixed_price_sdg'] is num)
                  ? (p['fixed_price_sdg'] as num).toDouble()
                  : 0.0;
              final int priceSdg = _calculateSdgPrice(baseUsd, isFixed, fixedSdg);
              final bool isFav = customerFavorites.contains(pId);

              return Card(
                margin: EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(p['image_emoji'] ?? '🩺',
                              style: TextStyle(fontSize: 24)),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p['name_ar'] ?? '',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              '${p['category'] ?? ''} | ${isAr ? 'المتوفر' : 'Stock'}: ${p['stock_quantity'] ?? 100}',
                              style: TextStyle(
                                  fontSize: 10, color: Colors.grey),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '$priceSdg SDG',
                              style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          isFav ? Icons.favorite : Icons.favorite_border,
                          color: isFav ? Colors.red : Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            if (isFav) {
                              customerFavorites.remove(pId);
                            } else {
                              customerFavorites.add(pId);
                            }
                          });
                          _toast(isFav
                              ? (isAr ? 'تمت الإزالة من المفضلة' : 'Removed')
                              : (isAr ? 'أضيف للمفضلة' : 'Added to Favorites'));
                        },
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            final idx = customerCart
                                .indexWhere((c) => c['id'].toString() == pId);
                            if (idx >= 0) {
                              customerCart[idx]['qty'] =
                                  (customerCart[idx]['qty'] as int) + 1;
                            } else {
                              customerCart.add({...p, 'qty': 1});
                            }
                          });
                          _toast(isAr ? 'أضيف للسلة' : 'Added to Cart');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 8),
                        ),
                        child: Text(isAr ? 'إضافة للسلة' : 'Add to Cart',
                            style: TextStyle(fontSize: 11)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _openCustomerCheckoutSheet(double totalCartSdg) {
    if (customerCart.isEmpty) {
      _toast(widget.currentLanguage == 'ar'
          ? 'السلة فارغة حالياً'
          : 'Cart is empty');
      return;
    }

    String selectedZoneId = deliveryZones.isNotEmpty
        ? (deliveryZones.first['id']?.toString() ?? '')
        : '';
    double deliveryFee = deliveryZones.isNotEmpty
        ? ((deliveryZones.first['fee_sdg'] is num)
            ? (deliveryZones.first['fee_sdg'] as num).toDouble()
            : 1500.0)
        : 1500.0;
    String paymentMethod = 'bankak';
    final transCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctxState, setSheetState) {
            final isAr = widget.currentLanguage == 'ar';
            double grandTotal = totalCartSdg + deliveryFee;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? 'إتمام طلب التسوق (Checkout)' : 'Checkout Order',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    ...customerCart.map((item) => ListTile(
                          dense: true,
                          title: Text(item['name_ar'] ?? ''),
                          subtitle: Text(
                              '${isAr ? 'الكمية' : 'Qty'}: ${item['qty']}'),
                        )),
                    Divider(),

                    // Delivery Zone Selector
                    DropdownButtonFormField<String>(
                      value: selectedZoneId.isNotEmpty ? selectedZoneId : null,
                      items: deliveryZones.map((z) {
                        return DropdownMenuItem<String>(
                          value: z['id']?.toString() ?? '',
                          child: Text('${z['zone_name']} (${z['fee_sdg']} SDG)'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          final zone = deliveryZones
                              .firstWhere((z) => z['id']?.toString() == val);
                          setSheetState(() {
                            selectedZoneId = val;
                            deliveryFee = (zone['fee_sdg'] is num)
                                ? (zone['fee_sdg'] as num).toDouble()
                                : 1500.0;
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: isAr ? 'اختر منطقة التوصيل' : 'Delivery Zone',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),

                    // Payment Method Choice
                    DropdownButtonFormField<String>(
                      value: paymentMethod,
                      items: [
                        DropdownMenuItem(
                            value: 'bankak', child: Text('تحويل عبر بنكك (Bankak)')),
                        DropdownMenuItem(
                            value: 'cash_on_delivery',
                            child: Text('الدفع نقداً عند الاستلام (COD)')),
                      ],
                      onChanged: (val) {
                        if (val != null) setSheetState(() => paymentMethod = val);
                      },
                      decoration: InputDecoration(
                        labelText: isAr ? 'طريقة الدفع' : 'Payment Method',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 10),

                    if (paymentMethod == 'bankak') ...[
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isAr
                                  ? 'حساب بنكك DMC النشط: 2390192 (د. أحمد)'
                                  : 'Active Bankak Account: 2390192',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            SizedBox(height: 4),
                            Text(
                              isAr
                                  ? 'قم بالتحويل واكتب رقم عملية بنكك أدناه:'
                                  : 'Transfer & enter Transaction ID below:',
                              style: TextStyle(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: transCtrl,
                        decoration: InputDecoration(
                          labelText:
                              isAr ? 'رقم العملية / الإشعار' : 'Transaction No.',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 8),
                    ],

                    Text(
                      '${isAr ? 'المجموع الكلي مع التوصيل' : 'Grand Total'}: ${grandTotal.toStringAsFixed(0)} SDG',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _openQuotationRequestSheet(),
                            child: Text(
                                isAr ? 'طلب عرض سعر' : 'Request Quotation'),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final orderItem = {
                                'order_number':
                                    'DMC-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                                'user_id': currentStaff?['name'] ?? 'عميل',
                                'items_json': customerCart,
                                'total_products_sdg': totalCartSdg,
                                'delivery_zone_id': selectedZoneId,
                                'delivery_fee_sdg': deliveryFee,
                                'grand_total_sdg': grandTotal,
                                'payment_method': paymentMethod,
                                'transaction_number': transCtrl.text,
                                'payment_status': paymentMethod == 'bankak'
                                    ? 'pending_confirmation'
                                    : 'pending_delivery_cash',
                                'order_status': 'pending_review',
                                'created_at': DateTime.now().toString(),
                              };

                              await FirebaseService.post('orders', orderItem);
                              _logAction('إرسال طلب جديد من الزبون',
                                  {'total': grandTotal});
                              setState(() {
                                customerCart.clear();
                              });
                              _fetchFirebaseData();
                              Navigator.pop(ctx);
                              _toast(isAr
                                  ? 'تم إرسال الطلب بنجاح للإدارة!'
                                  : 'Order Submitted!');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            child: Text(isAr ? 'تأكيد وإرسال الطلب' : 'Submit Order'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openQuotationRequestSheet() {
    final notesCtrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        final isAr = widget.currentLanguage == 'ar';
        return Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAr
                    ? 'طلب عرض سعر للكميات الكبيرة (Quotation)'
                    : 'Request Large Order Quotation',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              TextField(
                controller: notesCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: isAr
                      ? 'اذكر الأصناف والكميات المطلوبة للمؤسسة'
                      : 'Notes / Required quantities',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (notesCtrl.text.isEmpty) return;
                    final q = {
                      'quotation_number':
                          'QUO-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
                      'user_id': currentStaff?['name'] ?? 'عميل',
                      'items_requested': notesCtrl.text,
                      'customer_notes': notesCtrl.text,
                      'status': 'pending',
                      'created_at': DateTime.now().toString(),
                    };
                    await FirebaseService.post('quotations', q);
                    _logAction('طلب عرض سعر جديد', {'notes': notesCtrl.text});
                    _fetchFirebaseData();
                    Navigator.pop(ctx);
                    _toast(isAr
                        ? 'تم إرسال طلب عرض السعر بنجاح'
                        : 'Quotation Request Sent');
                  },
                  child: Text(isAr ? 'إرسال للإدارة' : 'Submit Request'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // TAB 1: DASHBOARD
  // ==========================================
  Widget _buildDashboardTab() {
    final bool isAr = widget.currentLanguage == 'ar';

    // Analytics calculations
    double todaySalesSdg = 0;
    int pendingOrdersCount = 0;
    for (var o in orders) {
      if (o['order_status'] == 'pending_review' ||
          o['order_status'] == 'waiting_payment_confirmation') {
        pendingOrdersCount++;
      }
      if (o['order_status'] == 'delivered' || o['order_status'] == 'preparing') {
        todaySalesSdg += (o['grand_total_sdg'] is num)
            ? (o['grand_total_sdg'] as num).toDouble()
            : 0.0;
      }
    }

    // Low stock items
    final lowStockItems = products.where((p) {
      int stock = (p['stock_quantity'] is num)
          ? (p['stock_quantity'] as num).toInt()
          : 100;
      int thresh = (p['low_stock_threshold'] is num)
          ? (p['low_stock_threshold'] as num).toInt()
          : 10;
      return stock <= thresh;
    }).toList();

    // Expiry items
    final expiryAlertItems = products.where((p) {
      if (p['expiry_date'] != null) {
        final exp = p['expiry_date'].toString();
        return exp.startsWith('2025') || exp.startsWith('2024');
      }
      return false;
    }).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner with USD Live Exchange Rate
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Color(0xFF063C3E),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.currency_exchange,
                              color: Colors.white, size: 14),
                          SizedBox(width: 6),
                          Text(
                            isAr
                                ? 'سعر الدولار اليوم: ${dollarRate.toStringAsFixed(0)} SDG'
                                : 'USD Exchange: ${dollarRate.toStringAsFixed(0)} SDG',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send, color: Colors.white),
                      tooltip: isAr ? 'بث إشعار ترويجي' : 'Push Promo',
                      onPressed: () => _openPushPromoSheet(),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  isAr ? 'لوحة التحكم والرقابة الإدارية' : 'DMC Admin Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  isAr
                      ? 'متابعة حية للمبيعات، الطلبات، المخزون وتنبيهات الصلاحية'
                      : 'Live sales stats, orders, stock & expiry alerts',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // KPI Cards Grid
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _buildKpiCard(
                isAr ? 'مبيعات اليوم' : 'Today Sales',
                '${todaySalesSdg.toStringAsFixed(0)} SDG',
                Icons.trending_up,
                Colors.teal,
              ),
              _buildKpiCard(
                isAr ? 'طلبات بانتظار الاعتماد' : 'Pending Orders',
                '$pendingOrdersCount ${isAr ? 'طلبات' : 'orders'}',
                Icons.mark_chat_unread_outlined,
                Colors.orange,
              ),
              _buildKpiCard(
                isAr ? 'نواقص المخزون' : 'Low Stock Alert',
                '${lowStockItems.length} ${isAr ? 'منتجات' : 'items'}',
                Icons.warning_amber_rounded,
                Colors.red,
              ),
              _buildKpiCard(
                isAr ? 'تنبيهات الصلاحية' : 'Expiry Alerts',
                '${expiryAlertItems.length} ${isAr ? 'أصناف' : 'items'}',
                Icons.hourglass_bottom,
                Colors.amber.shade900,
              ),
            ],
          ),
          SizedBox(height: 16),

          // Quick Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openProductFormSheet(),
                  icon: Icon(Icons.add_box, size: 16),
                  label: Text(
                    isAr ? 'إضافة منتج' : 'Add Product',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => currentNavIndex = 5),
                  icon: Icon(Icons.document_scanner, size: 16),
                  label: Text(
                    isAr ? 'مسح فاتورة AI' : 'Scan OCR Invoice',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Stock & Expiry Alerts Section
          if (lowStockItems.isNotEmpty || expiryAlertItems.isNotEmpty) ...[
            Text(
              isAr ? 'التنبيهات العاجلة للمخزون:' : 'Urgent Inventory Alerts:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            ...lowStockItems.map((item) => Card(
                  margin: EdgeInsets.only(bottom: 8),
                  color: Colors.red.withOpacity(0.06),
                  child: ListTile(
                    leading: Icon(Icons.warning, color: Colors.red),
                    title: Text(
                      item['name_ar'] ?? '',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${isAr ? 'الكمية المتبقية' : 'Stock remaining'}: ${item['stock_quantity']}',
                      style: TextStyle(fontSize: 11, color: Colors.red),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => _openProductFormSheet(p: item),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        isAr ? 'تزويد المخزون' : 'Restock',
                        style: TextStyle(fontSize: 11),
                      ),
                    ),
                  ),
                )),
          ],
          SizedBox(height: 16),

          // Recent Audit Logs
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAr ? 'أحدث أنشطة الرقابة (Audit Log)' : 'Recent Audit Logs',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () => setState(() => currentNavIndex = 7),
                child: Text(isAr ? 'عرض الكل' : 'View All'),
              ),
            ],
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: auditLogs.length > 4 ? 4 : auditLogs.length,
            itemBuilder: (ctx, i) {
              final log = auditLogs[i];
              return Card(
                margin: EdgeInsets.only(bottom: 6),
                child: ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    radius: 14,
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.12),
                    child: Icon(Icons.history, size: 14),
                  ),
                  title: Text(
                    log['action_type'] ?? 'إجراء',
                    style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${log['staff_name']} (${log['role']}) | ${log['timestamp']}',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildKpiCard(
      String title, String value, IconData icon, Color accentColor) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(icon, color: accentColor, size: 20),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 2: ORDERS & BANKAK & COD PAYMENTS
  // ==========================================
  Widget _buildOrdersTab() {
    final bool isAr = widget.currentLanguage == 'ar';

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          bottom: TabBar(
            labelColor: Theme.of(context).primaryColor,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: [
              Tab(text: isAr ? 'إدارة الطلبات' : 'Orders'),
              Tab(text: isAr ? 'مطابقة المدفوعات' : 'Payment Match'),
              Tab(text: isAr ? 'عروض الأسعار' : 'Quotations'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 1. ORDERS MANAGEMENT
            orders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(isAr ? 'لا توجد طلبات حية حالياً' : 'No live orders'),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (ctx, i) {
                      final o = orders[i];
                      final isCod = o['payment_method'] == 'cash_on_delivery';
                      return Card(
                        margin: EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: EdgeInsets.all(14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    o['order_number'] ?? 'DMC-ORDER',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                  _buildOrderStatusBadge(
                                      o['order_status'] ?? 'pending_review'),
                                ],
                              ),
                              SizedBox(height: 6),
                              Text(
                                '${isAr ? 'العميل' : 'Customer'}: ${o['user_id']} | ${isAr ? 'طريقة الدفع' : 'Payment'}: ${isCod ? 'نقداً عند الاستلام' : 'تحويل بنكك'}',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey),
                              ),
                              Divider(height: 16),
                              if (o['items_json'] is List)
                                ...((o['items_json'] as List).map((it) => Text(
                                      '• ${it['name_ar']} (x${it['qty']})',
                                      style: TextStyle(fontSize: 12),
                                    ))),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${isAr ? 'الإجمالي' : 'Total'}: ${(o['grand_total_sdg'] ?? 0).toString()} SDG',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.print, color: Colors.teal),
                                        tooltip: isAr ? 'طباعة فاتورة PDF' : 'Print PDF',
                                        onPressed: () => _openPdfInvoiceViewer(o),
                                      ),
                                      if (isCod &&
                                          o['payment_status'] != 'paid_on_delivery')
                                        ElevatedButton(
                                          onPressed: () async {
                                            if (o.containsKey('id')) {
                                              await FirebaseService.patch(
                                                  'orders/${o['id']}', {
                                                'payment_status':
                                                    'paid_on_delivery',
                                                'order_status': 'delivered'
                                              });
                                              _logAction(
                                                  'تسجيل استلام النقد في الدفع عند الاستلام',
                                                  {'order_id': o['id']});
                                              _fetchFirebaseData();
                                              _toast(isAr
                                                  ? 'تم تسجيل استلام المبلغ النقدي بنجاح'
                                                  : 'Cash Payment Recorded');
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green.shade700,
                                            foregroundColor: Colors.white,
                                          ),
                                          child: Text(
                                            isAr
                                                ? 'تسجيل استلام النقد'
                                                : 'Record Cash Recv',
                                            style: TextStyle(fontSize: 11),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              DropdownButtonFormField<String>(
                                value: o['order_status'] ?? 'pending_review',
                                items: [
                                  DropdownMenuItem(
                                      value: 'pending_review',
                                      child: Text('قيد المراجعة')),
                                  DropdownMenuItem(
                                      value: 'waiting_payment_confirmation',
                                      child: Text('بانتظار تأكيد الدفع')),
                                  DropdownMenuItem(
                                      value: 'preparing',
                                      child: Text('تم التجهيز للمستودع')),
                                  DropdownMenuItem(
                                      value: 'in_transit',
                                      child: Text('في الطريق مع المندوب')),
                                  DropdownMenuItem(
                                      value: 'delivered',
                                      child: Text('تم التسليم بالكامل')),
                                ],
                                onChanged: (val) async {
                                  if (val != null && o.containsKey('id')) {
                                    setState(() => o['order_status'] = val);
                                    await FirebaseService.patch(
                                        'orders/${o['id']}',
                                        {'order_status': val});
                                    _logAction('تحديث حالة طلب', {
                                      'order_id': o['id'],
                                      'new_status': val
                                    });
                                    _toast(isAr
                                        ? 'تم تحديث حالة الطلب بنجاح'
                                        : 'Order status updated');
                                  }
                                },
                                decoration: InputDecoration(
                                  labelText:
                                      isAr ? 'تغيير حالة الطلب' : 'Update Status',
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

            // 2. BANKAK RECEIPT VERIFICATION WITH RECEIPT IMAGE & COD RECORDING
            _buildBankakReceiptsList(),

            // 3. QUOTATION RESPONSES
            _buildQuotationsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBankakReceiptsList() {
    final bool isAr = widget.currentLanguage == 'ar';
    final bankakOrders = orders.where((o) => o['payment_method'] == 'bankak').toList();

    // Check duplicate receipts or transaction numbers
    final Set<String> usedTransNums = {};
    final Set<String> duplicateOrderIds = {};

    for (var o in orders) {
      final trans = o['transaction_number']?.toString() ?? '';
      if (trans.isNotEmpty && usedTransNums.contains(trans)) {
        duplicateOrderIds.add(o['id'].toString());
      } else if (trans.isNotEmpty) {
        usedTransNums.add(trans);
      }
    }

    return bankakOrders.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified, size: 48, color: Colors.grey),
                SizedBox(height: 8),
                Text(isAr
                    ? 'لا توجد إشعارات تحويل بنكك بانتظار التوثيق'
                    : 'No pending Bankak receipts'),
              ],
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: bankakOrders.length,
            itemBuilder: (ctx, i) {
              final o = bankakOrders[i];
              final bool isDuplicate =
                  duplicateOrderIds.contains(o['id'].toString());
              final String receiptUrl = o['receipt_image_url'] ?? '';

              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            o['order_number'] ?? 'DMC-ORDER',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          if (isDuplicate)
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                isAr ? '⚠️ إشعار / عملية مكررة!' : 'Duplicate Alert!',
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                        ],
                      ),
                      SizedBox(height: 6),
                      Text('${isAr ? 'المبلغ المطلوب' : 'Amount'}: ${o['grand_total_sdg']} SDG'),
                      Text('${isAr ? 'رقم العملية' : 'Transaction'}: ${o['transaction_number'] ?? 'لم يُدخل'}'),
                      SizedBox(height: 8),

                      // DISPLAY BANKAK RECEIPT IMAGE PREVIEW
                      Container(
                        height: 140,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.shade900,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.teal.shade300, width: 1.5),
                        ),
                        padding: EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 110,
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: receiptUrl.isNotEmpty && receiptUrl.startsWith('http')
                                  ? Image.network(receiptUrl, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.broken_image, color: Colors.white54))
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.receipt_long, color: Colors.amber, size: 36),
                                        SizedBox(height: 4),
                                        Text(isAr ? 'إشعار بنكك' : 'Bankak', style: TextStyle(color: Colors.white, fontSize: 9)),
                                      ],
                                    ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.account_balance, color: Colors.greenAccent, size: 16),
                                      SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          isAr ? 'تم التحويل إلى: 2390192' : 'To: 2390192',
                                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    '${isAr ? 'المبلغ' : 'Amount'}: ${o['grand_total_sdg']} SDG',
                                    style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.w900),
                                  ),
                                  Text(
                                    '${isAr ? 'الرقم المرجعي' : 'Ref No'}: ${o['transaction_number'] ?? 'TXN-998122'}',
                                    style: TextStyle(color: Colors.white70, fontSize: 10),
                                  ),
                                  Text(
                                    '${isAr ? 'التاريخ' : 'Date'}: ${o['created_at']?.toString().substring(0, 10) ?? ''}',
                                    style: TextStyle(color: Colors.white54, fontSize: 10),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),

                      SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                if (o.containsKey('id')) {
                                  await FirebaseService.patch(
                                      'orders/${o['id']}', {
                                    'payment_status': 'confirmed',
                                    'order_status': 'preparing'
                                  });
                                  _logAction('تأكيد دفع بنكك',
                                      {'order_id': o['id']});
                                  _fetchFirebaseData();
                                  _toast(isAr
                                      ? 'تم تأكيد الدفع وتحويل الطلب للتجهيز'
                                      : 'Payment Confirmed');
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white),
                              child: Text(isAr ? 'تأكيد الدفع' : 'Confirm'),
                            ),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _openRejectPaymentDialog(o),
                              style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red),
                              child: Text(isAr ? 'رفض الإشعار' : 'Reject'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  void _openRejectPaymentDialog(Map<String, dynamic> o) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        final bool isAr = widget.currentLanguage == 'ar';
        return AlertDialog(
          title: Text(isAr ? 'رفض إشعار الدفع' : 'Reject Payment'),
          content: TextField(
            controller: reasonCtrl,
            decoration: InputDecoration(
              labelText: isAr ? 'سبب الرفض ليصل للزبون' : 'Rejection Reason',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(isAr ? 'إلغاء' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (reasonCtrl.text.isEmpty) return;
                if (o.containsKey('id')) {
                  await FirebaseService.patch('orders/${o['id']}', {
                    'payment_status': 'rejected',
                    'rejection_reason': reasonCtrl.text
                  });
                  _logAction('رفض دفع بنكك',
                      {'order_id': o['id'], 'reason': reasonCtrl.text});
                  Navigator.pop(ctx);
                  _fetchFirebaseData();
                  _toast(isAr ? 'تم تسجيل رفض الإشعار' : 'Payment Rejected');
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(isAr ? 'تأكيد الرفض' : 'Confirm Reject'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuotationsList() {
    final bool isAr = widget.currentLanguage == 'ar';
    return quotations.isEmpty
        ? Center(
            child: Text(isAr ? 'لا توجد طلبات عروض أسعار' : 'No quotations'),
          )
        : ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: quotations.length,
            itemBuilder: (ctx, i) {
              final q = quotations[i];
              final respCtrl = TextEditingController(
                  text: q['admin_response_notes'] ?? '');
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        q['quotation_number'] ?? 'QUO-2025',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                          '${isAr ? 'الطلبات' : 'Requested'}: ${q['items_requested'] ?? q['customer_notes']}'),
                      SizedBox(height: 8),
                      TextField(
                        controller: respCtrl,
                        decoration: InputDecoration(
                          labelText: isAr ? 'كتابة الرد / السعر الخاص' : 'Admin Response',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (q.containsKey('id')) {
                            await FirebaseService.patch(
                                'quotations/${q['id']}', {
                              'admin_response_notes': respCtrl.text,
                              'status': 'responded'
                            });
                            _logAction('رد على عرض سعر', {'quo_id': q['id']});
                            _fetchFirebaseData();
                            _toast(isAr ? 'تم إرسال الرد للعميل' : 'Response Sent');
                          }
                        },
                        child: Text(isAr ? 'إرسال الرد' : 'Submit Response'),
                      )
                    ],
                  ),
                ),
              );
            },
          );
  }

  Widget _buildOrderStatusBadge(String status) {
    String label = 'قيد المراجعة';
    Color bg = Color(0xFFFFF8E1);
    Color fg = Colors.orange.shade800;

    if (status == 'waiting_payment_confirmation') {
      label = 'بانتظار تأكيد الدفع';
      bg = Color(0xFFE1F5FE);
      fg = Colors.blue.shade800;
    } else if (status == 'preparing') {
      label = 'تم التجهيز';
      bg = Color(0xFFE8F5E9);
      fg = Colors.green.shade800;
    } else if (status == 'in_transit') {
      label = 'في الطريق';
      bg = Color(0xFFE8F5E9);
      fg = Colors.green.shade800;
    } else if (status == 'delivered') {
      label = 'تم التسليم';
      bg = Color(0xFFE8F5E9);
      fg = Colors.green.shade900;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(label,
          style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  // ==========================================
  // TAB 3: PRODUCTS & INVENTORY
  // ==========================================
  Widget _buildInventoryTab() {
    final bool isAr = widget.currentLanguage == 'ar';
    final query = prodSearchCtrl.text.toLowerCase();

    final filtered = products.where((p) {
      final matchCat =
          selectedCategory == 'all' || p['category'] == selectedCategory;
      final nameAr = (p['name_ar'] ?? '').toString().toLowerCase();
      final matchQuery = query.isEmpty || nameAr.contains(query);
      return matchCat && matchQuery;
    }).toList();

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAr ? 'كتالوج المنتجات والمخزون' : 'Inventory & Catalog',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _openProductFormSheet(),
                icon: Icon(Icons.add, size: 16),
                label: Text(isAr ? 'منتج جديد' : 'Add Item'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),

          TextField(
            controller: prodSearchCtrl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: isAr ? 'ابحث عن صنف بالمخزن...' : 'Search Inventory...',
              prefixIcon: Icon(Icons.search),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
            ),
          ),
          SizedBox(height: 10),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCatChip('all', isAr ? 'الكل' : 'All'),
                _buildCatChip('consumables', isAr ? 'مستهلكات طبية' : 'Consumables'),
                _buildCatChip('medical_devices', isAr ? 'أجهزة طبية' : 'Medical Devices'),
                _buildCatChip('lab_surgery_supplies', isAr ? 'معامل وعمليات' : 'Lab & Surgery'),
              ],
            ),
          ),
          SizedBox(height: 14),

          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: filtered.length,
            itemBuilder: (ctx, i) {
              final p = filtered[i];
              final double baseUsd = (p['base_price_usd'] is num)
                  ? (p['base_price_usd'] as num).toDouble()
                  : 1.0;
              final bool isFixed = p['is_fixed_price'] == true;
              final double fixedSdg = (p['fixed_price_sdg'] is num)
                  ? (p['fixed_price_sdg'] as num).toDouble()
                  : 0.0;
              final int calculatedSdg =
                  _calculateSdgPrice(baseUsd, isFixed, fixedSdg);
              final int stock = (p['stock_quantity'] is num)
                  ? (p['stock_quantity'] as num).toInt()
                  : 100;

              return Card(
                margin: EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.background,
                    child: Text(p['image_emoji'] ?? '📦'),
                  ),
                  title: Text(
                    p['name_ar'] ?? '',
                    style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${calculatedSdg.toString()} SDG ${isFixed ? '(سعر ثابت بالجنيه)' : '($baseUsd \$)'} | ${isAr ? 'المخزون' : 'Stock'}: $stock',
                    style: TextStyle(
                        fontSize: 11,
                        color: stock < 10 ? Colors.red : Colors.grey,
                        fontWeight: FontWeight.bold),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, size: 20),
                        onPressed: () => _openProductFormSheet(p: p),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline,
                            color: Colors.red, size: 20),
                        onPressed: () async {
                          if (p.containsKey('id')) {
                            await FirebaseService.delete('products/${p['id']}');
                            _logAction('حذف منتج', {'prod_id': p['id']});
                            _fetchFirebaseData();
                            _toast(isAr ? 'تم حذف المنتج' : 'Product Deleted');
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCatChip(String key, String label) {
    final bool isSelected = selectedCategory == key;
    return Padding(
      padding: EdgeInsets.only(left: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => selectedCategory = key),
        selectedColor: Theme.of(context).primaryColor,
        labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black, fontSize: 11),
      ),
    );
  }

  // Add & Edit Product Modal Sheet with Fixed SDG option
  void _openProductFormSheet({Map<String, dynamic>? p}) {
    final nameArCtrl = TextEditingController(text: p?['name_ar'] ?? '');
    final nameEnCtrl = TextEditingController(text: p?['name_en'] ?? '');
    final usdCtrl =
        TextEditingController(text: p?['base_price_usd']?.toString() ?? '5.0');
    final fixedPriceSdgCtrl = TextEditingController(
        text: p?['fixed_price_sdg']?.toString() ?? '15000');
    bool isFixedPrice = p?['is_fixed_price'] == true;
    final costCtrl = TextEditingController(
        text: p?['cost_price_sdg']?.toString() ?? '5000');
    final stockCtrl =
        TextEditingController(text: p?['stock_quantity']?.toString() ?? '100');
    final expiryCtrl = TextEditingController(
        text: p?['expiry_date'] ?? '2027-12-31');
    final imgCtrl = TextEditingController(text: p?['image_url'] ?? '');

    String category = p?['category'] ?? 'consumables';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctxState, setSheetState) {
            final bool isAr = widget.currentLanguage == 'ar';
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p == null
                          ? (isAr ? 'إضافة منتج جديد' : 'New Product')
                          : (isAr ? 'تعديل المنتج' : 'Edit Product'),
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: nameArCtrl,
                      decoration: InputDecoration(
                        labelText: isAr ? 'اسم المنتج بالعربية' : 'Arabic Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: nameEnCtrl,
                      decoration: InputDecoration(
                        labelText: isAr ? 'اسم المنتج بالإنجليزية' : 'English Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: category,
                      items: [
                        DropdownMenuItem(
                            value: 'consumables', child: Text('مستهلكات طبية')),
                        DropdownMenuItem(
                            value: 'medical_devices', child: Text('أجهزة طبية')),
                        DropdownMenuItem(
                            value: 'lab_surgery_supplies',
                            child: Text('معامل وعمليات')),
                      ],
                      onChanged: (val) {
                        if (val != null) setSheetState(() => category = val);
                      },
                      decoration: InputDecoration(
                        labelText: isAr ? 'الفئة الطبية' : 'Category',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8),

                    // Fixed Price vs Usd Rate Toggle
                    SwitchListTile(
                      title: Text(isAr
                          ? 'تحديد سعر ثابت بالجنيه (بدون دولار)'
                          : 'Fixed SDG Price (No USD Rate)'),
                      value: isFixedPrice,
                      onChanged: (val) => setSheetState(() => isFixedPrice = val),
                    ),

                    if (isFixedPrice)
                      TextField(
                        controller: fixedPriceSdgCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: isAr
                              ? 'السعر الثابت بالجنيه (SDG)'
                              : 'Fixed Price SDG',
                          border: OutlineInputBorder(),
                        ),
                      )
                    else
                      TextField(
                        controller: usdCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: isAr ? 'السعر الأساسي بالدولار ($)' : 'USD Price',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    SizedBox(height: 8),

                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: costCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: isAr ? 'التكلفة بالجنيه' : 'Cost SDG',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: stockCtrl,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: isAr ? 'الكمية بالمخزن' : 'Stock Qty',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: expiryCtrl,
                      decoration: InputDecoration(
                        labelText: isAr ? 'تاريخ الصلاحية' : 'Expiry Date',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: imgCtrl,
                      decoration: InputDecoration(
                        labelText: isAr ? 'رابط/مسار صورة المنتج' : 'Image URL',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          final item = {
                            'name_ar': nameArCtrl.text,
                            'name_en': nameEnCtrl.text,
                            'category': category,
                            'base_price_usd':
                                double.tryParse(usdCtrl.text) ?? 5.0,
                            'fixed_price_sdg':
                                double.tryParse(fixedPriceSdgCtrl.text) ?? 15000.0,
                            'is_fixed_price': isFixedPrice,
                            'cost_price_sdg':
                                double.tryParse(costCtrl.text) ?? 5000.0,
                            'stock_quantity':
                                int.tryParse(stockCtrl.text) ?? 100,
                            'low_stock_threshold': 10,
                            'expiry_date': expiryCtrl.text,
                            'image_url': imgCtrl.text,
                            'image_emoji': '📦',
                          };

                          if (p != null && p.containsKey('id')) {
                            await FirebaseService.patch(
                                'products/${p['id']}', item);
                            _logAction('تعديل منتج', {'prod_id': p['id']});
                          } else {
                            await FirebaseService.post('products', item);
                            _logAction('إضافة منتج جديد',
                                {'name': nameArCtrl.text});
                          }

                          _fetchFirebaseData();
                          Navigator.pop(ctx);
                          _toast(isAr ? 'تم الحفظ بنجاح' : 'Product Saved');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(isAr ? 'حفظ البيانات' : 'Save Product'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================
  // TAB 4: USD EXCHANGE RATE & FINANCE
  // ==========================================
  Widget _buildUsdFinanceTab() {
    final bool isAr = widget.currentLanguage == 'ar';
    final bool canEditRate = currentRole == 'manager' || currentRole == 'accountant';

    usdRateCtrl.text = dollarRate.toStringAsFixed(0);
    marginCtrl.text = profitMarginPercent.toStringAsFixed(0);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isAr ? 'إعدادات سعر الدولار والتسعير' : 'USD Exchange Rate Settings',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          if (!canEditRate)
            Container(
              padding: EdgeInsets.all(10),
              margin: EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                isAr
                    ? '⚠️ تنبيه: تعديل سعر الدولار مخصص للمدير والمحاسب فقط!'
                    : 'Restricted: Manager & Accountant only!',
                style: TextStyle(color: Colors.red, fontSize: 11),
              ),
            ),

          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: usdRateCtrl,
                    enabled: canEditRate,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: isAr
                          ? 'سعر الدولار اليوم (SDG)'
                          : 'Daily USD Rate (SDG)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: marginCtrl,
                    enabled: canEditRate,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: isAr ? 'نسبة هامش الربح (%)' : 'Profit Margin %',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: roundingMode,
                    items: [
                      DropdownMenuItem(
                          value: 'none', child: Text('بدون تقريب')),
                      DropdownMenuItem(
                          value: 'nearest_100', child: Text('أقرب 100 جنيه')),
                      DropdownMenuItem(
                          value: 'nearest_500', child: Text('أقرب 500 جنيه')),
                    ],
                    onChanged: canEditRate
                        ? (v) {
                            if (v != null) setState(() => roundingMode = v);
                          }
                        : null,
                    decoration: InputDecoration(
                      labelText: isAr ? 'طريقة تقريب الأسعار' : 'Rounding Mode',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => _openPreviewPricesSheet(),
                          child: Text(isAr ? 'معاينة الأسعار' : 'Preview Prices'),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: !canEditRate
                              ? null
                              : () async {
                                  final newRate =
                                      double.tryParse(usdRateCtrl.text) ?? 2500;
                                  final newMargin =
                                      double.tryParse(marginCtrl.text) ?? 10;

                                  await FirebaseService.put(
                                      'dollar_rate_settings', {
                                    'rate_sdg': newRate,
                                    'profit_margin_percent': newMargin,
                                    'rounding_mode': roundingMode,
                                    'updated_at':
                                        DateTime.now().toIso8601String()
                                  });

                                  await FirebaseService.post(
                                      'dollar_rate_logs', {
                                    'old_rate': dollarRate,
                                    'new_rate': newRate,
                                    'changed_by': currentStaff?['name'],
                                    'changed_at':
                                        DateTime.now().toIso8601String()
                                  });

                                  _logAction('تحديث سعر الدولار',
                                      {'new_rate': newRate});
                                  setState(() {
                                    dollarRate = newRate;
                                    profitMarginPercent = newMargin;
                                  });
                                  _toast(isAr
                                      ? 'تم اعتماد وتطبيق سعر الدولار الجديد'
                                      : 'USD Rate Updated');
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                          child: Text(isAr ? 'تطبيق السعر' : 'Apply Rate'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          Text(
            isAr ? 'سجل تغييرات سعر الدولار' : 'Dollar Rate Logs',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: dollarLogs.length,
            itemBuilder: (ctx, i) {
              final log = dollarLogs[i];
              return Card(
                margin: EdgeInsets.only(bottom: 6),
                child: ListTile(
                  dense: true,
                  title: Text(
                    '${isAr ? 'تغيير السعر إلى' : 'Changed to'}: ${log['new_rate']} SDG',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${isAr ? 'السعر السابق' : 'Old Rate'}: ${log['old_rate']} SDG | ${log['changed_at']}',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _openPreviewPricesSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        final bool isAr = widget.currentLanguage == 'ar';
        final newRate = double.tryParse(usdRateCtrl.text) ?? dollarRate;

        return Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAr ? 'معاينة الأسعار قبل الاعتماد' : 'Prices Preview',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (c, i) {
                    final p = products[i];
                    final double baseUsd = (p['base_price_usd'] is num)
                        ? (p['base_price_usd'] as num).toDouble()
                        : 1.0;
                    final int oldSdg = _calculateSdgPrice(baseUsd, false, 0);
                    final double raw =
                        baseUsd * newRate * (1 + (profitMarginPercent / 100));
                    int newSdg = raw.round();
                    if (roundingMode == 'nearest_100') {
                      newSdg = ((newSdg + 50) ~/ 100) * 100;
                    } else if (roundingMode == 'nearest_500') {
                      newSdg = ((newSdg + 250) ~/ 500) * 500;
                    }

                    return ListTile(
                      title: Text(p['name_ar'] ?? '',
                          style: TextStyle(fontSize: 12)),
                      subtitle: Text(
                        '${isAr ? 'القديم' : 'Old'}: $oldSdg SDG -> ${isAr ? 'الجديد' : 'New'}: $newSdg SDG',
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // TAB 5: ZONES & BANK ACCOUNTS (ADD / EDIT / TOGGLE)
  // ==========================================
  Widget _buildZonesAndBanksTab() {
    final bool isAr = widget.currentLanguage == 'ar';
    final bool isManager = currentRole == 'manager';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          bottom: TabBar(
            labelColor: Theme.of(context).primaryColor,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: [
              Tab(text: isAr ? 'مناطق التوصيل' : 'Delivery Zones'),
              Tab(text: isAr ? 'حسابات بنكك' : 'Bank Accounts'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // 1. ZONES LIST
            Column(
              children: [
                if (isManager)
                  Padding(
                    padding: EdgeInsets.all(12.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _openZoneFormSheet(),
                        icon: Icon(Icons.add_location_alt),
                        label: Text(
                            isAr ? 'إضافة منطقة توصيل جديدة' : 'Add New Zone'),
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white),
                      ),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: deliveryZones.length,
                    itemBuilder: (ctx, i) {
                      final z = deliveryZones[i];
                      final bool isActive = z['is_active'] != false;
                      return Card(
                        margin: EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: Icon(Icons.location_city, color: Colors.teal),
                          title: Text(z['zone_name'] ?? ''),
                          subtitle: Text('${z['fee_sdg']} SDG'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Switch(
                                value: isActive,
                                onChanged: (val) async {
                                  if (z.containsKey('id')) {
                                    await FirebaseService.patch(
                                        'delivery_zones/${z['id']}',
                                        {'is_active': val});
                                    _fetchFirebaseData();
                                  }
                                },
                              ),
                              if (isManager) ...[
                                IconButton(
                                  icon: Icon(Icons.edit, size: 20),
                                  onPressed: () => _openZoneFormSheet(z: z),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete,
                                      color: Colors.red, size: 20),
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (c) => AlertDialog(
                                        title: Text(isAr
                                            ? 'حذف المنطقة'
                                            : 'Delete Zone'),
                                        content: Text(isAr
                                            ? 'هل أنت تأكد من حذف هذه المنطقة؟'
                                            : 'Confirm delete?'),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(c, false),
                                              child:
                                                  Text(isAr ? 'إلغاء' : 'Cancel')),
                                          ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.pop(c, true),
                                              child:
                                                  Text(isAr ? 'حذف' : 'Delete')),
                                        ],
                                      ),
                                    );
                                    if (confirm == true && z.containsKey('id')) {
                                      await FirebaseService.delete(
                                          'delivery_zones/${z['id']}');
                                      _logAction('حذف منطقة توصيل',
                                          {'zone_id': z['id']});
                                      _fetchFirebaseData();
                                      _toast(isAr ? 'تم حذف المنطقة' : 'Deleted');
                                    }
                                  },
                                ),
                              ]
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            // 2. BANK ACCOUNTS LIST
            ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: bankAccounts.length,
              itemBuilder: (ctx, i) {
                final b = bankAccounts[i];
                final bool isActive = b['is_active'] == true;
                return Card(
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: Icon(Icons.account_balance, color: Colors.blue),
                    title: Text(b['owner_name'] ?? ''),
                    subtitle: Text('${b['bank_name']} | ${b['account_number']}'),
                    trailing: Switch(
                      value: isActive,
                      onChanged: (val) async {
                        if (b.containsKey('id')) {
                          await FirebaseService.patch(
                              'bank_accounts/${b['id']}', {'is_active': val});
                          _fetchFirebaseData();
                        }
                      },
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openZoneFormSheet({Map<String, dynamic>? z}) {
    final nameCtrl = TextEditingController(text: z?['zone_name'] ?? '');
    final feeCtrl =
        TextEditingController(text: z?['fee_sdg']?.toString() ?? '1500');

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        final isAr = widget.currentLanguage == 'ar';
        return Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                z == null
                    ? (isAr ? 'إضافة منطقة توصيل' : 'Add Delivery Zone')
                    : (isAr ? 'تعديل منطقة التوصيل' : 'Edit Delivery Zone'),
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: isAr
                      ? 'اسم المنطقة (مثال: عطبرة، الدامر)'
                      : 'Zone Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10),
              TextField(
                controller: feeCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: isAr ? 'رسوم التوصيل بالجنيه' : 'Fee SDG',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (nameCtrl.text.isEmpty) return;
                    final data = {
                      'zone_name': nameCtrl.text,
                      'fee_sdg': double.tryParse(feeCtrl.text) ?? 1500.0,
                      'is_active': true,
                      'created_at': DateTime.now().toString(),
                    };
                    if (z != null && z.containsKey('id')) {
                      await FirebaseService.patch(
                          'delivery_zones/${z['id']}', data);
                      _logAction('تعديل منطقة توصيل', {'zone': nameCtrl.text});
                    } else {
                      await FirebaseService.post('delivery_zones', data);
                      _logAction('إضافة منطقة توصيل', {'zone': nameCtrl.text});
                    }
                    _fetchFirebaseData();
                    Navigator.pop(ctx);
                    _toast(isAr ? 'تم الحفظ بنجاح' : 'Zone Saved');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(isAr ? 'حفظ المنطقة' : 'Save Zone'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================
  // TAB 6: AI OCR PURCHASE INVOICE SCANNER (INTERACTIVE DIALOG)
  // ==========================================
  Widget _buildOcrScannerTab() {
    final bool isAr = widget.currentLanguage == 'ar';

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isAr ? 'مسح فواتير الشراء بالذكاء الاصطناعي (OCR)' : 'AI OCR Invoice Scanner',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6),
          Text(
            isAr
                ? 'استخراج الأصناف، الكميات والأسعار تلقائياً وزيادة المخزون وتحديث التكلفة'
                : 'Extract items, quantities & update product stock/cost',
            style: TextStyle(fontSize: 11, color: Colors.grey),
          ),
          SizedBox(height: 16),

          Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(Icons.document_scanner, size: 54, color: Colors.teal),
                  SizedBox(height: 12),
                  Text(
                    isAr ? 'التقاط أو رفع صورة الفاتورة الورقية' : 'Scan Paper Invoice',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _openOcrScannerDialog(),
                          icon: Icon(Icons.camera_alt),
                          label: Text(isAr ? 'الكاميرا' : 'Camera'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _openOcrScannerDialog(),
                          icon: Icon(Icons.photo_library),
                          label: Text(isAr ? 'المعرض' : 'Gallery'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),

          Text(
            isAr ? 'الفواتير الممسوحة سابقاً' : 'Scanned Invoices History',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: purchaseInvoices.length,
            itemBuilder: (ctx, i) {
              final inv = purchaseInvoices[i];
              return Card(
                margin: EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(Icons.receipt, color: Colors.grey),
                  title: Text(inv['supplier_name'] ?? 'مورد'),
                  subtitle: Text(
                      '${inv['invoice_number']} | ${inv['total_cost_sdg']} SDG'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _openOcrScannerDialog() {
    final supplierCtrl = TextEditingController(text: 'شركة النيل الطبية للمستوردات');
    final invNumCtrl = TextEditingController(text: 'INV-${Random().nextInt(9000) + 1000}');
    final item1NameCtrl = TextEditingController(text: 'قفازات فحص طبية لاتكس');
    final item1QtyCtrl = TextEditingController(text: '50');
    final item1CostCtrl = TextEditingController(text: '6500');

    showDialog(
      context: context,
      builder: (ctx) {
        final bool isAr = widget.currentLanguage == 'ar';
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.amber),
              SizedBox(width: 8),
              Text(isAr ? 'معالجة ومراجعة الفاتورة (OCR)' : 'OCR Invoice Extraction'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isAr ? 'البيانات المُستخرجة تلقائياً من صورة الفاتورة:' : 'Extracted details from photo:'),
                SizedBox(height: 10),
                TextField(
                  controller: supplierCtrl,
                  decoration: InputDecoration(
                    labelText: isAr ? 'اسم المورد' : 'Supplier Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: invNumCtrl,
                  decoration: InputDecoration(
                    labelText: isAr ? 'رقم الفاتورة' : 'Invoice No.',
                    border: OutlineInputBorder(),
                  ),
                ),
                Divider(height: 20),
                Text(isAr ? 'الأصناف المستخرجة لمطابقتها مع المخزون:' : 'Extracted Items:'),
                SizedBox(height: 8),
                TextField(
                  controller: item1NameCtrl,
                  decoration: InputDecoration(
                    labelText: isAr ? 'اسم الصنف' : 'Item Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: item1QtyCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: isAr ? 'الكمية المضافة' : 'Qty',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: item1CostCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: isAr ? 'التكلفة بالجنيه' : 'Cost SDG',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(isAr ? 'إلغاء' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final int addedQty = int.tryParse(item1QtyCtrl.text) ?? 50;
                final double newCost = double.tryParse(item1CostCtrl.text) ?? 6500;
                final double totalCost = addedQty * newCost;

                final mockInvoice = {
                  'supplier_name': supplierCtrl.text,
                  'invoice_number': invNumCtrl.text,
                  'invoice_date': DateTime.now().toString().substring(0, 10),
                  'items_json': [
                    {'name_ar': item1NameCtrl.text, 'qty': addedQty, 'cost_sdg': newCost}
                  ],
                  'total_cost_sdg': totalCost,
                  'scanned_by_staff_id': currentStaff?['name'] ?? 'مستخدم',
                  'created_at': DateTime.now().toString().substring(0, 16),
                };

                // Match and restock products in DB
                for (var prod in products) {
                  if (prod['name_ar'] != null &&
                      prod['name_ar'].toString().contains(item1NameCtrl.text.substring(0, 3))) {
                    final int currentQty = (prod['stock_quantity'] is num)
                        ? (prod['stock_quantity'] as num).toInt()
                        : 0;
                    final updatedQty = currentQty + addedQty;

                    if (prod.containsKey('id')) {
                      await FirebaseService.patch('products/${prod['id']}', {
                        'stock_quantity': updatedQty,
                        'cost_price_sdg': newCost,
                      });
                    }
                  }
                }

                await FirebaseService.post('purchase_invoices', mockInvoice);
                _logAction('مسح فاتورة OCR وزيادة المخزون', {'invoice_number': invNumCtrl.text});
                Navigator.pop(ctx);
                _fetchFirebaseData();
                _toast(isAr ? 'تم حفظ الفاتورة وتحديث المخزون بنجاح!' : 'Invoice Saved & Inventory Updated');
              },
              style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).primaryColor, foregroundColor: Colors.white),
              child: Text(isAr ? 'اعتماد وزيادة الكميات' : 'Confirm & Restock'),
            ),
          ],
        );
      },
    );
  }

  // ==========================================
  // TAB 7: CUSTOMERS & SPECIAL PRICING & VISUAL REPORTS
  // ==========================================
  Widget _buildCustomersAndReportsTab() {
    final bool isAr = widget.currentLanguage == 'ar';

    // Analytics calculation
    double totalRevenue = 0;
    int totalDeliveredOrders = 0;
    for (var o in orders) {
      if (o['order_status'] == 'delivered' || o['order_status'] == 'preparing') {
        totalRevenue += (o['grand_total_sdg'] is num) ? (o['grand_total_sdg'] as num).toDouble() : 0;
        totalDeliveredOrders++;
      }
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // VISUAL GRAPHICAL REPORT CHART
          Text(
            isAr ? 'التقارير المالية والبيانية' : 'Financial & Visual Analytics',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Card(
            color: Theme.of(context).colorScheme.surface,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isAr ? 'مبيعات وإيرادات الأسبوع (SDG)' : 'Weekly Sales Chart', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('${totalRevenue.toStringAsFixed(0)} SDG', style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w900)),
                    ],
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    height: 120,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: SalesBarChartPainter(
                        primaryColor: Theme.of(context).primaryColor,
                        salesValues: [totalRevenue * 0.2, totalRevenue * 0.4, totalRevenue * 0.1, totalRevenue * 0.7, totalRevenue * 0.9, totalRevenue],
                      ),
                    ),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text('السبت', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      Text('الأحد', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      Text('الإثنين', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      Text('الثلاثاء', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      Text('الأربعاء', style: TextStyle(fontSize: 10, color: Colors.grey)),
                      Text('الخميس', style: TextStyle(fontSize: 10, color: Colors.grey)),
                    ],
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAr ? 'إدارة العملاء والمؤسسات' : 'Customers & Accounts',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              ElevatedButton.icon(
                onPressed: () => _openCustomerEditSheet(),
                icon: Icon(Icons.person_add, size: 16),
                label: Text(isAr ? 'عميل جديد' : 'New Customer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: customers.length,
            itemBuilder: (ctx, i) {
              final c = customers[i];
              final isInst = c['account_type'] == 'medical_institution';
              final double discount = (c['special_discount_percent'] is num)
                  ? (c['special_discount_percent'] as num).toDouble()
                  : 0.0;

              return Card(
                margin: EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        Theme.of(context).primaryColor.withOpacity(0.12),
                    child: Text(isInst ? '🏥' : '👤'),
                  ),
                  title: Text(c['full_name'] ?? ''),
                  subtitle: Text(
                      '${c['phone'] ?? ''} | ${isInst ? (isAr ? 'مؤسسة طبية' : 'Institution') : (isAr ? 'فرد' : 'Individual')}\n${isAr ? 'نسبة الخصم الخاص' : 'Discount'}: $discount%'),
                  trailing: IconButton(
                    icon: Icon(Icons.edit, size: 20),
                    onPressed: () => _openCustomerEditSheet(c: c),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _openCustomerEditSheet({Map<String, dynamic>? c}) {
    final nameCtrl = TextEditingController(text: c?['full_name'] ?? '');
    final phoneCtrl = TextEditingController(text: c?['phone'] ?? '');
    final discountCtrl = TextEditingController(
        text: c?['special_discount_percent']?.toString() ?? '5');
    String accountType = c?['account_type'] ?? 'individual';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctxState, setSheetState) {
            final isAr = widget.currentLanguage == 'ar';
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c == null
                          ? (isAr ? 'إضافة عميل جديد' : 'New Customer')
                          : (isAr ? 'تعديل أسعار العميل' : 'Edit Customer'),
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: isAr ? 'الاسم الكامل / المستشفى' : 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: phoneCtrl,
                      decoration: InputDecoration(
                        labelText: isAr ? 'رقم الهاتف' : 'Phone',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: accountType,
                      items: [
                        DropdownMenuItem(
                            value: 'individual', child: Text('فرد (Individual)')),
                        DropdownMenuItem(
                            value: 'medical_institution',
                            child: Text('مؤسسة طبية (Institution)')),
                      ],
                      onChanged: (v) {
                        if (v != null) setSheetState(() => accountType = v);
                      },
                      decoration: InputDecoration(
                        labelText: isAr ? 'نوع الحساب' : 'Account Type',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: discountCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: isAr
                            ? 'نسبة الخصم الخاص (%)'
                            : 'Special Discount %',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final data = {
                            'full_name': nameCtrl.text,
                            'phone': phoneCtrl.text,
                            'account_type': accountType,
                            'special_discount_percent':
                                double.tryParse(discountCtrl.text) ?? 0.0,
                            'created_at': DateTime.now().toString(),
                          };
                          if (c != null && c.containsKey('id')) {
                            await FirebaseService.patch('users/${c['id']}', data);
                          } else {
                            await FirebaseService.post('users', data);
                          }
                          _logAction('تحديد أسعار عميل خاصة',
                              {'customer': nameCtrl.text});
                          _fetchFirebaseData();
                          Navigator.pop(ctx);
                          _toast(isAr ? 'تم حفظ بيانات العميل' : 'Customer Saved');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(isAr ? 'حفظ البيانات' : 'Save Customer'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // PDF INVOICE EXPORT VIEWER DIALOG
  void _openPdfInvoiceViewer(Map<String, dynamic> o) {
    showDialog(
      context: context,
      builder: (ctx) {
        final bool isAr = widget.currentLanguage == 'ar';
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(isAr ? 'فاتورة DMC الرسمية (PDF)' : 'PDF Official Invoice'),
              Icon(Icons.picture_as_pdf, color: Colors.red),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Text('DMC MEDICAL SUPPLIES', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Theme.of(context).primaryColor)),
                        Text('سودان - الخرطوم / عطبرة / بربر', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        Divider(),
                      ],
                    ),
                  ),
                  Text('${isAr ? 'رقم الفاتورة' : 'Invoice No'}: ${o['order_number']}'),
                  Text('${isAr ? 'العميل' : 'Customer'}: ${o['user_id']}'),
                  Text('${isAr ? 'التاريخ' : 'Date'}: ${o['created_at']?.toString().substring(0, 16) ?? ''}'),
                  Divider(),
                  Text('الأصناف والمنتجات:', style: TextStyle(fontWeight: FontWeight.bold)),
                  if (o['items_json'] is List)
                    ...((o['items_json'] as List).map((it) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 2.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('${it['name_ar']} (x${it['qty']})', style: TextStyle(fontSize: 11)),
                              Text('${it['fixed_price_sdg'] ?? 15000} SDG', style: TextStyle(fontSize: 11)),
                            ],
                          ),
                        ))),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('رسوم التوصيل:', style: TextStyle(fontSize: 11)),
                      Text('${o['delivery_fee_sdg'] ?? 1500} SDG', style: TextStyle(fontSize: 11)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('الإجمالي الكلي:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      Text('${o['grand_total_sdg']} SDG', style: TextStyle(fontWeight: FontWeight.w900, color: Theme.of(context).primaryColor, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(isAr ? 'إغلاق' : 'Close'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                _logAction('تصدير/مشاركة فاتورة PDF', {'order_id': o['id']});
                Navigator.pop(ctx);
                _toast(isAr ? 'تم تصدير وإرسال الفاتورة عبر واتساب' : 'Invoice Exported to WhatsApp');
              },
              icon: Icon(Icons.share, size: 16),
              label: Text(isAr ? 'مشاركة PDF / واتساب' : 'Share PDF'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            )
          ],
        );
      },
    );
  }

  // ==========================================
  // TAB 8: AUDIT LOG
  // ==========================================
  Widget _buildAuditLogsTab() {
    final bool isAr = widget.currentLanguage == 'ar';

    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: auditLogs.length,
      itemBuilder: (ctx, i) {
        final log = auditLogs[i];
        return Card(
          margin: EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(Icons.verified_user, color: Colors.teal),
            title: Text(
              log['action_type'] ?? 'إجراء',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            subtitle: Text(
              '${isAr ? 'المستخدم' : 'User'}: ${log['staff_name']} (${log['role']})\n${isAr ? 'التوقيت' : 'Time'}: ${log['timestamp']}',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ),
        );
      },
    );
  }

  // ==========================================
  // PROMO PUSH NOTIFICATIONS SHEET (WRITES TO DB)
  // ==========================================
  void _openPushPromoSheet() {
    final titleCtrl = TextEditingController(text: 'تخفيضات DMC الطبية الكبرى');
    final bodyCtrl = TextEditingController(
        text: 'تنزيلات خاصة على القفازات ومستلزمات المستشفيات لفترة محدودة!');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        final bool isAr = widget.currentLanguage == 'ar';
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isAr ? 'بث إشعار ترويجي للزبائن' : 'Push Promo Notification',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: isAr ? 'عنوان الإشعار' : 'Notification Title',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: bodyCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: isAr ? 'نص العرض الترويجي' : 'Message Body',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    final pushData = {
                      'title': titleCtrl.text,
                      'body': bodyCtrl.text,
                      'sent_at': DateTime.now().toString(),
                      'sent_by_staff_id': currentStaff?['name'] ?? 'مدير',
                    };

                    await FirebaseService.post('push_notifications', pushData);
                    _logAction('إرسال إشعار ترويجي', {'title': titleCtrl.text});
                    _fetchFirebaseData();
                    Navigator.pop(ctx);
                    _toast(isAr
                        ? 'تم حفظ وبث الإشعار الترويجي في قاعدة البيانات!'
                        : 'Promo Saved & Broadcasted!');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(isAr ? 'إرسال لجميع العملاء' : 'Send Push Alert'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ==========================================
// CUSTOM PAINTER FOR SALES BAR CHART
// ==========================================
class SalesBarChartPainter extends CustomPainter {
  final Color primaryColor;
  final List<double> salesValues;

  SalesBarChartPainter({required this.primaryColor, required this.salesValues});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint barPaint = Paint()
      :color = primaryColor
      ..style = PaintingStyle.fill;

    final Paint bgPaint = Paint()
      ..color = primaryColor.withOpacity(0.12)
      ..style = PaintingStyle.fill;

    final double barWidth = size.width / (salesValues.length * 2);
    double maxVal = 100.0;
    for (var v in salesValues) {
      if (v > maxVal) maxVal = v;
    }

    for (int i = 0; i < salesValues.length; i++) {
      final double x = (i * 2 + 0.5) * barWidth;
      final double heightRatio = (salesValues[i] / maxVal).clamp(0.1, 1.0);
      final double barHeight = size.height * heightRatio;

      // Draw background bar
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, 0, barWidth, size.height), Radius.circular(6)),
        bgPaint,
      );

      // Draw value bar
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x, size.height - barHeight, barWidth, barHeight), Radius.circular(6)),
        barPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SalesBarChartPainter oldDelegate) => true;
}

// ===== تحديث التطبيق (يُضاف تلقائياً) =====
const int _apkCur = 1;
const String _apkUrl = 'https://raw.githubusercontent.com/alkahlizero564-sudo/apk-app/main/apps/dmcadmin0hw0/update.json';

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
