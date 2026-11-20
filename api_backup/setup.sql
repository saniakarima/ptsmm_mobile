-- Database setup for PT Shafa Marwa Multiguna
CREATE DATABASE IF NOT EXISTS `ptsmm_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `ptsmm_db`;

-- 1. Table Users
CREATE TABLE IF NOT EXISTS `users` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(100) NOT NULL,
  `email` VARCHAR(100) NOT NULL UNIQUE,
  `password` VARCHAR(255) NOT NULL,
  `phone` VARCHAR(20) DEFAULT '',
  `address` TEXT DEFAULT '',
  `role` ENUM('customer', 'admin') DEFAULT 'customer',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. Table Products (16 Produk dalam 5 Kategori)
CREATE TABLE IF NOT EXISTS `products` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `name` VARCHAR(150) NOT NULL,
  `category` VARCHAR(50) NOT NULL,
  `price` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `description` TEXT,
  `stock` INT NOT NULL DEFAULT 100,
  `image_url` VARCHAR(255) DEFAULT '',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. Table Orders
CREATE TABLE IF NOT EXISTS `orders` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `user_id` INT NOT NULL,
  `total_price` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `status` ENUM('pending', 'processing', 'shipped', 'delivered', 'cancelled') DEFAULT 'pending',
  `address` TEXT NOT NULL,
  `notes` TEXT,
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. Table Order Items
CREATE TABLE IF NOT EXISTS `order_items` (
  `id` INT AUTO_INCREMENT PRIMARY KEY,
  `order_id` INT NOT NULL,
  `product_id` INT NOT NULL,
  `product_name` VARCHAR(150) NOT NULL,
  `price` DECIMAL(12,2) NOT NULL DEFAULT 0.00,
  `quantity` INT NOT NULL DEFAULT 1,
  FOREIGN KEY (`order_id`) REFERENCES `orders`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`product_id`) REFERENCES `products`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Data Awal: Default Admin & Customer Demo
-- Password hashed untuk 'admin123' dan 'password'
INSERT INTO `users` (`id`, `name`, `email`, `password`, `phone`, `address`, `role`) VALUES
(1, 'Administrator SMM', 'admin@ptsmm.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '081234567890', 'Kantor Pusat PT Shafa Marwa Multiguna', 'admin'),
(2, 'Pelanggan Setia', 'user@ptsmm.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '089876543210', 'Jl. Merdeka No. 45, Jakarta Selatan', 'customer')
ON DUPLICATE KEY UPDATE `email` = VALUES(`email`);

-- Seeder 16 Produk PT Shafa Marwa Multiguna dalam 5 Kategori
INSERT INTO `products` (`id`, `name`, `category`, `price`, `description`, `stock`) VALUES
(1, 'AQ Green', 'Pupuk Organik', 150000.00, 'Pupuk organik cair untuk meningkatkan kesuburan tanah dan pertumbuhan tanaman secara alami.', 50),
(2, 'AQ Green Gold', 'Pupuk Organik', 175000.00, 'Pupuk organik premium dengan formula emas untuk hasil panen maksimal.', 40),
(3, 'Aqua Green', 'Pupuk Organik', 135000.00, 'Pupuk cair ramah lingkungan untuk berbagai jenis tanaman pertanian.', 60),
(4, 'Sica Aqua Green', 'Pupuk Organik', 160000.00, 'Pupuk organik dengan teknologi Sica untuk penyerapan nutrisi optimal.', 35),
(5, 'Sica Pro Aqua Green', 'Pupuk Organik', 195000.00, 'Formula profesional pupuk organik untuk pertanian skala besar.', 30),
(6, 'Aqua Fish Premik', 'Perikanan', 120000.00, 'Premiks nutrisi lengkap untuk ikan budidaya air tawar dan payau.', 45),
(7, 'Probiotik', 'Perikanan', 95000.00, 'Probiotik untuk kesehatan pencernaan ikan dan meningkatkan kualitas air.', 55),
(8, 'Booster Plankton', 'Perikanan', 110000.00, 'Booster pertumbuhan plankton alami untuk pakan ikan budidaya.', 40),
(9, 'Lambung Gembira', 'Herbal', 85000.00, 'Herbal alami untuk menjaga kesehatan lambung dan pencernaan.', 70),
(10, 'Susu Etawa Ajwa', 'Herbal', 75000.00, 'Susu kambing etawa dengan kurma ajwa untuk kesehatan optimal.', 80),
(11, 'Kopi Sanghai', 'Kopi', 45000.00, 'Kopi premium blend Sanghai dengan cita rasa khas dan aroma kuat.', 100),
(12, 'Kopi Jet M Tanpa Gula', 'Kopi', 42000.00, 'Kopi instan tanpa gula untuk penikmat kopi murni.', 90),
(13, 'Kopi Romero', 'Kopi', 48000.00, 'Kopi Romero dengan herbal rosemary untuk energi dan fokus.', 85),
(14, 'Nuhsa Smart DHA', 'Vitamin Anak', 125000.00, 'Suplemen DHA untuk kecerdasan otak dan perkembangan anak.', 60),
(15, 'Nuhsa Growvit', 'Vitamin Anak', 115000.00, 'Vitamin pertumbuhan anak dengan nutrisi lengkap dan seimbang.', 55),
(16, 'Etawa Ajwa Lambung Anak', 'Vitamin Anak', 90000.00, 'Susu etawa ajwa khusus anak untuk kesehatan lambung.', 65)
ON DUPLICATE KEY UPDATE `name` = VALUES(`name`), `price` = VALUES(`price`), `category` = VALUES(`category`);

