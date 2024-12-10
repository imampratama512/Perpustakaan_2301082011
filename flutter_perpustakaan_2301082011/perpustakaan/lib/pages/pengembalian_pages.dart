import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class PengembalianScreen extends StatefulWidget {
  const PengembalianScreen({Key? key}) : super(key: key);

  @override
  State<PengembalianScreen> createState() => _PengembalianScreenState();
}

class _PengembalianScreenState extends State<PengembalianScreen> {
  List<Map<String, dynamic>> _pengembalian = [];
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
            "http://localhost/flutter_perpustakaan_2301082011/api/peminjaman.php?status=dikembalikan"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          var pengembalianList = List<Map<String, dynamic>>.from(data['data']);

          pengembalianList.sort((a, b) {
            int idA = int.parse(a['id'].toString());
            int idB = int.parse(b['id'].toString());
            return idB.compareTo(idA);
          });

          setState(() {
            _pengembalian = pengembalianList;
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
        title: const Text('Book Return History'),
        backgroundColor: Colors.red,
      ),
      backgroundColor: Colors.grey[900],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _pengembalian.length,
              itemBuilder: (context, index) {
                final kembali = _pengembalian[index];
                return Card(
                  color: Colors.grey[850],
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            kembali['url_gambar'] ?? '',
                            width: 100,
                            height: 150,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: 100,
                              height: 150,
                              color: Colors.grey[800],
                              child: const Icon(Icons.book,
                                  size: 50, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                kembali['judul'] ?? '',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Pengarang: ${kembali['pengarang'] ?? '-'}',
                                style: TextStyle(color: Colors.grey[300]),
                              ),
                              Text(
                                'Penerbit: ${kembali['penerbit'] ?? '-'}',
                                style: TextStyle(color: Colors.grey[300]),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Tanggal Pinjam: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(kembali['tanggal_pinjam']))}',
                                style: TextStyle(color: Colors.grey[300]),
                              ),
                              Text(
                                'Tanggal Kembali: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(kembali['tanggal_kembali']))}',
                                style: TextStyle(
                                  color: Colors.green[400],
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
                                  color: Colors.green[900],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Status: dikembalikan',
                                  style: TextStyle(
                                    color: Colors.green[100],
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
