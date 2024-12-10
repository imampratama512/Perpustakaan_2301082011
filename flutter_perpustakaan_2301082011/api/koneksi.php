<?php
$host = "localhost";
$user = "root";
$pass = "";
$db = "flutter_perpustakaan_2301082011";

$conn = mysqli_connect($host, $user, $pass, $db);

if (!$conn) {
    die("Koneksi gagal: " . mysqli_connect_error());
}
?>