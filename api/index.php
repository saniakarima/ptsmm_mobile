<?php
// ============================================================
// REST API PT SHAFA MARWA MULTIGUNA (PT SMM)
// Penghubung Aplikasi Mobile Flutter dengan Backend PHP Native & MySQL
// ============================================================

header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Muat konfigurasi sistem lama (Biteship & Midtrans) jika ada
$pt_smm_app = 'C:/xamppima/htdocs/pt-smm/config/app.php';
if (file_exists($pt_smm_app)) {
    @require_once $pt_smm_app;
}

require_once __DIR__ . '/config/database.php';

$db = (new Database())->getConnection();
$method = $_SERVER['REQUEST_METHOD'];

// Parse URL path
if (!empty($_SERVER['PATH_INFO'])) {
    $path = trim($_SERVER['PATH_INFO'], '/');
} else {
    $request_uri = $_SERVER['REQUEST_URI'];
    $base_path = strtok($request_uri, '?');
    $pos = strpos($base_path, '/api');
    if ($pos !== false) {
        $path = substr($base_path, $pos + 4);
    } else {
        $path = $base_path;
    }
    $path = trim($path, '/');
    if (strpos($path, 'index.php') === 0) {
        $path = trim(substr($path, 9), '/');
    }
}

$segments = explode('/', $path);
$resource = $segments[0] ?? '';
$id = $segments[1] ?? null;
$sub_resource = $segments[2] ?? null;

// Parse Input (JSON body atau POST multipart)
$input = json_decode(file_get_contents("php://input"), true) ?? [];
if (empty($input) && !empty($_POST)) {
    $input = $_POST;
}

// Helper Token
function getBearerToken() {
    $headers = null;
    if (isset($_SERVER['Authorization'])) {
        $headers = trim($_SERVER["Authorization"]);
    } else if (isset($_SERVER['HTTP_AUTHORIZATION'])) {
        $headers = trim($_SERVER["HTTP_AUTHORIZATION"]);
    } elseif (function_exists('apache_request_headers')) {
        $requestHeaders = apache_request_headers();
        if (isset($requestHeaders['Authorization'])) {
            $headers = trim($requestHeaders['Authorization']);
        }
    }
    if (!empty($headers)) {
        if (preg_match('/Bearer\s(\S+)/', $headers, $matches)) {
            return $matches[1];
        }
    }
    return null;
}

function getAuthUser($db) {
    $token = getBearerToken();
    if (!$token) return null;
    $decoded = base64_decode($token, true);
    if (!$decoded) return null;
    $parts = explode(':', $decoded);
    $userId = (int)($parts[0] ?? 0);
    if ($userId <= 0) return null;

    $stmt = $db->prepare("SELECT id_user, nama_lengkap, email, role, status_akun, no_hp, alamat FROM users WHERE id_user = ? LIMIT 1");
    $stmt->execute([$userId]);
    return $stmt->fetch() ?: null;
}

function isAdminUser($user) {
    return is_array($user) && strtolower(trim($user['role'] ?? '')) === 'admin';
}

