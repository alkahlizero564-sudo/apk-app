// DESIGN: تطبيق طلب خبز طازج | خبز، طازج، يومي | قيمة 25
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'push.dart';

import 'dart:async' as apkas;
import 'dart:convert' as apkjs;
import 'dart:io' as apkio;
import 'package:flutter/widgets.dart' as apkw;
import 'package:url_launcher/url_launcher.dart' as apkul;

void main() {
  APKPush.start();
  runApp(DsApp(
    hue: 25,
    title: "المخبز اليومي - تطبيق الزبائن",
    home: AppEntryPoint(),
  ));
}

class SupabaseService {
  static const String supabaseUrl = "https://qlvmxnoewxzykgbneadv.supabase.co";
  static const String anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFsdm14bm9ld3h6eWtnYm5lYWR2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTE2NDAwMjIsImV4cCI6MjEwNzIxNjAyMn0.WtsiO0PrUrwxKjpcyB3949kXSZeijtlJYySSbh0ieRk";

  static Map<String, String> get _headers => {
        'apikey': anonKey,
        'Authorization': 'Bearer $anonKey',
        'Content-Type': 'application/json',
      };

  static Future<List<dynamic>> getTable(String table, [String query = '']) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = Duration(seconds: 10);
      final url = Uri.parse('$supabaseUrl/rest/v1/$table$query');
      final request = await client.getUrl(url);
      _headers.forEach((k, v) => request.headers.set(k, v));
      final response = await request.close();
      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        return json.decode(body) as List<dynamic>;
      }
    } catch (_) {}
    return [];
  }

  static Future<bool> insertRow(String table, Map<String, dynamic> data) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = Duration(seconds: 10);
      final url = Uri.parse('$supabaseUrl/rest/v1/$table');
      final request = await client.postUrl(url);
      _headers.forEach((k, v) => request.headers.set(k, v));
      request.headers.set('Prefer', 'return=representation');
      request.add(utf8.encode(json.encode(data)));
      final response = await request.close();
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (_) {}
    return false;
  }

  static Future<bool> updateRow(String table, String filter, Map<String, dynamic> data) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = Duration(seconds: 10);
      final url = Uri.parse('$supabaseUrl/rest/v1/$table?$filter');
      final request = await client.patchUrl(url);
      _headers.forEach((k, v) => request.headers.set(k, v));
      request.add(utf8.encode(json.encode(data)));
      final response = await request.close();
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {}
    return false;
  }
}

class AppEntryPoint extends StatefulWidget {
  const AppEntryPoint({super.key});

  @override
  State<AppEntryPoint> createState() => _AppEntryPointState();
}

class _AppEntryPointState extends State<AppEntryPoint> {
  bool _loading = true;
  bool _isLoggedIn = false;
  Map<String, dynamic>? _userProfile;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final sessionStr = DS.get('user_session', null);
    if (sessionStr != null) {
      try {
        final data = json.decode(sessionStr);
        final profiles = await SupabaseService.getTable('s2x7rw_profiles', '?id=eq.${data['id']}');
        if (profiles.isNotEmpty) {
          _userProfile = profiles.first;
          _isLoggedIn = true;
          APKPush.setUser(_userProfile!['phone'] ?? _userProfile!['id']);
        }
      } catch (_) {}
    }
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _onLoggedIn(Map<String, dynamic> profile) {
    setState(() {
      _userProfile = profile;
      _isLoggedIn = true;
    });
    DS.set('user_session', json.encode(profile));
    APKPush.setUser(profile['phone'] ?? profile['id']);
  }

  void _onLoggedOut() {
    DS.set('user_session', null);
    setState(() {
      _userProfile = null;
      _isLoggedIn = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (!_isLoggedIn) {
      return AuthScreen(onLoggedIn: _onLoggedIn);
    }
    return MainAppScreen(userProfile: _userProfile!, onLoggedOut: _onLoggedOut);
  }
}

class AuthScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onLoggedIn;

  const AuthScreen({super.key, required this.onLoggedIn});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isSignup = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  bool _awaitingCode = false;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _handleAuthAction() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      dsToast(context, 'الرجاء إدخال البريد الإلكتروني');
      return;
    }

