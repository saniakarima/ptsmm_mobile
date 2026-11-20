import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'catalog_screen.dart';
import 'cart_screen.dart';
import 'order_history_screen.dart';
import 'profile_screen.dart';
import 'admin/admin_dashboard.dart';
import 'admin/admin_products.dart';
import 'admin/admin_orders.dart';
import 'admin/admin_reports_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final isAdmin = authProvider.isAdmin;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Daftar Halaman untuk Pengguna (5 Tab)
    final List<Widget> userPages = [
      HomeScreen(
        onNavigateToCatalog: () => setState(() => _selectedIndex = 1),
      ),
      const CatalogScreen(),
      const CartScreen(isFromBottomNav: true),
      const OrderHistoryScreen(),
      const ProfileScreen(),
    ];

    // Daftar Halaman untuk Admin (5 Tab)
    final List<Widget> adminPages = [
      AdminDashboard(
        onNavigateToProducts: () => setState(() => _selectedIndex = 1),
        onNavigateToOrders: () => setState(() => _selectedIndex = 2),
      ),
      const AdminProductsScreen(isFromBottomNav: true),
      const AdminOrdersScreen(isFromBottomNav: true),
      const AdminReportsScreen(),
      const ProfileScreen(),
    ];

    final currentPages = isAdmin ? adminPages : userPages;

    // Pastikan index tidak di luar batas
    if (_selectedIndex >= currentPages.length) {
      _selectedIndex = 0;
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: currentPages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : AppColors.primary).withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: _selectedIndex,
            height: 68,
            elevation: 0,
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            indicatorColor: (isDark ? AppColors.secondary : AppColors.primary)
                .withValues(alpha: isDark ? 0.25 : 0.15),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: isAdmin ? _buildAdminDestinations(isDark) : _buildUserDestinations(context, isDark),
          ),
        ),
      ),
    );
  }

  List<NavigationDestination> _buildUserDestinations(BuildContext context, bool isDark) {
    final activeColor = isDark ? AppColors.secondary : AppColors.primary;
    final inactiveColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return [
      NavigationDestination(
        icon: Icon(Icons.home_outlined, color: inactiveColor),
        selectedIcon: Icon(Icons.home_rounded, color: activeColor),
        label: 'Beranda',
      ),
      NavigationDestination(
        icon: Icon(Icons.grid_view_outlined, color: inactiveColor),
        selectedIcon: Icon(Icons.grid_view_rounded, color: activeColor),
        label: 'Katalog',
      ),
      NavigationDestination(
        icon: Consumer<CartProvider>(
          builder: (context, cart, _) => Badge(
            isLabelVisible: cart.itemCount > 0,
            label: Text(
              cart.itemCount.toString(),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppColors.error,
            child: Icon(Icons.shopping_cart_outlined, color: inactiveColor),
          ),
        ),
        selectedIcon: Consumer<CartProvider>(
          builder: (context, cart, _) => Badge(
            isLabelVisible: cart.itemCount > 0,
            label: Text(
              cart.itemCount.toString(),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
            backgroundColor: AppColors.error,
            child: Icon(Icons.shopping_cart_rounded, color: activeColor),
          ),
        ),
        label: 'Keranjang',
      ),
      NavigationDestination(
        icon: Icon(Icons.receipt_long_outlined, color: inactiveColor),
        selectedIcon: Icon(Icons.receipt_long_rounded, color: activeColor),
        label: 'Pesanan',
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outline_rounded, color: inactiveColor),
        selectedIcon: Icon(Icons.person_rounded, color: activeColor),
        label: 'Profil',
      ),
    ];
  }

  List<NavigationDestination> _buildAdminDestinations(bool isDark) {
    final activeColor = isDark ? AppColors.secondary : AppColors.primary;
    final inactiveColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return [
      NavigationDestination(
        icon: Icon(Icons.dashboard_outlined, color: inactiveColor),
        selectedIcon: Icon(Icons.dashboard_rounded, color: activeColor),
        label: 'Dashboard',
      ),
      NavigationDestination(
        icon: Icon(Icons.inventory_2_outlined, color: inactiveColor),
        selectedIcon: Icon(Icons.inventory_2_rounded, color: activeColor),
        label: 'Produk',
      ),
      NavigationDestination(
        icon: Icon(Icons.receipt_long_outlined, color: inactiveColor),
        selectedIcon: Icon(Icons.receipt_long_rounded, color: activeColor),
        label: 'Pesanan',
      ),
      NavigationDestination(
        icon: Icon(Icons.analytics_outlined, color: inactiveColor),
        selectedIcon: Icon(Icons.analytics_rounded, color: activeColor),
        label: 'Laporan',
      ),
      NavigationDestination(
        icon: Icon(Icons.person_outline_rounded, color: inactiveColor),
        selectedIcon: Icon(Icons.person_rounded, color: activeColor),
        label: 'Profil',
      ),
    ];
  }
}
