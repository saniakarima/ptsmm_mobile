import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../services/order_service.dart';
import '../theme/app_theme.dart';
import 'order_history_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedCourier = 'Biteship Standard (J&T / JNE)';
  double _shippingFee = 15000;
  String _selectedPaymentMethod = 'Transfer Bank BCA Virtual Account';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _courierOptions = [
    {
      'name': 'Biteship Standard (J&T / JNE)',
      'estimate': '2-3 Hari Kerja',
      'fee': 15000.0,
      'badge': 'HEMAT',
    },
    {
      'name': 'Biteship Express (SiCepat BEST)',
      'estimate': '1 Hari Sampai (Next Day)',
      'fee': 24000.0,
      'badge': 'CEPAT',
    },
    {
      'name': 'Biteship Cargo (JTR Truk)',
      'estimate': '3-5 Hari Kerja (Muatan Besar)',
      'fee': 35000.0,
      'badge': 'HEMAT KARGO',
    },
  ];

  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'name': 'Transfer Bank BCA Virtual Account',
      'icon': Icons.account_balance_rounded,
      'desc': 'Verifikasi otomatis dalam hitungan detik',
    },
    {
      'name': 'Transfer Bank Mandiri Virtual Account',
      'icon': Icons.account_balance_rounded,
      'desc': 'Verifikasi otomatis 24 jam',
    },
    {
      'name': 'Transfer Bank BNI / BRI',
      'icon': Icons.account_balance_rounded,
      'desc': 'ATM, Mobile & Internet Banking',
    },
    {
      'name': 'COD (Bayar Tunai di Tempat)',
      'icon': Icons.payments_rounded,
      'desc': 'Bayar langsung ke kurir saat paket tiba',
    },
  ];

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    if (user != null && user.address.isNotEmpty) {
      _addressController.text = user.address;
    }
    _fetchBiteshipRates();
  }

  Future<void> _fetchBiteshipRates() async {
    try {
      final cart = context.read<CartProvider>();
      final totalWeight = cart.items.fold<int>(0, (sum, i) => sum + (i.product.weight * i.quantity));
      final rates = await OrderService.getShippingRates(
        totalWeight: totalWeight > 0 ? totalWeight : 1000,
        productValue: cart.totalPrice.toInt(),
      );

      if (mounted && rates.isNotEmpty) {
        setState(() {
          _courierOptions.clear();
          for (final r in rates) {
            _courierOptions.add({
              'name': '${r['courier_name']} - ${r['courier_service_name'] ?? r['courier_service']}',
              'estimate': r['duration'] ?? '1-3 hari',
              'fee': (r['price'] as num).toDouble(),
              'badge': (r['price'] as num) <= 18000 ? 'HEMAT' : 'REGULER',
            });
          }
          if (_courierOptions.isNotEmpty) {
            _selectedCourier = _courierOptions.first['name'] as String;
            _shippingFee = _courierOptions.first['fee'] as double;
          }
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _handleCheckout() async {
    if (!_formKey.currentState!.validate()) return;

    final cart = context.read<CartProvider>();
    final auth = context.read<AuthProvider>();

    setState(() => _isLoading = true);

    try {
      final items = cart.items
          .map((item) => {
                'product_id': item.product.id,
                'product_name': item.product.name,
                'price': item.product.price,
                'quantity': item.quantity,
              })
          .toList();

      final token = auth.user?.token;
      if (token == null || token.isEmpty) {
        throw Exception('Sesi login berakhir. Silakan masuk kembali.');
      }

      await OrderService.createOrder(
        token: token,
        address: _addressController.text.trim(),
        recipientName: auth.user?.name ?? 'Pelanggan',
        recipientPhone: auth.user?.phone ?? '081234567890',
        courier: _selectedCourier.split(' ').first,
        service: _selectedCourier,
        shippingFee: _shippingFee,
        paymentMethod: _selectedPaymentMethod,
        notes: _notesController.text.trim(),
        items: items,
      );

      cart.clearCart();

      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      final message = e.toString().replaceFirst('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Pesanan gagal disimpan: $message'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.success,
                size: 56,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Pesanan Diterima!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Terima kasih! Pesanan Anda telah tercatat di sistem PT Shafa Marwa Multiguna dan akan segera diserahkan ke kurir Biteship.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx); // tutup dialog
                  Navigator.pop(context); // tutup checkout
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OrderHistoryScreen(),
                    ),
                  );
                },
                child: const Text('Pantau Pesanan Saya'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final grandTotal = cart.totalPrice + _shippingFee;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi Checkout'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Alamat Pengiriman Card
              _buildSectionCard(
                context,
                title: 'Alamat Pengiriman',
                icon: Icons.location_on_rounded,
                child: TextFormField(
                  controller: _addressController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Nama Jalan, RT/RW, Kelurahan, Kecamatan, Kota, Kode Pos...',
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Alamat pengiriman wajib diisi' : null,
                ),
              ),

              const SizedBox(height: 14),

              // Opsi Ekspedisi Pengiriman Biteship Card
              _buildSectionCard(
                context,
                title: 'Pengiriman via Biteship Logistics',
                icon: Icons.local_shipping_rounded,
                child: Column(
                  children: _courierOptions.map((courier) {
                    final isSelected = _selectedCourier == courier['name'];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedCourier = courier['name'] as String;
                          _shippingFee = courier['fee'] as double;
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? AppColors.secondary : AppColors.primary)
                                  .withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? (isDark ? AppColors.secondary : AppColors.primary)
                                : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? (isDark ? AppColors.secondary : AppColors.primary)
                                      : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isDark ? AppColors.secondary : AppColors.primary,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          courier['name'] as String,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: isDark
                                                ? AppColors.textPrimaryDark
                                                : AppColors.textPrimaryLight,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: (isDark ? AppColors.secondary : AppColors.primary)
                                              .withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          courier['badge'] as String,
                                          style: TextStyle(
                                            fontSize: 9,
                                            fontWeight: FontWeight.w700,
                                            color: isDark ? AppColors.secondary : AppColors.primary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    courier['estimate'] as String,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? AppColors.textMutedDark
                                          : AppColors.textMutedLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              currencyFormat.format(courier['fee']),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: isDark ? AppColors.secondary : AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 14),

              // Metode Pembayaran Card
              _buildSectionCard(
                context,
                title: 'Metode Pembayaran',
                icon: Icons.account_balance_wallet_rounded,
                child: Column(
                  children: _paymentMethods.map((method) {
                    final isSelected = _selectedPaymentMethod == method['name'];
                    return InkWell(
                      onTap: () {
                        setState(() => _selectedPaymentMethod = method['name'] as String);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? (isDark ? AppColors.secondary : AppColors.primary)
                                  .withValues(alpha: 0.1)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? (isDark ? AppColors.secondary : AppColors.primary)
                                : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? (isDark ? AppColors.secondary : AppColors.primary)
                                      : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                                  width: 2,
                                ),
                              ),
                              child: isSelected
                                  ? Center(
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isDark ? AppColors.secondary : AppColors.primary,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    method['name'] as String,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimaryLight,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    method['desc'] as String,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? AppColors.textMutedDark
                                          : AppColors.textMutedLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

              const SizedBox(height: 14),

              // Catatan Pesanan
              _buildSectionCard(
                context,
                title: 'Catatan untuk Penjual / Kurir',
                icon: Icons.note_alt_outlined,
                child: TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    hintText: 'Contoh: Titip ke resepsionis atau hubungi sebelum antar',
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Rincian Biaya Akhir
              _buildSectionCard(
                context,
                title: 'Rincian Pembayaran',
                icon: Icons.receipt_long_rounded,
                child: Column(
                  children: [
                    ...cart.items.map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  '${item.product.name} (${item.quantity}x)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondaryLight,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                currencyFormat.format(item.subtotal),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimaryLight,
                                ),
                              ),
                            ],
                          ),
                        )),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Subtotal Produk',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                        ),
                        Text(
                          currencyFormat.format(cart.totalPrice),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Ongkos Kirim Biteship',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textMutedDark
                                : AppColors.textMutedLight,
                          ),
                        ),
                        Text(
                          currencyFormat.format(_shippingFee),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Tagihan',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                        Text(
                          currencyFormat.format(grandTotal),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: isDark ? AppColors.secondary : AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Button Bayar Sekarang
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleCheckout,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Bayar Sekarang (${currencyFormat.format(grandTotal)})',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.primary)
                .withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 20,
                color: isDark ? AppColors.secondary : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
