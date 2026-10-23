import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

void main() {
  runApp(const ProMaxTasksApp());
}

// نموذج المهمة
class TaskItem {
  String id;
  String title;
  String category;
  DateTime date;
  bool isCompleted;
  int priority; // 1: عادي، 2: مهم، 3: عاجل جداً

  TaskItem({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    this.isCompleted = false,
    this.priority = 1,
  });
}

class ProMaxTasksApp extends StatefulWidget {
  const ProMaxTasksApp({super.key});

  @override
  State<ProMaxTasksApp> createState() => _ProMaxTasksAppState();
}

class _ProMaxTasksAppState extends State<ProMaxTasksApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    });
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UI/UX Pro Max مهامي',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1), // Indigo Pro Max
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.08),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            minimumSize: const Size.fromHeight(52),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF818CF8),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
        ),
        cardTheme: CardThemeData(
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1E293B),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFF818CF8), width: 2),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            minimumSize: const Size.fromHeight(52),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: MainHomeScreen(onToggleTheme: _toggleTheme, currentThemeMode: _themeMode),
    );
  }
}

class MainHomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode currentThemeMode;

  const MainHomeScreen({super.key, required this.onToggleTheme, required this.currentThemeMode});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;
  
  final List<TaskItem> _tasks = [
    TaskItem(id: '1', title: 'تصميم واجهات تطبيق Pro Max', category: 'عمل', date: DateTime.now(), priority: 3, isCompleted: true),
    TaskItem(id: '2', title: 'مراجعة الأكواد البرمجية مع الفريق', category: 'عمل', date: DateTime.now(), priority: 2),
    TaskItem(id: '3', title: 'ممارسة التمارين الرياضية الصباحية', category: 'شخصي', date: DateTime.now(), priority: 1),
    TaskItem(id: '4', title: 'قراءة 20 صفحة من الكتاب', category: 'تطوير', date: DateTime.now(), priority: 2),
  ];

  String _selectedFilter = 'الكل';

  void _addTask(TaskItem task) {
    setState(() {
      _tasks.insert(0, task);
    });
    HapticFeedback.lightImpact();
  }

  void _deleteTask(int index, TaskItem task) {
    setState(() {
      _tasks.removeAt(index);
    });
    HapticFeedback.mediumImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حذف المهمة: ${task.title}'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        action: SnackBarAction(
          label: 'تراجع',
          onPressed: () {
            setState(() {
              _tasks.insert(index, task);
            });
          },
        ),
      ),
    );
  }

  void _toggleTaskCompletion(TaskItem task) {
    setState(() {
      task.isCompleted = !task.isCompleted;
    });
    HapticFeedback.selectionClick();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTasks = _tasks.where((t) {
      if (_selectedFilter == 'الكل') return true;
      if (_selectedFilter == 'مكتملة') return t.isCompleted;
      if (_selectedFilter == 'غير مكتملة') return !t.isCompleted;
      return t.category == _selectedFilter;
    }).toList();

    final completedCount = _tasks.where((t) => t.isCompleted).length;
    final progress = _tasks.isEmpty ? 0.0 : completedCount / _tasks.length;

    final List<Widget> pages = [
      HomeDashboardTab(
        tasks: filteredTasks,
        allTasksCount: _tasks.length,
        completedCount: completedCount,
        progress: progress,
        selectedFilter: _selectedFilter,
        onFilterChanged: (filter) => setState(() => _selectedFilter = filter),
        onTaskToggle: _toggleTaskCompletion,
        onTaskDelete: _deleteTask,
        onToggleTheme: widget.onToggleTheme,
        currentThemeMode: widget.currentThemeMode,
      ),
      AnalyticsTab(tasks: _tasks),
      ProfileTab(completedCount: completedCount, totalCount: _tasks.length),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: pages[_currentIndex],
      ),
      floatingActionButton: _currentIndex == 0 ? FloatingActionButton.extended(
        onPressed: () => _showAddTaskBottomSheet(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('مهمة جديدة', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 4,
      ) : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
          HapticFeedback.selectionClick();
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.task_alt_outlined),
            selectedIcon: Icon(Icons.task_alt),
            label: 'المهام',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart),
            label: 'الإحصائيات',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'حسابي',
          ),
        ],
      ),
    );
  }

  void _showAddTaskBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => AddTaskSheet(onAdd: _addTask),
    );
  }
}

