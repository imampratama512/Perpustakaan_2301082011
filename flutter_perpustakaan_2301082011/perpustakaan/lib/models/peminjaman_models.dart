import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'anggota_models.dart';
import 'buku_models.dart';

class Peminjaman {
  final String id;
  final DateTime tanggalPinjam;
  final DateTime tanggalKembali;
  final String status;
  final Anggota anggota;
  final Buku buku;

  Peminjaman({
    required this.id,
    required this.tanggalPinjam,
    required this.tanggalKembali,
    required this.status,
    required this.anggota,
    required this.buku,
  });

  factory Peminjaman.fromJson(Map<String, dynamic> json) {
    return Peminjaman(
      id: json['id'].toString(),
      tanggalPinjam: DateTime.parse(json['tanggal_pinjam']),
      tanggalKembali: DateTime.parse(json['tanggal_kembali']),
      status: json['status'] ?? 'dipinjam',
      anggota: Anggota.fromJson(json['anggota']),
      buku: Buku.fromJson(json['buku']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tanggal_pinjam': DateFormat('yyyy-MM-dd').format(tanggalPinjam),
      'tanggal_kembali': DateFormat('yyyy-MM-dd').format(tanggalKembali),
      'status': status,
      'id_anggota': anggota.id,
      'id_buku': buku.id,
    };
  }

  // Getter untuk format tanggal yang lebih mudah dibaca
  String get formattedTanggalPinjam {
    return DateFormat('dd/MM/yyyy').format(tanggalPinjam);
  }

  String get formattedTanggalKembali {
    return DateFormat('dd/MM/yyyy').format(tanggalKembali);
  }

  // Getter untuk status
  bool get isDipinjam => status == 'dipinjam';
  bool get isDikembalikan => status == 'dikembalikan';

  // Getter untuk menghitung keterlambatan
  int get keterlambatan {
    if (isDikembalikan) return 0;

    final today = DateTime.now();
    if (today.isAfter(tanggalKembali)) {
      return today.difference(tanggalKembali).inDays;
    }
    return 0;
  }

  // Getter untuk menghitung denda (Rp 1000 per hari)
  double get denda => keterlambatan * 1000;

  // Getter untuk format denda
  String get formattedDenda {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return currencyFormat.format(denda);
  }

  // Getter untuk status dengan format yang lebih baik
  String get statusText {
    switch (status) {
      case 'dipinjam':
        return 'Dipinjam';
      case 'dikembalikan':
        return 'Dikembalikan';
      default:
        return status;
    }
  }

  // Getter untuk warna status
  Color get statusColor {
    switch (status) {
      case 'dipinjam':
        return Colors.blue;
      case 'dikembalikan':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Method untuk mengecek apakah peminjaman sudah terlambat
  bool get isTerlambat {
    if (isDikembalikan) return false;
    return DateTime.now().isAfter(tanggalKembali);
  }

  // Method untuk mendapatkan sisa hari peminjaman
  int get sisaHari {
    if (isDikembalikan) return 0;

    final today = DateTime.now();
    if (today.isBefore(tanggalKembali)) {
      return tanggalKembali.difference(today).inDays;
    }
    return 0;
  }

  // Method untuk mendapatkan pesan status
  String get statusMessage {
    if (isDikembalikan) {
      return 'Buku telah dikembalikan';
    }
    if (isTerlambat) {
      return 'Terlambat $keterlambatan hari\nDenda: $formattedDenda';
    }
    return 'Sisa waktu: $sisaHari hari';
  }

  // Method untuk copy dengan perubahan
  Peminjaman copyWith({
    String? id,
    DateTime? tanggalPinjam,
    DateTime? tanggalKembali,
    String? status,
    Anggota? anggota,
    Buku? buku,
  }) {
    return Peminjaman(
      id: id ?? this.id,
      tanggalPinjam: tanggalPinjam ?? this.tanggalPinjam,
      tanggalKembali: tanggalKembali ?? this.tanggalKembali,
      status: status ?? this.status,
      anggota: anggota ?? this.anggota,
      buku: buku ?? this.buku,
    );
  }
}
