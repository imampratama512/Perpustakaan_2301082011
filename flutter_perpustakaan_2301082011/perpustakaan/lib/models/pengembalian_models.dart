import 'package:intl/intl.dart';
import 'peminjaman_models.dart';

class Pengembalian {
  final String id;
  final DateTime tanggalPengembalian;
  final int terlambat;
  final double denda;
  final Peminjaman peminjaman;

  Pengembalian({
    required this.id,
    required this.tanggalPengembalian,
    required this.terlambat,
    required this.denda,
    required this.peminjaman,
  });

  factory Pengembalian.fromJson(Map<String, dynamic> json) {
    return Pengembalian(
      id: json['id'].toString(),
      tanggalPengembalian: DateTime.parse(json['tanggal_pengembalian']),
      terlambat: int.parse(json['terlambat'].toString()),
      denda: double.parse(json['denda'].toString()),
      peminjaman: Peminjaman.fromJson(json['peminjaman']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tanggal_pengembalian': DateFormat('yyyy-MM-dd').format(tanggalPengembalian),
      'terlambat': terlambat,
      'denda': denda,
      'id_peminjaman': peminjaman.id,
    };
  }

  String get formattedTanggalPengembalian {
    return DateFormat('dd/MM/yyyy').format(tanggalPengembalian);
  }

  String get formattedDenda {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return currencyFormat.format(denda);
  }
}
