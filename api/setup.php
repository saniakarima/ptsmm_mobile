<?php
// api/setup.php - Auto installer database ptsmm_db
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");

$host = "localhost";
$username = "root";
$password = "";

try {
    // 1. Koneksi awal ke MySQL tanpa database
    $pdo = new PDO("mysql:host=$host;charset=utf8mb4", $username, $password, [
        PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
    ]);

    // 2. Baca file setup.sql
    $sqlFile = __DIR__ . '/setup.sql';
    if (!file_exists($sqlFile)) {
        throw new Exception("File setup.sql tidak ditemukan di direktori /api.");
    }

    $sql = file_get_contents($sqlFile);

    // 3. Eksekusi seluruh skrip SQL
    $pdo->exec($sql);

    // 4. Verifikasi jumlah produk
    $pdo->exec("USE `ptsmm_db`");
    $stmt = $pdo->query("SELECT COUNT(*) as total FROM `products`");
    $productCount = $stmt->fetch(PDO::FETCH_ASSOC)['total'] ?? 0;

    $stmt = $pdo->query("SELECT COUNT(*) as total FROM `users`");
    $userCount = $stmt->fetch(PDO::FETCH_ASSOC)['total'] ?? 0;

    echo json_encode([
        "success" => true,
        "message" => "Database ptsmm_db berhasil disiapkan dan diinisialisasi!",
        "stats" => [
            "database" => "ptsmm_db",
            "total_products" => (int)$productCount,
            "total_users" => (int)$userCount,
        ],
        "demo_accounts" => [
            [
                "role" => "Admin",
                "email" => "admin@ptsmm.com",
                "password" => "admin123"
            ],
            [
                "role" => "Pelanggan",
                "email" => "user@ptsmm.com",
                "password" => "password"
            ]
        ]
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);

} catch (Exception $e) {
    http_response_code(500);
    echo json_encode([
        "success" => false,
        "message" => "Gagal inisialisasi database: " . $e->getMessage(),
        "instruction" => "Pastikan Apache dan MySQL di XAMPP Control Panel sudah dalam keadaan RUNNING."
    ], JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES);
}

