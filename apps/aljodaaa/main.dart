import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';

void main() {
  runApp(const SuperMarketApp());
}

// Data Models
class Product {
  final String id;
  final String name;
  final double price;
  final String category;
  final String image;
  final double rating;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.image,
    required this.rating,
  });
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class SuperMarketApp extends StatefulWidget {
  const SuperMarketApp({super.key});

  @override
  State<SuperMarketApp> createState() => _SuperMarketAppState();
}

class _SuperMarketAppState extends State<SuperMarketApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سوبر ماركت برو',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF2563EB),
          secondary: const Color(0xFF38BDF8),
          surface: const Color(0xFFF5F7FB),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.08),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          color: Colors.white,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF2563EB),
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 2,
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.dark,
          primary: const Color(0xFF38BDF8),
          surface: const Color(0xFF0F172A),
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardTheme: CardThemeData(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          color: const Color(0xFF1E293B),
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
            borderSide: BorderSide(color: Colors.grey.shade800),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(color: Color(0xFF38BDF8), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF38BDF8),
            foregroundColor: Colors.black,
            minimumSize: const Size(double.infinity, 54),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
      home: AuthScreen(onToggleTheme: _toggleTheme, currentTheme: _themeMode),
    );
  }
}

// -----------------------------------------------------------------------------
// AUTH SCREEN (Login & Register)
// -----------------------------------------------------------------------------
class AuthScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode currentTheme;

  const AuthScreen({super.key, required this.onToggleTheme, required this.currentTheme});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  void _submit() {
    if (_formKey.currentState!.validate()) {
      HapticFeedback.lightImpact();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            onToggleTheme: widget.onToggleTheme,
            currentTheme: widget.currentTheme,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '🛒 متجر النخبة',
                      style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: Icon(widget.currentTheme == ThemeMode.light ? Icons.dark_mode : Icons.light_mode, color: Colors.white),
                      onPressed: widget.onToggleTheme,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: Colors.white.withOpacity(0.2)),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  _isLogin ? 'أهلاً بك مجدداً!' : 'حساب جديد',
                                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _isLogin ? 'سجل دخولك لمتابعة التسوق' : 'انضم إلينا واحصل على عروض مميزة',
                                  style: TextStyle(color: Colors.grey.shade600),
                                ),
                                const SizedBox(height: 24),
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 300),
                                  child: !_isLogin
                                      ? Column(
                                          key: const ValueKey('nameField'),
                                          children: [
                                            TextFormField(
                                              controller: _nameController,
                                              decoration: const InputDecoration(
                                                labelText: 'الاسم الكامل',
                                                prefixIcon: Icon(Icons.person_outline),
                                              ),
                                              validator: (val) => val!.isEmpty ? 'الرجاء إدخال الاسم' : null,
                                            ),
                                            const SizedBox(height: 16),
                                          ],
                                        )
                                      : const SizedBox.shrink(key: ValueKey('emptyName')),
                                ),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: const InputDecoration(
                                    labelText: 'البريد الإلكتروني',
                                    prefixIcon: Icon(Icons.email_outlined),
                                  ),
                                  validator: (val) => val!.contains('@') ? null : 'البريد الإلكتروني غير صحيح',
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: true,
                                  decoration: const InputDecoration(
                                    labelText: 'كلمة المرور',
                                    prefixIcon: Icon(Icons.lock_outline),
                                  ),
                                  validator: (val) => val!.length >= 6 ? null : 'كلمة المرور قصيرة جداً',
                                ),
                                const SizedBox(height: 24),
                                FilledButton(
                                  onPressed: _submit,
                                  child: Text(_isLogin ? 'تسجيل الدخول' : 'إنشاء الحساب'),
                                ),
                                const SizedBox(height: 16),
                                TextButton(
                                  onPressed: () => setState(() => _isLogin = !_isLogin),
                                  child: Text(
                                    _isLogin ? 'ليس لديك حساب؟ انضم إلينا' : 'لديك حساب بالفعل؟ سجل دخولك',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
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

// -----------------------------------------------------------------------------
// HOME SCREEN & TABS
// -----------------------------------------------------------------------------
class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode currentTheme;

  const HomeScreen({super.key, required this.onToggleTheme, required this.currentTheme});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final List<CartItem> _cart = [];

  final List<Product> _products = [
    Product(id: '1', name: 'تفاح طازج أحمر', price: 15.0, category: 'فواكه', image: '🍎', rating: 4.8),
    Product(id: '2', name: 'حليب المراعي طازج', price: 7.5, category: 'ألبان', image: '🥛', rating: 4.9),
    Product(id: '3', name: 'خبز أبيض بريميوم', price: 4.0, category: 'مخبوزات', image: '🍞', rating: 4.5),
    Product(id: '4', name: 'موز طبيعي مستورد', price: 12.0, category: 'فواكه', image: '🍌', rating: 4.7),
    Product(id: '5', name: 'جبنة موزاريلا', price: 22.0, category: 'ألبان', image: '🧀', rating: 4.6),
    Product(id: '6', name: 'عصير برتقال طبيعي', price: 10.0, category: 'مشروبات', image: '🧃', rating: 4.9),
  ];

  void _addToCart(Product product) {
    HapticFeedback.lightImpact();
    setState(() {
      final index = _cart.indexWhere((item) => item.product.id == product.id);
      if (index >= 0) {
        _cart[index].quantity++;
      } else {
        _cart.add(CartItem(product: product));
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إضافة ${product.name} إلى السلة'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      ShopTab(products: _products, onAddToCart: _addToCart),
      CartTab(cart: _cart, onUpdate: () => setState(() {})),
      AnalyticsTab(cartCount: _cart.length),
      ProfileTab(onToggleTheme: widget.onToggleTheme, currentTheme: widget.currentTheme),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          HapticFeedback.selectionClick();
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.store_mall_directory_outlined), selectedIcon: Icon(Icons.store_mall_directory), label: 'المتجر'),
          NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), selectedIcon: Icon(Icons.shopping_cart), label: 'السلة'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights), label: 'الإحصائيات'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'حسابي'),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// SHOP TAB
// -----------------------------------------------------------------------------
class ShopTab extends StatefulWidget {
  final List<Product> products;
  final Function(Product) onAddToCart;

  const ShopTab({super.key, required this.products, required this.onAddToCart});

  @override
  State<ShopTab> createState() => _ShopTabState();
}

class _ShopTabState extends State<ShopTab> {
  String _selectedCategory = 'الكل';
  final List<String> _categories = ['الكل', 'فواكه', 'ألبان', 'مخبوزات', 'مشروبات'];
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.products.where((p) {
      final matchesCategory = _selectedCategory == 'الكل' || p.category == _selectedCategory;
      final matchesSearch = p.name.contains(_searchQuery);
      return matchesCategory && matchesSearch;
    }).toList();

    return CustomScrollView(
      slivers: [
        SliverAppBar.large(
          expandedHeight: 200,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text('سوبر ماركت النخبة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
            background: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF38BDF8)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 60,
                    right: 20,
                    child: Text(
                      'أفضل الأسعار الطازجة يومياً',
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: const InputDecoration(
                    hintText: 'ابحث عن منتج...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 45,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    itemBuilder: (context, index) {
                      final cat = _categories[index];
                      final isSelected = _selectedCategory == cat;
                      return Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (selected) {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedCategory = cat);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        filtered.isEmpty
            ? SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.search_off, size: 80, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('عذراً، لم نجد ما تبحث عنه!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('جرب البحث بكلمات أخرى', style: TextStyle(color: Colors.grey.shade600)),
                    ],
                  ),
                ),
              )
            : SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.75,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = filtered[index];
                      return TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: Duration(milliseconds: 300 + (index * 100)),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: Opacity(opacity: value, child: child),
                          );
                        },
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Container(
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).colorScheme.surface,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Center(
                                      child: Text(product.image, style: const TextStyle(fontSize: 50)),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  product.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.between,
                                  children: [
                                    Text(
                                      '${product.price} ر.س',
                                      style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.star, color: Colors.amber, size: 16),
                                        Text('${product.rating}', style: const TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  height: 36,
                                  child: FilledButton.tonal(
                                    onPressed: () => widget.onAddToCart(product),
                                    style: FilledButton.styleFrom(
                                      minimumSize: const Size.fromHeight(36),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    child: const Text('إضافة للسلة', style: TextStyle(fontSize: 12)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

// -----------------------------------------------------------------------------
// CART TAB
// -----------------------------------------------------------------------------
class CartTab extends StatelessWidget {
  final List<CartItem> cart;
  final VoidCallback onUpdate;

  const CartTab({super.key, required this.cart, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    double total = cart.fold(0, (sum, item) => sum + (item.product.price * item.quantity));

    return Scaffold(
      appBar: AppBar(title: const Text('سلة التسوق')),
      body: cart.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('سلة التسوق فارغة حالياً', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('أضف بعض المنتجات الرائعة لنبدأ!', style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return Dismissible(
                        key: Key(item.product.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(24)),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        onDismissed: (direction) {
                          final removed = cart.removeAt(index);
                          onUpdate();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('تم حذف ${removed.product.name}'),
                              action: SnackBarAction(
                                label: 'تراجع',
                                onPressed: () {
                                  cart.insert(index, removed);
                                  onUpdate();
                                },
                              ),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Text(item.product.image, style: const TextStyle(fontSize: 40)),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      const SizedBox(height: 4),
                                      Text('${item.product.price} ر.س', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                                    ],
                                  ),
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline),
                                      onPressed: () {
                                        if (item.quantity > 1) {
                                          item.quantity--;
                                        } else {
                                          cart.removeAt(index);
                                        }
                                        onUpdate();
                                      },
                                    ),
                                    Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle_outline),
                                      onPressed: () {
                                        item.quantity++;
                                        onUpdate();
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('المجموع الكلي:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('$total ر.س', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context,
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
                            builder: (context) => Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                                  const SizedBox(height: 24),
                                  const Icon(Icons.check_circle, color: Colors.green, size: 64),
                                  const SizedBox(height: 16),
                                  const Text('تم إتمام الطلب بنجاح!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  const Text('سيتم توصيل طلبك قريباً إلى باب منزلك'),
                                  const SizedBox(height: 24),
                                  FilledButton(
                                    onPressed: () {
                                      cart.clear();
                                      onUpdate();
                                      Navigator.pop(context);
                                    },
                                    child: const Text('حسناً'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: const Text('إتمام الشراء'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

// -----------------------------------------------------------------------------
// ANALYTICS TAB (CustomPainter graphs)
// -----------------------------------------------------------------------------
class AnalyticsTab extends StatelessWidget {
  final int cartCount;

  const AnalyticsTab({super.key, required this.cartCount});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإحصائيات والتقارير')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('استهلاك المنتجات الأسبوعي', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 180,
                    child: CustomPaint(
                      painter: BarChartPainter(primaryColor: Theme.of(context).colorScheme.primary),
                      size: const Size(double.infinity, 180),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('نسبة توفير الميزانية', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  Center(
                    child: SizedBox(
                      width: 150,
                      height: 150,
                      child: CustomPaint(
                        painter: CircularProgressPainter(primaryColor: Theme.of(context).colorScheme.primary),
                        child: const Center(
                          child: Text('78%', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
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

class BarChartPainter extends CustomPainter {
  final Color primaryColor;
  BarChartPainter({required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final values = [0.6, 0.8, 0.4, 0.9, 0.5, 0.7, 1.0];
    final width = size.width / (values.length * 1.5);

    for (int i = 0; i < values.length; i++) {
      final left = i * (width * 1.5) + width * 0.5;
      final height = size.height * values[i];
      final top = size.height - height;

      final rect = Rect.fromLTWH(left, top, width, height);
      final rRect = RRect.fromRectAndRadius(rect, const Radius.circular(8));
      canvas.drawRRect(rRect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CircularProgressPainter extends CustomPainter {
  final Color primaryColor;
  CircularProgressPainter({required this.primaryColor});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = 14.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, bgPaint);

    final fgPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    const angle = 2 * 3.1415926535 * 0.78;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -3.1415926535 / 2, angle, false, fgPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// -----------------------------------------------------------------------------
// PROFILE TAB
// -----------------------------------------------------------------------------
class ProfileTab extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode currentTheme;

  const ProfileTab({super.key, required this.onToggleTheme, required this.currentTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('حسابي')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFF2563EB),
                  child: Text('👤', style: TextStyle(fontSize: 40)),
                ),
                const SizedBox(height: 16),
                const Text('أحمد محمد', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('ahmed@example.com', style: TextStyle(color: Colors.grey.shade600)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.brightness_6_outlined),
                  title: const Text('الوضع الليلي'),
                  trailing: Switch(
                    value: currentTheme == ThemeMode.dark,
                    onChanged: (val) => onToggleTheme(),
                  ),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.location_on_outlined),
                  title: Text('عناويني المسجلة'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.payment_outlined),
                  title: Text('طرق الدفع'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.support_agent_outlined),
                  title: Text('الدعم الفني'),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.tonal(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => AuthScreen(onToggleTheme: onToggleTheme, currentTheme: currentTheme),
                ),
              );
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red.withOpacity(0.1),
              foregroundColor: Colors.red,
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
      ),
    );
  }
}