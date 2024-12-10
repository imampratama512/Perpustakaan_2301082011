import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BukuScreen extends StatefulWidget {
  const BukuScreen({Key? key}) : super(key: key);

  @override
  State<BukuScreen> createState() => _BukuScreenState();
}

class _BukuScreenState extends State<BukuScreen> {
  List<Map<String, dynamic>> _books = [];
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
            "http://localhost/flutter_perpustakaan_2301082011/api/buku.php"),
      );
      if (response.statusCode == 200) {
        final books =
            List<Map<String, dynamic>>.from(jsonDecode(response.body)['data']);

        // Cek status peminjaman untuk setiap buku
        for (var book in books) {
          try {
            final statusResponse = await http.get(
              Uri.parse(
                  "http://localhost/flutter_perpustakaan_2301082011/api/peminjaman.php?id_buku=${book['id']}"),
            );

            if (statusResponse.statusCode == 200) {
              final statusData = jsonDecode(statusResponse.body);
              book['status'] = statusData['data']['status'] ?? 'tersedia';
            } else {
              book['status'] = 'tersedia';
            }
          } catch (e) {
            print('Error checking status: $e');
            book['status'] = 'tersedia';
          }
        }

        setState(() {
          _books = books;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() => _isLoading = false);
    }
  }

  void _showDetail(Map<String, dynamic> book) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(book['judul'] ?? 'Detail Buku'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                book['url_gambar'] ?? '',
                height: 150,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150,
                  color: Colors.grey[300],
                  child: const Icon(Icons.book, size: 50),
                ),
              ),
              const SizedBox(height: 16),
              Text('Pengarang: ${book['pengarang'] ?? ''}'),
              const SizedBox(height: 8),
              Text('Penerbit: ${book['penerbit'] ?? ''}'),
              const SizedBox(height: 8),
              Text('Tahun Terbit: ${book['tahun_terbit'] ?? ''}'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: book['status'] == 'dipinjam'
                      ? Colors.orange[100]
                      : Colors.green[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  book['status'] == 'dipinjam' ? 'Dipinjam' : 'Tersedia',
                  style: TextStyle(
                    color: book['status'] == 'dipinjam'
                        ? Colors.orange[900]
                        : Colors.green[900],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _showFormDialog({Map<String, dynamic>? book}) {
    final _judulController = TextEditingController(text: book?['judul'] ?? '');
    final _pengarangController =
        TextEditingController(text: book?['pengarang'] ?? '');
    final _penerbitController =
        TextEditingController(text: book?['penerbit'] ?? '');
    final _tahunController =
        TextEditingController(text: book?['tahun_terbit'] ?? '');
    final _urlGambarController =
        TextEditingController(text: book?['url_gambar'] ?? '');
    final _formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(book == null ? 'Tambah Buku' : 'Edit Buku'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _judulController,
                  decoration: const InputDecoration(labelText: 'Judul'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Judul tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _pengarangController,
                  decoration: const InputDecoration(labelText: 'Pengarang'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Pengarang tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _penerbitController,
                  decoration: const InputDecoration(labelText: 'Penerbit'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Penerbit tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _tahunController,
                  decoration: const InputDecoration(labelText: 'Tahun Terbit'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Tahun terbit tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _urlGambarController,
                  decoration: const InputDecoration(labelText: 'URL Gambar'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'URL gambar tidak boleh kosong';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                if (book == null) {
                  await _tambahBuku(
                    _judulController.text,
                    _pengarangController.text,
                    _penerbitController.text,
                    _tahunController.text,
                    _urlGambarController.text,
                  );
                } else {
                  await _updateBuku(
                    book['id'],
                    _judulController.text,
                    _pengarangController.text,
                    _penerbitController.text,
                    _tahunController.text,
                    _urlGambarController.text,
                  );
                }
                Navigator.pop(context);
              }
            },
            child: Text(book == null ? 'Tambah' : 'Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _tambahBuku(String judul, String pengarang, String penerbit,
      String tahun, String urlGambar) async {
    try {
      final requestBody = {
        'action': 'create',
        'judul': judul,
        'pengarang': pengarang,
        'penerbit': penerbit,
        'tahun_terbit': tahun,
        'url_gambar': urlGambar,
      };
      print('Request body: $requestBody');

      final response = await http.post(
        Uri.parse(
            "http://localhost/flutter_perpustakaan_2301082011/api/buku.php"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      final data = jsonDecode(response.body);
      if (data['success']) {
        _getData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Buku berhasil ditambahkan')),
        );
      } else {
        throw Exception(data['message'] ?? 'Gagal menambahkan buku');
      }
    } catch (e) {
      print('Error detail: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _updateBuku(String id, String judul, String pengarang,
      String penerbit, String tahun, String urlGambar) async {
    try {
      final response = await http.post(
        Uri.parse(
            "http://localhost/flutter_perpustakaan_2301082011/api/buku.php"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'update',
          'id': id,
          'judul': judul,
          'pengarang': pengarang,
          'penerbit': penerbit,
          'tahun_terbit': tahun,
          'url_gambar': urlGambar,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['success']) {
        _getData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Buku berhasil diupdate')),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _deleteBuku(String id) async {
    try {
      final response = await http.post(
        Uri.parse(
            "http://localhost/flutter_perpustakaan_2301082011/api/buku.php"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'delete',
          'id': id,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['success']) {
        _getData();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Buku berhasil dihapus')),
        );
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _pinjamBuku(String id) async {
    try {
      final response = await http.post(
        Uri.parse(
            "http://localhost/flutter_perpustakaan_2301082011/api/peminjaman.php"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'pinjam',
          'id_buku': id,
          'tanggal_pinjam': DateTime.now().toString().split(' ')[0],
          'tanggal_kembali': DateTime.now()
              .add(const Duration(days: 7))
              .toString()
              .split(' ')[0],
        }),
      );

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
          'tanggal_pengembalian': DateTime.now().toString().split(' ')[0],
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Book Menu'),
        backgroundColor: Colors.red,
      ),
      backgroundColor: Colors.grey[850],
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _books.length,
              itemBuilder: (context, index) {
                final book = _books[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  color: Colors.grey[800],
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
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                style: TextStyle(color: Colors.grey[300]),
                              ),
                              Text(
                                'Penerbit: ${book['penerbit'] ?? ''}',
                                style: TextStyle(color: Colors.grey[300]),
                              ),
                              Text(
                                'Tahun: ${book['tahun_terbit'] ?? ''}',
                                style: TextStyle(color: Colors.grey[300]),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit,
                                        color: Colors.white),
                                    onPressed: () =>
                                        _showFormDialog(book: book),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete,
                                        color: Colors.white),
                                    onPressed: () => showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Hapus Buku'),
                                        content: const Text(
                                            'Apakah Anda yakin ingin menghapus buku ini?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Batal'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              _deleteBuku(book['id']);
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Hapus'),
                                          ),
                                        ],
                                      ),
                                    ),
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
    );
  }
}
