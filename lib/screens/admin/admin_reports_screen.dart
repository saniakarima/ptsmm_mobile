import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/product_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/admin_service.dart';
import '../../theme/app_theme.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen> {
  String _selectedPeriod = 'Bulan Ini';
  final List<String> _periods = ['Hari Ini', 'Minggu Ini', 'Bulan Ini', 'Tahun 2026'];
  final Map<String, String> _periodKeys = {
    'Hari Ini': 'today',
    'Minggu Ini': 'week',
    'Bulan Ini': 'month',
    'Tahun 2026': 'year',
  };
  Map<String, dynamic> _stats = {};
  bool _isLoading = true;
  bool _isFetching = false;
  String? _error;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadStats();
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 15),
      (_) => _loadStats(),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadStats() async {
    if (_isFetching) return;
    _isFetching = true;
    if (mounted && !_isLoading) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final token = context.read<AuthProvider>().token;
      if (token == null || token.isEmpty) {
        throw Exception('Sesi admin tidak tersedia. Silakan masuk kembali.');
      }
      final stats = await AdminService.getDashboardStats(
        token,
        period: _periodKeys[_selectedPeriod]!,
      );
      if (mounted) {
        setState(() {
          _stats = stats;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      _isFetching = false;
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final productProvider = context.watch<ProductProvider>();
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

    final totalStock = productProvider.products.fold<int>(0, (sum, p) => sum + p.stock);
    final totalValue = productProvider.products.fold<double>(
        0.0, (sum, p) => sum + (p.price * p.stock));
    final totalOrders = (_stats['period_orders'] as num?)?.toInt() ?? 0;
    final pendingOrders =
        (_stats['period_pending_orders'] as num?)?.toInt() ?? 0;
    final completedOrders =
        (_stats['period_completed_orders'] as num?)?.toInt() ?? 0;
    final totalRevenue =
        (_stats['period_revenue'] as num?)?.toDouble() ?? 0.0;
    final weeklySales = (_stats['weekly_sales'] as List?) ?? const [];
    final weeklyOrders = weeklySales.isEmpty
        ? List.generate(7, (index) => {'day': '', 'count': 0})
        : weeklySales;
    var maxWeeklyOrders = 1.0;
    for (final rawDay in weeklyOrders) {
      final count =
          ((rawDay as Map<String, dynamic>)['count'] as num?)?.toDouble() ?? 0;
      if (count > maxWeeklyOrders) maxWeeklyOrders = count;
    }
    final categories = <String, int>{};
    for (final product in productProvider.products) {
      categories.update(
        product.category,
        (count) => count + 1,
        ifAbsent: () => 1,
      );
    }
    final categoryCount = productProvider.products.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan & Analitik'),
        automaticallyImplyLeading: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedPeriod,
                dropdownColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
                items: _periods.map((p) {
                  return DropdownMenuItem(value: p, child: Text(p));
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedPeriod = val);
                    _loadStats();
                  }
                },
              ),
            ),
          ),
          IconButton(
            tooltip: 'Muat ulang laporan',
            onPressed: _isLoading ? null : _loadStats,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Gagal memuat data laporan: $_error',
                  style: const TextStyle(color: AppColors.error, fontSize: 12),
                ),
              ),
            if (_isLoading) const LinearProgressIndicator(),
            const SizedBox(height: 8),
            // Revenue Highlight Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [AppColors.primaryLight, AppColors.darkCard]
                      : [AppColors.primary, AppColors.accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'TOTAL PENDAPATAN',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          color: AppColors.secondaryLight,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '$totalOrders pesanan',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currencyFormat.format(totalRevenue),
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$_selectedPeriod • $pendingOrders menunggu • $completedOrders selesai',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Performance KPI Grid
            Row(
              children: [
                Expanded(
                  child: _buildKPICard(
                    context,
                    title: 'Nilai Aset Stok',
                    value: currencyFormat.format(totalValue),
                    subtitle: '$totalStock unit gudang',
                    icon: Icons.account_balance_wallet_rounded,
                    color: AppColors.secondaryDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildKPICard(
                    context,
                    title: 'Pesanan Menunggu',
                    value: '$pendingOrders',
                    subtitle: 'dari $totalOrders pesanan',
                    icon: Icons.receipt_long_rounded,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Sales Chart Representation
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Pesanan 7 Hari Terakhir',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        'Jumlah pesanan',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Visual Bar Chart
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ...weeklyOrders.map((rawDay) {
                        final day = rawDay as Map<String, dynamic>;
                        return _buildBar(
                          context,
                          day['day']?.toString() ?? '',
                          (day['count'] as num?)?.toDouble() ?? 0,
                          maxWeeklyOrders,
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Category Contribution
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Proporsi Produk per Kategori',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (categoryCount == 0)
                    const Text('Belum ada data produk.')
                  else
                    ...categories.entries.map((entry) {
                      final share = entry.value / categoryCount;
                      return _buildCategoryProgress(
                        context,
                        entry.key,
                        share,
                        '${(share * 100).round()}%',
                      );
                    }),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildKPICard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(BuildContext context, String day, double value, double maxValue,
      {bool isHighlight = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final heightRatio = (value / maxValue).clamp(0.15, 1.0);

    return Column(
      children: [
        Text(
          '${value.toInt()}',
          style: TextStyle(
            fontSize: 10,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.normal,
            color: isHighlight
                ? (isDark ? AppColors.secondary : AppColors.primary)
                : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: 22,
          height: 110 * heightRatio,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isHighlight
                  ? [AppColors.secondary, AppColors.primary]
                  : [
                      (isDark ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.3),
                      (isDark ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.6),
                    ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryProgress(
      BuildContext context, String label, double progress, String percentage) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              Text(
                percentage,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.secondary : AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: (isDark ? AppColors.darkCard : AppColors.lightBg),
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark ? AppColors.secondary : AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

