import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _user?.token;
  bool get isLoggedIn => _user != null;
  bool get isAdmin => _user?.isAdmin ?? false;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await AuthService.login(email, password);
      final token = data['token'] as String;
      _user = User.fromJson(data['user'] as Map<String, dynamic>, token: token);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(
      String name, String email, String password, String phone) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await AuthService.register(name, email, password, phone);
      final token = data['token'] as String;
      _user = User.fromJson(data['user'] as Map<String, dynamic>, token: token);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', token);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    notifyListeners();
  }

  Future<bool> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null) return false;

    try {
      final data = await AuthService.getProfile(token);
      _user = User.fromJson(data['user'] as Map<String, dynamic>, token: token);
      notifyListeners();
      return true;
    } catch (e) {
      await prefs.remove('auth_token');
      return false;
    }
  }

  Future<bool> updateProfile(
      String name, String phone, String address) async {
    if (_user?.token == null) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data =
          await AuthService.updateProfile(_user!.token!, name, phone, address);
      _user = User.fromJson(
          data['user'] as Map<String, dynamic>, token: _user!.token);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

