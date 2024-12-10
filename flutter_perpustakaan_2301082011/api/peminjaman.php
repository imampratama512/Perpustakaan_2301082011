<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Content-Type');

include 'koneksi.php';

error_reporting(E_ALL);
ini_set('display_errors', 1);

try {
    if ($_SERVER['REQUEST_METHOD'] === 'GET') {
        if (isset($_GET['id_buku'])) {
            // Cek status peminjaman buku
            $id_buku = mysqli_real_escape_string($conn, $_GET['id_buku']);
            $query = "SELECT * FROM peminjaman 
                     WHERE id_buku = '$id_buku' 
                     AND status = 'dipinjam' 
                     ORDER BY tanggal_pinjam DESC 
                     LIMIT 1";
            
            $result = mysqli_query($conn, $query);
            $data = mysqli_fetch_assoc($result);
            
            echo json_encode([
                'success' => true,
                'data' => $data
            ]);
        } else {
            // Tampilkan semua data peminjaman berdasarkan status
            $status = isset($_GET['status']) ? mysqli_real_escape_string($conn, $_GET['status']) : 'dipinjam';
            
            $query = "SELECT p.*, b.judul, b.pengarang, b.url_gambar, b.penerbit 
                     FROM peminjaman p 
                     JOIN buku b ON p.id_buku = b.id 
                     WHERE p.status = '$status'
                     ORDER BY p.tanggal_pinjam DESC";
            
            $result = mysqli_query($conn, $query);
            $data = [];
            while ($row = mysqli_fetch_assoc($result)) {
                $data[] = $row;
            }
            
            echo json_encode([
                'success' => true,
                'data' => $data
            ]);
        }
    }
    elseif ($_SERVER['REQUEST_METHOD'] === 'POST') {
        $data = json_decode(file_get_contents('php://input'), true);
        
        if ($data['action'] === 'pinjam') {
            if (!isset($data['id_buku'])) {
                throw new Exception("ID buku tidak ditemukan");
            }
            
            $id_buku = mysqli_real_escape_string($conn, $data['id_buku']);
            
            // Debug log
            error_log("Mencoba meminjam buku dengan ID: " . $id_buku);
            
            // Cek apakah buku sedang dipinjam
            $check_query = "SELECT id FROM peminjaman 
                          WHERE id_buku = '$id_buku' 
                          AND status = 'dipinjam'";
            
            $check_result = mysqli_query($conn, $check_query);
            if (!$check_result) {
                throw new Exception("Error checking buku: " . mysqli_error($conn));
            }
            
            if (mysqli_num_rows($check_result) > 0) {
                throw new Exception("Buku sedang dipinjam");
            }
            
            // Insert data peminjaman
            $insert_query = "INSERT INTO peminjaman 
                           (id_buku, id_anggota, tanggal_pinjam, tanggal_kembali, status) 
                           VALUES 
                           ('$id_buku', '1', CURRENT_DATE, DATE_ADD(CURRENT_DATE, INTERVAL 7 DAY), 'dipinjam')";
            
            error_log("Query insert: " . $insert_query); // Debug log
            
            if (!mysqli_query($conn, $insert_query)) {
                throw new Exception("Error insert data: " . mysqli_error($conn));
            }
            
            $new_id = mysqli_insert_id($conn);
            error_log("ID baru: " . $new_id); // Debug log
            
            // Ambil data yang baru diinsert
            $select_query = "SELECT p.*, b.judul 
                           FROM peminjaman p 
                           JOIN buku b ON p.id_buku = b.id 
                           WHERE p.id = '$new_id'";
            
            $result = mysqli_query($conn, $select_query);
            if (!$result) {
                throw new Exception("Error mengambil data baru: " . mysqli_error($conn));
            }
            
            $inserted_data = mysqli_fetch_assoc($result);
            
            echo json_encode([
                'success' => true,
                'message' => 'Buku berhasil dipinjam',
                'data' => $inserted_data
            ]);
        }
        elseif ($data['action'] === 'kembali') {
            if (!isset($data['id_buku'])) {
                throw new Exception('ID buku tidak ditemukan');
            }
            
            $id_buku = mysqli_real_escape_string($conn, $data['id_buku']);
            
            // Cek apakah buku sedang dipinjam
            $check_query = "SELECT id FROM peminjaman 
                          WHERE id_buku = '$id_buku' 
                          AND status = 'dipinjam'";
            
            $check_result = mysqli_query($conn, $check_query);
            
            if (mysqli_num_rows($check_result) === 0) {
                throw new Exception('Buku tidak dalam status dipinjam');
            }
            
            // Update status menjadi dikembalikan
            $update_query = "UPDATE peminjaman 
                           SET status = 'dikembalikan',
                               tanggal_kembali = CURRENT_DATE
                           WHERE id_buku = '$id_buku' 
                           AND status = 'dipinjam'";
            
            if (!mysqli_query($conn, $update_query)) {
                throw new Exception('Gagal mengembalikan buku: ' . mysqli_error($conn));
            }
            
            echo json_encode([
                'success' => true,
                'message' => 'Buku berhasil dikembalikan'
            ]);
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