// تبويب الشاشة الرئيسية والمهام
class HomeDashboardTab extends StatelessWidget {
  final List<TaskItem> tasks;
  final int allTasksCount;
  final int completedCount;
  final double progress;
  final String selectedFilter;
  final Function(String) onFilterChanged;
  final Function(TaskItem) onTaskToggle;
  final Function(int, TaskItem) onTaskDelete;
  final VoidCallback onToggleTheme;
  final ThemeMode currentThemeMode;

  const HomeDashboardTab({
    super.key,
    required this.tasks,
    required this.allTasksCount,
    required this.completedCount,
    required this.progress,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.onTaskToggle,
    required this.onTaskDelete,
    required this.onToggleTheme,
    required this.currentThemeMode,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          expandedHeight: 220,
          pinned: true,
          actions: [
            IconButton(
              icon: Icon(currentThemeMode == ThemeMode.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
              onPressed: onToggleTheme,
            ),
            const SizedBox(width: 8),
          ],
          flexibleSpace: FlexibleSpaceBar(
            titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            title: const Text(
              'مهامي اليومية 🚀',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            background: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.tertiary],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: -50,
                    top: -50,
                    child: CircleAvatar(
                      radius: 80,
                      backgroundColor: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // بطاقة الإنجاز الزجاجية الفخمة
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [colorScheme.primaryContainer, colorScheme.secondaryContainer.withOpacity(0.5)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.primary.withOpacity(0.15),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'إنجاز اليوم',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$completedCount من $allTasksCount مهام مكتملة',
                              style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
                            ),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 10,
                                backgroundColor: colorScheme.surface.withOpacity(0.5),
                                valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      SizedBox(
                        width: 70,
                        height: 70,
                        child: CustomPaint(
                          painter: CircleProgressPainter(progress: progress, color: colorScheme.primary),
                          child: Center(
                            child: Text(
                              '${(progress * 100).toInt()}%',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // الفلاتر الأفقية
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['الكل', 'غير مكتملة', 'مكتملة', 'عمل', 'شخصي', 'تطوير'].map((filter) {
                      final isSelected = selectedFilter == filter;
                      return Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: ChoiceChip(
                          label: Text(filter),
                          selected: isSelected,
                          onSelected: (_) => onFilterChanged(filter),
                          selectedColor: colorScheme.primary,
                          labelStyle: TextStyle(
                            color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'المهام الحالية',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        tasks.isEmpty
            ? SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline_rounded, size: 80, color: colorScheme.primary.withOpacity(0.5)),
                      const SizedBox(height: 16),
                      const Text(
                        'لا توجد مهام هنا حالياً!',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'استمتع بيومك أو أضف مهمة جديدة للإنجاز',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              )
            : SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final task = tasks[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                      child: Dismissible(
                        key: Key(task.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 28),
                        ),
                        onDismissed: (_) => onTaskDelete(index, task),
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 200 + (index * 50)),
                          builder: (context, value, child) {
                            return Transform.translate(
                              offset: Offset(0, 30 * (1 - value)),
                              child: Opacity(opacity: value, child: child),
                            );
                          },
                          child: Card(
                            margin: EdgeInsets.zero,
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              leading: Checkbox(
                                value: task.isCompleted,
                                onChanged: (_) => onTaskToggle(task),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                              title: Text(
                                task.title,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                  color: task.isCompleted ? colorScheme.onSurfaceVariant : colorScheme.onSurface,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primaryContainer.withOpacity(0.5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        task.category,
                                        style: TextStyle(fontSize: 12, color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (task.priority == 3)
                                      const Text('🔥 عاجل', style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  childCount: tasks.length,
                ),
              ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

// رسام دائري للإحصائيات السريعة
class CircleProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircleProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.2)
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 4;

    canvas.drawCircle(center, radius, paint);

    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = 8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// نموذج إضافة مهمة جديدة بداخل Modal Bottom Sheet
class AddTaskSheet extends StatefulWidget {
  final Function(TaskItem) onAdd;

  const AddTaskSheet({super.key, required this.onAdd});

  @override
  State<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<AddTaskSheet> {
  final _controller = TextEditingController();
  String _category = 'عمل';
  final int _priority = 1;
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _isValid = _controller.text.trim().isNotEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'إضافة مهمة جديدة ✨',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'ما الذي ترغب في إنجازه اليوم؟',
            ),
          ),
          const SizedBox(height: 20),
          const Text('التصنيف', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'عمل', label: Text('عمل'), icon: Icon(Icons.work_outline)),
              ButtonSegment(value: 'شخصي', label: Text('شخصي'), icon: Icon(Icons.person_outline)),
              ButtonSegment(value: 'تطوير', label: Text('تطوير'), icon: Icon(Icons.trending_up)),
            ],
            selected: {_category},
            onSelectionChanged: (val) => setState(() => _category = val.first),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _isValid
                ? () {
                    widget.onAdd(
                      TaskItem(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        title: _controller.text.trim(),
                        category: _category,
                        date: DateTime.now(),
                        priority: _priority,
                      ),
                    );
                    Navigator.pop(context);
                  }
                : null,
            child: const Text('حفظ المهمة'),
          ),
        ],
      ),
    );
  }
}

// تبويب الإحصائيات
class AnalyticsTab extends StatelessWidget {
  final List<TaskItem> tasks;

  const AnalyticsTab({super.key, required this.tasks});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final completed = tasks.where((t) => t.isCompleted).length;
    final total = tasks.length;

    return Scaffold(
      appBar: AppBar(title: const Text('إحصائيات الإنجاز 📊', style: TextStyle(fontWeight: FontWeight.bold))),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('إجمالي المهام', '$total', colorScheme.primary),
                    _buildStatItem('المكتملة', '$completed', Colors.green),
                    _buildStatItem('المتبقية', '${total - completed}', Colors.orange),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('تحليل الأداء الأسبوعي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            _buildBar('السبت', 0.8, colorScheme),
                            _buildBar('الأحد', 0.5, colorScheme),
                            _buildBar('الإثنين', 0.9, colorScheme),
                            _buildBar('الثلاثاء', 0.7, colorScheme),
                            _buildBar('الأربعاء', 1.0, colorScheme),
                            _buildBar('الخميس', 0.4, colorScheme),
                            _buildBar('الجمعة', 0.6, colorScheme),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String title, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(title, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildBar(String day, double heightFactor, ColorScheme colorScheme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 24,
          height: 140 * heightFactor,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.primary, colorScheme.tertiary],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        const SizedBox(height: 8),
        Text(day, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// تبويب الملف الشخصي
class ProfileTab extends StatelessWidget {
  final int completedCount;
  final int totalCount;

  const ProfileTab({super.key, required this.completedCount, required this.totalCount});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('حسابي الشخصي 👤', style: TextStyle(fontWeight: FontWeight.bold))),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFF6366F1),
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text('مستخدم Pro Max', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('مطور تطبيقات Flutter محترف', style: TextStyle(color: colorScheme.onSurfaceVariant)),
            const SizedBox(height: 32),
            Card(
              child: ListTile(
                leading: const Icon(Icons.workspace_premium, color: Colors.amber, size: 30),
                title: const Text('نسخة Pro Max مفعلة', style: TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('جميع المميزات المتقدمة متاحة الآن'),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.task_alt, color: Colors.green, size: 30),
                title: const Text('إجمالي المهام المنجزة', style: TextStyle(fontWeight: FontWeight.bold)),
                trailing: Text('$completedCount / $totalCount', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}