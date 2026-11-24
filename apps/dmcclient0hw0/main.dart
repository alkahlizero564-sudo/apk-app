import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'dart:async' as apkas;
import 'dart:convert' as apkjs;
import 'dart:io' as apkio;
import 'package:flutter/widgets.dart' as apkw;
import 'package:url_launcher/url_launcher.dart' as apkul;

// ==========================================
// NOTIFICATION SERVICE
// ==========================================
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initLocalNotifications() async {
  try {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  } catch (_) {}
}

Future<void> triggerNotification(String title, String body) async {
  try {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'dmc_channel_id',
      'DMC Sudan Notifications',
      channelDescription: 'Updates on orders, status and medical quotes',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);
    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      platformDetails,
    );
  } catch (_) {}
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  initLocalNotifications();
  runApp(DmcApp());
}

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
class DmcApp extends StatefulWidget {
  const DmcApp({Key? key}) : super(key: key);

  @override
  State<DmcApp> createState() => _DmcAppState();
}

class _DmcAppState extends State<DmcApp> {
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
        child: HomeScreen(
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
// HOME SCREEN & STATE MANAGEMENT
// ==========================================
class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;
  final String currentLanguage;
  final ValueChanged<String> onLanguageChanged;

  const HomeScreen({
    Key? key,
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.currentLanguage,
    required this.onLanguageChanged,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentNavIndex = 0;
  Timer? pollingTimer;

  // Remote Data
  double dollarRate = 2500.0;
  List<Map<String, dynamic>> products = [];
  List<Map<String, dynamic>> orders = [];
  List<Map<String, dynamic>> quotations = [];
  List<Map<String, dynamic>> deliveryZones = [];
  List<Map<String, dynamic>> auditLogs = [];
  Map<String, dynamic> bankAccount = {
    'bank_name': 'بنك الخرطوم (بنكك)',
    'account_number': '2849102',
    'owner_name': 'شركة DMC للمعدات والمستلزمات الطبية المحدودة',
    'is_active': true
  };

  // Auth & Persistence State
  Map<String, dynamic>? currentUser;
  Map<String, dynamic>? currentStaff; // Admin logged in staff
  List<Map<String, dynamic>> cart = [];
  List<String> favorites = [];

  // Controllers & Filtering
  final TextEditingController searchController = TextEditingController();
  String selectedCategory = 'all';
  String selectedBrand = 'all';

  @override
  void initState() {
    super.initState();
    _loadLocalSavedData();
    _fetchFirebaseData();
    pollingTimer = Timer.periodic(Duration(seconds: 5), (_) {
      if (mounted) _fetchFirebaseData();
    });
  }

  @override
  void dispose() {
    pollingTimer?.cancel();
    searchController.dispose();
    super.dispose();
  }

  // Local Storage via SharedPreferences
  Future<void> _loadLocalSavedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? cartStr = prefs.getString('dmc_cart_v3');
      if (cartStr != null && cartStr.isNotEmpty) {
        final List decoded = json.decode(cartStr);
        cart = decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      final String? userStr = prefs.getString('dmc_user_v3');
      if (userStr != null && userStr.isNotEmpty) {
        currentUser = Map<String, dynamic>.from(json.decode(userStr));
      }
      final List<String>? favs = prefs.getStringList('dmc_favs_v3');
      if (favs != null) {
        favorites = favs;
      }
      if (mounted) setState(() {});
    } catch (_) {}
  }

  Future<void> _saveCartLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('dmc_cart_v3', json.encode(cart));
    } catch (_) {}
  }

