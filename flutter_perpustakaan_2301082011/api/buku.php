<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Content-Type');

include 'koneksi.php';

try {
    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        $query = "SELECT b.id, b.judul, b.pengarang, b.penerbit, 
                         b.tahun_terbit, b.url_gambar, b.stok
                  FROM buku b";
        
        $result = mysqli_query($conn, $query);
        
        if ($result) {
            $data = [];
            while ($row = mysqli_fetch_assoc($result)) {
                $data[] = $row;
            }
            echo json_encode([
                'success' => true,
                'data' => $data
            ]);
        } else {
            throw new Exception('Gagal mengambil data: ' . mysqli_error($conn));
        }
    } 
    else if ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $data = json_decode(file_get_contents('php://input'), true);
        $action = $data['action'] ?? '';

        switch ($action) {
            case 'create':
                if (empty($data['judul']) || empty($data['pengarang'])) {
                    throw new Exception('Judul dan pengarang wajib diisi');
                }

                $stmt = mysqli_prepare($conn, 
                    "INSERT INTO buku (judul, pengarang, penerbit, tahun_terbit, url_gambar, stok) 
                     VALUES (?, ?, ?, ?, ?, ?)"
                );
                
                $stok = 1; // Default stok
                mysqli_stmt_bind_param($stmt, "sssssi", 
                    $data['judul'],
                    $data['pengarang'],
                    $data['penerbit'],
                    $data['tahun_terbit'],
                    $data['url_gambar'],
                    $stok
                );
                
                if (!mysqli_stmt_execute($stmt)) {
                    throw new Exception('Gagal menambahkan buku: ' . mysqli_error($conn));
                }
                
                echo json_encode(['success' => true, 'message' => 'Buku berhasil ditambahkan']);
                break;

            case 'update':
                if (empty($data['id'])) {
                    throw new Exception('ID tidak ditemukan');
                }

                $stmt = mysqli_prepare($conn, 
                    "UPDATE buku SET judul=?, pengarang=?, penerbit=?, 
                     tahun_terbit=?, url_gambar=? WHERE id=?"
                );
                
                mysqli_stmt_bind_param($stmt, "sssssi",
                    $data['judul'],
                    $data['pengarang'],
                    $data['penerbit'],
                    $data['tahun_terbit'],
                    $data['url_gambar'],
                    $data['id']
                );
                
                if (!mysqli_stmt_execute($stmt)) {
                    throw new Exception('Gagal mengupdate buku: ' . mysqli_error($conn));
                }
                
                echo json_encode(['success' => true, 'message' => 'Buku berhasil diupdate']);
                break;

            case 'delete':
                if (empty($data['id'])) {
                    throw new Exception('ID tidak ditemukan');
                }

                // Cek apakah buku sedang dipinjam
                $stmt = mysqli_prepare($conn, "SELECT status FROM peminjaman WHERE id_buku = ? AND status = 'dipinjam'");
                mysqli_stmt_bind_param($stmt, "i", $data['id']);
                mysqli_stmt_execute($stmt);
                $result = mysqli_stmt_get_result($stmt);

                if (mysqli_num_rows($result) > 0) {
                    throw new Exception('Buku tidak dapat dihapus karena sedang dipinjam');
                }

                // Hapus buku
                $stmt = mysqli_prepare($conn, "DELETE FROM buku WHERE id = ?");
                mysqli_stmt_bind_param($stmt, "i", $data['id']);
                
                if (!mysqli_stmt_execute($stmt)) {
                    throw new Exception('Gagal menghapus buku: ' . mysqli_error($conn));
                }
                
                echo json_encode(['success' => true, 'message' => 'Buku berhasil dihapus']);
                break;

            default:
                throw new Exception('Action tidak valid');
        }
    }
} catch (Exception $e) {
    echo json_encode([
        'success' => false,
        'message' => $e->getMessage()
    ]);
}

mysqli_close($conn);
?>
