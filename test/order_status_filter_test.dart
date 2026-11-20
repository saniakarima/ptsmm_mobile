import 'package:flutter_test/flutter_test.dart';
import 'package:ptsmmmobile/models/order.dart';

void main() {
  test(
    'status filters use the canonical order status, not its display label',
    () {
      final order = Order(
        id: 12,
        userId: 3,
        items: const [],
        totalPrice: 125000,
        status: 'pending',
        statusLabel: 'Menunggu Konfirmasi',
        createdAt: DateTime(2026, 11, 16),
      );

      expect(order.matchesStatusFilter('Semua'), isTrue);
      expect(order.matchesStatusFilter('Menunggu'), isTrue);
      expect(order.matchesStatusFilter('Dikirim'), isFalse);
    },
  );
}
