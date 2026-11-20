class Vacancy {
  final int id;
  final String title;
  final String position;
  final String description;
  final String qualifications;
  final String location;
  final String deadline;
  final String status;

  Vacancy({
    required this.id,
    required this.title,
    required this.position,
    required this.description,
    required this.qualifications,
    this.location = 'Bandar Lampung',
    this.deadline = '',
    this.status = 'Dibuka',
  });

  bool get isOpen => status == 'Dibuka';

  factory Vacancy.fromJson(Map<String, dynamic> json) {
    return Vacancy(
      id: json['id_lowongan'] is int
          ? json['id_lowongan']
          : int.parse(json['id_lowongan']?.toString() ?? '0'),
      title: json['judul_lowongan'] ?? '',
      position: json['posisi'] ?? '',
      description: json['deskripsi'] ?? '',
      qualifications: json['kualifikasi'] ?? '',
      location: json['lokasi'] ?? 'Bandar Lampung',
      deadline: json['batas_lamaran'] ?? '',
      status: json['status_lowongan'] ?? 'Dibuka',
    );
  }

  Map<String, dynamic> toJson() => {
        'id_lowongan': id,
        'judul_lowongan': title,
        'posisi': position,
        'deskripsi': description,
        'kualifikasi': qualifications,
        'lokasi': location,
        'batas_lamaran': deadline,
        'status_lowongan': status,
      };
}

