import 'package:flutter/material.dart';

class OrderItem {
  final int id;
  final int productId;
  final String productName;
  final double price;
  final int quantity;
  final double subtotal;

  OrderItem({
    this.id = 0,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    double? subtotal,
  }) : subtotal = subtotal ?? (price * quantity);

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['id_detail'] ?? 0;
    final rawPid = json['product_id'] ?? json['id_produk'] ?? 0;
    final rawName =
        json['product_name'] ?? json['nama_produk_saat_pesan'] ?? '';
    final rawPrice = json['price'] ?? json['harga_satuan'] ?? 0;
    final rawQty = json['quantity'] ?? json['jumlah'] ?? 1;
    final rawSub = json['subtotal'] ?? 0;

    final priceVal = rawPrice is double
        ? rawPrice
        : double.parse(rawPrice.toString());
    final qtyVal = rawQty is int ? rawQty : int.parse(rawQty.toString());
    final subVal = rawSub is double ? rawSub : double.parse(rawSub.toString());

    return OrderItem(
      id: rawId is int ? rawId : int.parse(rawId.toString()),
      productId: rawPid is int ? rawPid : int.parse(rawPid.toString()),
      productName: rawName.toString(),
      price: priceVal,
      quantity: qtyVal,
      subtotal: subVal > 0 ? subVal : (priceVal * qtyVal),
    );
  }

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'product_name': productName,
    'price': price,
    'quantity': quantity,
    'subtotal': subtotal,
  };
}

class Order {
  final int id;
  final String orderCode;
  final int userId;
  final String recipientName;
  final String recipientPhone;
  final String address;
  final String courier;
  final String service;
  final double shippingFee;
  final double totalPrice;
  final String status;
  final String statusLabel;
  final String paymentStatus;
  final String paymentMethod;
  final String? snapToken;
  final String? waybillId;
  final String? biteshipOrderId;
  final String? notes;
  final DateTime createdAt;
  final List<OrderItem> items;

  Order({
    required this.id,
    this.orderCode = '',
    required this.userId,
    this.recipientName = '',
    this.recipientPhone = '',
    required this.items,
    required this.totalPrice,
    required this.status,
    String? statusLabel,
    this.paymentStatus = 'Belum Dibayar',
    this.paymentMethod = 'Transfer Bank',
    this.snapToken,
    this.waybillId,
    this.biteshipOrderId,
    required this.createdAt,
    this.address = '',
    this.courier = 'JNE',
    this.service = 'Reguler',
    this.shippingFee = 0,
    this.notes,
  }) : statusLabel = statusLabel ?? _defaultStatusLabel(status);

  static String _defaultStatusLabel(String s) {
    switch (s.toLowerCase()) {
      case 'pending':
        return 'Menunggu Konfirmasi';
      case 'processing':
        return 'Diproses';
      case 'shipped':
        return 'Dikirim';
      case 'delivered':
        return 'Selesai';
      case 'cancelled':
        return 'Dibatalkan';
      default:
        return s;
    }
  }

  bool matchesStatusFilter(String filter) {
    if (filter == 'Semua') return true;

    final statusForFilter = {
      'Menunggu': 'pending',
      'Diproses': 'processing',
      'Dikirim': 'shipped',
      'Selesai': 'delivered',
      'Dibatalkan': 'cancelled',
    };
    return status == statusForFilter[filter];
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    List<OrderItem> items = [];
    if (json['items'] != null && json['items'] is List) {
      items = (json['items'] as List)
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    final rawId = json['id'] ?? json['id_pesanan'] ?? 0;
    final rawUid = json['user_id'] ?? json['id_user'] ?? 0;
    final rawCode = json['order_code'] ?? json['kode_pesanan'] ?? '';
    final rawTotal = json['total_price'] ?? json['total_harga'] ?? 0;
    final rawOngkir = json['shipping_fee'] ?? json['ongkir'] ?? 0;
    final rawStatus = json['status'] ?? 'pending';
    final rawStatusLabel = json['status_label'] ?? json['status_pesanan'];
    final rawCreatedAt = json['created_at'] ?? json['tanggal_pesanan'];

    return Order(
      id: rawId is int ? rawId : int.parse(rawId.toString()),
      orderCode: rawCode.toString(),
      userId: rawUid is int ? rawUid : int.parse(rawUid.toString()),
      recipientName: (json['recipient_name'] ?? json['nama_penerima'] ?? '')
          .toString(),
      recipientPhone: (json['recipient_phone'] ?? json['no_hp_penerima'] ?? '')
          .toString(),
      items: items,
      totalPrice: rawTotal is double
          ? rawTotal
          : double.parse(rawTotal.toString()),
      status: rawStatus.toString(),
      statusLabel: rawStatusLabel?.toString(),
      paymentStatus:
          (json['payment_status'] ??
                  json['status_pembayaran'] ??
                  'Belum Dibayar')
              .toString(),
      paymentMethod:
          (json['payment_method'] ??
                  json['metode_pembayaran'] ??
                  'Transfer Bank')
              .toString(),
      snapToken: json['snap_token']?.toString(),
      waybillId: (json['waybill_id'] ?? json['nomor_resi'])?.toString(),
      biteshipOrderId: (json['biteship_order_id'])?.toString(),
      createdAt: rawCreatedAt != null
          ? (DateTime.tryParse(rawCreatedAt.toString()) ?? DateTime.now())
          : DateTime.now(),
      address: (json['address'] ?? json['alamat_pengiriman'] ?? '').toString(),
      courier: (json['courier'] ?? json['kurir'] ?? 'JNE').toString(),
      service: (json['service'] ?? json['layanan_pengiriman'] ?? 'Reguler')
          .toString(),
      shippingFee: rawOngkir is double
          ? rawOngkir
          : double.parse(rawOngkir.toString()),
      notes: json['notes']?.toString() ?? json['catatan']?.toString(),
    );
  }

  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'processing':
        return const Color(0xFF3B82F6);
      case 'shipped':
        return const Color(0xFF8B5CF6);
      case 'delivered':
        return const Color(0xFF10B981);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return Colors.blueGrey;
    }
  }

  IconData get statusIcon {
    switch (status.toLowerCase()) {
      case 'pending':
        return Icons.schedule_rounded;
      case 'processing':
        return Icons.autorenew_rounded;
      case 'shipped':
        return Icons.local_shipping_rounded;
      case 'delivered':
        return Icons.check_circle_rounded;
      case 'cancelled':
        return Icons.cancel_rounded;
      default:
        return Icons.info_outline_rounded;
    }
  }
}
