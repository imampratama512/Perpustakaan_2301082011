import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'peminjaman_pages.dart';
import 'pengembalian_pages.dart';
import 'buku_pages.dart';
import 'anggota_pages.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _books = [];
  bool _isLoading = true;
  int _selectedIndex = 0;

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
            "http://localhost/flutter_perpustakaan_2301082011/api/buku.php"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final books = List<Map<String, dynamic>>.from(data['data']);

          for (var book in books) {
            try {
              final statusResponse = await http.get(
                Uri.parse(
                    "http://localhost/flutter_perpustakaan_2301082011/api/peminjaman.php?id_buku=${book['id']}"),
              );

              print(
                  'Status response for book ${book['id']}: ${statusResponse.body}');

              if (statusResponse.statusCode == 200) {
                final statusData = jsonDecode(statusResponse.body);
                if (statusData['success'] && statusData['data'] != null) {
                  book['status'] = statusData['data']['status'] ?? 'tersedia';
                } else {
                  book['status'] = 'tersedia';
                }
              }
            } catch (e) {
              print('Error checking status: $e');
              book['status'] = 'tersedia';
            }
          }

          books.sort((a, b) {
            int idA = int.parse(a['id'].toString());
            int idB = int.parse(b['id'].toString());
            return idB.compareTo(idA);
          });

          setState(() {
            _books = books;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pinjamBuku(String id) async {
    try {
      print('Meminjam buku dengan ID: $id');

      final response = await http.post(
        Uri.parse(
            "http://localhost/flutter_perpustakaan_2301082011/api/peminjaman.php"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'pinjam',
          'id_buku': id,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final data = jsonDecode(response.body);
      if (data['success']) {
        _getData(); // Refresh data
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Buku berhasil dipinjam')),
        );
      } else {
        throw Exception(data['message']);
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _kembalikanBuku(String id) async {
    try {
      final response = await http.post(
        Uri.parse(
            "http://localhost/flutter_perpustakaan_2301082011/api/peminjaman.php"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'kembali',
          'id_buku': id,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['success']) {
        _getData(); // Refresh data
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Buku berhasil dikembalikan')),
        );
      } else {
        throw Exception(data['message']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Halaman Home - tidak perlu navigasi
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PeminjamanScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PengembalianScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BukuScreen()),
        );
        break;
      case 4:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AnggotaScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70.0),
        child: AppBar(
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Center(
              child: Text(
                'PERPUSTAKAAN PNP',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                softWrap: false,
                overflow: TextOverflow.visible,
              ),
            ),
          ),
          backgroundColor: Colors.red,
        ),
      ),
      body: Container(
        color: Colors.grey[900],
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _books.length,
                      itemBuilder: (context, index) {
                        final book = _books[index];
                        return Card(
                          color: Colors.grey[850],
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    book['url_gambar'] ?? '',
                                    width: 100,
                                    height: 150,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                      width: 100,
                                      height: 150,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.book, size: 50),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        book['judul'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Pengarang: ${book['pengarang'] ?? ''}',
                                        style: const TextStyle(
                                            color: Colors.white70),
                                      ),
                                      Text(
                                        'Penerbit: ${book['penerbit'] ?? ''}',
                                        style: const TextStyle(
                                            color: Colors.white70),
                                      ),
                                      Text(
                                        'Tahun: ${book['tahun_terbit'] ?? ''}',
                                        style: const TextStyle(
                                            color: Colors.white70),
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: book['status'] == 'dipinjam'
                                              ? const Color(0xFF424242)
                                              : Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          book['status'] == 'dipinjam'
                                              ? 'Unavailable'
                                              : 'Available',
                                          style: TextStyle(
                                            color: book['status'] == 'dipinjam'
                                                ? Colors.white
                                                : Colors.black,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          if (book['status'] == 'tersedia')
                                            ElevatedButton(
                                              onPressed: () =>
                                                  _pinjamBuku(book['id']),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                                foregroundColor: Colors.white,
                                              ),
                                              child: const Text('BORROW BOOK'),
                                            ),
                                          if (book['status'] == 'dipinjam')
                                            ElevatedButton(
                                              onPressed: () =>
                                                  _kembalikanBuku(book['id']),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.grey,
                                                foregroundColor: Colors.white,
                                              ),
                                              child: const Text('RETURN BOOK'),
                                            ),
                                        ],
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
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.red,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'BORROWING',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_return),
            label: 'RETURN',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'BOOK',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'MEMBER',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[400],
        unselectedItemColor: Colors.grey[400],
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
