import 'package:flutter/foundation.dart';

class ApiConfig {
  // 1. URL untuk Pengujian Desktop (Windows) / Web Browser
  static const String webBaseUrl = 'http://localhost/ptsmmobile/api';

  // 2. URL untuk Android Emulator (10.0.2.2 me-route otomatis ke localhost komputer host)
  static const String androidEmulatorBaseUrl = 'http://10.0.2.2/ptsmmobile/api';

  // 3. URL untuk HP Android Fisik via Jaringan Wi-Fi lokal komputer
  static const String androidPhysicalBaseUrl = 'http://10.210.206.166/ptsmmobile/api';

  // Ubah ke true jika ingin menguji langsung di HP Android fisik yang terhubung ke Wi-Fi yang sama
  static const bool usePhysicalPhone = false;

  static String get baseUrl {
    if (kIsWeb) {
      return webBaseUrl;
    }
    if (defaultTargetPlatform == TargetPlatform.windows) {
      return webBaseUrl;
    }
    if (usePhysicalPhone) {
      return androidPhysicalBaseUrl;
    }
    return androidEmulatorBaseUrl;
  }

  // Auth Endpoints
  static String get login => '$baseUrl/auth/login';
  static String get register => '$baseUrl/auth/register';
  static String get profile => '$baseUrl/auth/profile';

  // Products Endpoints
  static String get products => '$baseUrl/products';
  static String product(int id) => '$baseUrl/products/$id';

  // Categories Endpoints
  static String get categories => '$baseUrl/categories';
  static String category(int id) => '$baseUrl/categories/$id';

  // Orders Endpoints
  static String get orders => '$baseUrl/orders';
  static String order(int id) => '$baseUrl/orders/$id';
  static String orderStatus(int id) => '$baseUrl/orders/$id/status';
  static String get allOrders => '$baseUrl/orders/all';

  // Biteship Shipping Endpoints
  static String get shippingRates => '$baseUrl/shipping/rates';
  static String shippingTrack(String waybill) => '$baseUrl/shipping/track/$waybill';

  // Midtrans Payment Endpoints
  static String get snapToken => '$baseUrl/payment/snap-token';

  // Vacancies Endpoints (Lowongan Karir)
  static String get vacancies => '$baseUrl/vacancies';
  static String vacancy(int id) => '$baseUrl/vacancies/$id';

  // Users Management Endpoints (Admin)
  static String get users => '$baseUrl/users';
  static String toggleUserStatus(int id) => '$baseUrl/users/$id/toggle-status';

  // Company Profile Endpoints
  static String get companyProfile => '$baseUrl/company-profile';

  // Admin Dashboard Statistics Endpoint
  static String get adminStats => '$baseUrl/admin-stats';
}
