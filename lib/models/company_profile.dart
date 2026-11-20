class CompanyProfile {
  final int id;
  final String name;
  final String description;
  final String address;
  final String email;
  final String phone;
  final String website;

  CompanyProfile({
    this.id = 1,
    required this.name,
    required this.description,
    required this.address,
    required this.email,
    required this.phone,
    this.website = 'www.shafamarwa.com',
  });

  factory CompanyProfile.fromJson(Map<String, dynamic> json) {
    return CompanyProfile(
      id: json['id_profil'] is int
          ? json['id_profil']
          : int.parse(json['id_profil']?.toString() ?? '1'),
      name: json['nama_perusahaan'] ?? 'PT Shafa Marwa Multiguna',
      description: json['deskripsi'] ?? '',
      address: json['alamat'] ?? '',
      email: json['email'] ?? '',
      phone: json['no_telepon'] ?? '',
      website: json['website'] ?? 'www.shafamarwa.com',
    );
  }

  Map<String, dynamic> toJson() => {
        'nama_perusahaan': name,
        'deskripsi': description,
        'alamat': address,
        'email': email,
        'no_telepon': phone,
        'website': website,
      };
}