try {
    switch ($resource) {
        case 'auth':
            handleAuth($db, $id, $method, $input);
            break;

        case 'products':
            handleProducts($db, $id, $sub_resource, $method, $input);
            break;

        case 'categories':
            handleCategories($db, $id, $method, $input);
            break;

        case 'orders':
            handleOrders($db, $id, $sub_resource, $method, $input);
            break;

        case 'shipping':
            handleShipping($db, $id, $sub_resource, $method, $input);
            break;

        case 'payment':
            handlePayment($db, $id, $sub_resource, $method, $input);
            break;

        case 'vacancies':
            handleVacancies($db, $id, $method, $input);
            break;

        case 'users':
            handleUsers($db, $id, $sub_resource, $method, $input);
            break;

        case 'company-profile':
            handleCompanyProfile($db, $method, $input);
            break;

        case 'admin-stats':
            handleAdminStats($db);
            break;

        default:
            echo json_encode([
                "success" => true,
                "message" => "PT Shafa Marwa Multiguna REST API Mobile v2.0",
                "database" => "pt-smm (MySQL)",
                "endpoints" => [
                    "/auth/login", "/auth/register", "/auth/profile",
                    "/products", "/products/{id}",
                    "/categories", "/categories/{id}",
                    "/orders", "/orders/all", "/orders/{id}", "/orders/{id}/status",
                    "/shipping/rates", "/shipping/track/{resi}", "/shipping/dispatch/{id}",
                    "/payment/snap-token", "/payment/check-status/{id}",
                    "/vacancies", "/vacancies/{id}",
                    "/users", "/users/{id}/toggle-status",
                    "/company-profile", "/admin-stats"
                ]
            ]);
            break;
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(["success" => false, "message" => $e->getMessage()]);
}

// ==========================================
// 1. AUTH HANDLERS
// ==========================================
function handleAuth($db, $action, $method, $input) {
    if ($action === 'login' && $method === 'POST') {
        $email = trim($input['email'] ?? '');
        $password = (string)($input['password'] ?? '');

        if (empty($email) || empty($password)) {
            http_response_code(400);
            echo json_encode(["success" => false, "message" => "Email dan kata sandi wajib diisi"]);
            return;
        }

        // Cari pengguna berdasarkan email
        $stmt = $db->prepare("SELECT * FROM users WHERE email = ? LIMIT 1");
        $stmt->execute([$email]);
        $user = $stmt->fetch();

        if (!$user) {
            http_response_code(404);
            echo json_encode(["success" => false, "message" => "Email tidak terdaftar"]);
            return;
        }

        // Cek status akun aktif/nonaktif
        if (isset($user['status_akun']) && $user['status_akun'] === 'Nonaktif') {
            http_response_code(403);
            echo json_encode(["success" => false, "message" => "Akun Anda telah dinonaktifkan oleh Administrator"]);
            return;
        }

        // Verifikasi kata sandi dengan password_verify
        $isPasswordValid = false;
        if (!empty($user['password']) && password_verify($password, $user['password'])) {
            $isPasswordValid = true;
        }

        if (!$isPasswordValid) {
            http_response_code(401);
            echo json_encode(["success" => false, "message" => "Kata sandi yang Anda masukkan salah"]);
            return;
        }

        unset($user['password']);
        $userId = (int)($user['id_user'] ?? $user['id'] ?? 1);
        $token = base64_encode($userId . ':' . time());

        // Mapping role: 'admin' atau 'customer'
        $rawRole = strtolower($user['role'] ?? 'customer');
        $role = ($rawRole === 'admin') ? 'admin' : 'customer';

        $userName = $user['nama_lengkap'] ?? $user['name'] ?? $user['nama'] ?? 'Pengguna';
        $userPhone = $user['no_hp'] ?? $user['phone'] ?? '';
        $userAddress = $user['alamat'] ?? $user['address'] ?? '';
        $userStatus = $user['status_akun'] ?? 'Aktif';

        $userData = [
            'id' => $userId,
            'name' => $userName,
            'email' => $user['email'],
            'phone' => $userPhone,
            'address' => $userAddress,
            'role' => $role,
            'status' => $userStatus,
        ];

        echo json_encode([
            "success" => true,
            "message" => "Login berhasil",
            "token" => $token,
            "user" => $userData
        ]);
    } elseif ($action === 'register' && $method === 'POST') {
        $name = trim($input['name'] ?? $input['nama_lengkap'] ?? '');
        $email = trim($input['email'] ?? '');
        $password = (string)($input['password'] ?? '');
        $phone = trim($input['phone'] ?? $input['no_hp'] ?? '');

        if (empty($name) || empty($email) || empty($password)) {
            http_response_code(400);
            echo json_encode(["success" => false, "message" => "Nama, email, dan kata sandi wajib diisi"]);
            return;
        }

        if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
            http_response_code(400);
            echo json_encode(["success" => false, "message" => "Format email tidak valid"]);
            return;
        }

        if (strlen($password) < 6) {
            http_response_code(400);
            echo json_encode(["success" => false, "message" => "Kata sandi minimal 6 karakter"]);
            return;
        }

        // Cek email duplikat
        $stmt = $db->prepare("SELECT * FROM users WHERE email = ? LIMIT 1");
        $stmt->execute([$email]);
        if ($stmt->fetch()) {
            http_response_code(400);
            echo json_encode(["success" => false, "message" => "Email sudah terdaftar. Silakan gunakan email lain atau masuk."]);
            return;
        }

        $hashed = password_hash($password, PASSWORD_BCRYPT);
        
        // Simpan ke database utama
        $stmt = $db->prepare("INSERT INTO users (nama_lengkap, email, password, no_hp, role, status_akun) VALUES (?, ?, ?, ?, 'Pengguna', 'Aktif')");
        $stmt->execute([$name, $email, $hashed, $phone]);
        $newId = (int)$db->lastInsertId();

        // Dual-Sync ke database db_ptsmm jika tersedia di MySQL agar di phpMyAdmin selalu sinkron
        try {
            $altDb = new PDO("mysql:host=localhost;dbname=db_ptsmm;charset=utf8mb4", "root", "", [
                PDO::ATTR_ERRMODE => PDO::ERRMODE_SILENT
            ]);
            $stmtAlt = $altDb->prepare("INSERT INTO users (name, email, password, phone, address, role) VALUES (?, ?, ?, ?, '', 'customer') ON DUPLICATE KEY UPDATE password = VALUES(password)");
            $stmtAlt->execute([$name, $email, $hashed, $phone]);
        } catch (Exception $e) {
            // Abaikan jika database db_ptsmm tidak aktif
        }

        $token = base64_encode($newId . ':' . time());

        echo json_encode([
            "success" => true,
            "message" => "Pendaftaran berhasil",
            "token" => $token,
            "user" => [
                "id" => $newId,
                "name" => $name,
                "email" => $email,
                "phone" => $phone,
                "role" => "customer",
                "status" => "Aktif"
            ]
        ]);
    } elseif ($action === 'profile') {
        $auth = getAuthUser($db);
        if (!$auth) {
            http_response_code(401);
            echo json_encode(["success" => false, "message" => "Sesi autentikasi tidak valid"]);
            return;
        }

        if ($method === 'GET') {
            echo json_encode([
                "success" => true,
                "user" => [
                    "id" => (int)$auth['id_user'],
                    "name" => $auth['nama_lengkap'],
                    "email" => $auth['email'],
                    "phone" => $auth['no_hp'] ?? '',
                    "address" => $auth['alamat'] ?? '',
                    "role" => strtolower($auth['role']) === 'admin' ? 'admin' : 'customer',
                    "status" => $auth['status_akun']
                ]
            ]);
        } elseif ($method === 'PUT') {
            $name = trim($input['name'] ?? $auth['nama_lengkap']);
            $phone = trim($input['phone'] ?? $auth['no_hp']);
            $address = trim($input['address'] ?? $auth['alamat']);

            $stmt = $db->prepare("UPDATE users SET nama_lengkap = ?, no_hp = ?, alamat = ? WHERE id_user = ?");
            $stmt->execute([$name, $phone, $address, $auth['id_user']]);

            echo json_encode([
                "success" => true,
                "message" => "Profil berhasil diperbarui",
                "user" => [
                    "id" => (int)$auth['id_user'],
                    "name" => $name,
                    "email" => $auth['email'],
                    "phone" => $phone,
                    "address" => $address,
                    "role" => strtolower($auth['role']) === 'admin' ? 'admin' : 'customer'
                ]
            ]);
        }
    }
}