  Future<void> _saveUserLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (currentUser != null) {
        await prefs.setString('dmc_user_v3', json.encode(currentUser));
      } else {
        await prefs.remove('dmc_user_v3');
      }
    } catch (_) {}
  }

  Future<void> _saveFavoritesLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('dmc_favs_v3', favorites);
    } catch (_) {}
  }

  // Fetch Firebase Data
  Future<void> _fetchFirebaseData() async {
    // 1. Dollar Rate
    final rateData = await FirebaseService.get('dollar_rate_settings');
    if (rateData != null && rateData is Map && rateData.containsKey('rate_sdg')) {
      final r = rateData['rate_sdg'];
      dollarRate = (r is num) ? r.toDouble() : 2500.0;
    } else {
      await FirebaseService.put('dollar_rate_settings', {
        'rate_sdg': 2500,
        'profit_margin_percent': 10,
        'updated_at': DateTime.now().toIso8601String()
      });
    }

    // 2. Bank Accounts
    final accounts = await FirebaseService.getList('bank_accounts');
    if (accounts.isNotEmpty) {
      final active = accounts.firstWhere(
        (a) => a['is_active'] == true,
        orElse: () => accounts.first,
      );
      bankAccount = active;
    } else {
      final defaultBank = {
        'bank_name': 'بنك الخرطوم (بنكك)',
        'account_number': '2849102',
        'owner_name': 'شركة DMC للمعدات والمستلزمات الطبية المحدودة',
        'is_active': true,
        'created_at': DateTime.now().toIso8601String(),
      };
      await FirebaseService.post('bank_accounts', defaultBank);
      bankAccount = defaultBank;
    }

    // 3. Delivery Zones
    final zones = await FirebaseService.getList('delivery_zones');
    if (zones.isNotEmpty) {
      deliveryZones = zones;
    } else {
      final defaultZones = [
        {'id': 'z1', 'zone_name': 'عطبرة - وسط المدينة والأسواق', 'fee_sdg': 3000, 'is_active': true},
        {'id': 'z2', 'zone_name': 'الدامر - المجمع الطبي والولائي', 'fee_sdg': 3500, 'is_active': true},
        {'id': 'z3', 'zone_name': 'بربر - المنطقة الحضرية', 'fee_sdg': 5000, 'is_active': true},
        {'id': 'z4', 'zone_name': 'أبوحمد - موقع المشافي', 'fee_sdg': 8500, 'is_active': true},
        {'id': 'z5', 'zone_name': 'بورتسودان (شحن ولايات)', 'fee_sdg': 12000, 'is_active': true},
      ];
      for (var z in defaultZones) {
        await FirebaseService.post('delivery_zones', z);
      }
      deliveryZones = defaultZones;
    }

    // 4. Products
    final fetchedProds = await FirebaseService.getList('products');
    if (fetchedProds.isNotEmpty) {
      products = fetchedProds;
    } else {
      final defaultProds = [
        {
          'id': 'p1',
          'name_ar': 'قفازات فحص طبية لاتكس معقمة (علبة 100 حبة)',
          'name_en': 'Latex Examination Gloves Box',
          'category': 'consumables',
          'brand': 'Ansell',
          'description': 'قفازات فحص عالية الجودة ومقاومة للتمزق مريحة للاستعمال الطبي.',
          'specifications': 'الحجم: Medium / Large - العلبة تحتوي 100 قفاز خالية من البودرة.',
          'image_url': 'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=400&q=80',
          'image_emoji': '🧤',
          'base_price_usd': 4.50,
          'stock_quantity': 450,
          'low_stock_threshold': 50,
          'expiry_date': '2026-12-31',
        },
        {
          'id': 'p2',
          'name_ar': 'جهاز قياس ضغط الدم الرقمي Omron M3',
          'name_en': 'Omron M3 Digital Blood Pressure Monitor',
          'category': 'medical_devices',
          'brand': 'Omron',
          'description': 'جهاز قياس ضغط ذكي بدقة عالية ومعتمد طبياً مع كفة مريحة.',
          'specifications': 'شاشة LCD واسعة - ذاكرة تحفظ 60 قراءة لشخصين.',
          'image_url': 'https://images.unsplash.com/photo-1576091160399-112ba8d25d1d?w=400&q=80',
          'image_emoji': '🩺',
          'base_price_usd': 48.00,
          'stock_quantity': 24,
          'low_stock_threshold': 5,
          'expiry_date': '2030-01-01',
        },
        {
          'id': 'p3',
          'name_ar': 'سرنجات طبية معقمة 5 مل (كرتونة 100 سرنجة)',
          'name_en': 'Disposable Syringes 5ml (Box of 100)',
          'category': 'consumables',
          'brand': 'DMC Pack',
          'description': 'سرنجات ذات استخدام واحد معقمة بشرائح ETO مع إبرة حادة.',
          'specifications': 'سعة 5 مل - سن 21G - غلاف فردي معقم بالكامل.',
          'image_url': 'https://images.unsplash.com/photo-1583947215259-38e31be8751f?w=400&q=80',
          'image_emoji': '💉',
          'base_price_usd': 7.50,
          'stock_quantity': 8, // Low stock demo
          'low_stock_threshold': 20,
          'expiry_date': '2025-05-01', // Near expiry demo
        },
        {
          'id': 'p4',
          'name_ar': 'مجهر طبي ضوئي ثنائي العينين (Binocular Lab Microscope)',
          'name_en': 'Binocular Biological Laboratory Microscope',
          'category': 'lab_surgery_supplies',
          'brand': 'Olympus',
          'description': 'مجهر مخبري عالي الدقة للمختبرات والمستشفيات مع إضاءة LED.',
          'specifications': 'عدسات أكروماتيكية 4x, 10x, 40x, 100x.',
          'image_url': 'https://images.unsplash.com/photo-1516549655169-df83a0774514?w=400&q=80',
          'image_emoji': '🔬',
          'base_price_usd': 350.00,
          'stock_quantity': 6,
          'low_stock_threshold': 2,
          'expiry_date': '2035-01-01',
        },
        {
          'id': 'p5',
          'name_ar': 'شاش طبي معقم ورول مربط 10 سم × 4 متر',
          'name_en': 'Sterile Medical Gauze Roll',
          'category': 'consumables',
          'brand': 'DMC Care',
          'description': 'شاش طبي قطني 100% شديد الامتصاص لإعادة غيار الجروح.',
          'specifications': 'عبوة تحتوي 12 رول - نسيج قطني ناعم.',
          'image_url': 'https://images.unsplash.com/photo-1584017911766-d451b3d0e843?w=400&q=80',
          'image_emoji': '🩹',
          'base_price_usd': 3.20,
          'stock_quantity': 800,
          'low_stock_threshold': 100,
          'expiry_date': '2027-08-20',
        },
        {
          'id': 'p6',
          'name_ar': 'جهاز تخطيط القلب 12 قناة (12-Lead ECG Machine)',
          'name_en': '12-Lead Portable ECG Machine',
          'category': 'medical_devices',
          'brand': 'Edan',
          'description': 'جهاز تخطيط قلب محمول مزود بشاشة ملونة وطابعة حرارية.',
          'specifications': 'شاشة 7 بوصة لمسية - طابعة حرارية 110 مم.',
          'image_url': 'https://images.unsplash.com/photo-1530497610245-94d3c16cda28?w=400&q=80',
          'image_emoji': '📟',
          'base_price_usd': 820.00,
          'stock_quantity': 3,
          'low_stock_threshold': 1,
          'expiry_date': '2032-10-10',
        }
      ];
      for (var p in defaultProds) {
        await FirebaseService.post('products', p);
      }
      products = defaultProds;
    }

    // 5. Orders
    final fetchedOrders = await FirebaseService.getList('orders');
    if (fetchedOrders.isNotEmpty) {
      if (orders.length != fetchedOrders.length) {
        // Detect order status change for push notification
        triggerNotification('تحديث الطلبات', 'هناك تحديثات جديدة في حالة طلباتك لدى DMC Medical');
      }
      orders = fetchedOrders;
    }

    // 6. Quotations
    final fetchedQuotations = await FirebaseService.getList('quotations');
    if (fetchedQuotations.isNotEmpty) {
      quotations = fetchedQuotations;
    }

    // 7. Audit Logs
    final fetchedAudit = await FirebaseService.getList('audit_logs');
    if (fetchedAudit.isNotEmpty) {
      auditLogs = fetchedAudit;
    }

    if (mounted) setState(() {});
  }

  void _toast(String msg) {
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

  // Audit Logging
  Future<void> _logAdminActivity(String action, Map<String, dynamic> details) async {
    final log = {
      'staff_name': currentStaff?['name'] ?? 'مدير النظام',
      'role': currentStaff?['role'] ?? 'manager',
      'action_type': action,
      'details_json': details,
      'timestamp': DateTime.now().toString().substring(0, 16),
    };
    await FirebaseService.post('audit_logs', log);
    setState(() => auditLogs.insert(0, log));
  }

  List<String> _getAvailableBrands() {
    final Set<String> brands = {'all'};
    for (var p in products) {
      if (p.containsKey('brand') && p['brand'].toString().isNotEmpty) {
        brands.add(p['brand'].toString());
      }
    }
    return brands.toList();
  }

  void _toggleFavorite(String prodId) {
    setState(() {
      if (favorites.contains(prodId)) {
        favorites.remove(prodId);
        _toast('تم الحذف من المفضلة');
      } else {
        favorites.add(prodId);
        _toast('تمت الإضافة للمفضلة');
      }
    });
    _saveFavoritesLocally();
  }

  void _addToCart(String prodId, int qty) {
    setState(() {
      final idx = cart.indexWhere((c) => c['product_id'] == prodId);
      if (idx >= 0) {
        cart[idx]['qty'] = (cart[idx]['qty'] as int) + qty;
      } else {
        cart.add({'product_id': prodId, 'qty': qty});
      }
    });
    _saveCartLocally();
    _toast('تمت إضافة $qty قطع للسلة وتحديث التخزين المحلي');
  }

  void _updateCartQty(String prodId, int delta) {
    setState(() {
      final idx = cart.indexWhere((c) => c['product_id'] == prodId);
      if (idx >= 0) {
        int newQty = (cart[idx]['qty'] as int) + delta;
        if (newQty <= 0) {
          cart.removeAt(idx);
        } else {
          cart[idx]['qty'] = newQty;
        }
      }
    });
    _saveCartLocally();
  }

  void _reorderQuickly(Map<String, dynamic> order) {
    if (order['items_json'] is List) {
      final items = order['items_json'] as List;
      for (var item in items) {
        if (item is Map && item.containsKey('product_id')) {
          _addToCart(item['product_id'].toString(), (item['qty'] as int? ?? 1));
        }
      }
      _toast('تمت إعادة جميع عناصر الطلب إلى السلة بنجاح!');
      _openCartSheet();
    }
  }

  void _openWhatsAppChat() async {
    final String phone = "249912345678";
    final String text = "مرحباً DMC Medical، أود الاستفسار عن المنتجات والعروض الطبية المتاحة.";
    final Uri uri = Uri.parse("https://wa.me/$phone?text=${Uri.encodeComponent(text)}");
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (_) {
      _toast('جاري تحويلك إلى الواتساب الرسمي +249912345678');
    }
  }

  // ==========================================
  // MAIN BUILD
  // ==========================================
  @override
  Widget build(BuildContext context) {
    final bool isAr = widget.currentLanguage == 'ar';

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
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'DMC Medical',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  Text(
                    isAr
                        ? 'المعدات والمستلزمات الطبية'
                        : 'Medical Equipment & Supplies',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.chat_bubble_outline, color: Color(0xFF25D366)),
              tooltip: isAr ? 'واتساب الدعم الفني' : 'WhatsApp Support',
              onPressed: _openWhatsAppChat,
            ),
            TextButton.icon(
              onPressed: () => _openAdminLoginModal(),
              icon: Icon(Icons.admin_panel_settings, size: 18),
              label: Text(
                currentStaff != null
                    ? (currentStaff!['role'] ?? 'Admin')
                    : (isAr ? 'الإدارة' : 'Admin'),
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
                backgroundColor:
                    Theme.of(context).primaryColor.withOpacity(0.12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.shopping_cart_outlined),
                  onPressed: () => _openCartSheet(),
                ),
                if (cart.isNotEmpty)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${cart.length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 8),
          ],
        ),
      ),
      body: IndexedStack(
        index: currentNavIndex,
        children: [
          _buildHomeCatalogTab(),
          _buildOrdersTab(),
          _buildFavoritesTab(),
          _buildProfileTab(),
        ],
      ),
      bottomNavigationBar: Container(
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
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront),
              label: isAr ? 'الرئيسية' : 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long),
              label: isAr ? 'طلباتي' : 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_outline),
              label: isAr ? 'المفضلة' : 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: isAr ? 'حسابي' : 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // TAB 1: HOME & CATALOG
  // ==========================================
  Widget _buildHomeCatalogTab() {
    final bool isAr = widget.currentLanguage == 'ar';
    final query = searchController.text.toLowerCase();
    final filtered =
        products.filterProduct(selectedCategory, selectedBrand, query);
    final brandsList = _getAvailableBrands();

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
                    Icon(Icons.verified, color: Colors.white70, size: 20),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  isAr ? 'مرحباً بك في DMC Sudan' : 'Welcome to DMC Sudan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  isAr
                      ? 'التوريد المباشر للمستشفيات، المراكز والصيدليات'
                      : 'Direct Supply to Hospitals, Clinics & Pharmacies',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),

          // Search Box
          TextField(
            controller: searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: isAr
                  ? 'ابحث عن منتج، قفازات، جهاز، محقنة...'
                  : 'Search for products, gloves, devices...',
              prefixIcon: Icon(Icons.search),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surface,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                    color: Theme.of(context).dividerColor, width: 0.8),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                    color: Theme.of(context).dividerColor, width: 0.8),
              ),
            ),
          ),
          SizedBox(height: 16),

          // Category Filter Chips
          Text(
            isAr ? 'الفئات الرئيسية:' : 'Main Categories:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildCategoryChip('all', isAr ? 'الكل' : 'All'),
                _buildCategoryChip('consumables', isAr ? 'مستهلكات طبية' : 'Consumables'),
                _buildCategoryChip('medical_devices', isAr ? 'أجهزة طبية' : 'Medical Devices'),
                _buildCategoryChip('lab_surgery_supplies', isAr ? 'معامل وعمليات' : 'Lab & Surgery'),
              ],
            ),
          ),
          SizedBox(height: 12),

          // Brand Filter Chips
          Text(
            isAr ? 'الفلترة حسب العلامة التجارية:' : 'Filter by Brand:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          SizedBox(height: 6),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: brandsList.map((b) => _buildBrandChip(b)).toList(),
            ),
          ),
          SizedBox(height: 16),

          // Catalog List Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAr ? 'المنتجات المتاحة للطلب' : 'Available Products',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Text(
                '${filtered.length} ${isAr ? 'منتجات' : 'items'}',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: 12),

          // Product Grid
          if (filtered.isEmpty)
            Container(
              padding: EdgeInsets.all(32),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Icon(Icons.search_off, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    isAr ? 'لم يتم العثور على نتائج للبحث' : 'No products found',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: filtered.length,
              itemBuilder: (ctx, i) {
                final p = filtered[i];
                final String pId = p['id'].toString();
                final bool isFav = favorites.contains(pId);
                final double baseUsd = (p['base_price_usd'] is num)
                    ? (p['base_price_usd'] as num).toDouble()
                    : 1.0;
                final int calculatedSdg = (baseUsd * dollarRate).round();

                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _openProductDetailModal(p),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              Container(
                                width: double.infinity,
                                color: Theme.of(context).colorScheme.background,
                                child: (p['image_url'] != null &&
                                        p['image_url'].toString().length > 5)
                                    ? Image.network(
                                        p['image_url'],
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Center(
                                          child: Text(
                                            p['image_emoji'] ?? '📦',
                                            style: TextStyle(fontSize: 40),
                                          ),
                                        ),
                                      )
                                    : Center(
                                        child: Text(
                                          p['image_emoji'] ?? '📦',
                                          style: TextStyle(fontSize: 40),
                                        ),
                                      ),
                              ),
                              Positioned(
                                top: 6,
                                left: 6,
                                child: InkWell(
                                  onTap: () => _toggleFavorite(pId),
                                  child: Container(
                                    padding: EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      isFav
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: isFav ? Colors.red : Colors.grey,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                              if (p['brand'] != null)
                                Positioned(
                                  bottom: 6,
                                  right: 6,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.6),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      p['brand'],
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 9),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAr
                                    ? (p['name_ar'] ?? '')
                                    : (p['name_en'] ?? p['name_ar'] ?? ''),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  height: 1.2,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                '${calculatedSdg.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} SDG',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(height: 6),
                              SizedBox(
                                width: double.infinity,
                                height: 32,
                                child: ElevatedButton.icon(
                                  onPressed: () => _addToCart(pId, 1),
                                  icon: Icon(Icons.add_shopping_cart, size: 14),
                                  label: Text(
                                    isAr ? 'السلة' : 'Add to Cart',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).primaryColor,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
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

  Widget _buildCategoryChip(String catKey, String label) {
    final bool isSelected = selectedCategory == catKey;
    return Padding(
      padding: EdgeInsets.only(left: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => selectedCategory = catKey),
        selectedColor: Theme.of(context).primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _buildBrandChip(String brand) {
    final bool isSelected = selectedBrand == brand;
    final String label = brand == 'all' ? (widget.currentLanguage == 'ar' ? 'كل الماركات' : 'All Brands') : brand;
    return Padding(
      padding: EdgeInsets.only(left: 6),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => setState(() => selectedBrand = brand),
        selectedColor: Theme.of(context).colorScheme.secondary,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontSize: 11,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
    );
  }

  // ==========================================
  // TAB 2: ORDERS & QUOTATIONS
  // ==========================================
  Widget _buildOrdersTab() {
    final bool isAr = widget.currentLanguage == 'ar';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 0,
          bottom: TabBar(
            labelColor: Theme.of(context).primaryColor,
            indicatorColor: Theme.of(context).primaryColor,
            tabs: [
              Tab(text: isAr ? 'طلبات الشراء' : 'Purchase Orders'),
              Tab(text: isAr ? 'عروض الأسعار (Quotations)' : 'Quotations'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            orders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(isAr ? 'لا توجد طلبات سابقة حتى الآن' : 'No previous orders'),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: orders.length,
                    itemBuilder: (ctx, i) {
                      final o = orders[i];
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
                                    o['order_number'] ?? 'DMC-2025-ORDER',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  _buildOrderStatusBadge(
                                      o['order_status'] ?? 'pending_review'),
                                ],
                              ),
                              SizedBox(height: 6),
                              Text(
                                '${isAr ? 'التاريخ' : 'Date'}: ${o['created_at'] ?? ''} | ${isAr ? 'التوصيل' : 'Delivery'}: ${o['delivery_zone'] ?? 'عطبرة'}',
                                style: TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                              Divider(height: 16),
                              if (o['items_json'] is List)
                                ...((o['items_json'] as List).map((it) => Text(
                                      '• ${it['name_ar']} (x${it['qty']})',
                                      style: TextStyle(fontSize: 12),
                                    ))),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Text(
                                    '${isAr ? 'الإجمالي' : 'Total'}: ${(o['grand_total_sdg'] ?? 0).toString()} SDG',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                  Spacer(),
                                  ElevatedButton.icon(
                                    onPressed: () => _reorderQuickly(o),
                                    icon: Icon(Icons.refresh, size: 14),
                                    label: Text(
                                      isAr ? 'إعادة الطلب السريع' : 'Quick Reorder',
                                      style: TextStyle(fontSize: 11),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme.of(context).primaryColor,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                    ),
                                  ),
                                  SizedBox(width: 6),
                                  OutlinedButton(
                                    onPressed: () => _openInvoiceSheet(o),
                                    child: Text(
                                      isAr ? 'الفاتورة PDF' : 'PDF Invoice',
                                      style: TextStyle(fontSize: 11),
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),

            quotations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.request_quote_outlined, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(isAr ? 'لا توجد طلبات عروض أسعار' : 'No quotations found'),
                        SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => _openQuotationSheet(),
                          icon: Icon(Icons.add),
                          label: Text(isAr ? 'طلب عرض سعر جديد' : 'New Quotation Request'),
                        )
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: quotations.length,
                    itemBuilder: (ctx, i) {
                      final q = quotations[i];
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
                                    q['quotation_number'] ?? 'QUO-2025',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Chip(
                                    label: Text(
                                      q['status'] == 'responded'
                                          ? (isAr ? 'تم الرد' : 'Responded')
                                          : (isAr ? 'قيد الدراسة' : 'Under Review'),
                                      style: TextStyle(
                                          fontSize: 10,
                                          color: q['status'] == 'responded'
                                              ? Colors.green
                                              : Colors.orange),
                                    ),
                                    backgroundColor: q['status'] == 'responded'
                                        ? Color(0xFFE8F5E9)
                                        : Color(0xFFFFF3E0),
                                  ),
                                ],
                              ),
                              SizedBox(height: 6),
                              Text(
                                '${isAr ? 'المنتجات والكميات' : 'Requested'}: ${q['items_requested'] ?? ''}',
                                style: TextStyle(fontSize: 12),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '${isAr ? 'ملاحظات العميل' : 'Notes'}: ${q['customer_notes'] ?? ''}',
                                style: TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                              if (q['admin_response_notes'] != null &&
                                  q['admin_response_notes'].toString().isNotEmpty) ...[
                                Divider(height: 12),
                                Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${isAr ? 'رد إدارة DMC' : 'DMC Admin Response'}: ${q['admin_response_notes']}',
                                    style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue),
                                  ),
                                )
                              ]
                            ],
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
  // TAB 3: FAVORITES
  // ==========================================
  Widget _buildFavoritesTab() {
    final bool isAr = widget.currentLanguage == 'ar';
    final favProducts =
        products.where((p) => favorites.contains(p['id'].toString())).toList();

    return favProducts.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 54, color: Colors.grey),
                SizedBox(height: 12),
                Text(isAr ? 'قائمة المفضلة فارغة' : 'Favorites list is empty',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(
                  isAr
                      ? 'أضف الأجهزة والمستلزمات للوصول السريع إليها'
                      : 'Add items here for quick access',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: favProducts.length,
            itemBuilder: (ctx, i) {
              final p = favProducts[i];
              final double baseUsd = (p['base_price_usd'] is num)
                  ? (p['base_price_usd'] as num).toDouble()
                  : 1.0;
              final int calculatedSdg = (baseUsd * dollarRate).round();

              return Card(
                margin: EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.background,
                    child: Text(p['image_emoji'] ?? '📦'),
                  ),
                  title: Text(
                    isAr ? (p['name_ar'] ?? '') : (p['name_en'] ?? p['name_ar'] ?? ''),
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('$calculatedSdg SDG',
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.bold)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.add_shopping_cart, size: 20),
                        onPressed: () => _addToCart(p['id'].toString(), 1),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline,
                            color: Colors.red, size: 20),
                        onPressed: () => _toggleFavorite(p['id'].toString()),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }

  // ==========================================
  // TAB 4: PROFILE & SETTINGS
  // ==========================================
  Widget _buildProfileTab() {
    final bool isAr = widget.currentLanguage == 'ar';

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          // User Profile Card with Edit Action
          Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor:
                            Theme.of(context).primaryColor.withOpacity(0.15),
                        child: Text(
                          '🏥',
                          style: TextStyle(
                            fontSize: 26,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              currentUser != null
                                  ? (currentUser!['full_name'] ?? '')
                                  : (isAr ? 'زائر (لم تسجل الدخول)' : 'Guest User'),
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 2),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                currentUser != null
                                    ? (currentUser!['account_type'] ==
                                            'medical_institution'
                                        ? (isAr ? 'حساب مؤسسة طبية' : 'Medical Institution')
                                        : (isAr ? 'حساب فردي' : 'Individual Account'))
                                    : (isAr ? 'غير مسجل' : 'Not Registered'),
                                style: TextStyle(
                                    fontSize: 10, color: Colors.green),
                              ),
                            ),
                            if (currentUser != null) ...[
                              SizedBox(height: 2),
                              Text(
                                '${currentUser!['phone'] ?? ''} | ${currentUser!['email'] ?? ''}',
                                style: TextStyle(
                                    fontSize: 11, color: Colors.grey),
                              ),
                            ],
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _openAuthSheet(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                          currentUser == null
                              ? (isAr ? 'تسجيل الدخول' : 'Login')
                              : (isAr ? 'تعديل الحساب' : 'Edit Profile'),
                          style: TextStyle(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  if (currentUser != null &&
                      currentUser!['address'] != null &&
                      currentUser!['address'].toString().isNotEmpty) ...[
                    Divider(height: 16),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                        SizedBox(width: 4),
                        Text(
                          '${isAr ? 'العنوان' : 'Address'}: ${currentUser!['address']}',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                      ],
                    ),
                  ]
                ],
              ),
            ),
          ),
          SizedBox(height: 12),

          // Admin Dashboard Button
          InkWell(
            onTap: () => _openAdminLoginModal(),
            child: Card(
              color: Theme.of(context).primaryColor.withOpacity(0.08),
              child: Padding(
                padding: EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(Icons.dashboard_outlined,
                        color: Theme.of(context).primaryColor),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isAr ? 'لوحة إدارة DMC Admin' : 'DMC Admin Panel',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          Text(
                            isAr
                                ? 'تحديث سعر الدولار، المخزون والتنبيهات، والطلبات'
                                : 'USD Exchange, Inventory Alerts & Orders',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, size: 14),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 12),

          // App Settings Section
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: Text(isAr ? 'الوضع الداكن (Dark Mode)' : 'Dark Mode'),
                  value: widget.isDarkMode,
                  onChanged: widget.onThemeChanged,
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.language),
                  title: Text(isAr ? 'لغة التطبيق' : 'App Language'),
                  subtitle: Text(widget.currentLanguage == 'ar'
                      ? 'العربية (Arabic)'
                      : 'English'),
                  trailing: TextButton(
                    onPressed: () {
                      final next = widget.currentLanguage == 'ar' ? 'en' : 'ar';
                      widget.onLanguageChanged(next);
                      _toast(next == 'ar'
                          ? 'تم التحويل للغة العربية'
                          : 'Switched to English');
                    },
                    child: Text(
                      widget.currentLanguage == 'ar' ? 'English' : 'العربية',
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.chat, color: Color(0xFF25D366)),
                  title: Text(isAr ? 'الدعم الفني عبر الواتساب' : 'WhatsApp Support'),
                  subtitle: Text(isAr ? 'محادثة مباشرة مع قسم المبيعات' : 'Direct DMC sales channel'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 14),
                  onTap: _openWhatsAppChat,
                ),
                Divider(height: 1),
                ListTile(
                  leading: Icon(Icons.privacy_tip_outlined),
                  title: Text(isAr ? 'الشروط وسياسة الخصوصية' : 'Terms & Privacy Policy'),
                  onTap: () => _toast(isAr
                      ? 'شروط التوريد: يتم الشحن المباشر للمستشفيات والعيادات بجميع ولايات السودان.'
                      : 'Supply policy: Direct delivery across Sudan via DMC.'),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          Text('DMC Client & Admin System v2.5.0 (Sudan)',
              style: TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }

  // ==========================================
  // MODALS & SHEETS
  // ==========================================

  // 1. AUTHENTICATION & PROFILE EDIT (users TABLE)
  void _openAuthSheet() {
    bool isEditing = currentUser != null;
    final phoneCtrl = TextEditingController(text: currentUser?['phone'] ?? '');
    final nameCtrl = TextEditingController(text: currentUser?['full_name'] ?? '');
    final emailCtrl = TextEditingController(text: currentUser?['email'] ?? '');
    final addressCtrl = TextEditingController(text: currentUser?['address'] ?? '');
    String accountType = currentUser?['account_type'] ?? 'medical_institution';

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
                      isEditing
                          ? (isAr ? 'تعديل بيانات الملف الشخصي (users)' : 'Edit Profile')
                          : (isAr ? 'تسجيل الدخول / حساب جديد' : 'Login / Register'),
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: Center(
                                child: Text(isAr ? 'مؤسسة طبية' : 'Institution',
                                    style: TextStyle(fontSize: 11))),
                            selected: accountType == 'medical_institution',
                            onSelected: (_) => setSheetState(
                                () => accountType = 'medical_institution'),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: Center(
                                child: Text(isAr ? 'حساب فردي' : 'Individual',
                                    style: TextStyle(fontSize: 11))),
                            selected: accountType == 'individual',
                            onSelected: (_) => setSheetState(
                                () => accountType = 'individual'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),

                    TextField(
                      controller: phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: isAr ? 'رقم الهاتف / الواتساب' : 'Phone Number',
                        hintText: '0912345678',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    SizedBox(height: 10),

                    TextField(
                      controller: nameCtrl,
                      decoration: InputDecoration(
                        labelText: isAr
                            ? 'الاسم الكامل / اسم المركز الطبي'
                            : 'Full Name / Clinic Name',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    SizedBox(height: 10),

                    TextField(
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: isAr ? 'البريد الإلكتروني' : 'Email Address',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    SizedBox(height: 10),

                    TextField(
                      controller: addressCtrl,
                      decoration: InputDecoration(
                        labelText: isAr ? 'العنوان التفصيلي (الولاية - المدينة - الشارع)' : 'Address Details',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                    SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (phoneCtrl.text.isEmpty || nameCtrl.text.isEmpty) {
                            _toast(isAr ? 'يرجى إدخال الاسم ورقم الهاتف' : 'Enter name and phone');
                            return;
                          }

                          final userData = {
                            'full_name': nameCtrl.text,
                            'phone': phoneCtrl.text,
                            'email': emailCtrl.text,
                            'address': addressCtrl.text,
                            'account_type': accountType,
                            'created_at': DateTime.now().toIso8601String(),
                          };

                          if (currentUser != null && currentUser!.containsKey('id')) {
                            final String uid = currentUser!['id'].toString();
                            await FirebaseService.patch('users/$uid', userData);
                            userData['id'] = uid;
                          } else {
                            final newId =
                                await FirebaseService.post('users', userData);
                            if (newId != null) userData['id'] = newId;
                          }

                          setState(() => currentUser = userData);
                          await _saveUserLocally();
                          Navigator.pop(ctx);
                          _toast(isAr
                              ? 'تم حفظ وتحديث الحساب بنجاح بجدول users'
                              : 'User profile updated successfully');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          isEditing
                              ? (isAr ? 'تعديل وحفظ التغييرات' : 'Save Changes')
                              : (isAr ? 'حفظ وتأكيد الحساب' : 'Save & Register'),
                        ),
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

  // 2. PRODUCT DETAIL MODAL
  void _openProductDetailModal(Map<String, dynamic> prod) {
    int detailQuantity = 1;
    final double baseUsd = (prod['base_price_usd'] is num)
        ? (prod['base_price_usd'] as num).toDouble()
        : 1.0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctxState, setModalState) {
            final bool isAr = widget.currentLanguage == 'ar';
            final int calculatedSdg = (baseUsd * dollarRate).round();
            final int totalSdg = calculatedSdg * detailQuantity;

            return Padding(
              padding: EdgeInsets.all(20),
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
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: (prod['image_url'] != null &&
                            prod['image_url'].toString().length > 5)
                        ? Image.network(prod['image_url'], fit: BoxFit.cover)
                        : Center(
                            child: Text(prod['image_emoji'] ?? '📦',
                                style: TextStyle(fontSize: 60))),
                  ),
                  SizedBox(height: 14),
                  Text(
                    isAr ? (prod['name_ar'] ?? '') : (prod['name_en'] ?? prod['name_ar'] ?? ''),
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text('العلامة التجارية: ${prod['brand'] ?? 'DMC Medical'}',
                      style: TextStyle(fontSize: 11, color: Colors.grey)),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$totalSdg SDG',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Theme.of(context).primaryColor),
                      ),
                      Text(
                        '(${isAr ? 'المخزون' : 'Stock'}: ${prod['stock_quantity'] ?? 100})',
                        style: TextStyle(
                          fontSize: 11,
                          color: ((prod['stock_quantity'] ?? 100) < 10)
                              ? Colors.red
                              : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(prod['description'] ?? '', style: TextStyle(fontSize: 12)),
                  SizedBox(height: 4),
                  Text(
                    '${isAr ? 'المواصفات الفنية' : 'Specs'}: ${prod['specifications'] ?? ''}',
                    style: TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                  SizedBox(height: 16),

                  // Quantity (+ / -)
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isAr ? 'الكمية المطلوبة:' : 'Selected Quantity:',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                if (detailQuantity > 1) {
                                  setModalState(() => detailQuantity--);
                                }
                              },
                            ),
                            Text(
                              '$detailQuantity',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: Icon(Icons.add_circle_outline),
                              onPressed: () {
                                setModalState(() => detailQuantity++);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _openQuotationSheet(prefill: prod['name_ar']);
                          },
                          child: Text(
                            isAr ? 'طلب عرض سعر (Quotation)' : 'Request Quotation',
                            style: TextStyle(fontSize: 11),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            _addToCart(prod['id'].toString(), detailQuantity);
                            Navigator.pop(ctx);
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white),
                          child: Text(isAr ? 'إضافة للسلة' : 'Add to Cart'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 3. CART SHEET WITH LOCAL STORAGE PERSISTENCE
  void _openCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctxState, setSheetState) {
            final bool isAr = widget.currentLanguage == 'ar';
            int totalSdg = 0;
            for (var item in cart) {
              final prod = products.firstWhere(
                (p) => p['id'].toString() == item['product_id'],
                orElse: () => {'base_price_usd': 1.0, 'name_ar': 'منتج'},
              );
              final double baseUsd = (prod['base_price_usd'] is num)
                  ? (prod['base_price_usd'] as num).toDouble()
                  : 1.0;
              totalSdg += ((baseUsd * dollarRate) * (item['qty'] as int)).round();
            }

            return Padding(
              padding: EdgeInsets.all(20),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.sd_card, color: Colors.teal, size: 18),
                          SizedBox(width: 6),
                          Text(isAr ? 'السلة (محفوظة محلياً على الهاتف)' : 'Shopping Cart (Saved Locally)',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx)),
                    ],
                  ),
                  SizedBox(height: 12),
                  if (cart.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: Text(
                          isAr ? 'السلة فارغة حالياً' : 'Your cart is empty',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: 260),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: cart.length,
                        itemBuilder: (ctx, i) {
                          final item = cart[i];
                          final prod = products.firstWhere(
                            (p) => p['id'].toString() == item['product_id'],
                            orElse: () => {'name_ar': 'منتج', 'base_price_usd': 1.0},
                          );
                          final double baseUsd = (prod['base_price_usd'] is num)
                              ? (prod['base_price_usd'] as num).toDouble()
                              : 1.0;
                          final int itemTotal =
                              ((baseUsd * dollarRate) * (item['qty'] as int)).round();

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(prod['name_ar'] ?? '',
                                style: TextStyle(fontSize: 12)),
                            subtitle: Text('$itemTotal SDG',
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontWeight: FontWeight.bold)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.remove_circle_outline,
                                      size: 20),
                                  onPressed: () {
                                    _updateCartQty(
                                        item['product_id'].toString(), -1);
                                    setSheetState(() {});
                                  },
                                ),
                                Text('${item['qty']}',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: Icon(Icons.add_circle_outline,
                                      size: 20),
                                  onPressed: () {
                                    _updateCartQty(
                                        item['product_id'].toString(), 1);
                                    setSheetState(() {});
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  Divider(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isAr ? 'إجمالي المنتجات:' : 'Subtotal:'),
                      Text('$totalSdg SDG',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor)),
                    ],
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: cart.isEmpty
                          ? null
                          : () {
                              Navigator.pop(ctx);
                              _openCheckoutSheet(totalSdg);
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(isAr ? 'متابعة لإتمام الطلب' : 'Proceed to Checkout'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // 4. CHECKOUT SHEET WITH BANKAK RECEIPT ATTACHMENT
  void _openCheckoutSheet(int productsTotalSdg) {
    String selectedZoneId =
        deliveryZones.isNotEmpty ? deliveryZones[0]['id'].toString() : 'z1';
    String paymentMethod = 'bankak';
    final receiptUrlCtrl = TextEditingController(
        text: 'https://dmc-sudan.sd/receipts/bankak_trans_7781.png');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctxState, setSheetState) {
            final bool isAr = widget.currentLanguage == 'ar';
            final zone = deliveryZones.firstWhere(
              (z) => z['id'].toString() == selectedZoneId,
              orElse: () => {'zone_name': 'عطبرة', 'fee_sdg': 3000},
            );
            final int deliveryFee = (zone['fee_sdg'] is num)
                ? (zone['fee_sdg'] as num).toInt()
                : 3000;
            final int grandTotal = productsTotalSdg + deliveryFee;

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
                      isAr ? 'إتمام الطلب والتوصيل والدفع' : 'Order Checkout & Payment',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 12),

                    Text(isAr ? 'منطقة التوصيل بالولايات:' : 'Delivery Zone:',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    SizedBox(height: 4),
                    DropdownButtonFormField<String>(
                      value: selectedZoneId,
                      items: deliveryZones.map((z) {
                        return DropdownMenuItem<String>(
                          value: z['id'].toString(),
                          child: Text(
                              '${z['zone_name']} (+${z['fee_sdg']} SDG)',
                              style: TextStyle(fontSize: 12)),
                        );
                      }).toList(),
                      onChanged: (v) {
                        if (v != null) {
                          setSheetState(() => selectedZoneId = v);
                        }
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                    SizedBox(height: 14),

                    Text(isAr ? 'طريقة الدفع:' : 'Payment Method:',
                        style: TextStyle(fontSize: 12, color: Colors.grey)),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ChoiceChip(
                            label: Center(
                                child: Text(isAr ? 'تحويل بنكك' : 'Bankak Transfer',
                                    style: TextStyle(fontSize: 11))),
                            selected: paymentMethod == 'bankak',
                            onSelected: (_) =>
                                setSheetState(() => paymentMethod = 'bankak'),
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: ChoiceChip(
                            label: Center(
                                child: Text(isAr ? 'الدفع عند الاستلام' : 'Cash on Delivery',
                                    style: TextStyle(fontSize: 11))),
                            selected: paymentMethod == 'cash_on_delivery',
                            onSelected: (_) => setSheetState(
                                () => paymentMethod = 'cash_on_delivery'),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    if (paymentMethod == 'bankak') ...[
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Theme.of(context).primaryColor.withOpacity(0.3)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${bankAccount['bank_name'] ?? 'بنكك'}',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).primaryColor,
                                  fontSize: 13),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '${isAr ? 'اسم الحساب' : 'Owner'}: ${bankAccount['owner_name']}',
                              style: TextStyle(fontSize: 11),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${isAr ? 'رقم الحساب' : 'Account'}: ${bankAccount['account_number']}',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold),
                                ),
                                TextButton.icon(
                                  icon: Icon(Icons.copy, size: 14),
                                  label: Text(isAr ? 'نسخ الحساب' : 'Copy'),
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(
                                        text: bankAccount['account_number']
                                            .toString()));
                                    _toast(isAr ? 'تم نسخ رقم الحساب' : 'Copied');
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 10),

                      TextField(
                        controller: receiptUrlCtrl,
                        decoration: InputDecoration(
                          labelText: isAr
                              ? 'صورة إشعار التحويل (receipt_image_url)'
                              : 'Receipt Image URL',
                          hintText: 'https://...',
                          suffixIcon: IconButton(
                            icon: Icon(Icons.cloud_upload_outlined),
                            onPressed: () {
                              _toast(isAr
                                  ? 'تم إرفاق صورة إشعار بنكك (محاكاة الرفع)'
                                  : 'Receipt Attached');
                            },
                          ),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      SizedBox(height: 12),
                    ],

                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(isAr ? 'إجمالي المنتجات:' : 'Subtotal:',
                                  style: TextStyle(fontSize: 12)),
                              Text('$productsTotalSdg SDG',
                                  style: TextStyle(fontSize: 12)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(isAr ? 'رسوم التوصيل:' : 'Delivery Fee:',
                                  style: TextStyle(fontSize: 12)),
                              Text('$deliveryFee SDG',
                                  style: TextStyle(fontSize: 12)),
                            ],
                          ),
                          Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(isAr ? 'الإجمالي الكلي للفاتورة:' : 'Grand Total:',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold)),
                              Text('$grandTotal SDG',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: Theme.of(context).primaryColor,
                                      fontSize: 16)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () async {
                          final newOrd = {
                            'order_number':
                                'DMC-2025-${1000 + (orders.length * 17)}',
                            'user_id': currentUser?['id'] ?? 'guest',
                            'items_json': cart.map((c) {
                              final pr = products.firstWhere(
                                (p) => p['id'].toString() == c['product_id'],
                                orElse: () => {'name_ar': 'منتج'},
                              );
                              return {
                                'product_id': c['product_id'],
                                'name_ar': pr['name_ar'],
                                'qty': c['qty']
                              };
                            }).toList(),
                            'grand_total_sdg': grandTotal,
                            'delivery_zone': zone['zone_name'],
                            'delivery_fee_sdg': deliveryFee,
                            'payment_method': paymentMethod,
                            'receipt_image_url': paymentMethod == 'bankak'
                                ? receiptUrlCtrl.text
                                : '',
                            'order_status': paymentMethod == 'bankak'
                                ? 'waiting_payment_confirmation'
                                : 'preparing',
                            'payment_status': paymentMethod == 'bankak'
                                ? 'pending_confirmation'
                                : 'paid_on_delivery',
                            'created_at':
                                DateTime.now().toString().substring(0, 16),
                          };

                          await FirebaseService.post('orders', newOrd);
                          setState(() {
                            orders.insert(0, newOrd);
                            cart.clear();
                          });
                          await _saveCartLocally();

                          Navigator.pop(ctx);
                          _toast(isAr ? 'تم تأكيد وإرسال الطلب بنجاح!' : 'Order submitted!');
                          triggerNotification(
                              'تم إرسال طلبك بنجاح', 'رقم الطلب ${newOrd['order_number']} قيد المراجعة لدى DMC');
                          setState(() => currentNavIndex = 1);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(isAr ? 'تأكيد وإرسال الطلب' : 'Confirm & Submit Order'),
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

  // 5. QUOTATION REQUEST SHEET
  void _openQuotationSheet({String? prefill}) {
    final textCtrl = TextEditingController(text: prefill ?? '');
    final notesCtrl = TextEditingController();

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
                isAr
                    ? 'طلب عرض سعر للكميات الضخمة (Quotation)'
                    : 'Request Price Quotation',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              TextField(
                controller: textCtrl,
                decoration: InputDecoration(
                  labelText: isAr ? 'المنتجات والكميات المطلوبة' : 'Requested Items & Quantities',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: notesCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: isAr ? 'ملاحظات وتفاصيل إضافية للشركة' : 'Custom Notes for DMC',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () async {
                    if (textCtrl.text.isEmpty) return;
                    final q = {
                      'quotation_number':
                          'QUO-2025-${100 + quotations.length}',
                      'user_id': currentUser?['id'] ?? 'guest',
                      'items_requested': textCtrl.text,
                      'customer_notes': notesCtrl.text,
                      'admin_response_notes': '',
                      'status': 'pending',
                      'created_at': DateTime.now().toString().substring(0, 16),
                    };

                    await FirebaseService.post('quotations', q);
                    setState(() => quotations.insert(0, q));
                    Navigator.pop(ctx);
                    _toast(isAr ? 'تم إرسال طلب عرض السعر' : 'Quotation Request Sent');
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white),
                  child: Text(isAr ? 'إرسال الطلب للإدارة' : 'Submit Quotation'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 6. ELECTRONIC INVOICE PDF MODAL & WHATSAPP SHARE
  void _openInvoiceSheet(Map<String, dynamic> ord) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        final bool isAr = widget.currentLanguage == 'ar';

        return Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${isAr ? 'الفاتورة الإلكترونية' : 'Electronic Invoice'}: ${ord['order_number']}',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              Divider(),
              Text('${isAr ? 'العميل' : 'Customer'}: ${currentUser?['full_name'] ?? 'عميل DMC'}'),
              Text('${isAr ? 'المنطقة' : 'Zone'}: ${ord['delivery_zone']}'),
              Text('${isAr ? 'طريقة الدفع' : 'Payment'}: ${ord['payment_method']}'),
              if (ord['receipt_image_url'] != null &&
                  ord['receipt_image_url'].toString().isNotEmpty)
                Text('${isAr ? 'رابط الإشعار' : 'Receipt'}: ${ord['receipt_image_url']}',
                    style: TextStyle(fontSize: 11, color: Colors.blue)),
              SizedBox(height: 8),
              Text('${isAr ? 'الإجمالي الكلي' : 'Total'}: ${ord['grand_total_sdg']} SDG',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).primaryColor)),
              SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        _generateAndPrintPdfInvoice(ord);
                      },
                      icon: Icon(Icons.picture_as_pdf),
                      label: Text(isAr ? 'تحميل / طباعة PDF' : 'Download PDF'),
                    ),
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _shareInvoiceWhatsApp(ord);
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF25D366),
                          foregroundColor: Colors.white),
                      icon: Icon(Icons.share),
                      label: Text(isAr ? 'مشاركة بالواتساب' : 'Share WhatsApp'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _generateAndPrintPdfInvoice(Map<String, dynamic> ord) async {
    final pdf = pw.Document();
    final items = (ord['items_json'] is List) ? (ord['items_json'] as List) : [];

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: pw.EdgeInsets.all(24),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Header(
                  level: 0,
                  child: pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('DMC Medical Sudan - Electronic Invoice',
                          style: pw.TextStyle(
                              fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Order #${ord['order_number']}',
                          style: pw.TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Text('Customer: ${currentUser?['full_name'] ?? 'DMC Client'}'),
                pw.Text('Date: ${ord['created_at'] ?? ''}'),
                pw.Text('Zone: ${ord['delivery_zone'] ?? ''}'),
                pw.Text('Payment Method: ${ord['payment_method'] ?? ''}'),
                pw.SizedBox(height: 16),
                pw.Table.fromTextArray(
                  headers: ['Product Name', 'Qty'],
                  data: items
                      .map((it) => [
                            it['name_ar'] ?? it['product_id'] ?? 'Item',
                            '${it['qty'] ?? 1}'
                          ])
                      .toList(),
                ),
                pw.Divider(),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Grand Total:',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 14)),
                    pw.Text('${ord['grand_total_sdg']} SDG',
                        style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold, fontSize: 14)),
                  ],
                ),
                pw.SizedBox(height: 24),
                pw.Text(
                    'Thank you for ordering from DMC Medical Equipment & Supplies Sudan.',
                    style: pw.TextStyle(fontSize: 10)),
              ],
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  void _shareInvoiceWhatsApp(Map<String, dynamic> ord) {
    final String text =
        "فاتورة رقم ${ord['order_number']} - شركة DMC للمعدات الطبية\nالمبلغ الإجمالي: ${ord['grand_total_sdg']} SDG\nمنطقة التوصيل: ${ord['delivery_zone']}\nشكراً لتتعاملكم معنا!";
    Share.share(text);
  }

  // 7. ADMIN STAFF LOGIN & DASHBOARD
  void _openAdminLoginModal() {
    if (currentStaff != null) {
      _openAdminDashboardSheet();
      return;
    }

    final userCtrl = TextEditingController(text: 'admin');
    final passCtrl = TextEditingController(text: '123456');
    String selectedRole = 'manager';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        final bool isAr = widget.currentLanguage == 'ar';

        return StatefulBuilder(
          builder: (ctxState, setModalState) {
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
                    isAr ? 'تسجيل دخول كادر الإدارة (staff)' : 'Staff Admin Login',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedRole,
                    items: [
                      DropdownMenuItem(value: 'manager', child: Text('مدير النظام (Manager)')),
                      DropdownMenuItem(value: 'sales', child: Text('موظف مبيعات (Sales)')),
                      DropdownMenuItem(value: 'warehouse', child: Text('أمين المخزن (Warehouse)')),
                      DropdownMenuItem(value: 'accountant', child: Text('محاسب (Accountant)')),
                    ],
                    onChanged: (v) {
                      if (v != null) setModalState(() => selectedRole = v);
                    },
                    decoration: InputDecoration(
                      labelText: isAr ? 'الصلاحية / الدور' : 'Staff Role',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: userCtrl,
                    decoration: InputDecoration(
                      labelText: isAr ? 'اسم المستخدم' : 'Username',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: passCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: isAr ? 'كلمة المرور' : 'Password',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          currentStaff = {
                            'name': userCtrl.text,
                            'role': selectedRole,
                            'logged_at': DateTime.now().toIso8601String()
                          };
                        });
                        Navigator.pop(ctx);
                        _logAdminActivity('تسجيل دخول الإدارة', {'role': selectedRole});
                        _toast(isAr
                            ? 'تم تسجيل الدخول بنجاح بصلاحية: $selectedRole'
                            : 'Logged in as $selectedRole');
                        _openAdminDashboardSheet();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(isAr ? 'دخول لوحة التحكم' : 'Login Dashboard'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // COMPLETE DMC ADMIN DASHBOARD
  void _openAdminDashboardSheet() {
    final rateCtrl = TextEditingController(text: dollarRate.toStringAsFixed(0));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        final bool isAr = widget.currentLanguage == 'ar';

        // Check Inventory Alerts
        final lowStockItems = products.where((p) {
          int qty = (p['stock_quantity'] is num) ? (p['stock_quantity'] as num).toInt() : 100;
          int threshold = (p['low_stock_threshold'] is num) ? (p['low_stock_threshold'] as num).toInt() : 10;
          return qty <= threshold;
        }).toList();

        return DefaultTabController(
          length: 4,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: SizedBox(
              height: 560,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(isAr ? 'لوحة تحكم إدارة DMC Admin' : 'DMC Admin Panel',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(
                            'الموظف: ${currentStaff?['name']} | الدور: ${currentStaff?['role']}',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() => currentStaff = null);
                          Navigator.pop(ctx);
                          _toast(isAr ? 'تم تسجيل الخروج من الإدارة' : 'Logged out');
                        },
                        child: Text(isAr ? 'خروج' : 'Logout',
                            style: TextStyle(color: Colors.red, fontSize: 11)),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  // Stock Alert Banner
                  if (lowStockItems.isNotEmpty)
                    Container(
                      margin: EdgeInsets.only(bottom: 8),
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Colors.red, size: 18),
                          SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              isAr
                                  ? 'تنبيه مخزون: يوجد ${lowStockItems.length} منتجات قاربت على النفاد!'
                                  : 'Low stock alert for ${lowStockItems.length} items!',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),

                  TabBar(
                    isScrollable: true,
                    labelColor: Theme.of(context).primaryColor,
                    tabs: [
                      Tab(text: isAr ? 'الدولار والمنتجات' : 'Rate & Catalog'),
                      Tab(text: isAr ? 'إدارة الطلبات' : 'Orders'),
                      Tab(text: isAr ? 'عروض الأسعار' : 'Quotations'),
                      Tab(text: isAr ? 'سجل النشاط' : 'Audit Logs'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        // TAB 1: DOLLAR RATE & PRODUCTS
                        SingleChildScrollView(
                          padding: EdgeInsets.only(top: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Card(
                                child: Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isAr
                                            ? 'تعديل سعر الدولار اليومي (تغيير تلقائي لجميع الأسعار):'
                                            : 'Daily Dollar Exchange Rate:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12),
                                      ),
                                      SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              controller: rateCtrl,
                                              keyboardType: TextInputType.number,
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(10)),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 10),
                                              ),
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          ElevatedButton(
                                            onPressed: () async {
                                              final newR = double.tryParse(rateCtrl.text);
                                              if (newR != null) {
                                                await FirebaseService.put(
                                                  'dollar_rate_settings',
                                                  {'rate_sdg': newR},
                                                );
                                                await FirebaseService.post(
                                                  'dollar_rate_logs',
                                                  {
                                                    'old_rate': dollarRate,
                                                    'new_rate': newR,
                                                    'changed_at': DateTime.now().toIso8601String()
                                                  },
                                                );
                                                setState(() => dollarRate = newR);
                                                _logAdminActivity(
                                                    'تحديث سعر الدولار', {'new_rate': newR});
                                                _toast(isAr
                                                    ? 'تم تحديث سعر الدولار إلى $newR SDG'
                                                    : 'Dollar Rate updated');
                                              }
                                            },
                                            child: Text(isAr ? 'تحديث' : 'Update'),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    isAr ? 'كتالوج المنتجات والمخزون:' : 'Product Catalog:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.add_circle, color: Colors.teal),
                                    onPressed: () {
                                      Navigator.pop(ctx);
                                      _openEditProductModal();
                                    },
                                  ),
                                ],
                              ),
                              ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: products.length,
                                itemBuilder: (c, i) {
                                  final p = products[i];
                                  final int stock = (p['stock_quantity'] is num)
                                      ? (p['stock_quantity'] as num).toInt()
                                      : 100;

                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: Text(p['image_emoji'] ?? '📦'),
                                    title: Text(p['name_ar'] ?? '',
                                        style: TextStyle(fontSize: 12)),
                                    subtitle: Text(
                                        '\$${p['base_price_usd']} | المخزون: $stock حبة',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: stock < 10 ? Colors.red : Colors.grey)),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: Icon(Icons.edit, size: 18),
                                          onPressed: () {
                                            Navigator.pop(ctx);
                                            _openEditProductModal(p: p);
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(Icons.delete,
                                              size: 18, color: Colors.red),
                                          onPressed: () async {
                                            if (p.containsKey('id')) {
                                              await FirebaseService.delete(
                                                  'products/${p['id']}');
                                              _logAdminActivity(
                                                  'حذف منتج', {'product_id': p['id']});
                                              _fetchFirebaseData();
                                              _toast(isAr ? 'تم حذف المنتج' : 'Deleted');
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        // TAB 2: LIVE ORDERS MANAGEMENT
                        ListView.builder(
                          padding: EdgeInsets.only(top: 10),
                          itemCount: orders.length,
                          itemBuilder: (c, i) {
                            final o = orders[i];
                            return Card(
                              margin: EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: Text(o['order_number'] ?? '',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 13)),
                                subtitle: Text(
                                    '${o['grand_total_sdg']} SDG | ${o['payment_method']} | ${o['order_status']}'),
                                trailing: DropdownButton<String>(
                                  value: o['order_status'] ?? 'preparing',
                                  underline: SizedBox(),
                                  items: [
                                    DropdownMenuItem(
                                        value: 'waiting_payment_confirmation',
                                        child: Text('تأكيد الدفع',
                                            style: TextStyle(fontSize: 10))),
                                    DropdownMenuItem(
                                        value: 'preparing',
                                        child: Text('جاري التجهيز',
                                            style: TextStyle(fontSize: 10))),
                                    DropdownMenuItem(
                                        value: 'in_transit',
                                        child: Text('في الطريق',
                                            style: TextStyle(fontSize: 10))),
                                    DropdownMenuItem(
                                        value: 'delivered',
                                        child: Text('تم التسليم',
                                            style: TextStyle(fontSize: 10))),
                                  ],
                                  onChanged: (val) async {
                                    if (val != null) {
                                      setState(() => o['order_status'] = val);
                                      if (o.containsKey('id')) {
                                        await FirebaseService.patch(
                                            'orders/${o['id']}',
                                            {'order_status': val});
                                      }
                                      _logAdminActivity('تغيير حالة طلب',
                                          {'order_id': o['id'], 'new_status': val});
                                      _toast('تم تحديث حالة الطلب بجدول orders');
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),

                        // TAB 3: QUOTATIONS REVIEW
                        ListView.builder(
                          padding: EdgeInsets.only(top: 10),
                          itemCount: quotations.length,
                          itemBuilder: (c, i) {
                            final q = quotations[i];
                            final respCtrl = TextEditingController(
                                text: q['admin_response_notes'] ?? '');

                            return Card(
                              margin: EdgeInsets.only(bottom: 8),
                              child: Padding(
                                padding: EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(q['quotation_number'] ?? 'QUO',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text('عناصر الطلب: ${q['items_requested']}'),
                                    SizedBox(height: 6),
                                    TextField(
                                      controller: respCtrl,
                                      decoration: InputDecoration(
                                        labelText: 'كتابة الرد أو السعر الخاص من الإدارة',
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.all(8),
                                      ),
                                    ),
                                    SizedBox(height: 6),
                                    ElevatedButton(
                                      onPressed: () async {
                                        q['admin_response_notes'] = respCtrl.text;
                                        q['status'] = 'responded';
                                        if (q.containsKey('id')) {
                                          await FirebaseService.patch(
                                            'quotations/${q['id']}',
                                            {
                                              'admin_response_notes': respCtrl.text,
                                              'status': 'responded'
                                            },
                                          );
                                        }
                                        _logAdminActivity('الرد على عرض سعر',
                                            {'quo_id': q['id']});
                                        _toast('تم إرسال الرد للعميل بنجاح');
                                      },
                                      child: Text('إرسال الرد للعميل',
                                          style: TextStyle(fontSize: 11)),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        // TAB 4: AUDIT LOGS
                        ListView.builder(
                          padding: EdgeInsets.only(top: 10),
                          itemCount: auditLogs.length,
                          itemBuilder: (c, i) {
                            final log = auditLogs[i];
                            return Card(
                              margin: EdgeInsets.only(bottom: 6),
                              child: ListTile(
                                title: Text(log['action_type'] ?? 'إجراء',
                                    style: TextStyle(
                                        fontSize: 12, fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                    'الموظف: ${log['staff_name']} (${log['role']}) | ${log['timestamp']}',
                                    style: TextStyle(fontSize: 10, color: Colors.grey)),
                              ),
                            );
                          },
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
    );
  }

  // 8. ADD / EDIT PRODUCT MODAL
  void _openEditProductModal({Map<String, dynamic>? p}) {
    final nameArCtrl = TextEditingController(text: p?['name_ar'] ?? '');
    final nameEnCtrl = TextEditingController(text: p?['name_en'] ?? '');
    final brandCtrl = TextEditingController(text: p?['brand'] ?? 'DMC');
    final priceUsdCtrl =
        TextEditingController(text: p?['base_price_usd']?.toString() ?? '5.0');
    final stockCtrl =
        TextEditingController(text: p?['stock_quantity']?.toString() ?? '100');
    final urlCtrl = TextEditingController(text: p?['image_url'] ?? '');

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    p == null
                        ? (isAr ? 'إضافة منتج جديد للكتالوج' : 'Add New Product')
                        : (isAr ? 'تعديل المنتج' : 'Edit Product'),
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                TextField(
                  controller: nameArCtrl,
                  decoration: InputDecoration(
                      labelText: isAr ? 'اسم المنتج بالعربية' : 'Arabic Name',
                      border: OutlineInputBorder()),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: nameEnCtrl,
                  decoration: InputDecoration(
                      labelText: isAr ? 'اسم المنتج بالإنجليزية' : 'English Name',
                      border: OutlineInputBorder()),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: brandCtrl,
                  decoration: InputDecoration(
                      labelText: isAr ? 'العلامة التجارية (Brand)' : 'Brand Name',
                      border: OutlineInputBorder()),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceUsdCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: isAr ? 'السعر الأساسي ($)' : 'USD Price ($)',
                            border: OutlineInputBorder()),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: stockCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: isAr ? 'الكمية بالمخزن' : 'Stock Qty',
                            border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                TextField(
                  controller: urlCtrl,
                  decoration: InputDecoration(
                      labelText: isAr ? 'رابط صورة المنتج (image_url)' : 'Product Image URL',
                      border: OutlineInputBorder()),
                ),
                SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      final newProduct = {
                        'name_ar': nameArCtrl.text,
                        'name_en': nameEnCtrl.text,
                        'brand': brandCtrl.text,
                        'base_price_usd':
                            double.tryParse(priceUsdCtrl.text) ?? 5.0,
                        'stock_quantity': int.tryParse(stockCtrl.text) ?? 100,
                        'low_stock_threshold': 10,
                        'image_url': urlCtrl.text,
                        'image_emoji': '📦',
                        'category': p?['category'] ?? 'consumables',
                        'description': 'معدات ومستلزمات طبية عالية الجودة معتمدة.',
                      };

                      if (p != null && p.containsKey('id')) {
                        await FirebaseService.patch(
                            'products/${p['id']}', newProduct);
                        _logAdminActivity(
                            'تعديل منتج', {'product_id': p['id']});
                      } else {
                        await FirebaseService.post('products', newProduct);
                        _logAdminActivity('إضافة منتج جديد', {'name': nameArCtrl.text});
                      }

                      _fetchFirebaseData();
                      Navigator.pop(ctx);
                      _toast(isAr ? 'تم حفظ المنتج بجدول products' : 'Product Saved');
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white),
                    child: Text(isAr ? 'حفظ وإغلاق' : 'Save & Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ==========================================
// FILTER EXTENSION
// ==========================================
extension ProductFilter on List<Map<String, dynamic>> {
  List<Map<String, dynamic>> filterProduct(
      String category, String brand, String query) {
    return where((p) {
      final bool matchCat = category == 'all' || p['category'] == category;
      final bool matchBrand = brand == 'all' ||
          p['brand'].toString().toLowerCase() == brand.toLowerCase();
      final String nameAr = (p['name_ar'] ?? '').toString().toLowerCase();
      final String nameEn = (p['name_en'] ?? '').toString().toLowerCase();
      final String brandStr = (p['brand'] ?? '').toString().toLowerCase();
      final bool matchQuery = query.isEmpty ||
          nameAr.contains(query) ||
          nameEn.contains(query) ||
          brandStr.contains(query);
      return matchCat && matchBrand && matchQuery;
    }).toList();
  }
}

// ===== تحديث التطبيق (يُضاف تلقائياً) =====
const int _apkCur = 1;
const String _apkUrl = 'https://raw.githubusercontent.com/alkahlizero564-sudo/apk-app/main/apps/dmcclient0hw0/update.json';

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
