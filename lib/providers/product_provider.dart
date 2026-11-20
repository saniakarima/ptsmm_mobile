import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/product_service.dart';
import '../services/admin_service.dart';

class ProductProvider extends ChangeNotifier {
  List<Product> _products = [];
  List<String> _categories = ['Semua'];
  String _selectedCategory = 'Semua';
  String _searchQuery = '';
  bool _isLoading = false;

  List<Product> get products => _products;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  List<Product> get filteredProducts {
    return _products.where((product) {
      final matchCategory =
          _selectedCategory == 'Semua' || product.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchQuery =
          product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              product.description
                  .toLowerCase()
                  .contains(_searchQuery.toLowerCase());
      return matchCategory && matchQuery;
    }).toList();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Product? getProductById(int id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      final results = await Future.wait([
        ProductService.getProducts(),
        AdminService.getCategories(),
      ]);

      _products = results[0] as List<Product>;
      final catList = results[1] as List;
      
      final names = <String>{'Semua'};
      for (final c in catList) {
        if (c.name.isNotEmpty) names.add(c.name);
      }
      for (final p in _products) {
        if (p.category.isNotEmpty) names.add(p.category);
      }
      _categories = names.toList();
    } catch (_) {
      _products = Product.demoProducts;
      _categories = [
        'Semua',
        'Pupuk Organik Pertanian',
        'Produk Perikanan',
        'Produk Herbal',
        'Produk Kopi',
        'Vitamin Anak'
      ];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshProducts() async {
    try {
      _products = await ProductService.getProducts();
      final catList = await AdminService.getCategories();
      final names = <String>{'Semua'};
      for (final c in catList) {
        if (c.name.isNotEmpty) names.add(c.name);
      }
      for (final p in _products) {
        if (p.category.isNotEmpty) names.add(p.category);
      }
      _categories = names.toList();
    } catch (_) {
      if (_products.isEmpty) {
        _products = Product.demoProducts;
      }
    }
    notifyListeners();
  }

  Future<bool> addProduct(String name, String description, double price,
      String category, int stock, {String? token, int weight = 500}) async {
    final newProductData = {
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'stock': stock,
      'weight': weight,
    };

    try {
      final created = await ProductService.createProduct(token ?? 'token', newProductData);
      _products.insert(0, created);
      if (!_categories.contains(category)) {
        _categories.add(category);
      }
      notifyListeners();
      return true;
    } catch (_) {
      final newId = (_products.map((p) => p.id).fold<int>(0, (a, b) => a > b ? a : b)) + 1;
      final created = Product(
        id: newId,
        name: name,
        description: description,
        price: price,
        category: category,
        stock: stock,
        weight: weight,
      );
      _products.insert(0, created);
      if (!_categories.contains(category)) {
        _categories.add(category);
      }
      notifyListeners();
      return true;
    }
  }

  Future<bool> updateProduct(int id, String name, String description, double price,
      String category, int stock, {String? token, int weight = 500}) async {
    final updateData = {
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'stock': stock,
      'weight': weight,
    };

    try {
      await ProductService.updateProduct(token ?? 'token', id, updateData);
    } catch (_) {}

    final index = _products.indexWhere((p) => p.id == id);
    if (index >= 0) {
      _products[index] = Product(
        id: id,
        name: name,
        description: description,
        price: price,
        category: category,
        stock: stock,
        weight: weight,
      );
      if (!_categories.contains(category)) {
        _categories.add(category);
      }
      notifyListeners();
    }
    return true;
  }

  Future<bool> deleteProduct(int id, {String? token}) async {
    try {
      await ProductService.deleteProduct(token ?? 'token', id);
    } catch (_) {}
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
    return true;
  }
}