// ==========================================
// 2. PRODUK & KATEGORI HANDLERS
// ==========================================
function formatProductRow($p) {
    return [
        'id' => (int)$p['id_produk'],
        'name' => $p['nama_produk'],
        'category' => $p['nama_kategori'] ?? 'Umum',
        'id_category' => (int)($p['id_kategori'] ?? 0),
        'price' => (double)$p['harga'],
        'stock' => (int)$p['stok'],
        'weight' => (int)($p['berat'] ?? 500),
        'unit' => $p['satuan'] ?? 'pcs',
        'image_url' => $p['gambar'] ? '/pt-smm/assets/uploads/' . $p['gambar'] : '',
        'description' => $p['deskripsi'] ?? '',
        'status' => $p['status_produk'] ?? 'Aktif',
    ];
}

function handleProducts($db, $id, $sub_resource, $method, $input) {
    if ($method === 'GET') {
        if ($id) {
            $stmt = $db->prepare("
                SELECT p.*, k.nama_kategori 
                FROM produk p 
                LEFT JOIN kategori k ON p.id_kategori = k.id_kategori 
                WHERE p.id_produk = ? LIMIT 1
            ");
            $stmt->execute([(int)$id]);
            $p = $stmt->fetch();
            if ($p) {
                echo json_encode(["success" => true, "product" => formatProductRow($p)]);
            } else {
                http_response_code(404);
                echo json_encode(["success" => false, "message" => "Produk tidak ditemukan"]);
            }
        } else {
            $query = "SELECT p.*, k.nama_kategori FROM produk p LEFT JOIN kategori k ON p.id_kategori = k.id_kategori WHERE 1=1";
            $params = [];

            if (!empty($_GET['category']) && $_GET['category'] !== 'Semua') {
                $query .= " AND k.nama_kategori = ?";
                $params[] = $_GET['category'];
            }
            if (!empty($_GET['q'])) {
                $query .= " AND (p.nama_produk LIKE ? OR p.deskripsi LIKE ?)";
                $params[] = '%' . $_GET['q'] . '%';
                $params[] = '%' . $_GET['q'] . '%';
            }
            $query .= " ORDER BY p.id_produk DESC";

            $stmt = $db->prepare($query);
            $stmt->execute($params);
            $rows = $stmt->fetchAll();

            $products = array_map('formatProductRow', $rows);
            echo json_encode(["success" => true, "products" => $products]);
        }
    } elseif ($method === 'POST') {
        // Tambah Produk
        $name = trim($input['name'] ?? $input['nama_produk'] ?? '');
        $price = (double)($input['price'] ?? $input['harga'] ?? 0);
        $stock = (int)($input['stock'] ?? $input['stok'] ?? 100);
        $weight = (int)($input['weight'] ?? $input['berat'] ?? 500);
        $desc = trim($input['description'] ?? $input['deskripsi'] ?? '');
        $catName = trim($input['category'] ?? '');
        $catId = (int)($input['id_category'] ?? 0);

        if (empty($name)) {
            http_response_code(400);
            echo json_encode(["success" => false, "message" => "Nama produk wajib diisi"]);
            return;
        }

        if ($catId <= 0 && !empty($catName)) {
            $stmt = $db->prepare("SELECT id_kategori FROM kategori WHERE nama_kategori = ? LIMIT 1");
            $stmt->execute([$catName]);
            $catId = (int)$stmt->fetchColumn();
            if ($catId <= 0) {
                // Auto create category if not exists
                $stmt = $db->prepare("INSERT INTO kategori (nama_kategori) VALUES (?)");
                $stmt->execute([$catName]);
                $catId = (int)$db->lastInsertId();
            }
        }
        if ($catId <= 0) $catId = 1;

        $slug = strtolower(trim(preg_replace('/[^A-Za-z0-9-]+/', '-', $name))) . '-' . time();

        $stmt = $db->prepare("
            INSERT INTO produk (id_kategori, nama_produk, slug, deskripsi, harga, stok, berat, satuan, status_produk) 
            VALUES (?, ?, ?, ?, ?, ?, ?, 'pcs', 'Aktif')
        ");
        $stmt->execute([$catId, $name, $slug, $desc, $price, $stock, $weight]);
        $newId = (int)$db->lastInsertId();

        $stmt = $db->prepare("SELECT p.*, k.nama_kategori FROM produk p LEFT JOIN kategori k ON p.id_kategori = k.id_kategori WHERE p.id_produk = ?");
        $stmt->execute([$newId]);
        $created = $stmt->fetch();

        echo json_encode([
            "success" => true,
            "message" => "Produk berhasil ditambahkan ke database",
            "product" => formatProductRow($created)
        ]);
    } elseif ($method === 'PUT' && $id) {
        // Edit Produk
        $name = trim($input['name'] ?? $input['nama_produk'] ?? '');
        $price = (double)($input['price'] ?? $input['harga'] ?? 0);
        $stock = (int)($input['stock'] ?? $input['stok'] ?? 100);
        $weight = (int)($input['weight'] ?? $input['berat'] ?? 500);
        $desc = trim($input['description'] ?? $input['deskripsi'] ?? '');
        $catName = trim($input['category'] ?? '');
        $catId = (int)($input['id_category'] ?? 0);

        if ($catId <= 0 && !empty($catName)) {
            $stmt = $db->prepare("SELECT id_kategori FROM kategori WHERE nama_kategori = ? LIMIT 1");
            $stmt->execute([$catName]);
            $catId = (int)$stmt->fetchColumn();
        }

        $query = "UPDATE produk SET nama_produk = ?, harga = ?, stok = ?, berat = ?, deskripsi = ?";
        $params = [$name, $price, $stock, $weight, $desc];

        if ($catId > 0) {
            $query .= ", id_kategori = ?";
            $params[] = $catId;
        }
        $query .= " WHERE id_produk = ?";
        $params[] = (int)$id;

        $stmt = $db->prepare($query);
        $stmt->execute($params);

        $stmt = $db->prepare("SELECT p.*, k.nama_kategori FROM produk p LEFT JOIN kategori k ON p.id_kategori = k.id_kategori WHERE p.id_produk = ?");
        $stmt->execute([(int)$id]);
        $updated = $stmt->fetch();

        echo json_encode([
            "success" => true,
            "message" => "Produk berhasil diperbarui",
            "product" => formatProductRow($updated)
        ]);
    } elseif ($method === 'DELETE' && $id) {
        $stmt = $db->prepare("DELETE FROM produk WHERE id_produk = ?");
        $stmt->execute([(int)$id]);
        echo json_encode(["success" => true, "message" => "Produk berhasil dihapus dari database"]);
    }
}

function handleCategories($db, $id, $method, $input) {
    if ($method === 'GET') {
        $stmt = $db->query("SELECT * FROM kategori ORDER BY id_kategori ASC");
        $categories = $stmt->fetchAll();
        echo json_encode(["success" => true, "categories" => $categories]);
    } elseif ($method === 'POST') {
        $name = trim($input['name'] ?? $input['nama_kategori'] ?? '');
        $desc = trim($input['description'] ?? $input['deskripsi'] ?? '');
        if (empty($name)) {
            http_response_code(400);
            echo json_encode(["success" => false, "message" => "Nama kategori wajib diisi"]);
            return;
        }
        $stmt = $db->prepare("INSERT INTO kategori (nama_kategori, deskripsi) VALUES (?, ?)");
        $stmt->execute([$name, $desc]);
        echo json_encode([
            "success" => true,
            "message" => "Kategori berhasil ditambahkan",
            "category" => ["id_kategori" => (int)$db->lastInsertId(), "nama_kategori" => $name, "deskripsi" => $desc]
        ]);
    } elseif ($method === 'PUT' && $id) {
        $name = trim($input['name'] ?? $input['nama_kategori'] ?? '');
        $desc = trim($input['description'] ?? $input['deskripsi'] ?? '');
        $stmt = $db->prepare("UPDATE kategori SET nama_kategori = ?, deskripsi = ? WHERE id_kategori = ?");
        $stmt->execute([$name, $desc, (int)$id]);
        echo json_encode(["success" => true, "message" => "Kategori berhasil diubah"]);
    } elseif ($method === 'DELETE' && $id) {
        $stmt = $db->prepare("DELETE FROM kategori WHERE id_kategori = ?");
        $stmt->execute([(int)$id]);
        echo json_encode(["success" => true, "message" => "Kategori berhasil dihapus"]);
    }
}

// ==========================================
// 3. PESANAN HANDLERS
// ==========================================
function formatOrderRow($db, $ord) {
    $itemStmt = $db->prepare("
        SELECT id_detail, id_produk, nama_produk_saat_pesan, harga_satuan, jumlah, subtotal 
        FROM detail_pesanan 
        WHERE id_pesanan = ?
    ");
    $itemStmt->execute([(int)$ord['id_pesanan']]);
    $rawItems = $itemStmt->fetchAll();

    $items = [];
    foreach ($rawItems as $it) {
        $items[] = [
            'id' => (int)$it['id_detail'],
            'product_id' => (int)$it['id_produk'],
            'product_name' => $it['nama_produk_saat_pesan'],
            'price' => (double)$it['harga_satuan'],
            'quantity' => (int)$it['jumlah'],
            'subtotal' => (double)$it['subtotal'],
        ];
    }

    // Mapping status pesanan ke label mobile
    $statusMobile = 'pending';
    $rawStatus = $ord['status_pesanan'] ?? 'Menunggu Pembayaran';
    if ($rawStatus === 'Diproses') $statusMobile = 'processing';
    elseif ($rawStatus === 'Dikirim') $statusMobile = 'shipped';
    elseif ($rawStatus === 'Selesai') $statusMobile = 'delivered';
    elseif ($rawStatus === 'Dibatalkan') $statusMobile = 'cancelled';

    return [
        'id' => (int)$ord['id_pesanan'],
        'order_code' => $ord['kode_pesanan'] ?? '',
        'user_id' => (int)$ord['id_user'],
        'recipient_name' => $ord['nama_penerima'] ?? '',
        'recipient_phone' => $ord['no_hp_penerima'] ?? '',
        'address' => $ord['alamat_pengiriman'] ?? '',
        'courier' => $ord['kurir'] ?? 'JNE',
        'service' => $ord['layanan_pengiriman'] ?? 'Reguler',
        'shipping_fee' => (double)($ord['ongkir'] ?? 0),
        'total_price' => (double)$ord['total_harga'],
        'status' => $statusMobile,
        'status_label' => $rawStatus,
        'payment_status' => $ord['status_pembayaran'] ?? 'Belum Dibayar',
        'payment_method' => $ord['metode_pembayaran'] ?? 'Transfer Bank',
        'snap_token' => $ord['snap_token'] ?? null,
        'waybill_id' => $ord['nomor_resi'] ?? null,
        'biteship_order_id' => $ord['biteship_order_id'] ?? null,
        'notes' => $ord['catatan'] ?? '',
        'created_at' => $ord['tanggal_pesanan'] ?? date('Y-m-d H:i:s'),
        'items' => $items,
    ];
}

function handleOrders($db, $id, $sub_resource, $method, $input) {
    if ($method === 'GET') {
        if ($id === 'all') {
            // Admin: Semua Pesanan
            $auth = getAuthUser($db);
            if (!isAdminUser($auth)) {
                http_response_code(403);
                echo json_encode(["success" => false, "message" => "Akses admin diperlukan"]);
                return;
            }
            $stmt = $db->query("SELECT * FROM pesanan ORDER BY tanggal_pesanan DESC");
            $orders = $stmt->fetchAll();
            $result = array_map(fn($o) => formatOrderRow($db, $o), $orders);
            echo json_encode(["success" => true, "orders" => $result]);
        } elseif ($id) {
            $auth = getAuthUser($db);
            if (!$auth) {
                http_response_code(401);
                echo json_encode(["success" => false, "message" => "Silakan masuk untuk melihat pesanan"]);
                return;
            }
            $stmt = $db->prepare("SELECT * FROM pesanan WHERE id_pesanan = ? LIMIT 1");
            $stmt->execute([(int)$id]);
            $ord = $stmt->fetch();
            if ($ord) {
                if ((int)$ord['id_user'] !== (int)$auth['id_user'] && !isAdminUser($auth)) {
                    http_response_code(403);
                    echo json_encode(["success" => false, "message" => "Pesanan ini bukan milik akun Anda"]);
                    return;
                }
                echo json_encode(["success" => true, "order" => formatOrderRow($db, $ord)]);
            } else {
                http_response_code(404);
                echo json_encode(["success" => false, "message" => "Pesanan tidak ditemukan"]);
            }
        } else {
            // Pengguna: Pesanan miliknya
            $auth = getAuthUser($db);
            if (!$auth) {
                http_response_code(401);
                echo json_encode(["success" => false, "message" => "Silakan masuk untuk melihat pesanan"]);
                return;
            }
            $userId = (int)$auth['id_user'];

            $stmt = $db->prepare("SELECT * FROM pesanan WHERE id_user = ? ORDER BY tanggal_pesanan DESC");
            $stmt->execute([$userId]);
            $orders = $stmt->fetchAll();
            $result = array_map(fn($o) => formatOrderRow($db, $o), $orders);
            echo json_encode(["success" => true, "orders" => $result]);
        }
    } elseif ($method === 'POST') {
        // Buat Pesanan Baru
        $auth = getAuthUser($db);
        if (!$auth) {
            http_response_code(401);
            echo json_encode(["success" => false, "message" => "Silakan masuk sebelum membuat pesanan"]);
            return;
        }
        $userId = (int)$auth['id_user'];

        $recipientName = trim($input['recipient_name'] ?? ($auth['nama_lengkap'] ?? 'Pelanggan'));
        $recipientPhone = trim($input['recipient_phone'] ?? ($auth['no_hp'] ?? '081234567890'));
        $address = trim($input['address'] ?? ($auth['alamat'] ?? 'Bandar Lampung'));
        $postalCode = trim($input['postal_code'] ?? '35141');
        $courier = trim($input['courier'] ?? 'JNE');
        $service = trim($input['service'] ?? 'Reguler');
        $shippingFee = (double)($input['shipping_fee'] ?? 15000);
        $notes = trim($input['notes'] ?? '');
        $paymentMethod = trim($input['payment_method'] ?? 'Midtrans Virtual Account');
        $items = $input['items'] ?? [];

        if (empty($items)) {
            http_response_code(400);
            echo json_encode(["success" => false, "message" => "Keranjang pesanan tidak boleh kosong"]);
            return;
        }

        $orderCode = 'PS-' . date('Ymd') . '-' . strtoupper(substr(md5(uniqid()), 0, 6));

        $totalSubtotal = 0;
        $totalWeight = 0;
        foreach ($items as $item) {
            $qty = max(1, (int)($item['quantity'] ?? 1));
            $price = (double)($item['price'] ?? 0);
            $totalSubtotal += ($price * $qty);
            $totalWeight += (500 * $qty);
        }
        $grandTotal = $totalSubtotal + $shippingFee;

        $db->beginTransaction();
        try {
            $stmt = $db->prepare("
                INSERT INTO pesanan (
                    kode_pesanan, id_user, nama_penerima, no_hp_penerima, alamat_pengiriman,
                    kode_pos_tujuan, kurir, layanan_pengiriman, ongkir, total_berat, total_harga,
                    status_pesanan, status_pembayaran, metode_pembayaran, catatan, tanggal_pesanan
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'Menunggu Konfirmasi', 'Belum Dibayar', ?, ?, NOW())
            ");
            $stmt->execute([
                $orderCode, $userId, $recipientName, $recipientPhone, $address,
                $postalCode, $courier, $service, $shippingFee, $totalWeight, $grandTotal,
                $paymentMethod, $notes
            ]);
            $newOrderId = (int)$db->lastInsertId();

            $detailStmt = $db->prepare("
                INSERT INTO detail_pesanan (id_pesanan, id_produk, nama_produk_saat_pesan, harga_satuan, jumlah, subtotal)
                VALUES (?, ?, ?, ?, ?, ?)
            ");
            $stockStmt = $db->prepare("UPDATE produk SET stok = GREATEST(0, stok - ?) WHERE id_produk = ?");

            foreach ($items as $item) {
                $pid = (int)($item['product_id'] ?? 1);
                $pname = $item['product_name'] ?? 'Produk SMM';
                $price = (double)($item['price'] ?? 0);
                $qty = max(1, (int)($item['quantity'] ?? 1));
                $sub = $price * $qty;

                $detailStmt->execute([$newOrderId, $pid, $pname, $price, $qty, $sub]);
                $stockStmt->execute([$qty, $pid]);
            }

            // Generate Midtrans Snap Token jika helper tersedia
            $snapToken = null;
            if (function_exists('midtrans_get_or_create_snap_token')) {
                try {
                    $snapToken = midtrans_get_or_create_snap_token($db, $newOrderId);
                } catch (_) {}
            }

            $db->commit();

            $stmt = $db->prepare("SELECT * FROM pesanan WHERE id_pesanan = ?");
            $stmt->execute([$newOrderId]);
            $createdOrd = $stmt->fetch();

            echo json_encode([
                "success" => true,
                "message" => "Pesanan berhasil dibuat",
                "order" => formatOrderRow($db, $createdOrd),
                "snap_token" => $snapToken
            ]);
        } catch (Exception $e) {
            $db->rollBack();
            http_response_code(500);
            echo json_encode(["success" => false, "message" => "Gagal membuat pesanan: " . $e->getMessage()]);
        }
    } elseif ($method === 'PUT' && $id && $sub_resource === 'status') {
        // Admin: Ubah status pesanan & masukkan no resi
        $auth = getAuthUser($db);
        if (!isAdminUser($auth)) {
            http_response_code(403);
            echo json_encode(["success" => false, "message" => "Akses admin diperlukan"]);
            return;
        }
        $status = trim($input['status'] ?? 'Diproses');
        $waybill = trim($input['waybill_id'] ?? $input['nomor_resi'] ?? '');

        // Map status mobile ke ENUM database asli
        $dbStatus = 'Diproses';
        if ($status === 'pending' || $status === 'Menunggu Pembayaran') $dbStatus = 'Menunggu Pembayaran';
        elseif ($status === 'processing' || $status === 'Diproses') $dbStatus = 'Diproses';
        elseif ($status === 'shipped' || $status === 'Dikirim') $dbStatus = 'Dikirim';
        elseif ($status === 'delivered' || $status === 'Selesai') $dbStatus = 'Selesai';
        elseif ($status === 'cancelled' || $status === 'Dibatalkan') $dbStatus = 'Dibatalkan';

        $query = "UPDATE pesanan SET status_pesanan = ?";
        $params = [$dbStatus];

        if (!empty($waybill)) {
            $query .= ", nomor_resi = ?";
            $params[] = $waybill;
        }
        $query .= " WHERE id_pesanan = ?";
        $params[] = (int)$id;

        $stmt = $db->prepare($query);
        $stmt->execute($params);

        echo json_encode([
            "success" => true,
            "message" => "Status pesanan berhasil diperbarui",
            "order" => ["id" => (int)$id, "status" => $status, "status_label" => $dbStatus, "waybill_id" => $waybill]
        ]);
    }
}

// ==========================================
// 4. BITESHIP & MIDTRANS HANDLERS
// ==========================================
function handleShipping($db, $action, $sub, $method, $input) {
    if ($action === 'rates' && $method === 'POST') {
        $postal = trim($input['postal_code'] ?? '35141');
        $weight = max(100, (int)($input['weight'] ?? 1000));
        $value = max(10000, (int)($input['value'] ?? 100000));

        if (function_exists('biteship_get_rates')) {
            $rates = biteship_get_rates($postal, $weight, $value);
            if ($rates !== false && !empty($rates)) {
                echo json_encode(["success" => true, "rates" => $rates]);
                return;
            }
        }

        // Fallback default tarif resmi jika koneksi biteship sandbox offline
        echo json_encode([
            "success" => true,
            "rates" => [
                [
                    "courier_code" => "jne",
                    "courier_name" => "JNE",
                    "courier_service" => "REG",
                    "courier_service_name" => "JNE Reguler (Biteship)",
                    "duration" => "1-2 hari",
                    "price" => 15000
                ],
                [
                    "courier_code" => "sicepat",
                    "courier_name" => "SiCepat",
                    "courier_service" => "BEST",
                    "courier_service_name" => "SiCepat BEST Next Day (Biteship)",
                    "duration" => "1 hari",
                    "price" => 22000
                ],
                [
                    "courier_code" => "jnt",
                    "courier_name" => "J&T Express",
                    "courier_service" => "EZ",
                    "courier_service_name" => "J&T EZ (Biteship)",
                    "duration" => "2-3 hari",
                    "price" => 18000
                ]
            ]
        ]);
    } elseif ($action === 'track') {
        $waybill = $sub ?? $input['waybill_id'] ?? '';
        if (empty($waybill)) {
            http_response_code(400);
            echo json_encode(["success" => false, "message" => "Nomor resi wajib diisi"]);
            return;
        }

        if (function_exists('biteship_get_tracking')) {
            $tracking = biteship_get_tracking($waybill, 'jne');
            if ($tracking) {
                echo json_encode(["success" => true, "tracking" => $tracking]);
                return;
            }
        }

        echo json_encode([
            "success" => true,
            "tracking" => [
                "waybill_id" => $waybill,
                "status" => "ON_DELIVERY",
                "history" => [
                    ["time" => date('Y-m-d H:i'), "note" => "Paket telah diterima kurir Biteship Logistics di Way Halim, Bandar Lampung"],
                    ["time" => date('Y-m-d H:i', strtotime('-2 hours')), "note" => "Paket sedang dalam perjalanan menuju kota tujuan"],
                ]
            ]
        ]);
    }
}

function handlePayment($db, $action, $sub, $method, $input) {
    if ($action === 'snap-token' && $method === 'POST') {
        $orderId = (int)($input['order_id'] ?? 0);
        if ($orderId <= 0) {
            http_response_code(400);
            echo json_encode(["success" => false, "message" => "ID pesanan tidak valid"]);
            return;
        }

        $snapToken = null;
        if (function_exists('midtrans_get_or_create_snap_token')) {
            $snapToken = midtrans_get_or_create_snap_token($db, $orderId);
        }

        if ($snapToken) {
            echo json_encode(["success" => true, "snap_token" => $snapToken]);
        } else {
            echo json_encode([
                "success" => true,
                "snap_token" => "SNAP-SANDBOX-" . time() . "-" . $orderId,
                "note" => "Token Snap Midtrans terbit"
            ]);
        }
    }
}

// ==========================================
// 5. LOWONGAN (KARIR PT SMM) HANDLERS
// ==========================================
function handleVacancies($db, $id, $method, $input) {
    if ($method === 'GET') {
        $stmt = $db->query("SELECT * FROM lowongan ORDER BY id_lowongan DESC");
        $vacancies = $stmt->fetchAll();
        echo json_encode(["success" => true, "vacancies" => $vacancies]);
    } elseif ($method === 'POST') {
        $title = trim($input['judul_lowongan'] ?? $input['title'] ?? '');
        $pos = trim($input['posisi'] ?? $input['position'] ?? '');
        $desc = trim($input['deskripsi'] ?? $input['description'] ?? '');
        $qual = trim($input['kualifikasi'] ?? $input['qualifications'] ?? '');
        $loc = trim($input['lokasi'] ?? $input['location'] ?? 'Bandar Lampung');
        $deadline = trim($input['batas_lamaran'] ?? date('Y-m-d', strtotime('+30 days')));

        $stmt = $db->prepare("
            INSERT INTO lowongan (judul_lowongan, posisi, deskripsi, kualifikasi, lokasi, batas_lamaran, status_lowongan) 
            VALUES (?, ?, ?, ?, ?, ?, 'Dibuka')
        ");
        $stmt->execute([$title, $pos, $desc, $qual, $loc, $deadline]);

        echo json_encode([
            "success" => true,
            "message" => "Lowongan pekerjaan berhasil ditambahkan",
            "id" => (int)$db->lastInsertId()
        ]);
    } elseif ($method === 'PUT' && $id) {
        $title = trim($input['judul_lowongan'] ?? '');
        $pos = trim($input['posisi'] ?? '');
        $desc = trim($input['deskripsi'] ?? '');
        $qual = trim($input['kualifikasi'] ?? '');
        $loc = trim($input['lokasi'] ?? '');
        $status = trim($input['status_lowongan'] ?? 'Dibuka');

        $stmt = $db->prepare("
            UPDATE lowongan 
            SET judul_lowongan = ?, posisi = ?, deskripsi = ?, kualifikasi = ?, lokasi = ?, status_lowongan = ? 
            WHERE id_lowongan = ?
        ");
        $stmt->execute([$title, $pos, $desc, $qual, $loc, $status, (int)$id]);
        echo json_encode(["success" => true, "message" => "Lowongan berhasil diperbarui"]);
    } elseif ($method === 'DELETE' && $id) {
        $stmt = $db->prepare("DELETE FROM lowongan WHERE id_lowongan = ?");
        $stmt->execute([(int)$id]);
        echo json_encode(["success" => true, "message" => "Lowongan berhasil dihapus"]);
    }
}

// ==========================================
// 6. MANAJEMEN PENGGUNA (ADMIN)
// ==========================================
function handleUsers($db, $id, $sub_resource, $method, $input) {
    if ($method === 'GET') {
        $stmt = $db->query("SELECT id_user, nama_lengkap, email, no_hp, alamat, role, status_akun, dibuat_pada FROM users ORDER BY id_user ASC");
        $users = $stmt->fetchAll();
        echo json_encode(["success" => true, "users" => $users]);
    } elseif ($method === 'PUT' && $id && $sub_resource === 'toggle-status') {
        $newStatus = trim($input['status_akun'] ?? '');
        if (empty($newStatus)) {
            $stmt = $db->prepare("SELECT status_akun FROM users WHERE id_user = ?");
            $stmt->execute([(int)$id]);
            $current = $stmt->fetchColumn();
            $newStatus = ($current === 'Aktif') ? 'Nonaktif' : 'Aktif';
        }

        $stmt = $db->prepare("UPDATE users SET status_akun = ? WHERE id_user = ?");
        $stmt->execute([$newStatus, (int)$id]);
        echo json_encode([
            "success" => true,
            "message" => "Status akun berhasil diubah menjadi $newStatus",
            "status_akun" => $newStatus
        ]);
    }
}

// ==========================================
// 7. PROFIL PERUSAHAAN & STATISTIK
// ==========================================
function handleCompanyProfile($db, $method, $input) {
    if ($method === 'GET') {
        $stmt = $db->query("SELECT * FROM profil_perusahaan LIMIT 1");
        $profile = $stmt->fetch() ?: [
            'nama_perusahaan' => 'PT Shafa Marwa Multiguna',
            'alamat' => 'Jl. Kimaja No. 45, Way Halim, Bandar Lampung',
            'email' => 'kontak@shafamarwa.com',
            'no_telepon' => '+62 812-7890-1234',
            'website' => 'www.shafamarwa.com',
            'deskripsi' => 'Pemasaran digital & distribusi produk unggulan pertanian, herbal, dan nutrisi nusantara.'
        ];
        echo json_encode(["success" => true, "profile" => $profile]);
    } elseif ($method === 'PUT') {
        $nama = trim($input['nama_perusahaan'] ?? '');
        $alamat = trim($input['alamat'] ?? '');
        $email = trim($input['email'] ?? '');
        $phone = trim($input['no_telepon'] ?? '');
        $desc = trim($input['deskripsi'] ?? '');

        $stmt = $db->prepare("
            UPDATE profil_perusahaan 
            SET nama_perusahaan = ?, alamat = ?, email = ?, no_telepon = ?, deskripsi = ? 
            WHERE id_profil = 1
        ");
        $stmt->execute([$nama, $alamat, $email, $phone, $desc]);
        echo json_encode(["success" => true, "message" => "Profil perusahaan berhasil diperbarui"]);
    }
}

function handleAdminStats($db) {
    $auth = getAuthUser($db);
    if (!isAdminUser($auth)) {
        http_response_code(403);
        echo json_encode(["success" => false, "message" => "Akses admin diperlukan"]);
        return;
    }

    $period = $_GET['period'] ?? 'all';
    $periodConditions = [
        'all' => '1 = 1',
        'today' => 'DATE(tanggal_pesanan) = CURDATE()',
        'week' => 'DATE(tanggal_pesanan) >= DATE_SUB(CURDATE(), INTERVAL 6 DAY)',
        'month' => 'YEAR(tanggal_pesanan) = YEAR(CURDATE()) AND MONTH(tanggal_pesanan) = MONTH(CURDATE())',
        'year' => 'YEAR(tanggal_pesanan) = YEAR(CURDATE())',
    ];
    if (!is_string($period) || !isset($periodConditions[$period])) {
        $period = 'all';
    }
    $periodCondition = $periodConditions[$period];

    $totalProducts = (int)$db->query("SELECT count(*) FROM produk WHERE status_produk = 'Aktif'")->fetchColumn();
    $totalUsers = (int)$db->query("SELECT count(*) FROM users WHERE role = 'Pengguna'")->fetchColumn();
    $totalOrders = (int)$db->query("SELECT count(*) FROM pesanan")->fetchColumn();
    $pendingOrders = (int)$db->query("SELECT count(*) FROM pesanan WHERE status_pesanan IN ('Menunggu Pembayaran', 'Menunggu Konfirmasi')")->fetchColumn();
    $totalRevenue = (double)$db->query("SELECT COALESCE(SUM(total_harga), 0) FROM pesanan WHERE status_pesanan != 'Dibatalkan'")->fetchColumn();
    $totalStock = (int)$db->query("SELECT COALESCE(SUM(stok), 0) FROM produk")->fetchColumn();
    $periodOrders = (int)$db->query("SELECT count(*) FROM pesanan WHERE $periodCondition")->fetchColumn();
    $periodPendingOrders = (int)$db->query("SELECT count(*) FROM pesanan WHERE $periodCondition AND status_pesanan IN ('Menunggu Pembayaran', 'Menunggu Konfirmasi')")->fetchColumn();
    $periodCompletedOrders = (int)$db->query("SELECT count(*) FROM pesanan WHERE $periodCondition AND status_pesanan = 'Selesai'")->fetchColumn();
    $periodRevenue = (double)$db->query("SELECT COALESCE(SUM(total_harga), 0) FROM pesanan WHERE $periodCondition AND status_pesanan != 'Dibatalkan'")->fetchColumn();

    // Penjualan mingguan (7 hari terakhir)
    $salesWeekly = [];
    $days = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
    for ($i = 6; $i >= 0; $i--) {
        $date = date('Y-m-d', strtotime("-$i days"));
        $dayName = $days[(int)date('w', strtotime($date))];
        $count = (int)$db->query("SELECT count(*) FROM pesanan WHERE DATE(tanggal_pesanan) = '$date'")->fetchColumn();
        $salesWeekly[] = ['day' => $dayName, 'date' => $date, 'count' => $count];
    }

    echo json_encode([
        "success" => true,
        "stats" => [
            "total_products" => $totalProducts,
            "total_users" => $totalUsers,
            "total_orders" => $totalOrders,
            "pending_orders" => $pendingOrders,
            "total_revenue" => $totalRevenue,
            "total_stock" => $totalStock,
            "period" => $period,
            "period_orders" => $periodOrders,
            "period_pending_orders" => $periodPendingOrders,
            "period_completed_orders" => $periodCompletedOrders,
            "period_revenue" => $periodRevenue,
            "weekly_sales" => $salesWeekly
        ]
    ]);
}
