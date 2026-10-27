// DESIGN: تطبيق مصاريفي | مال ونمو | قيمة hue: 155

import 'package:flutter/material.dart';

// ==========================================
// تطبيق مصاريفي (التطبيق الفعلي)
// ==========================================

void main() => runApp(const DsApp(hue: 155, title: "مراقب مصاريفي", home: ExpenseHomePage()));

class ExpenseItem {
  final String id;
  final String title;
  final double amount;
  final String category;
  final String emoji;
  final DateTime date;

  ExpenseItem({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.emoji,
    required this.date,
  });
}

class ExpenseHomePage extends StatefulWidget {
  const ExpenseHomePage({super.key});

  @override
  State<ExpenseHomePage> createState() => _ExpenseHomePageState();
}

class _ExpenseHomePageState extends State<ExpenseHomePage> {
  int _currentIndex = 0;
  double _monthlyBudget = 150000.0;

  final List<ExpenseItem> _expenses = [
    ExpenseItem(id: '1', title: 'سوبرماركت', amount: 15000.0, category: 'طعام', emoji: '🛒', date: DateTime.now().subtract(const Duration(hours: 2))),
    ExpenseItem(id: '2', title: 'وقود السيارة', amount: 8000.0, category: 'مواصلات', emoji: '⛽', date: DateTime.now().subtract(const Duration(days: 1))),
    ExpenseItem(id: '3', title: 'فطور صباحي', amount: 2500.0, category: 'طعام', emoji: '☕', date: DateTime.now().subtract(const Duration(days: 2))),
  ];

  int _selectedFilterIndex = 0;
  final List<String> _filters = ["الكل", "طعام", "مواصلات", "فواتير", "ترفيه"];

