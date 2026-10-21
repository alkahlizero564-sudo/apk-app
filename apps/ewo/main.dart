import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class Task {
  String id;
  String title;
  String category;
  String priority;
  bool completed;
  String time;

  Task({
    required this.id,
    required this.title,
    required this.category,
    required this.priority,
    this.completed = false,
    required this.time,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مهامي اليومية',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        fontFamily: 'Roboto',
      ),
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const TasksHomePage(),
    );
  }
}

class TasksHomePage extends StatefulWidget {
  const TasksHomePage({super.key});

  @override
  State<TasksHomePage> createState() => _TasksHomePageState();
}

class _TasksHomePageState extends State<TasksHomePage> {
  final List<Task> _tasks = [];
  String _currentFilter = 'all';

  void _addTask(String title, String category, String priority) {
    setState(() {
      _tasks.insert(
        0,
        Task(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: title,
          category: category,
          priority: priority,
          time: TimeOfDay.now().format(context),
        ),
      );
    });
  }

  void _toggleTask(String id) {
    setState(() {
      for (var task in _tasks) {
        if (task.id == id) {
          task.completed = !task.completed;
        }
      }
    });
  }

  void _deleteTask(String id) {
    setState(() {
      _tasks.removeWhere((task) => task.id == id);
    });
  }

  List<Task> get _filteredTasks {
    if (_currentFilter == 'pending') {
      return _tasks.where((t) => !t.completed).toList();
    } else if (_currentFilter == 'completed') {
      return _tasks.where((t) => t.completed).toList();
    } else if (['personal', 'work', 'health', 'study'].contains(_currentFilter)) {
      return _tasks.where((t) => t.category == _currentFilter).toList();
    }
    return _tasks;
  }

  String _getCategoryName(String key) {
    switch (key) {
      case 'personal':
        return 'شخصي';
      case 'work':
        return 'العمل';
      case 'health':
        return 'الصحة';
      case 'study':
        return 'دراسة';
      default:
        return 'أخرى';
    }
  }

  Map<String, dynamic> _getPriorityDetails(String p) {
    if (p == 'high') {
      return {'label': 'أولوية عالية', 'color': Colors.red, 'bg': const Color(0xFFFEE2E2)};
    } else if (p == 'low') {
      return {'label': 'أولوية منخفضة', 'color': Colors.blue, 'bg': const Color(0xFFE0F2FE)};
    }
    return {'label': 'أولوية متوسطة', 'color': Colors.orange, 'bg': const Color(0xFFFEF3C7)};
  }

  void _showAddModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddTaskModal(onAdd: _addTask),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = _tasks.length;
    final completedCount = _tasks.where((t) => t.completed).length;
    final percent = total == 0 ? 0 : ((completedCount / total) * 100).round();

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x334F46E5),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                )
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'مهامي اليومية 📝',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'اليوم',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إنجاز اليوم: $completedCount من $total مهام',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: total == 0 ? 0 : completedCount / total,
                                backgroundColor: Colors.white.withOpacity(0.3),
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF34D399)),
                                minHeight: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '$percent%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                _buildFilterChip('الكل', 'all'),
                _buildFilterChip('قيد التنفيذ', 'pending'),
                _buildFilterChip('المكتملة', 'completed'),
                _buildFilterChip('شخصي', 'personal'),
                _buildFilterChip('العمل', 'work'),
                _buildFilterChip('الصحة', 'health'),
              ],
            ),
          ),

          // Task List
          Expanded(
            child: _filteredTasks.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.task_alt, size: 80, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text(
                          'لا توجد مهام هنا',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'أنت جاهز لقضاء يوم رائع ومنجز!',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: _filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = _filteredTasks[index];
                      final priorityInfo = _getPriorityDetails(task.priority);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: task.completed ? const Color(0xFFF1F5F9) : Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: InkWell(
                            onTap: () => _toggleTask(task.id),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: task.completed ? const Color(0xFF10B981) : Colors.transparent,
                                border: Border.all(
                                  color: task.completed ? const Color(0xFF10B981) : Colors.grey.shade400,
                                  width: 2,
                                ),
                              ),
                              child: task.completed
                                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                                  : null,
                            ),
                          ),
                          title: Text(
                            task.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              decoration: task.completed ? TextDecoration.lineThrough : null,
                              color: task.completed ? Colors.grey : Colors.black87,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0E7FF),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    _getCategoryName(task.category),
                                    style: const TextStyle(
                                      color: Color(0xFF4F46E5),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: priorityInfo['bg'],
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    priorityInfo['label'],
                                    style: TextStyle(
                                      color: priorityInfo['color'],
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Text(
                                  task.time,
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.grey),
                            onPressed: () => _deleteTask(task.id),
                          ),
                          onTap: () => _toggleTask(task.id),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _showAddModal,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 8,
              shadowColor: const Color(0x664F46E5),
            ),
            icon: const Icon(Icons.add, size: 22),
            label: const Text(
              'إضافة مهمة جديدة',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _currentFilter == value;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _currentFilter = value;
          });
        },
        selectedColor: const Color(0xFF4F46E5),
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade600,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(
            color: isSelected ? const Color(0xFF4F46E5) : Colors.grey.shade300,
          ),
        ),
      ),
    );
  }
}

class AddTaskModal extends StatefulWidget {
  final Function(String, String, String) onAdd;

  const AddTaskModal({super.key, required this.onAdd});

  @override
  State<AddTaskModal> createState() => _AddTaskModalState();
}

class _AddTaskModalState extends State<AddTaskModal> {
  final TextEditingController _controller = TextEditingController();
  String _selectedCategory = 'personal';
  String _selectedPriority = 'med';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        top: 24,
        left: 20,
        right: 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'إضافة مهمة جديدة',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFF1F5F9),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('عنوان المهمة', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'مثال: مراجعة التقرير اليومي...',
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Color(0xFF4F46E5)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text('التصنيف', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildOptionChip('شخصي', 'personal', _selectedCategory, (val) => setState(() => _selectedCategory = val)),
                  _buildOptionChip('العمل', 'work', _selectedCategory, (val) => setState(() => _selectedCategory = val)),
                  _buildOptionChip('الصحة', 'health', _selectedCategory, (val) => setState(() => _selectedCategory = val)),
                  _buildOptionChip('دراسة', 'study', _selectedCategory, (val) => setState(() => _selectedCategory = val)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text('الأولوية', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildOptionChip('🔥 عالي', 'high', _selectedPriority, (val) => setState(() => _selectedPriority = val)),
                  _buildOptionChip('⚡ متوسط', 'med', _selectedPriority, (val) => setState(() => _selectedPriority = val)),
                  _buildOptionChip('☕ منخفض', 'low', _selectedPriority, (val) => setState(() => _selectedPriority = val)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (_controller.text.trim().isEmpty) return;
                  widget.onAdd(_controller.text.trim(), _selectedCategory, _selectedPriority);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F46E5),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'حفظ المهمة',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionChip(String label, String value, String groupValue, Function(String) onSelected) {
    final isSelected = groupValue == value;
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) => onSelected(value),
        selectedColor: const Color(0xFFE0E7FF),
        backgroundColor: const Color(0xFFF8FAFC),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF4F46E5) : Colors.black87,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
    );
  }
}