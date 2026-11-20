<?php
require_once 'C:/xamppima/htdocs/pt-smm/config/database.php';
$stmt = $pdo->query("SELECT id_user, nama_lengkap, email, role, status_akun FROM users");
echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC), JSON_PRETTY_PRINT);

