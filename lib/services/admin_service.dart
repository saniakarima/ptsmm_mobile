import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user.dart';
import '../models/vacancy.dart';
import '../models/category.dart';
import '../models/company_profile.dart';

class AdminService {
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

  // === USERS MANAGEMENT ===
  static Future<List<User>> getUsers(String token) async {
    final response = await http.get(
      Uri.parse(ApiConfig.users),
      headers: _headers(token),
    );
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      return (data['users'] as List).map((u) => User.fromJson(u)).toList();
    }
    throw Exception(data['message'] ?? 'Gagal memuat pengguna');
  }

  static Future<bool> toggleUserStatus(String token, int userId) async {
    final response = await http.put(
      Uri.parse(ApiConfig.toggleUserStatus(userId)),
      headers: _headers(token),
    );
    final data = jsonDecode(response.body);
    return response.statusCode == 200 && data['success'] == true;
  }

  // === VACANCIES (LOWONGAN PEKERJAAN) ===
  static Future<List<Vacancy>> getVacancies() async {
    final response = await http.get(Uri.parse(ApiConfig.vacancies));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      return (data['vacancies'] as List).map((v) => Vacancy.fromJson(v)).toList();
    }
    return [];
  }

  static Future<bool> addVacancy(String token, Map<String, dynamic> vData) async {
    final response = await http.post(
      Uri.parse(ApiConfig.vacancies),
      headers: _headers(token),
      body: jsonEncode(vData),
    );
    final data = jsonDecode(response.body);
    return response.statusCode == 200 && data['success'] == true;
  }

  static Future<bool> updateVacancy(String token, int id, Map<String, dynamic> vData) async {
    final response = await http.put(
      Uri.parse(ApiConfig.vacancy(id)),
      headers: _headers(token),
      body: jsonEncode(vData),
    );
    final data = jsonDecode(response.body);
    return response.statusCode == 200 && data['success'] == true;
  }

  static Future<bool> deleteVacancy(String token, int id) async {
    final response = await http.delete(
      Uri.parse(ApiConfig.vacancy(id)),
      headers: _headers(token),
    );
    final data = jsonDecode(response.body);
    return response.statusCode == 200 && data['success'] == true;
  }

  // === CATEGORIES (KATEGORI PRODUK) ===
  static Future<List<ProductCategory>> getCategories() async {
    final response = await http.get(Uri.parse(ApiConfig.categories));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      return (data['categories'] as List).map((c) => ProductCategory.fromJson(c)).toList();
    }
    return [];
  }

  static Future<bool> addCategory(String token, String name, String desc) async {
    final response = await http.post(
      Uri.parse(ApiConfig.categories),
      headers: _headers(token),
      body: jsonEncode({'name': name, 'description': desc}),
    );
    final data = jsonDecode(response.body);
    return response.statusCode == 200 && data['success'] == true;
  }

  static Future<bool> updateCategory(String token, int id, String name, String desc) async {
    final response = await http.put(
      Uri.parse(ApiConfig.category(id)),
      headers: _headers(token),
      body: jsonEncode({'name': name, 'description': desc}),
    );
    final data = jsonDecode(response.body);
    return response.statusCode == 200 && data['success'] == true;
  }

  static Future<bool> deleteCategory(String token, int id) async {
    final response = await http.delete(
      Uri.parse(ApiConfig.category(id)),
      headers: _headers(token),
    );
    final data = jsonDecode(response.body);
    return response.statusCode == 200 && data['success'] == true;
  }

  // === PROFIL PERUSAHAAN ===
  static Future<CompanyProfile> getCompanyProfile() async {
    final response = await http.get(Uri.parse(ApiConfig.companyProfile));
    final data = jsonDecode(response.body);
    if (response.statusCode == 200 && data['success'] == true) {
      return CompanyProfile.fromJson(data['profile']);
    }
    return CompanyProfile(
      name: 'PT Shafa Marwa Multiguna',
      description: 'Pemasaran digital & distribusi produk terpadu',
      address: 'Way Halim, Bandar Lampung',
      email: 'kontak@shafamarwa.com',
      phone: '+62 812-7890-1234',
    );
  }

  static Future<bool> updateCompanyProfile(String token, Map<String, dynamic> cData) async {
    final response = await http.put(
      Uri.parse(ApiConfig.companyProfile),
      headers: _headers(token),
      body: jsonEncode(cData),
    );
    final data = jsonDecode(response.body);
    return response.statusCode == 200 && data['success'] == true;
  }

  // === DASHBOARD STATS ===
  static Future<Map<String, dynamic>> getDashboardStats(
    String token, {
    String period = 'all',
  }) async {
    final uri = Uri.parse(ApiConfig.adminStats)
        .replace(queryParameters: {'period': period});
    final response = await http.get(uri, headers: _headers(token));
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 && data['success'] == true) {
      return data['stats'] as Map<String, dynamic>;
    }
    throw Exception(data['message'] ?? 'Gagal memuat statistik dashboard');
  }
}

