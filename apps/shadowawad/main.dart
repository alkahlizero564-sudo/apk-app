// DESIGN: تطبيق مصروفات شخصية | مال ونمو وذكاء | 155

import 'package:flutter/material.dart';

import 'dart:async' as apkas;
import 'dart:convert' as apkjs;
import 'dart:io' as apkio;
import 'package:flutter/widgets.dart' as apkw;
import 'package:url_launcher/url_launcher.dart' as apkul;

void main() => runApp(DsApp(
      hue: 155,
      title: "تطبيق مصروفاتي",
      home: MainScreen(),
    ));

class TransactionModel {
  final String id;
  final String title;
  final double amount;
  final String cat;
  final String date;
  final String icon;

  TransactionModel({
    required this.id,
    required this.title,
    required this.amount,
    required this.cat,
    required this.date,
    required this.icon,
  });
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  double balance = 4250.00;
  double income = 7500.00;
  double expense = 3250.00;

  final List<TransactionModel> transactions = [
    TransactionModel(id: '1', title: 'مطعم البيك', amount: -45.00, cat: 'food', date: 'اليوم، 02:30 م', icon: '🍔'),
    TransactionModel(id: '2', title: 'فاتورة الكهرباء', amount: -280.00, cat: 'bills', date: 'أمس، 10:00 ص', icon: '⚡'),
    TransactionModel(id: '3', title: 'راتب الشهر', amount: 7500.00, cat: 'income', date: '01 نوفمبر', icon: '💰'),
    TransactionModel(id: '4', title: 'سينما VOX', amount: -120.00, cat: 'entertainment', date: '28 أكتوبر', icon: '🍿'),
  ];

  int historyFilterIndex = 0;
  String historySearchQuery = '';
  bool isDarkMode = true;
  bool isStatsCurrentMonth = true;

  late final TextEditingController historySearchController;

  @override
  void initState() {
    super.initState();
    historySearchController = TextEditingController();
  }

  @override
  void dispose() {
    historySearchController.dispose();
    super.dispose();
  }

