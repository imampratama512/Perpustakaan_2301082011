<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Content-Type');

include 'koneksi.php';

try {
    $method = $_SERVER['REQUEST_METHOD'];
    
    if ($method === 'GET') {
        // Read - Mengambil data anggota kecuali ID 1 dan mengurutkan berdasarkan ID
        $stmt = mysqli_prepare($conn, "SELECT id, nim, nama, alamat, jenis_kelamin, email FROM anggota WHERE id != 1 ORDER BY id ASC");
        mysqli_stmt_execute($stmt);
        $result = mysqli_stmt_get_result($stmt);
        
        $data = array();
        while ($row = mysqli_fetch_assoc($result)) {
            $data[] = $row;
        }
        
        echo json_encode(['success' => true, 'data' => $data]);
        
    } else if ($method === 'POST') {
        $data = json_decode(file_get_contents('php://input'), true);
        $action = $data['action'] ?? '';
        
        switch($action) {
            case 'create':
                // Validasi data wajib
                if (empty($data['nim']) || empty($data['nama'])) {
                    throw new Exception('NIM dan Nama wajib diisi');
                }

                // Cek NIM sudah terdaftar
                $stmt = mysqli_prepare($conn, "SELECT id FROM anggota WHERE nim = ?");
                mysqli_stmt_bind_param($stmt, "s", $data['nim']);
                mysqli_stmt_execute($stmt);
                $result = mysqli_stmt_get_result($stmt);
                
                if (mysqli_num_rows($result) > 0) {
                    throw new Exception('NIM sudah terdaftar');
                }

                // Insert data anggota baru
                $stmt = mysqli_prepare($conn, 
                    "INSERT INTO anggota (nim, nama, alamat, jenis_kelamin, email, password) 
                     VALUES (?, ?, ?, ?, ?, ?)"
                );
                
                $password = $data['nim']; // Password default sama dengan NIM
                mysqli_stmt_bind_param($stmt, "ssssss", 
                    $data['nim'],
                    $data['nama'],
                    $data['alamat'],
                    $data['jenis_kelamin'],
                    $data['email'],
                    $password
                );
                
                if (!mysqli_stmt_execute($stmt)) {
                    throw new Exception('Gagal menambahkan anggota: ' . mysqli_error($conn));
                }
                
                echo json_encode(['success' => true, 'message' => 'Anggota berhasil ditambahkan']);
                break;

            case 'update':
                if (empty($data['id'])) {
                    throw new Exception('ID tidak ditemukan');
                }

                $updates = array();
                $types = "";
                $values = array();

                // Menyiapkan data yang akan diupdate
                if (!empty($data['nama'])) {
                    $updates[] = "nama = ?";
                    $types .= "s";
                    $values[] = $data['nama'];
                }
                if (!empty($data['alamat'])) {
                    $updates[] = "alamat = ?";
                    $types .= "s";
                    $values[] = $data['alamat'];
                }
                if (!empty($data['jenis_kelamin'])) {
                    $updates[] = "jenis_kelamin = ?";
                    $types .= "s";
                    $values[] = $data['jenis_kelamin'];
                }
                if (!empty($data['email'])) {
                    $updates[] = "email = ?";
                    $types .= "s";
                    $values[] = $data['email'];
                }

                if (count($updates) > 0) {
                    $query = "UPDATE anggota SET " . implode(', ', $updates) . " WHERE id = ?";
                    $stmt = mysqli_prepare($conn, $query);
                    
                    $types .= "i"; // untuk ID
                    $values[] = $data['id'];
                    
                    mysqli_stmt_bind_param($stmt, $types, ...$values);
                    
                    if (!mysqli_stmt_execute($stmt)) {
                        throw new Exception('Gagal mengupdate anggota: ' . mysqli_error($conn));
                    }
                    
                    echo json_encode(['success' => true, 'message' => 'Data anggota berhasil diupdate']);
                } else {
                    throw new Exception('Tidak ada data yang diupdate');
                }
                break;

            case 'delete':
                if (empty($data['id'])) {
                    throw new Exception('ID tidak ditemukan');
                }

                $stmt = mysqli_prepare($conn, "DELETE FROM anggota WHERE id = ?");
                mysqli_stmt_bind_param($stmt, "i", $data['id']);
                
                if (!mysqli_stmt_execute($stmt)) {
                    throw new Exception('Gagal menghapus anggota: ' . mysqli_error($conn));
                }
                
                echo json_encode(['success' => true, 'message' => 'Anggota berhasil dihapus']);
                break;

            case 'login':
                if (empty($data['nim']) || empty($data['password'])) {
                    throw new Exception('NIM dan password harus diisi');
                }

                $stmt = mysqli_prepare($conn, "SELECT id, nim, nama, alamat, jenis_kelamin, email FROM anggota WHERE nim = ? AND password = ?");
                mysqli_stmt_bind_param($stmt, "ss", $data['nim'], $data['password']);
                mysqli_stmt_execute($stmt);
                $result = mysqli_stmt_get_result($stmt);

                if ($user = mysqli_fetch_assoc($result)) {
                    echo json_encode([
                        'success' => true,
                        'message' => 'Login berhasil',
                        'data' => $user
                    ]);
                } else {
                    throw new Exception('NIM atau password salah');
                }
                break;

            default:
                throw new Exception('Action tidak valid');
        }
        
    } else {
        throw new Exception('Method tidak diizinkan');
    }

} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}

mysqli_close($conn);
?>