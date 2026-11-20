import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/product.dart';

class ProductService {
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

  static Future<List<Product>> getProducts() async {
    final response = await http.get(
      Uri.parse(ApiConfig.products),
      headers: _headers(),
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 && data['success'] == true) {
      return (data['products'] as List)
          .map((json) => Product.fromJson(json))
          .toList();
    }
    throw Exception(data['message'] ?? 'Gagal memuat produk');
  }

  static Future<Product> getProduct(int id) async {
    final response = await http.get(
      Uri.parse(ApiConfig.product(id)),
      headers: _headers(),
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 && data['success'] == true) {
      return Product.fromJson(data['product']);
    }
    throw Exception(data['message'] ?? 'Produk tidak ditemukan');
  }

  static Future<Product> createProduct(
      String token, Map<String, dynamic> productData) async {
    final response = await http.post(
      Uri.parse(ApiConfig.products),
      headers: _headers(token),
      body: jsonEncode(productData),
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 && data['success'] == true) {
      return Product.fromJson(data['product']);
    }
    throw Exception(data['message'] ?? 'Gagal menambah produk');
  }

  static Future<Product> updateProduct(
      String token, int id, Map<String, dynamic> productData) async {
    final response = await http.put(
      Uri.parse(ApiConfig.product(id)),
      headers: _headers(token),
      body: jsonEncode(productData),
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 && data['success'] == true) {
      return Product.fromJson(data['product']);
    }
    throw Exception(data['message'] ?? 'Gagal mengupdate produk');
  }

  static Future<bool> deleteProduct(String token, int id) async {
    final response = await http.delete(
      Uri.parse(ApiConfig.product(id)),
      headers: _headers(token),
    );
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 && data['success'] == true) {
      return true;
    }
    throw Exception(data['message'] ?? 'Gagal menghapus produk');
  }
}

