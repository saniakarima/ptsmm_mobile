class ProductCategory {
  final int id;
  final String name;
  final String description;

  ProductCategory({
    required this.id,
    required this.name,
    this.description = '',
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id_kategori'] is int
          ? json['id_kategori']
          : int.parse(json['id_kategori']?.toString() ?? '0'),
      name: json['nama_kategori'] ?? '',
      description: json['deskripsi'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id_kategori': id,
        'nama_kategori': name,
        'deskripsi': description,
      };
}

