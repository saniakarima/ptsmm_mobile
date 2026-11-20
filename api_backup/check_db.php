<?php
require_once 'C:/xamppima/htdocs/pt-smm/config/database.php';

$tables = ['users', 'kategori', 'produk', 'pesanan', 'lowongan', 'profil_perusahaan', 'kontak_pesan'];
foreach ($tables as $t) {
    try {
        $c = $pdo->query("SELECT count(*) FROM $t")->fetchColumn();
        echo "Table $t: $c rows\n";
    } catch (Exception $e) {
        echo "Table $t: ERROR (" . $e->getMessage() . ")\n";
    }
}