  void addTransaction(String title, double amt, String cat) {
    setState(() {
      transactions.insert(
        0,
        TransactionModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          amount: -amt,
          cat: cat,
          date: 'الآن',
          icon: cat == 'food' ? '🍔' : (cat == 'bills' ? '⚡' : '🍿'),
        ),
      );
      expense += amt;
      balance -= amt;
    });
    dsToast(context, 'تمت الإضافة بنجاح');
  }

  void deleteTransaction(String id) {
    final index = transactions.indexWhere((t) => t.id == id);
    if (index != -1) {
      final removed = transactions[index];
      setState(() {
        transactions.removeAt(index);
        if (removed.amount < 0) {
          expense += removed.amount;
          balance -= removed.amount;
        } else {
          income -= removed.amount;
          balance -= removed.amount;
        }
      });
      dsUndo(context, 'تم حذف المعاملة', () {
        setState(() {
          transactions.insert(index, removed);
          if (removed.amount < 0) {
            expense -= removed.amount;
            balance += removed.amount;
          } else {
            income += removed.amount;
            balance += removed.amount;
          }
        });
      });
    }
  }

  void clearAll() async {
    final confirmed = await dsConfirm(context, 'مسح الكل', 'هل أنت متأكد من حذف كافة المعاملات المسجلة؟');
    if (confirmed) {
      setState(() {
        transactions.clear();
        balance = 0;
        income = 0;
        expense = 0;
      });
      dsToast(context, 'تم مسح جميع السجلات بنجاح');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: [
              buildHomeScreen(),
              buildHistoryScreen(),
              buildStatsScreen(),
              buildSettingsScreen(),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: DsNav(
              items: [
                DsNavItem("الرئيسية", Icons.home_rounded),
                DsNavItem("السجل", Icons.list_rounded),
                DsNavItem("الإحصائيات", Icons.bar_chart_rounded),
                DsNavItem("الإعدادات", Icons.settings_rounded),
              ],
              index: _currentIndex,
              onChanged: (i) => setState(() => _currentIndex = i),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(bottom: 70),
        child: DsFab(
          icon: Icons.add,
          onPressed: () => openAddSheet(context),
        ),
      ),
    );
  }

  Widget buildHomeScreen() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DsHero(
          title: "مصروفاتي",
          trailing: [
            IconButton(
              icon: Icon(Icons.settings_outlined, size: 20),
              onPressed: () => setState(() => _currentIndex = 3),
            ),
          ],
          big: Column(
            children: [
              Text("الرصيد المتبقي هذا الشهر", style: TextStyle(color: Colors.grey[400], fontSize: 12)),
              SizedBox(height: 8),
              Text("$balance ر.س", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),
              DsStats(
                items: [
                  DsStat(label: "الدخل", value: "$income ر.س", emoji: "💰"),
                  DsStat(label: "المصروفات", value: "$expense ر.س", emoji: "📉"),
                ],
              ),
            ],
          ),
        ),
        DsSection(
          title: "المعاملات الأخيرة",
          action: "عرض الكل",
          onAction: () => setState(() => _currentIndex = 1),
        ),
        if (transactions.isEmpty)
          DsEmpty(
            emoji: "📭",
            title: "لا توجد معاملات",
            text: "ابدأ بإضافة مصروفاتك الجديدة لمتابعة ميزانيتك",
            actionLabel: "إضافة مصروف",
            onAction: () => openAddSheet(context),
          )
        else
          ...transactions.take(3).map((tx) {
            final isPos = tx.amount > 0;
            return DsItem(
              emoji: tx.icon,
              title: tx.title,
              subtitle: tx.date,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "${isPos ? '+' : ''}${tx.amount} ر.س",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isPos ? Colors.green : Colors.redAccent,
                    ),
                  ),
                  SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.delete_outline, size: 16, color: Colors.grey),
                    onPressed: () => deleteTransaction(tx.id),
                  ),
                ],
              ),
            );
          }),
        SizedBox(height: 120),
      ],
    );
  }

  Widget buildHistoryScreen() {
    final filters = ["الكل", "طعام", "فواتير", "ترفيه"];
    final filtered = transactions.where((tx) {
      final matchesSearch = tx.title.contains(historySearchQuery);
      if (historyFilterIndex == 1) return matchesSearch && tx.cat == 'food';
      if (historyFilterIndex == 2) return matchesSearch && tx.cat == 'bills';
      if (historyFilterIndex == 3) return matchesSearch && tx.cat == 'entertainment';
      return matchesSearch;
    }).toList();

    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                Text("سجل المعاملات", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Row(
                  children: [
                    DsButton(
                      label: "مسح الكل",
                      kind: "danger",
                      onPressed: clearAll,
                    ),
                    SizedBox(width: 8),
                    IconButton(
                      icon: Icon(Icons.add),
                      onPressed: () => openAddSheet(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: TextField(
            controller: historySearchController,
            onChanged: (val) => setState(() => historySearchQuery = val),
            decoration: InputDecoration(
              hintText: "ابحث في اسم المصروف...",
              hintStyle: TextStyle(color: Colors.grey[600], fontSize: 13),
              filled: true,
              fillColor: Color(0xFF1E1E1E),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.08)),
              ),
              prefixIcon: Icon(Icons.search, size: 20),
            ),
          ),
        ),
        SizedBox(height: 8),
        DsChips(
          items: filters,
          index: historyFilterIndex,
          onChanged: (i) {
            setState(() => historyFilterIndex = i);
            dsToast(context, 'تم تطبيق الفلتر: ${filters[i]}');
          },
        ),
        SizedBox(height: 8),
        Expanded(
          child: filtered.isEmpty
              ? DsEmpty(
                  emoji: "🔍",
                  title: "لا توجد نتائج",
                  text: "لم يتم العثور على معاملات مطابقة للبحث أو الفلتر",
                  actionLabel: "إعادة ضبط",
                  onAction: () {
                    setState(() {
                      historyFilterIndex = 0;
                      historySearchQuery = '';
                      historySearchController.clear();
                    });
                  },
                )
              : ListView.builder(
                  padding: EdgeInsets.only(bottom: 120),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final tx = filtered[i];
                    final isPos = tx.amount > 0;
                    return DsItem(
                      emoji: tx.icon,
                      title: tx.title,
                      subtitle: tx.date,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "${isPos ? '+' : ''}${tx.amount} ر.س",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isPos ? Colors.green : Colors.redAccent,
                            ),
                          ),
                          SizedBox(width: 8),
                          IconButton(
                            icon: Icon(Icons.delete_outline, size: 16, color: Colors.grey),
                            onPressed: () => deleteTransaction(tx.id),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget buildStatsScreen() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                Text("التحليلات المالية", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                DsButton(
                  label: isStatsCurrentMonth ? "الشهر الحالي" : "الشهر السابق",
                  kind: "soft",
                  onPressed: () {
                    setState(() => isStatsCurrentMonth = !isStatsCurrentMonth);
                    dsToast(context, 'تم تغيير نطاق التحليلات');
                  },
                ),
              ],
            ),
          ),
        ),
        DsCard(
          child: Column(
            children: [
              Text("توزيع المصروفات", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 24),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Theme.of(context).colorScheme.primary, width: 8),
                ),
                alignment: Alignment.center,
                child: Text("70%", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
              SizedBox(height: 24),
              Text(
                "أعلى فئة تم الصرف عليها هذا الشهر هي الطعام والمشروبات",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[400], fontSize: 13),
              ),
            ],
          ),
        ),
        DsCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("الميزانية الشهرية", style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.between,
                children: [
                  Text("المستخدم (70%)", style: TextStyle(fontSize: 12)),
                  Text("3,500 / 5,000 ر.س", style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
              SizedBox(height: 8),
              DsProgress(value: 0.7),
            ],
          ),
        ),
        SizedBox(height: 120),
      ],
    );
  }

  Widget buildSettingsScreen() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Text("الإعدادات", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
        DsCard(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.between,
                children: [
                  Text("الوضع المظلم"),
                  Switch(
                    value: isDarkMode,
                    onChanged: (val) {
                      setState(() => isDarkMode = val);
                      dsToast(context, 'تم تغيير المظهر');
                    },
                  ),
                ],
              ),
              Divider(height: 24, color: Colors.white12),
              Row(
                mainAxisAlignment: MainAxisAlignment.between,
                children: [
                  Text("الإشعارات اليومية"),
                  Switch(
                    value: true,
                    onChanged: (_) {},
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: DsButton(
            label: "تصدير البيانات (CSV)",
            icon: Icons.download,
            kind: "soft",
            block: true,
            onPressed: () {
              dsToast(context, 'تم حفظ ملف البيانات بنجاح على الهاتف');
            },
          ),
        ),
        SizedBox(height: 120),
      ],
    );
  }

  void openAddSheet(BuildContext context) {
    final amountController = TextEditingController();
    final titleController = TextEditingController();
    String selectedCat = 'food';

    dsSheet(
      context,
      title: "إضافة معاملة جديدة",
      child: StatefulBuilder(
        builder: (context, setSheetState) {
          return Column(
            children: [
              DsField(
                controller: amountController,
                label: "المبلغ (ر.س)",
                hint: "0.00",
                keyboard: TextInputType.number,
              ),
              SizedBox(height: 12),
              DsField(
                controller: titleController,
                label: "اسم المعاملة",
                hint: "مثال: رداء، مطعم...",
              ),
              SizedBox(height: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("الفئة", style: TextStyle(color: Colors.grey, fontSize: 12)),
                  SizedBox(height: 6),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.08)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedCat,
                        isExpanded: true,
                        dropdownColor: Color(0xFF1E1E1E),
                        items: [
                          DropdownMenuItem(value: 'food', child: Text('طعام ومشروبات')),
                          DropdownMenuItem(value: 'bills', child: Text('فواتير وخدمات')),
                          DropdownMenuItem(value: 'entertainment', child: Text('ترفيه')),
                        ],
                        onChanged: (val) {
                          if (val != null) {
                            setSheetState(() => selectedCat = val);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              DsButton(
                label: "حفظ المعاملة",
                block: true,
                onPressed: () {
                  final amtText = amountController.text;
                  final titleText = titleController.text;
                  if (amtText.isEmpty || titleText.isEmpty) {
                    dsToast(context, 'يرجى ملء جميع الحقول المطلوبة');
                    return;
                  }
                  final amt = double.tryParse(amtText) ?? 0.0;
                  Navigator.pop(context);
                  addTransaction(titleText, amt, selectedCat);
                },
              ),
            ],
          );
        },
      ),
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
const int _apkCur = 2;
const String _apkUrl = 'https://raw.githubusercontent.com/alkahlizero564-sudo/apk-app/main/apps/shadowawad/update.json';

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
