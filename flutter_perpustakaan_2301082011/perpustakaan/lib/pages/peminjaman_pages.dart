import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PeminjamanScreen extends StatefulWidget {
  final String? bukuId;

  const PeminjamanScreen({
    Key? key,
    this.bukuId,
  }) : super(key: key);

  @override
  State<PeminjamanScreen> createState() => _PeminjamanScreenState();
}

class _PeminjamanScreenState extends State<PeminjamanScreen> {
  List<Map<String, dynamic>> _peminjaman = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  Future<void> _getData() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse(
            "http://localhost/flutter_perpustakaan_2301082011/api/peminjaman.php?status=dipinjam"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            _peminjaman = List<Map<String, dynamic>>.from(data['data']);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Borrowing Book Menu'),
        backgroundColor: Colors.red,
      ),
      backgroundColor: Colors.grey[900],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _peminjaman.length,
              itemBuilder: (context, index) {
                final pinjam = _peminjaman[index];
                return Card(
                  color: Colors.grey[850],
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Gambar Buku
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            pinjam['url_gambar'] ?? '',
                            width: 100,
                            height: 150,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: 100,
                              height: 150,
                              color: Colors.grey[300],
                              child: const Icon(Icons.book, size: 50),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Informasi Buku
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pinjam['judul'] ?? '',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Pengarang: ${pinjam['pengarang'] ?? '-'}',
                                style: TextStyle(color: Colors.grey[300]),
                              ),
                              Text(
                                'Penerbit: ${pinjam['penerbit'] ?? '-'}',
                                style: TextStyle(color: Colors.grey[300]),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Tanggal Pinjam: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(pinjam['tanggal_pinjam']))}',
                                style: TextStyle(color: Colors.grey[300]),
                              ),
                              Text(
                                'Batas Kembali: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(pinjam['tanggal_kembali']))}',
                                style: TextStyle(
                                  color: Colors.red[400],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.orange[900],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Status: dipinjam',
                                  style: TextStyle(
                                    color: Colors.orange[100],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
