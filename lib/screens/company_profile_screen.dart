import 'package:flutter/material.dart';
import '../models/company_profile.dart';
import '../services/admin_service.dart';
import '../theme/app_theme.dart';

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  CompanyProfile? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final p = await AdminService.getCompanyProfile();
      if (mounted) {
        setState(() {
          _profile = p;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final p = _profile ??
        CompanyProfile(
          name: 'PT Shafa Marwa Multiguna',
          description:
              'PT Shafa Marwa Multiguna (PT SMM) merupakan perusahaan yang berlokasi di Way Halim, Bandar Lampung, yang bergerak di bidang pemasaran digital dan promosi produk terpadu. Perusahaan aktif mengelola penyiaran langsung (live streaming) melalui platform TikTok serta memasarkan produk-produk agrikultur, perikanan, herbal, kopi, dan nutrisi anak unggulan bernilai tinggi.',
          address:
              'Jalan Urip Sumoharjo Nomor 159 B, Kel. Way Halim Permai, Kec. Way Halim, Kota Bandar Lampung 35122',
          phone: '08117291000',
          email: 'smm4us.co.id@gmail.com',
          website: 'www.shafamarwa.com',
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Perusahaan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: isDark ? AppColors.secondary : AppColors.primary,
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Hero Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isDark
                            ? [AppColors.darkSurface, AppColors.darkCard]
                            : [AppColors.primary, AppColors.primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: (isDark ? Colors.black : AppColors.primary)
                              .withValues(alpha: isDark ? 0.3 : 0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.business_rounded,
                              size: 40,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                p.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.verified_rounded,
                              color: AppColors.secondary,
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Way Halim, Bandar Lampung',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppColors.secondary : AppColors.secondaryLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Digital Marketing & TikTok Live Agency',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Tentang Perusahaan
                  _buildSectionCard(
                    context,
                    title: 'Tentang Perusahaan',
                    icon: Icons.info_outline_rounded,
                    child: Text(
                      p.description,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Visi & Misi
                  _buildSectionCard(
                    context,
                    title: 'Visi & Misi',
                    icon: Icons.lightbulb_outline_rounded,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Visi',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.secondary : AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Menjadi perusahaan agribisnis, produk herbal, dan platform live commerce digital terdepan di Indonesia yang berdaya saing tinggi serta memberikan dampak positif bagi kemaslahatan masyarakat luas.',
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.5,
                            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Misi',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.secondary : AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildMisiItem(context, '1', 'Menghadirkan 16 produk terpercaya dalam 5 lini kategori unggulan (Pupuk Organik, Perikanan, Herbal, Kopi, dan Vitamin Anak) yang berkualitas tinggi dan bersertifikasi.'),
                        _buildMisiItem(context, '2', 'Mengembangkan ekosistem pemasaran digital modern melalui penyiaran langsung (Live Streaming) TikTok Shop dan multi-channel marketplace.'),
                        _buildMisiItem(context, '3', 'Memberikan pelayanan pelanggan prima dengan kecepatan logistik Biteship serta keamanan transaksi terintegrasi.'),
                        _buildMisiItem(context, '4', 'Membuka peluang karir dan memberdayakan talenta lokal di Bandar Lampung dan sekitarnya.'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 5 Lini Kategori Bisnis
                  _buildSectionCard(
                    context,
                    title: '5 Lini Kategori Produk',
                    icon: Icons.category_rounded,
                    child: Column(
                      children: [
                        _buildCategoryRow(context, Icons.eco_rounded, 'Pupuk Organik', 'AQ Green, AQ Green Gold, Aqua Green, Sica Aqua Green, Sica Pro Aqua Green'),
                        const Divider(height: 16),
                        _buildCategoryRow(context, Icons.water_rounded, 'Perikanan', 'Aqua Fish Premik, Probiotik, Booster Plankton'),
                        const Divider(height: 16),
                        _buildCategoryRow(context, Icons.health_and_safety_rounded, 'Herbal', 'Lambung Gembira, Susu Etawa Ajwa'),
                        const Divider(height: 16),
                        _buildCategoryRow(context, Icons.coffee_rounded, 'Kopi Pilihan', 'Kopi Sanghai, Kopi Jet M Tanpa Gula, Kopi Romero'),
                        const Divider(height: 16),
                        _buildCategoryRow(context, Icons.child_care_rounded, 'Vitamin & Nutrisi Anak', 'Nuhsa Smart DHA, Nuhsa Growvit, Etawa Ajwa Lambung Anak'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Informasi Kontak & Alamat
                  _buildSectionCard(
                    context,
                    title: 'Informasi Kontak & Alamat',
                    icon: Icons.contact_phone_outlined,
                    child: Column(
                      children: [
                        _buildContactRow(
                          context,
                          icon: Icons.location_on_rounded,
                          title: 'Alamat Kantor',
                          value: p.address,
                        ),
                        const SizedBox(height: 12),
                        _buildContactRow(
                          context,
                          icon: Icons.phone_in_talk_rounded,
                          title: 'Telepon / CS',
                          value: p.phone,
                        ),
                        const SizedBox(height: 12),
                        _buildContactRow(
                          context,
                          icon: Icons.email_rounded,
                          title: 'Email Resmi',
                          value: p.email,
                        ),
                        const SizedBox(height: 12),
                        _buildContactRow(
                          context,
                          icon: Icons.language_rounded,
                          title: 'Situs Resmi',
                          value: p.website,
                        ),
                        const SizedBox(height: 12),
                        _buildContactRow(
                          context,
                          icon: Icons.access_time_rounded,
                          title: 'Jam Operasional',
                          value: 'Senin - Sabtu: 08.00 - 17.00 WIB',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.primary)
                .withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isDark ? AppColors.secondary : AppColors.primary)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isDark ? AppColors.secondary : AppColors.primary,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
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

  Widget _buildMisiItem(BuildContext context, String num, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: (isDark ? AppColors.secondary : AppColors.primary).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Text(
              num,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.secondary : AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                height: 1.45,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(BuildContext context, IconData icon, String catName, String items) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? AppColors.secondary : AppColors.primary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                catName,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              Text(
                items,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? AppColors.secondary : AppColors.primary,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                ),
              ),
              const SizedBox(height: 2),
              SelectableText(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

