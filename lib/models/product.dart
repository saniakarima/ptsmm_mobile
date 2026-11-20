import 'package:flutter/material.dart';

class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String category;
  final int idCategory;
  final String imageUrl;
  final int stock;
  final int weight; // Dalam gram untuk Biteship
  final String unit;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.idCategory = 1,
    this.imageUrl = '',
    this.stock = 100,
    this.weight = 500,
    this.unit = 'pcs',
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['id_produk'] ?? 0;
    final rawName = json['name'] ?? json['nama_produk'] ?? '';
    final rawDesc = json['description'] ?? json['deskripsi'] ?? '';
    final rawPrice = json['price'] ?? json['harga'] ?? 0;
    final rawCat = json['category'] ?? json['nama_kategori'] ?? 'Umum';
    final rawCatId = json['id_category'] ?? json['id_kategori'] ?? 1;
    final rawStock = json['stock'] ?? json['stok'] ?? 100;
    final rawWeight = json['weight'] ?? json['berat'] ?? 500;
    final rawUnit = json['unit'] ?? json['satuan'] ?? 'pcs';
    final rawImage = json['image_url'] ?? json['gambar'] ?? '';

    return Product(
      id: rawId is int ? rawId : int.parse(rawId.toString()),
      name: rawName.toString(),
      description: rawDesc.toString(),
      price: rawPrice is double ? rawPrice : double.parse(rawPrice.toString()),
      category: rawCat.toString(),
      idCategory: rawCatId is int ? rawCatId : int.parse(rawCatId.toString()),
      imageUrl: rawImage.toString(),
      stock: rawStock is int ? rawStock : int.parse(rawStock.toString()),
      weight: rawWeight is int ? rawWeight : int.parse(rawWeight.toString()),
      unit: rawUnit.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'price': price,
        'category': category,
        'id_category': idCategory,
        'image_url': imageUrl,
        'stock': stock,
        'weight': weight,
        'unit': unit,
      };

  // Icon & Styling berdasarkan kategori
  static const Map<String, List<IconData>> _categoryIcons = {
    'Pupuk Organik Pertanian': [Icons.eco_rounded, Icons.grass_rounded, Icons.nature_rounded],
    'Pupuk Organik': [Icons.eco_rounded, Icons.grass_rounded, Icons.nature_rounded],
    'Produk Perikanan': [Icons.water_rounded, Icons.waves_rounded, Icons.water_drop_rounded],
    'Perikanan': [Icons.water_rounded, Icons.waves_rounded, Icons.water_drop_rounded],
    'Produk Herbal': [Icons.local_florist_rounded, Icons.healing_rounded],
    'Herbal': [Icons.local_florist_rounded, Icons.healing_rounded],
    'Produk Kopi': [Icons.coffee_rounded, Icons.emoji_food_beverage_rounded],
    'Kopi': [Icons.coffee_rounded, Icons.emoji_food_beverage_rounded],
    'Vitamin Anak': [Icons.child_care_rounded, Icons.favorite_rounded],
  };

  static const Map<String, Color> _categoryColors = {
    'Pupuk Organik Pertanian': Color(0xFFE4F2E5),
    'Pupuk Organik': Color(0xFFE4F2E5),
    'Produk Perikanan': Color(0xFFDDEFFA),
    'Perikanan': Color(0xFFDDEFFA),
    'Produk Herbal': Color(0xFFF8E6DB),
    'Herbal': Color(0xFFF8E6DB),
    'Produk Kopi': Color(0xFFECE0D5),
    'Kopi': Color(0xFFECE0D5),
    'Vitamin Anak': Color(0xFFF8E7F0),
  };

  static const Map<String, Color> _categoryIconColors = {
    'Pupuk Organik Pertanian': Color(0xFF2A7A45),
    'Pupuk Organik': Color(0xFF2A7A45),
    'Produk Perikanan': Color(0xFF1E6CB8),
    'Perikanan': Color(0xFF1E6CB8),
    'Produk Herbal': Color(0xFFD9531E),
    'Herbal': Color(0xFFD9531E),
    'Produk Kopi': Color(0xFF6B4226),
    'Kopi': Color(0xFF6B4226),
    'Vitamin Anak': Color(0xFFB8286A),
  };

  IconData get icon {
    final icons = _categoryIcons[category] ?? [Icons.inventory_2_rounded];
    return icons[id % icons.length];
  }

  Color get color => _categoryColors[category] ?? const Color(0xFFEAF5FF);

  Color get iconColor => _categoryIconColors[category] ?? const Color(0xFF173B67);

  static List<Product> get demoProducts => [
    Product(
      id: 1,
      name: 'SMART BRAIN',
      description: 'Vitamin dan nutrisi tumbuh kembang otak anak dengan formula herbal alami.',
      price: 35000,
      category: 'Vitamin Anak',
      stock: 150,
      weight: 250,
    ),
    Product(
      id: 2,
      name: 'AQUA FISH',
      description: 'Suplemen probiotik pendukung kualitas air tambak dan kesehatan ikan.',
      price: 60000,
      category: 'Produk Perikanan',
      stock: 94,
      weight: 500,
    ),
    Product(
      id: 3,
      name: 'Pupuk AQ GREEN (berteknologi mikroba)',
      description: 'Pupuk organik berteknologi mikroba majemuk penyubur tanah dan tanaman.',
      price: 60000,
      category: 'Produk Perikanan',
      stock: 60,
      weight: 1000,
    ),
    Product(
      id: 4,
      name: 'AQ Green (pupuk hayati majemuk)',
      description: 'Pupuk hayati cair konsentrat tinggi untuk pertanian ramah lingkungan.',
      price: 45000,
      category: 'Pupuk Organik Pertanian',
      stock: 79,
      weight: 1000,
    ),
    Product(
      id: 5,
      name: 'AQUA GREEN (Anti Rontok & Roboh)',
      description: 'Formula pencegah kerontokan bunga dan batang tanaman pertanian.',
      price: 60000,
      category: 'Pupuk Organik Pertanian',
      stock: 120,
      weight: 1000,
    ),
  ];
}
