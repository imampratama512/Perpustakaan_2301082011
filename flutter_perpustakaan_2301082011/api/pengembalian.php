<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Content-Type');

include 'koneksi.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'POST') {
    try {
        $data = json_decode(file_get_contents('php://input'), true);
        
        if (!isset($data['id_peminjaman'])) {
            throw new Exception('ID peminjaman harus diisi');
        }

        $id_peminjaman = mysqli_real_escape_string($conn, $data['id_peminjaman']);
        
        // Menggunakan transaksi untuk memastikan konsistensi data
        mysqli_begin_transaction($conn);
        
        try {
            // Update status peminjaman
            $query = "UPDATE peminjaman SET 
                     status = 'dikembalikan',
                     tanggal_kembali = CURRENT_DATE
                     WHERE id = '$id_peminjaman' 
                     AND status = 'dipinjam'";

            if (!mysqli_query($conn, $query)) {
                throw new Exception(mysqli_error($conn));
            }

            // Commit transaksi jika berhasil
            mysqli_commit($conn);
            
            echo json_encode([
                'success' => true,
                'message' => 'Buku berhasil dikembalikan'
            ]);
        } catch (Exception $e) {
            mysqli_rollback($conn);
            throw $e;
        }
    } catch (Exception $e) {
        echo json_encode([
            'success' => false,
            'message' => 'Gagal mengembalikan buku',
            'error' => $e->getMessage()
        ]);
    }
} else {
    echo json_encode([
        'success' => false,
        'message' => 'Method tidak diizinkan'
    ]);
}

mysqli_close($conn);
?>
