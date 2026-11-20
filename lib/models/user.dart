class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String role;
  final String status;
  final String? token;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.address = '',
    this.role = 'customer',
    this.status = 'Aktif',
    this.token,
  });

  bool get isAdmin => role.toLowerCase() == 'admin';
  bool get isActive => status == 'Aktif';

  factory User.fromJson(Map<String, dynamic> json, {String? token}) {
    final rawId = json['id'] ?? json['id_user'] ?? 0;
    final rawName = json['name'] ?? json['nama_lengkap'] ?? '';
    final rawPhone = json['phone'] ?? json['no_hp'] ?? '';
    final rawAddress = json['address'] ?? json['alamat'] ?? '';
    final rawRole = json['role'] ?? 'customer';
    final rawStatus = json['status'] ?? json['status_akun'] ?? 'Aktif';

    return User(
      id: rawId is int ? rawId : int.parse(rawId.toString()),
      name: rawName.toString(),
      email: (json['email'] ?? '').toString(),
      phone: rawPhone.toString(),
      address: rawAddress.toString(),
      role: rawRole.toString().toLowerCase() == 'admin' ? 'admin' : 'customer',
      status: rawStatus.toString(),
      token: token ?? json['token']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'role': role,
        'status': status,
      };

  User copyWith({
    String? name,
    String? phone,
    String? address,
    String? status,
    String? token,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      role: role,
      status: status ?? this.status,
      token: token ?? this.token,
    );
  }
}