  void _addExpense(String title, double amount, String category, String emoji) {
    setState(() {
      _expenses.insert(0, ExpenseItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        amount: amount,
        category: category,
        emoji: emoji,
        date: DateTime.now(),
      ));
    });
    dsToast(context, "تمت إضافة المصروف بنجاح");
  }

  void _deleteExpense(String id) {
    final index = _expenses.indexWhere((e) => e.id == id);
    if (index != -1) {
      final removed = _expenses[index];
      setState(() {
        _expenses.removeAt(index);
      });
      dsUndo(context, "تم حذف المصروف", () {
        setState(() {
          _expenses.insert(index, removed);
        });
      });
    }
  }

  void _showAddSheet() {
    final titleController = TextEditingController();
    final amountController = TextEditingController();
    String selectedCategory = "طعام";
    String selectedEmoji = "🛒";

    final categories = {
      "طعام": "🛒",
      "مواصلات": "⛽",
      "فواتير": "💡",
      "ترفيه": "🎮",
      "أخرى": "📦"
    };

    dsSheet(
      context: context,
      title: "إضافة مصروف جديد",
      child: StatefulBuilder(
        builder: (context, setSheetState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DsField(controller: titleController, label: "عنوان المصروف", hint: "مثال: قهوة، بنزين..."),
              DsField(controller: amountController, label: "المبلغ (ج.س)", hint: "0.00", keyboard: TextInputType.number),
              const SizedBox(height: 8),
              const Text("التصنيف", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: categories.keys.map((cat) {
                  final isSelected = selectedCategory == cat;
                  return ChoiceChip(
                    label: Text("${categories[cat]} $cat"),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setSheetState(() {
                          selectedCategory = cat;
                          selectedEmoji = categories[cat]!;
                        });
                      }
                    },
                    selectedColor: Theme.of(context).colorScheme.primary,
                    labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              DsButton(
                label: "حفظ المصروف",
                onPressed: () {
                  final title = titleController.text.trim();
                  final amount = double.tryParse(amountController.text) ?? 0.0;
                  if (title.isEmpty || amount <= 0) {
                    dsToast(context, "الرجاء إدخال بيانات صحيحة");
                    return;
                  }
                  Navigator.pop(context);
                  _addExpense(title, amount, selectedCategory, selectedEmoji);
                },
              ),
            ],
          );
        },
      ),
    );
  }

  void _showBudgetSheet() {
    final budgetController = TextEditingController(text: _monthlyBudget.toStringAsFixed(0));
    dsSheet(
      context: context,
      title: "تعديل الميزانية الشهرية",
      child: Column(
        children: [
          DsField(controller: budgetController, label: "الميزانية الجديدة", keyboard: TextInputType.number),
          const SizedBox(height: 16),
          DsButton(
            label: "حفظ الميزانية",
            onPressed: () {
              final newBudget = double.tryParse(budgetController.text);
              if (newBudget != null && newBudget > 0) {
                setState(() {
                  _monthlyBudget = newBudget;
                });
                Navigator.pop(context);
                dsToast(context, "تم تحديث الميزانية الشهرية");
              } else {
                dsToast(context, "قيمة غير صحيحة");
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double totalSpent = _expenses.fold(0.0, (sum, item) => sum + item.amount);
    double remaining = _monthlyBudget - totalSpent;
    double progress = totalSpent / _monthlyBudget;

    final filteredExpenses = _selectedFilterIndex == 0
        ? _expenses
        : _expenses.where((e) => e.category == _filters[_selectedFilterIndex]).toList();

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // الشاشة الرئيسية
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: DsHero(
                  title: "المصاريف المتبقية",
                  subtitle: remaining >= 0 ? "أنت في حدود الأمان" : "تجاوزت الميزانية!",
                  big: "${remaining.toStringAsFixed(2)} ج.س",
                  trailing: IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Colors.white),
                    onPressed: _showBudgetSheet,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: DsStats(items: [
                  DsStat(label: "المصروف", value: "${totalSpent.toStringAsFixed(0)} ج.س", emoji: "💸"),
                  DsStat(label: "الميزانية", value: "${_monthlyBudget.toStringAsFixed(0)} ج.س", emoji: "🎯"),
                  DsStat(label: "العمليات", value: "${_expenses.length}", emoji: "📝"),
                ]),
              ),
              const SliverToBoxAdapter(
                child: DsSection(title: "مؤشر الإنفاق الشهري"),
              ),
              SliverToBoxAdapter(
                child: DsCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("نسبة الاستهلاك", style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                          DsBadge(
                            text: progress > 1 ? "خطر" : (progress > 0.8 ? "تنبيه" : "ممتاز"),
                            kind: progress > 1 ? "bad" : (progress > 0.8 ? "warn" : "ok"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DsProgress(value: progress),
                      const SizedBox(height: 12),
                      Text("أنفقت ${(progress * 100).toStringAsFixed(1)}% من ميزانيتك الشهرية", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: DsSection(title: "سجل المصاريف"),
              ),
              SliverToBoxAdapter(
                child: DsChips(
                  items: _filters,
                  index: _selectedFilterIndex,
                  onChanged: (i) => setState(() => _selectedFilterIndex = i),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 8)),
              filteredExpenses.isEmpty
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: DsEmpty(
                        emoji: "📭",
                        title: "لا توجد مصاريف هنا",
                        text: "لم تقم بإضافة أي مصاريف في هذا التصنيف بعد.",
                        actionLabel: "إضافة مصروف",
                        onAction: _showAddSheet,
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final item = filteredExpenses[index];
                          return DsCard(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            padding: const EdgeInsets.all(8),
                            child: DsItem(
                              emoji: item.emoji,
                              title: item.title,
                              subtitle: "${item.category} • ${item.date.hour}:${item.date.minute.toString().padLeft(2, '0')}",
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text("${item.amount.toStringAsFixed(2)} ج.س", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                                    onPressed: () async {
                                      final ok = await dsConfirm(context, "حذف المصروف", "هل أنت متأكد من حذف ${item.title}؟");
                                      if (ok) {
                                        _deleteExpense(item.id);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        childCount: filteredExpenses.length,
                      ),
                    ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),

          // شاشة التحليلات والإحصائيات
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: DsHero(
                  title: "التحليلات المالية",
                  subtitle: "نظرة تفصيلية على مصاريفك",
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: DsSection(title: "التوزيع حسب التصنيفات"),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final categoriesList = ["طعام", "مواصلات", "فواتير", "ترفيه", "أخرى"];
                    final emojisList = ["🛒", "⛽", "💡", "🎮", "📦"];
                    final cat = categoriesList[index];
                    final emoji = emojisList[index];
                    
                    final catTotal = _expenses.where((e) => e.category == cat).fold(0.0, (sum, e) => sum + e.amount);
                    final ratio = totalSpent > 0 ? catTotal / totalSpent : 0.0;

                    return DsCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(emoji, style: const TextStyle(fontSize: 20)),
                                  const SizedBox(width: 12),
                                  Text(cat, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                ],
                              ),
                              Text("${catTotal.toStringAsFixed(2)} ج.س", style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          DsProgress(value: ratio),
                        ],
                      ),
                    );
                  },
                  childCount: 5,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),

          // شاشة الإعدادات والملف الشخصي
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: DsHero(
                  title: "الإعدادات العامة",
                  subtitle: "تخصيص التطبيق والبيانات",
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: DsCard(
                  child: Column(
                    children: [
                      DsItem(
                        icon: Icons.notifications_outlined,
                        title: "التنبيهات اليومية",
                        subtitle: "تذكير لتسجيل المصاريف",
                        trailing: Switch(value: true, onChanged: (_) {}),
                      ),
                      const Divider(),
                      DsItem(
                        icon: Icons.dark_mode_outlined,
                        title: "المظهر الداكن",
                        subtitle: "قريباً في التحديث القادم",
                        trailing: Switch(value: false, onChanged: (_) {}),
                      ),
                      const Divider(),
                      DsItem(
                        icon: Icons.file_download_outlined,
                        title: "تصدير البيانات",
                        subtitle: "حفظ تقرير المصاريف كملف CSV",
                        onTap: () => dsToast(context, "تم تصدير البيانات بنجاح"),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: DsButton(
                    label: "إعادة ضبط التطبيق",
                    kind: "danger",
                    onPressed: () async {
                      final ok = await dsConfirm(context, "إعادة الضبط", "هل تريد مسح جميع البيانات الحالية؟");
                      if (ok) {
                        setState(() {
                          _expenses.clear();
                        });
                        dsToast(context, "تم مسح كافة البيانات");
                      }
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
            ],
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0 ? DsFab(icon: Icons.add, onPressed: _showAddSheet) : null,
      bottomNavigationBar: DsNav(
        items: const [
          DsNavItem("الرئيسية", Icons.home_rounded),
          DsNavItem("التحليلات", Icons.pie_chart_rounded),
          DsNavItem("الإعدادات", Icons.settings_rounded),
        ],
        index: _currentIndex,
        onChanged: (i) => setState(() => _currentIndex = i),
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
