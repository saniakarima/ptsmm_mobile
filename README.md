# PT Shafa Marwa Multiguna - Mobile Application

Aplikasi Android modern, profesional, dan responsif untuk **PT Shafa Marwa Multiguna** yang dikembangkan menggunakan **Flutter & Dart** dengan backend **PHP Native REST API** dan database **MySQL**.

---

## 📱 Fitur Utama Aplikasi

1. **Autentikasi Pengguna:**
   * Registrasi akun baru pelanggan.
   * Login pengguna & admin dengan token autentikasi.
   * Splash screen animasi logo PT SMM.
2. **Beranda Perusahaan:**
   * Banner utama PT SMM dengan aksen warna hijau modern.
   * Navigasi kategori ringkas (5 kategori).
   * Produk pilihan terlaris dan informasi profil perusahaan.
3. **Katalog 16 Produk:**
   * 16 produk terdistribusi rapi ke dalam 5 kategori:
     1. **Pupuk Organik** (AQ Green, AQ Green Gold, Aqua Green, Sica Aqua Green, Sica Pro Aqua Green)
     2. **Perikanan** (Aqua Fish Premik, Probiotik, Booster Plankton)
     3. **Herbal** (Lambung Gembira, Susu Etawa Ajwa)
     4. **Kopi** (Kopi Sanghai, Kopi Jet M Tanpa Gula, Kopi Romero)
     5. **Vitamin Anak** (Nuhsa Smart DHA, Nuhsa Growvit, Etawa Ajwa Lambung Anak)
4. **Pencarian & Detail Produk:**
   * Pencarian langsung berdasarkan kata kunci nama maupun deskripsi.
   * Informasi detail produk, harga, stok gudang, dan manfaat produk.
5. **Keranjang & Checkout:**
   * Manajemen kuantitas produk di keranjang belanja.
   * Checkout pesanan dengan input alamat pengiriman & catatan khusus.
   * Pilihan metode pembayaran (Transfer Bank & COD) serta perhitungan ongkos kirim.
6. **Riwayat & Detail Pesanan:**
   * Pemantauan status transaksi (*Menunggu, Diproses, Dikirim, Selesai, Dibatalkan*).
   * Rincian produk yang dipesan beserta total tagihan dan tanggal transaksi.
7. **Profil Pengguna:**
   * Pembaruan data pribadi pelanggan (nama, telepon, alamat pengiriman).
   * Badge status akun (Pelanggan / Administrator).
8. **Dashboard Administrator:**
   * Visualisasi ringkasan inventaris produk, kategori, dan pesanan masuk.
   * Pengelolaan 16 produk (tambah produk baru, perbarui harga, stok, deskripsi, atau hapus produk).
   * Pengelolaan pesanan pelanggan dan pembaruan status pengiriman real-time.

---

## 🚀 Panduan Menjalankan Backend (XAMPP)

1. Buka **XAMPP Control Panel**, lalu aktifkan **Apache** dan **MySQL**.
2. **Inisialisasi Database Otomatis:**
   * Buka browser dan akses URL installer instan berikut:
     ```
     http://localhost/ptsmmmobile/api/setup.php
     ```
   * Skrip ini akan secara otomatis membuat database `ptsmm_db`, seluruh tabel yang diperlukan, serta mengisi 16 produk dan 2 akun demo.
   * *Alternatif:* Impor file `api/setup.sql` melalui **phpMyAdmin** (`http://localhost/phpmyadmin`).

3. **Akun Uji Coba (Demo):**
   * **Akun Admin:** `admin@ptsmm.com` | Password: `admin123`
   * **Akun Pelanggan:** `user@ptsmm.com` | Password: `password`

---

## 📲 Panduan Menjalankan Aplikasi Flutter

1. **Konfigurasi Alamat API:**
   * File konfigurasi berada di: `lib/config/api_config.dart`.
   * **Web (Chrome di Windows):** Menggunakan otomatis `http://localhost/ptsmmobile/api`.
   * **Android Emulator:** Menggunakan `http://10.0.2.2/ptsmmobile/api`.
   * **Device Fisik Android (USB/WiFi):** Ganti dengan alamat IP lokal komputer Anda (contoh: `http://192.168.1.50/ptsmmobile/api`).

2. **Jalankan Aplikasi:**
   ```powershell
   flutter run
   ```

3. **Menjalankan Unit/Widget Test:**
   ```powershell
   flutter test
   ```
