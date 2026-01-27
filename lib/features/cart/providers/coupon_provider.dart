/// Coupon Provider
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/coupon_model.dart';
import 'cart_providers.dart';

/// Available coupons provider
final availableCouponsProvider = FutureProvider<List<Coupon>>((ref) async {
  final repository = ref.watch(cartRepositoryProvider);
  final response = await repository.getCoupons();

  if (response.success && response.data != null) {
    return response.data!;
  }

  // Return mock data if API fails or returns empty (for development)
  // In production, this should likely just return empty list or throw
  if (response.data == null || response.data!.isEmpty) {
    return _getMockCoupons();
  }

  return [];
});

/// Mock coupons for testing
List<Coupon> _getMockCoupons() {
  return [
    Coupon(
      id: 1,
      code: 'MASAGI10',
      title: 'Diskon 10% Pengguna Baru',
      discountType: 'percentage',
      discount: 10,
      minPurchase: 50000,
      maxDiscount: 20000,
      expireDate: DateTime.now().add(const Duration(days: 7)),
    ),
    Coupon(
      id: 2,
      code: 'ONGKIR15',
      title: 'Potongan Ongkir Rp 15.000',
      discountType: 'amount',
      discount: 15000,
      minPurchase: 100000,
      expireDate: DateTime.now().add(const Duration(days: 30)),
    ),
    Coupon(
      id: 3,
      code: 'FLASH50',
      title: 'Flash Sale Diskon 50%',
      discountType: 'percentage',
      discount: 50,
      minPurchase: 0,
      maxDiscount: 10000,
      expireDate: DateTime.now().add(const Duration(hours: 5)),
    ),
    Coupon(
      id: 4,
      code: 'EXPIRED123',
      title: 'Kupon Kadaluarsa',
      discountType: 'amount',
      discount: 5000,
      expireDate: DateTime.now().subtract(const Duration(days: 1)),
      isActive: false,
    ),
  ];
}