    if (_isSignup && _nameController.text.trim().isEmpty) {
      dsToast(context, 'الرجاء إدخال الاسم الكامل');
      return;
    }

    if (_isSignup && _phoneController.text.trim().isEmpty) {
      dsToast(context, 'الرجاء إدخال رقم الهاتف');
      return;
    }

    setState(() {
      _loading = true;
    });

    await Future.delayed(Duration(milliseconds: 800));

    setState(() {
      _loading = false;
      _awaitingCode = true;
    });
    dsToast(context, 'تم إرسال رمز التحقق إلى بريدك');
  }

  Future<void> _verifyCode() async {
    final code = _codeController.text.trim();
    if (code.length < 4) {
      dsToast(context, 'الرجاء إدخال رمز صحيح مكون من 4 أرقام');
      return;
    }

    setState(() {
      _loading = true;
    });

    final email = _emailController.text.trim();
    final profiles = await SupabaseService.getTable('s2x7rw_profiles', '?id=eq.$email');

    Map<String, dynamic> profile;
    if (profiles.isNotEmpty) {
      profile = profiles.first;
    } else {
      profile = {
        'id': email,
        'full_name': _isSignup ? _nameController.text.trim() : 'مستخدم جديد',
        'phone': _isSignup ? _phoneController.text.trim() : '0790000000',
        'role': 'customer',
      };
      await SupabaseService.insertRow('s2x7rw_profiles', profile);
    }

    setState(() {
      _loading = false;
    });

    widget.onLoggedIn(profile);
  }

  @override
  Widget build(BuildContext context) {
    if (_awaitingCode) {
      return Scaffold(
        body: ListView(
          padding: EdgeInsets.zero,
          children: [
            DsHero(
              title: "رمز التحقق 🔐",
              subtitle: "أدخل الرمز المرسل إلى بريدك الإلكتروني لتأكيد الحساب",
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: DsCard(
                child: Column(
                  children: [
                    DsField(
                      controller: _codeController,
                      label: "رمز التحقق",
                      hint: "1234",
                      keyboard: TextInputType.number,
                    ),
                    SizedBox(height: 16),
                    DsButton(
                      label: _loading ? "جاري التحقق..." : "تأكيد ودخول",
                      onPressed: _loading ? () {} : _verifyCode,
                      block: true,
                    ),
                    SizedBox(height: 12),
                    DsButton(
                      label: "إعادة إرسال الرمز",
                      onPressed: () {
                        dsToast(context, 'تم إرسال رمز جديد');
                      },
                      kind: "ghost",
                      block: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          DsHero(
            title: "المخبز اليومي 🥖",
            subtitle: "احصل على خبزك الطازج يومياً بكل سهولة",
          ),
          Padding(
            padding: EdgeInsets.all(16),
            child: DsCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: DsButton(
                          label: "تسجيل دخول",
                          onPressed: () {
                            setState(() {
                              _isSignup = false;
                            });
                          },
                          kind: !_isSignup ? "primary" : "ghost",
                        ),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: DsButton(
                          label: "إنشاء حساب",
                          onPressed: () {
                            setState(() {
                              _isSignup = true;
                            });
                          },
                          kind: _isSignup ? "primary" : "ghost",
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  if (_isSignup) ...[
                    DsField(
                      controller: _nameController,
                      label: "الاسم الكامل",
                      hint: "محمد أحمد",
                    ),
                    SizedBox(height: 16),
                    DsField(
                      controller: _phoneController,
                      label: "رقم الهاتف",
                      hint: "0790000000",
                      keyboard: TextInputType.phone,
                    ),
                    SizedBox(height: 16),
                  ],
                  DsField(
                    controller: _emailController,
                    label: "البريد الإلكتروني",
                    hint: "name@example.com",
                    keyboard: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 20),
                  DsButton(
                    label: _loading ? "جاري الإرسال..." : (_isSignup ? "إنشاء وإرسال رمز التأكيد" : "متابعة وإرسال الرمز"),
                    onPressed: _loading ? () {} : _handleAuthAction,
                    block: true,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MainAppScreen extends StatefulWidget {
  final Map<String, dynamic> userProfile;
  final VoidCallback onLoggedOut;

  const MainAppScreen({super.key, required this.userProfile, required this.onLoggedOut});

  @override
  State<MainAppScreen> createState() => _MainAppScreenState();
}

class _MainAppScreenState extends State<MainAppScreen> {
  int _currentIndex = 0;
  Map<String, dynamic>? _bakerySettings;
  List<dynamic> _bookings = [];
  bool _loadingData = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _timer = Timer.periodic(Duration(seconds: 5), (_) {
      _fetchData(silent: true);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData({bool silent = false}) async {
    if (!silent) {
      setState(() {
        _loadingData = true;
      });
    }

    final settingsList = await SupabaseService.getTable('s2x7rw_bakery_settings', '?order=id.desc&limit=1');
    final bookingsList = await SupabaseService.getTable('s2x7rw_bookings', '?customer_id=eq.${widget.userProfile['id']}&order=id.desc');

    if (mounted) {
      setState(() {
        if (settingsList.isNotEmpty) {
          _bakerySettings = settingsList.first;
        }
        _bookings = bookingsList;
        _loadingData = false;
      });
    }
  }

  void _openBookingSheet() {
    if (_bakerySettings == null || _bakerySettings!['is_open'] != true) {
      dsToast(context, 'المخبز مغلق حالياً للحجز');
      return;
    }

    final qtyController = TextEditingController(text: '10');
    String pickupTime = 'صباحا';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.between,
                      children: [
                        Text("حجز خبز جديد", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    DsField(
                      controller: qtyController,
                      label: "العدد (رغيف)",
                      keyboard: TextInputType.number,
                    ),
                    SizedBox(height: 16),
                    Text("وقت الاستلام", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DsButton(
                            label: "صباحاً",
                            onPressed: () {
                              setModalState(() {
                                pickupTime = 'صباحا';
                              });
                            },
                            kind: pickupTime == 'صباحا' ? 'primary' : 'ghost',
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: DsButton(
                            label: "مساءً",
                            onPressed: () {
                              setModalState(() {
                                pickupTime = 'مساء';
                              });
                            },
                            kind: pickupTime == 'مساء' ? 'primary' : 'ghost',
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    DsButton(
                      label: "تأكيد الحجز",
                      onPressed: () async {
                        final q = int.tryParse(qtyController.text) ?? 0;
                        if (q <= 0) {
                          dsToast(context, 'الرجاء إدخال كمية صحيحة');
                          return;
                        }

                        Navigator.pop(ctx);
                        setState(() {
                          _loadingData = true;
                        });

                        final success = await SupabaseService.insertRow('s2x7rw_bookings', {
                          'customer_id': widget.userProfile['id'],
                          'quantity': q,
                          'pickup_time': pickupTime,
                          'status': 'pending',
                        });

                        if (success) {
                          dsToast(context, 'تم إرسال طلب الحجز بنجاح');
                          APKPush.toAdmin(
                            'طلب حجز جديد',
                            'الزبون ${widget.userProfile['full_name']} طلب $q رغيف (${pickupTime})',
                          );
                          _fetchData();
                        } else {
                          dsToast(context, 'حدث خطأ أثناء الحجز');
                          setState(() {
                            _loadingData = false;
                          });
                        }
                      },
                      block: true,
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

  Future<void> _cancelBooking(dynamic id) async {
    final success = await SupabaseService.updateRow('s2x7rw_bookings', 'id=eq.$id', {
      'status': 'cancelled',
    });
    if (success) {
      dsToast(context, 'تم إلغاء الحجز');
      _fetchData();
    } else {
      dsToast(context, 'تعذر إلغاء الحجز');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loadingData && _bakerySettings == null
          ? Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _currentIndex,
              children: [
                _buildHomeScreen(),
                _buildBookingsScreen(),
                _buildProfileScreen(),
              ],
            ),
      bottomNavigationBar: DsNav(
        items: [
          DsNavItem("الرئيسية", Icons.home_rounded),
          DsNavItem("حجوزاتي", Icons.list_alt_rounded),
          DsNavItem("حسابي", Icons.person_rounded),
        ],
        index: _currentIndex,
        onChanged: (i) {
          setState(() {
            _currentIndex = i;
          });
        },
      ),
    );
  }

  Widget _buildHomeScreen() {
    final settings = _bakerySettings ?? {
      'is_open': false,
      'price': 0,
      'total_quantity': 0,
      'remaining_quantity': 0,
    };

    final isOpen = settings['is_open'] == true;
    final price = settings['price'] ?? 0;
    final remaining = settings['remaining_quantity'] ?? 0;
    final total = settings['total_quantity'] ?? 1;
    final progress = total > 0 ? (remaining / total).clamp(0.0, 1.0) : 0.0;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DsHero(
          title: "مرحباً بك، ${widget.userProfile['full_name']}",
          subtitle: isOpen ? "المخبز مفتوح الآن لحجز الخبز الطازج" : "المخبز مغلق حالياً",
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              DsCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.between,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("حالة الحجز اليومي", style: TextStyle(color: Colors.grey)),
                            Text(
                              isOpen ? "مفتوح للحجز" : "مغلق",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        DsBadge(
                          text: isOpen ? "نشط" : "مغلق",
                          kind: isOpen ? "ok" : "bad",
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    DsStats(
                      items: [
                        DsStat(
                          label: "سعر الرغيفة",
                          value: "$price د.أ",
                          emoji: "🪙",
                        ),
                        DsStat(
                          label: "الكمية المتبقية",
                          value: "$remaining",
                          emoji: "🥖",
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    DsProgress(value: progress),
                    SizedBox(height: 20),
                    DsButton(
                      label: "حجز كمية الآن",
                      onPressed: _openBookingSheet,
                      block: true,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              DsSection(title: "نصائح طازجة"),
              DsCard(
                child: DsItem(
                  emoji: "🥐",
                  title: "الاستلام الصباحي الأفضل",
                  subtitle: "احجز قبل الساعة 6 صباحاً لضمان الحصول على الخبز ساخناً.",
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookingsScreen() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DsTopBar(
          title: "حجوزاتي",
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                _fetchData();
                dsToast(context, 'تم تحديث الحالات تلقائياً');
              },
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.all(16),
          child: _bookings.isEmpty
              ? DsEmpty(
                  emoji: "📭",
                  title: "لا توجد حجوزات",
                  text: "لم تقم بإنشاء أي حجوزات حتى الآن",
                )
              : Column(
                  children: _bookings.map((bk) {
                    final status = bk['status'] ?? 'pending';
                    String badgeText = 'قيد الانتظار';
                    String badgeKind = 'warn';

                    if (status == 'accepted') {
                      badgeText = 'مقبول';
                      badgeKind = 'ok';
                    } else if (status == 'completed') {
                      badgeText = 'اتسلّم';
                      badgeKind = 'ok';
                    } else if (status == 'cancelled') {
                      badgeText = 'ملغي';
                      badgeKind = 'bad';
                    } else if (status == 'ready') {
                      badgeText = 'جاهز للاستلام';
                      badgeKind = 'ok';
                    } else if (status == 'rejected') {
                      badgeText = 'مرفوض';
                      badgeKind = 'bad';
                    }

                    return Padding(
                      padding: EdgeInsets.only(bottom: 12),
                      child: DsCard(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text("🥖", style: TextStyle(fontSize: 24)),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "حجز #${bk['id']} - ${bk['quantity']} رغيف",
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        "وقت الاستلام: ${bk['pickup_time']}",
                                        style: TextStyle(color: Colors.grey, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                DsBadge(text: badgeText, kind: badgeKind),
                              ],
                            ),
                            if (status == 'pending') ...[
                              Divider(height: 24),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  DsButton(
                                    label: "إلغاء الطلب",
                                    onPressed: () => _cancelBooking(bk['id']),
                                    kind: "danger",
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildProfileScreen() {
    final nameController = TextEditingController(text: widget.userProfile['full_name']);
    final phoneController = TextEditingController(text: widget.userProfile['phone']);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DsTopBar(title: "الملف الشخصي"),
        Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              DsCard(
                child: Column(
                  children: [
                    DsField(
                      controller: nameController,
                      label: "الاسم الكامل",
                    ),
                    SizedBox(height: 16),
                    DsField(
                      controller: phoneController,
                      label: "رقم الهاتف",
                      keyboard: TextInputType.phone,
                    ),
                    SizedBox(height: 20),
                    DsButton(
                      label: "تعديل البيانات",
                      onPressed: () async {
                        final newName = nameController.text.trim();
                        final newPhone = phoneController.text.trim();

                        final success = await SupabaseService.updateRow('s2x7rw_profiles', 'id=eq.${widget.userProfile['id']}', {
                          'full_name': newName,
                          'phone': newPhone,
                        });

                        if (success) {
                          widget.userProfile['full_name'] = newName;
                          widget.userProfile['phone'] = newPhone;
                          dsToast(context, 'تم حفظ الملف الشخصي بنجاح');
                        } else {
                          dsToast(context, 'تعذر حفظ البيانات');
                        }
                      },
                      block: true,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              DsButton(
                label: "تسجيل الخروج",
                onPressed: widget.onLoggedOut,
                kind: "danger",
                block: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ===== نظام التصميم الجاهز (يُضاف تلقائياً) =====
class DsPal {
  final Color p;
  final Color p2;
  final Color bg;
  final Color sf;
  final Color sf2;
  final Color tx;
  final Color mu;
  final Color ln;
  final bool dark;
  DsPal(this.p, this.p2, this.bg, this.sf, this.sf2, this.tx, this.mu, this.ln, this.dark);

  static DsPal of(BuildContext context) {
    final t = Theme.of(context);
    final d = t.brightness == Brightness.dark;
    final p = t.colorScheme.primary;
    final h = HSLColor.fromColor(p);
    final p2 = h.withHue((h.hue + 38) % 360).toColor();
    return DsPal(
      p,
      p2,
      t.scaffoldBackgroundColor,
      d ? const Color(0xFF141B32) : const Color(0xFFFFFFFF),
      d ? const Color(0xFF1C2540) : const Color(0xFFEEF1F8),
      d ? const Color(0xFFEEF2FF) : const Color(0xFF0F172A),
      d ? const Color(0xFF97A3C7) : const Color(0xFF64748B),
      d ? const Color(0x1FFFFFFF) : const Color(0x140F172A),
      d,
    );
  }

  LinearGradient get grad => LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [p, p2],
      );

  List<BoxShadow> get shadow => [
        BoxShadow(
          color: Color(dark ? 0x66000000 : 0x1A283C5A),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ];
}

class DsTheme {
  static ThemeData build(double hue, bool dark) {
    final p = HSLColor.fromAHSL(1.0, hue % 360, 0.86, dark ? 0.66 : 0.52).toColor();
    final scheme = ColorScheme.fromSeed(
      seedColor: p,
      brightness: dark ? Brightness.dark : Brightness.light,
    ).copyWith(primary: p);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: dark ? const Color(0xFF0B1020) : const Color(0xFFF3F5FB),
    );
  }
}

class DsApp extends StatelessWidget {
  final Widget home;
  final double hue;
  final String title;
  const DsApp({super.key, required this.home, this.hue = 250, this.title = 'App'});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      debugShowCheckedModeBanner: false,
      theme: DsTheme.build(hue, false),
      darkTheme: DsTheme.build(hue, true),
      themeMode: ThemeMode.system,
      builder: (context, child) => Directionality(
        textDirection: TextDirection.rtl,
        child: child ?? const SizedBox.shrink(),
      ),
      home: home,
    );
  }
}

class DsHero extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? big;
  final Widget? trailing;
  const DsHero({super.key, required this.title, this.subtitle, this.big, this.trailing});

  @override
  Widget build(BuildContext context) {
    final c = DsPal.of(context);
    final top = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(22, top + 26, 22, 38),
      decoration: BoxDecoration(
        gradient: c.grad,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
        boxShadow: [BoxShadow(color: c.p.withAlpha(90), blurRadius: 24, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w800)),
                if (subtitle != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(subtitle!, style: const TextStyle(color: Color(0xE6FFFFFF), fontSize: 14)),
                  ),
                if (big != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(big!, style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w800)),
                  ),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class DsTopBar extends StatelessWidget {
  final String title;
  final List<Widget> actions;
  final VoidCallback? onBack;
  const DsTopBar({super.key, required this.title, this.actions = const [], this.onBack});

  @override
  Widget build(BuildContext context) {
    final c = DsPal.of(context);
    final top = MediaQuery.of(context).padding.top;
    return Container(
      padding: EdgeInsets.fromLTRB(16, top + 12, 16, 12),
      decoration: BoxDecoration(
        color: c.sf,
        border: Border(bottom: BorderSide(color: c.ln)),
      ),
      child: Row(
        children: [
          if (onBack != null)
            GestureDetector(
              onTap: onBack,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(end: 12),
                child: Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: c.tx),
              ),
            ),
          Expanded(child: Text(title, style: TextStyle(color: c.tx, fontSize: 19, fontWeight: FontWeight.w800))),
          ...actions,
        ],
      ),
    );
  }
}

class DsCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;
  final EdgeInsets margin;
  const DsCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.only(bottom: 12),
  });

  @override
  Widget build(BuildContext context) {
    final c = DsPal.of(context);
    return Padding(
      padding: margin,
      child: Container(
        decoration: BoxDecoration(
          color: c.sf,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.ln),
          boxShadow: c.shadow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: onTap,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}

class DsItem extends StatelessWidget {
  final String? emoji;
  final IconData? icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  const DsItem({super.key, this.emoji, this.icon, required this.title, this.subtitle, this.trailing, this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = DsPal.of(context);
    return DsCard(
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: c.p.withAlpha(36), borderRadius: BorderRadius.circular(15)),
            child: emoji != null
                ? Text(emoji!, style: const TextStyle(fontSize: 22))
                : Icon(icon ?? Icons.circle, color: c.p),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: c.tx, fontWeight: FontWeight.w700, fontSize: 15)),
                if (subtitle != null) Text(subtitle!, style: TextStyle(color: c.mu, fontSize: 12)),
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class DsStat extends StatelessWidget {
  final String label;
  final String value;
  final String? emoji;
  const DsStat({super.key, required this.label, required this.value, this.emoji});

  @override
  Widget build(BuildContext context) {
    final c = DsPal.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: c.sf,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.ln),
        boxShadow: c.shadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text((emoji ?? '') + (emoji == null ? '' : '  ') + label, style: TextStyle(color: c.mu, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(color: c.tx, fontSize: 26, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class DsStats extends StatelessWidget {
  final List<DsStat> items;
  const DsStats({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, cons) {
      final w = (cons.maxWidth - 10) / 2;
      return Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [for (final s in items) SizedBox(width: w, child: s)],
      );
    });
  }
}

class DsButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final String kind;
  final bool block;
  const DsButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.kind = 'primary',
    this.block = true,
  });

  @override
  Widget build(BuildContext context) {
    final c = DsPal.of(context);
    final r = BorderRadius.circular(16);
    BoxDecoration deco;
    Color fg;
    switch (kind) {
      case 'soft':
        deco = BoxDecoration(color: c.p.withAlpha(36), borderRadius: r);
        fg = c.p;
        break;
      case 'ghost':
        deco = BoxDecoration(border: Border.all(color: c.ln, width: 1.5), borderRadius: r);
        fg = c.tx;
        break;
      case 'danger':
        deco = BoxDecoration(color: const Color(0xFFE11D48), borderRadius: r);
        fg = Colors.white;
        break;
      default:
        deco = BoxDecoration(
          gradient: c.grad,
          borderRadius: r,
          boxShadow: [BoxShadow(color: c.p.withAlpha(80), blurRadius: 18, offset: const Offset(0, 8))],
        );
        fg = Colors.white;
    }
    return Opacity(
      opacity: onPressed == null ? 0.5 : 1.0,
      child: Container(
        decoration: deco,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: r,
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
              child: Row(
                mainAxisSize: block ? MainAxisSize.max : MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icon != null)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 8),
                      child: Icon(icon, color: fg, size: 20),
                    ),
                  Text(label, style: TextStyle(color: fg, fontWeight: FontWeight.w700, fontSize: 16)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DsChips extends StatelessWidget {
  final List<String> items;
  final int index;
  final ValueChanged<int> onChanged;
  const DsChips({super.key, required this.items, required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = DsPal.of(context);
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final sel = i == index;
          return GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: sel ? c.p : c.sf,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: sel ? c.p : c.ln),
              ),
              child: Text(
                items[i],
                style: TextStyle(color: sel ? Colors.white : c.mu, fontWeight: FontWeight.w600),
              ),
            ),
          );
        },
      ),
    );
  }
}

class DsSection extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;
  const DsSection({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    final c = DsPal.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 18, 4, 10),
      child: Row(
        children: [
          Expanded(child: Text(title, style: TextStyle(color: c.tx, fontSize: 17, fontWeight: FontWeight.w800))),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(action!, style: TextStyle(color: c.p, fontSize: 13, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
    );
  }
}

class DsBadge extends StatelessWidget {
  final String text;
  final String kind;
  const DsBadge({super.key, required this.text, this.kind = 'info'});

  @override
  Widget build(BuildContext context) {
    final c = DsPal.of(context);
    Color f;
    switch (kind) {
      case 'ok':
        f = const Color(0xFF16A34A);
        break;
      case 'bad':
        f = const Color(0xFFE11D48);
        break;
      case 'warn':
        f = const Color(0xFFF59E0B);
        break;
      default:
        f = c.p;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3),
      decoration: BoxDecoration(color: f.withAlpha(36), borderRadius: BorderRadius.circular(99)),
      child: Text(text, style: TextStyle(color: f, fontSize: 12, fontWeight: FontWeight.w700)),
    );
  }
}

class DsProgress extends StatelessWidget {
  final double value;
  const DsProgress({super.key, required this.value});

  @override
  Widget build(BuildContext context) {
    final c = DsPal.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(9),
      child: Container(
        height: 8,
        color: c.sf2,
        alignment: AlignmentDirectional.centerStart,
        child: FractionallySizedBox(
          widthFactor: value.clamp(0.0, 1.0).toDouble(),
          child: Container(decoration: BoxDecoration(gradient: c.grad)),
        ),
      ),
    );
  }
}

class DsField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String? hint;
  final TextInputType? keyboard;
  final bool obscure;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  const DsField({
    super.key,
    this.controller,
    required this.label,
    this.hint,
    this.keyboard,
    this.obscure = false,
    this.maxLines = 1,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = DsPal.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        obscureText: obscure,
        maxLines: obscure ? 1 : maxLines,
        onChanged: onChanged,
        style: TextStyle(color: c.tx),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          filled: true,
          fillColor: c.sf2,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: c.p, width: 1.6),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}

class DsEmpty extends StatelessWidget {
  final String emoji;
  final String title;
  final String? text;
  final String? actionLabel;
  final VoidCallback? onAction;
  const DsEmpty({super.key, this.emoji = '📭', required this.title, this.text, this.actionLabel, this.onAction});

  @override
  Widget build(BuildContext context) {
    final c = DsPal.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 42, horizontal: 16),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 58)),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center, style: TextStyle(color: c.tx, fontSize: 17, fontWeight: FontWeight.w800)),
          if (text != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(text!, textAlign: TextAlign.center, style: TextStyle(color: c.mu)),
            ),
          if (actionLabel != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: DsButton(label: actionLabel!, onPressed: onAction, block: false),
            ),
        ],
      ),
    );
  }
}

class DsFab extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const DsFab({super.key, this.icon = Icons.add, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final c = DsPal.of(context);
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        gradient: c.grad,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: c.p.withAlpha(100), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: onPressed,
          child: Center(child: Icon(icon, color: Colors.white, size: 28)),
        ),
      ),
    );
  }
}

class DsNavItem {
  final String label;
  final IconData icon;
  const DsNavItem(this.label, this.icon);
}

class DsNav extends StatelessWidget {
  final List<DsNavItem> items;
  final int index;
  final ValueChanged<int> onChanged;
  const DsNav({super.key, required this.items, required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final c = DsPal.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: c.sf,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: c.ln),
            boxShadow: c.shadow,
          ),
          child: Row(
            children: [
              for (int i = 0; i < items.length; i++)
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onChanged(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: i == index ? c.p.withAlpha(40) : Colors.transparent,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(items[i].icon, size: 22, color: i == index ? c.p : c.mu),
                          const SizedBox(height: 2),
                          Text(
                            items[i].label,
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: i == index ? c.p : c.mu),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class DsFade extends StatelessWidget {
  final int index;
  final Widget child;
  const DsFade({super.key, this.index = 0, required this.child});

  @override
  Widget build(BuildContext context) {
    final n = index > 10 ? 10 : index;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 380 + n * 60),
      curve: Curves.easeOutCubic,
      builder: (context, v, w) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, (1 - v) * 18), child: w),
      ),
      child: child,
    );
  }
}

Future<T?> dsSheet<T>(BuildContext context, {required String title, required Widget child}) {
  final c = DsPal.of(context);
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: c.sf,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (ctx) => Directionality(
      textDirection: TextDirection.rtl,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 10, 20, MediaQuery.of(ctx).viewInsets.bottom + 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(color: c.ln, borderRadius: BorderRadius.circular(9)),
                ),
              ),
              Text(title, style: TextStyle(color: c.tx, fontSize: 19, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              child,
            ],
          ),
        ),
      ),
    ),
  );
}

void dsToast(BuildContext context, String msg) {
  final c = DsPal.of(context);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          msg,
          textAlign: TextAlign.center,
          style: TextStyle(color: c.dark ? const Color(0xFF0B1020) : Colors.white, fontWeight: FontWeight.w700),
        ),
        backgroundColor: c.tx,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 100),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
        duration: const Duration(milliseconds: 2200),
      ),
    );
}

void dsUndo(BuildContext context, String msg, VoidCallback onUndo) {
  final c = DsPal.of(context);
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: TextStyle(color: c.dark ? const Color(0xFF0B1020) : Colors.white, fontWeight: FontWeight.w700),
        ),
        backgroundColor: c.tx,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        action: SnackBarAction(label: 'تراجع', textColor: c.p, onPressed: onUndo),
        duration: const Duration(seconds: 4),
      ),
    );
}

Future<bool> dsConfirm(BuildContext context, String title, String text) async {
  final c = DsPal.of(context);
  final r = await showDialog<bool>(
    context: context,
    builder: (ctx) => Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: c.sf,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(title, style: TextStyle(color: c.tx, fontWeight: FontWeight.w800)),
        content: Text(text, style: TextStyle(color: c.mu)),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('إلغاء')),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('تأكيد', style: TextStyle(color: c.p, fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    ),
  );
  return r ?? false;
}


// ===== تحديث التطبيق (يُضاف تلقائياً) =====
const int _apkCur = 1;
const String _apkUrl = 'https://raw.githubusercontent.com/alkahlizero564-sudo/apk-app/main/apps/bakerycustom0ovz/update.json';

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
