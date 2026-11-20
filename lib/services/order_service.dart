import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/order.dart';

class OrderService {
  static Map<String, String> _headers([String? token]) {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<Order> createOrder({
    required String token,
    required String address,
    required String recipientName,
    required String recipientPhone,
    required String courier,
    required String service,
    required double shippingFee,
    required String paymentMethod,
    String? notes,
    required List<Map<String, dynamic>> items,
  }) async {
    final response = await http.post(
      Uri.parse(ApiConfig.orders),
      headers: _headers(token),
      body: jsonEncode({
        'address': address,
        'recipient_name': recipientName,
        'recipient_phone': recipientPhone,
        'courier': courier,
        'service': service,
        'shipping_fee': shippingFee,
        'payment_method': paymentMethod,
        'notes': notes ?? '',
        'items': items,
      }),
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 && data['success'] == true) {
      return Order.fromJson(data['order']);
    }
    throw Exception(data['message'] ?? 'Gagal membuat pesanan');
  }

  static Future<List<Order>> getOrders(String token) async {
    final response = await http.get(
      Uri.parse(ApiConfig.orders),
      headers: _headers(token),
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 && data['success'] == true) {
      return (data['orders'] as List)
          .map((json) => Order.fromJson(json))
          .toList();
    }
    throw Exception(data['message'] ?? 'Gagal memuat pesanan');
  }

  static Future<List<Order>> getAllOrders(String token) async {
    final response = await http.get(
      Uri.parse(ApiConfig.allOrders),
      headers: _headers(token),
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 && data['success'] == true) {
      return (data['orders'] as List)
          .map((json) => Order.fromJson(json))
          .toList();
    }
    throw Exception(data['message'] ?? 'Gagal memuat pesanan');
  }

  static Future<Order> getOrder(String token, int id) async {
    final response = await http.get(
      Uri.parse(ApiConfig.order(id)),
      headers: _headers(token),
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 && data['success'] == true) {
      return Order.fromJson(data['order']);
    }
    throw Exception(data['message'] ?? 'Pesanan tidak ditemukan');
  }

  static Future<bool> updateOrderStatus(
      String token, int id, String status, {String? waybillId}) async {
    final response = await http.put(
      Uri.parse(ApiConfig.orderStatus(id)),
      headers: _headers(token),
      body: jsonEncode({
        'status': status,
        if (waybillId != null && waybillId.isNotEmpty) 'waybill_id': waybillId,
      }),
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return response.statusCode == 200 && data['success'] == true;
  }

  // === BITESHIP SHIPPING ONGKIR & TRACKING ===
  static Future<List<Map<String, dynamic>>> getShippingRates({
    String postalCode = '35141',
    int totalWeight = 1000,
    int productValue = 100000,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.shippingRates),
        headers: _headers(),
        body: jsonEncode({
          'postal_code': postalCode,
          'weight': totalWeight,
          'value': productValue,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['rates']);
      }
    } catch (_) {}

    return [
      {
        'courier_code': 'jne',
        'courier_name': 'JNE',
        'courier_service': 'REG',
        'courier_service_name': 'JNE Reguler (Biteship)',
        'duration': '1-2 hari',
        'price': 15000,
      },
      {
        'courier_code': 'sicepat',
        'courier_name': 'SiCepat',
        'courier_service': 'BEST',
        'courier_service_name': 'SiCepat BEST Next Day (Biteship)',
        'duration': '1 hari',
        'price': 22000,
      },
      {
        'courier_code': 'jnt',
        'courier_name': 'J&T',
        'courier_service': 'EZ',
        'courier_service_name': 'J&T EZ (Biteship)',
        'duration': '2-3 hari',
        'price': 18000,
      },
    ];
  }

  static Future<Map<String, dynamic>?> trackShipment(String waybillId) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConfig.shippingTrack(waybillId)),
        headers: _headers(),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return data['tracking'] as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  // === MIDTRANS PAYMENT ===
  static Future<String?> getSnapToken(String token, int orderId) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConfig.snapToken),
        headers: _headers(token),
        body: jsonEncode({'order_id': orderId}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return data['snap_token']?.toString();
      }
    } catch (_) {}
    return null;
  }
}
