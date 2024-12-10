import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AnggotaScreen extends StatefulWidget {
  const AnggotaScreen({Key? key}) : super(key: key);

  @override
  State<AnggotaScreen> createState() => _AnggotaScreenState();
}

class _AnggotaScreenState extends State<AnggotaScreen> {
  List<Map<String, dynamic>> _anggota = [];
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
            "http://localhost/flutter_perpustakaan_2301082011/api/anggota.php"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success']) {
          setState(() {
            _anggota = List<Map<String, dynamic>>.from(data['data']);
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteAnggota(String id) async {
    try {
      final response = await http.post(
        Uri.parse(
            'http://localhost/flutter_perpustakaan_2301082011/api/anggota.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'delete',
          'id': id,
        }),
      );

      final data = jsonDecode(response.body);
      if (data['success']) {
        await _getData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Anggota berhasil dihapus')),
          );
        }
      } else {
        throw Exception(data['message'] ?? 'Gagal menghapus anggota');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showDeleteConfirmation(String id) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: const Text('Apakah Anda yakin ingin menghapus anggota ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteAnggota(id);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Member Menu'),
        backgroundColor: Colors.red,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormAnggotaScreen()),
          ).then((_) => _getData());
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
      backgroundColor: Colors.grey[850],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _anggota.length,
              itemBuilder: (context, index) {
                final anggota = _anggota[index];
                return Card(
                  color: Colors.grey[800],
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    title: Text(
                      anggota['nama'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NIM: ${anggota['nim'] ?? ''}',
                          style: TextStyle(color: Colors.grey[300]),
                        ),
                        Text(
                          'Jenis Kelamin: ${anggota['jenis_kelamin'] == 'L' ? 'Laki-laki' : 'Perempuan'}',
                          style: TextStyle(color: Colors.grey[300]),
                        ),
                        Text(
                          'Alamat: ${anggota['alamat'] ?? ''}',
                          style: TextStyle(color: Colors.grey[300]),
                        ),
                        Text(
                          'Email: ${anggota['email'] ?? ''}',
                          style: TextStyle(color: Colors.grey[300]),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          color: Colors.blue,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FormAnggotaScreen(anggota: anggota),
                              ),
                            ).then((_) => _getData());
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () =>
                              _showDeleteConfirmation(anggota['id']),
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

class FormAnggotaScreen extends StatefulWidget {
  final Map<String, dynamic>? anggota;

  const FormAnggotaScreen({Key? key, this.anggota}) : super(key: key);

  @override
  State<FormAnggotaScreen> createState() => _FormAnggotaScreenState();
}

class _FormAnggotaScreenState extends State<FormAnggotaScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _jenisKelamin = 'L'; // Default value
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.anggota != null) {
      _namaController.text = widget.anggota!['nama'] ?? '';
      _nimController.text = widget.anggota!['nim'] ?? '';
      _alamatController.text = widget.anggota!['alamat'] ?? '';
      _emailController.text = widget.anggota!['email'] ?? '';
      _jenisKelamin = widget.anggota!['jenis_kelamin'] ?? 'L';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.anggota == null ? 'Tambah Anggota' : 'Edit Anggota'),
        backgroundColor: Colors.grey[900],
      ),
      backgroundColor: Colors.grey[850],
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: InputDecoration(
                  labelText: 'Nama',
                  labelStyle: TextStyle(color: Colors.grey[300]),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[600]!),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nimController,
                decoration: InputDecoration(
                  labelText: 'NIM',
                  labelStyle: TextStyle(color: Colors.grey[300]),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[600]!),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'NIM tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _jenisKelamin,
                decoration: InputDecoration(
                  labelText: 'Jenis Kelamin',
                  labelStyle: TextStyle(color: Colors.grey[300]),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[600]!),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
                  DropdownMenuItem(value: 'P', child: Text('Perempuan')),
                ],
                onChanged: (value) {
                  setState(() {
                    _jenisKelamin = value!;
                  });
                },
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _alamatController,
                decoration: InputDecoration(
                  labelText: 'Alamat',
                  labelStyle: TextStyle(color: Colors.grey[300]),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[600]!),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Alamat tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(color: Colors.grey[300]),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[600]!),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Email tidak boleh kosong';
                  }
                  if (!value.contains('@')) {
                    return 'Email tidak valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse(
            'http://localhost/flutter_perpustakaan_2301082011/api/anggota.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': widget.anggota == null ? 'create' : 'update',
          if (widget.anggota != null) 'id': widget.anggota!['id'],
          'nama': _namaController.text,
          'nim': _nimController.text,
          'jenis_kelamin': _jenisKelamin,
          'alamat': _alamatController.text,
          'email': _emailController.text,
          'password': _nimController.text, // Password default sama dengan NIM
        }),
      );

      final data = jsonDecode(response.body);
      if (data['success']) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.anggota == null
                ? 'Anggota berhasil ditambahkan'
                : 'Anggota berhasil diperbarui'),
          ),
        );
      } else {
        throw Exception(data['message']);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nimController.dispose();
    _alamatController.dispose();
    _emailController.dispose();
    super.dispose();
  }
}
