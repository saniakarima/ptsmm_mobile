import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// SmartphoneFrame
/// Memberikan simulasi bingkai smartphone modern yang realistis ketika website
/// dibuka di laptop atau komputer desktop, dan secara otomatis beralih menjadi
/// tampilan mobile penuh (edge-to-edge) tanpa bingkai ketika dibuka di smartphone fisik.
class SmartphoneFrame extends StatefulWidget {
  final Widget child;

  const SmartphoneFrame({super.key, required this.child});

  @override
  State<SmartphoneFrame> createState() => _SmartphoneFrameState();
}

class _SmartphoneFrameState extends State<SmartphoneFrame> {
  late Timer _clockTimer;
  String _currentTime = '14:00';

  @override
  void initState() {
    super.initState();
    _updateClock();
    _clockTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) _updateClock();
    });
  }

  void _updateClock() {
    final now = DateTime.now();
    setState(() {
      _currentTime = DateFormat('HH:mm').format(now);
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // Breakpoint Responsif:
        // Jika dibuka pada Smartphone sebenarnya (lebar <= 520 px),
        // langsung tampilkan halaman secara penuh tanpa bingkai simulasi HP.
        if (screenWidth <= 520) {
          return widget.child;
        }

        // Tampilan Desktop / Laptop: Tampilkan smartphone modern di tengah layar
        // Dimensi smartphone modern proporsional rasio ~20:9 (Pixel 8 / Galaxy S24)
        const double phoneWidth = 402.0;
        final double maxAllowedHeight = screenHeight - 64.0;
        final double phoneHeight = (maxAllowedHeight > 870.0)
            ? 870.0
            : (maxAllowedHeight < 620.0 ? 620.0 : maxAllowedHeight);

        return Scaffold(
          backgroundColor: const Color(0xFF090E17),
          body: Stack(
            children: [
              // 1. Ambient Background Studio Glow (Aura Cahaya Biru Elegan)
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(0.0, -0.1),
                      radius: 1.1,
                      colors: [
                        Color(0xFF162A45),
                        Color(0xFF0D1726),
                        Color(0xFF06090F),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Konten Utama: Smartphone Terpusat
              Center(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Badge Informasi Simulasi Laptop
                      _buildDesktopHeaderBadge(),
                      const SizedBox(height: 16),

                      // Device Frame & Side Buttons Wrapper
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.center,
                        children: [
                          // Tombol Fisik Sisi Kiri: Volume Up & Down
                          Positioned(
                            left: -4,
                            top: 140,
                            child: _buildSideButton(height: 52),
                          ),
                          Positioned(
                            left: -4,
                            top: 204,
                            child: _buildSideButton(height: 52),
                          ),

                          // Tombol Fisik Sisi Kanan: Power / Lock Button
                          Positioned(
                            right: -4,
                            top: 165,
                            child: _buildSideButton(height: 64),
                          ),

                          // Bodi Utama Smartphone (Realistic Bezel & Titanium Border)
                          Container(
                            width: phoneWidth,
                            height: phoneHeight,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0B1017),
                              borderRadius: BorderRadius.circular(46),
                              border: Border.all(
                                color: const Color(0xFF3B4858),
                                width: 3.5,
                              ),
                              boxShadow: [
                                // Bayangan Luar Realistis (Realistic Drop Shadow)
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  blurRadius: 48,
                                  spreadRadius: 4,
                                  offset: const Offset(0, 24),
                                ),
                                // Ambient Glow Biru SMM di Sekeliling HP
                                BoxShadow(
                                  color: const Color(0xFF38BDF8).withValues(alpha: 0.14),
                                  blurRadius: 60,
                                  spreadRadius: -4,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Padding(
                              // Bezel Tipis Realistis Sekitar Layar HP (8px)
                              padding: const EdgeInsets.all(8.5),
                              child: Stack(
                                children: [
                                  // Layar HP Aktif (Screen Area)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(37),
                                    child: Container(
                                      color: Theme.of(context).scaffoldBackgroundColor,
                                      child: MediaQuery(
                                        data: MediaQuery.of(context).copyWith(
                                          size: Size(phoneWidth - 17, phoneHeight - 17),
                                          padding: const EdgeInsets.only(top: 30, bottom: 18),
                                          viewPadding: const EdgeInsets.only(top: 30, bottom: 18),
                                        ),
                                        child: widget.child,
                                      ),
                                    ),
                                  ),

                                  // Status Bar Android Modern di Bagian Atas Layar HP
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    right: 0,
                                    child: _buildAndroidStatusBar(),
                                  ),

                                  // Punch-hole Kamera Depan & Speaker Earphone
                                  Positioned(
                                    top: 10,
                                    left: 0,
                                    right: 0,
                                    child: _buildCameraAndSpeaker(),
                                  ),

                                  // Gesture Bar Android di Bagian Bawah Layar HP
                                  Positioned(
                                    bottom: 6,
                                    left: 0,
                                    right: 0,
                                    child: _buildGestureBar(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Footer Caption
                      _buildDesktopFooter(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Header Badge Tampilan Laptop
  Widget _buildDesktopHeaderBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF475569).withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF10B981),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF10B981),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'PT Shafa Marwa Multiguna',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
          const Text(
            ' • Mobile App Simulation',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Tombol Samping Logam (Volume / Power)
  Widget _buildSideButton({required double height}) {
    return Container(
      width: 4,
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFF475569),
        borderRadius: BorderRadius.circular(2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }

  // Status Bar Android Modern
  Widget _buildAndroidStatusBar() {
    return IgnorePointer(
      child: Container(
        height: 28,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Jam Status Bar
            Text(
              _currentTime,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            // Indikator Jaringan & Baterai
            Row(
              children: [
                const Icon(Icons.wifi_rounded, size: 14, color: Colors.white),
                const SizedBox(width: 5),
                const Icon(Icons.signal_cellular_alt_rounded, size: 14, color: Colors.white),
                const SizedBox(width: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        '98%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(Icons.battery_charging_full_rounded, size: 12, color: Color(0xFF10B981)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Punch Hole Kamera Depan & Speaker
  Widget _buildCameraAndSpeaker() {
    return IgnorePointer(
      child: Center(
        child: Column(
          children: [
            // Speaker Earphone
            Container(
              width: 50,
              height: 3.5,
              decoration: BoxDecoration(
                color: const Color(0xFF1F2937),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 5),
            // Lensa Kamera Punch Hole
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: const Color(0xFF030712),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF111827),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: Container(
                  width: 3.5,
                  height: 3.5,
                  decoration: const BoxDecoration(
                    color: Color(0xFF38BDF8),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Android Gesture Pill
  Widget _buildGestureBar() {
    return IgnorePointer(
      child: Center(
        child: Container(
          width: 120,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }

  // Footer Caption
  Widget _buildDesktopFooter() {
    return const Text(
      'Simulasi Layar Smartphone Android • Responsif untuk Seluruh Perangkat',
      style: TextStyle(
        color: Color(0xFF64748B),
        fontSize: 11,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.2,
      ),
    );
  }
}

