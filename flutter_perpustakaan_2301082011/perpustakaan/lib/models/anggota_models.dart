class Anggota {
  final String id;
  final String nim;
  final String nama;
  final String alamat;
  final String jenisKelamin;
  final String email;
  final String password;


  Anggota({
    required this.id,
    required this.nim,
    required this.nama,
    required this.alamat,
    required this.jenisKelamin,
    required this.email,
    required this.password,
  });

  factory Anggota.fromJson(Map<String, dynamic> json) {
    return Anggota(
      id: json['id'].toString(),
      nim: json['nim'] ?? '',
      nama: json['nama'] ?? '',
      alamat: json['alamat'] ?? '',
      jenisKelamin: json['jenis_kelamin'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nim': nim,
      'nama': nama,
      'alamat': alamat,
      'jenis_kelamin': jenisKelamin,
      'email': email,
      'password': password,
    };
  }
}
