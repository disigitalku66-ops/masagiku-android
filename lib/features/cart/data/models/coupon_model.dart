/// Coupon Model
library;

import 'package:equatable/equatable.dart';

/// Coupon model
class Coupon extends Equatable {
  final int id;
  final String code;
  final String title;
  final String discountType; // percentage, amount
  final double discount;
  final double minPurchase;
  final double maxDiscount;
  final DateTime? startDate;
  final DateTime? expireDate;
  final bool isActive;

  const Coupon({
    required this.id,
    required this.code,
    required this.title,
    required this.discountType,
    required this.discount,
    this.minPurchase = 0,
    this.maxDiscount = 0,
    this.startDate,
    this.expireDate,
    this.isActive = true,
  });

  /// Check if coupon is expired
  bool get isExpired {
    if (expireDate == null) return false;
    return DateTime.now().isAfter(expireDate!);
  }

  /// Check if coupon is valid (not expired and active)
  bool get isValid => isActive && !isExpired;

  /// Discount type label
  String get discountTypeLabel {
    return discountType == 'percentage' ? 'Persentase' : 'Nominal';
  }

  /// Formatted discount
  String get formattedDiscount {
    if (discountType == 'percentage') {
      return '${discount.toStringAsFixed(0)}%';
    }
    return 'Rp ${discount.toStringAsFixed(0)}';
  }

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'] as int,
      code: json['code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      discountType: json['discount_type'] as String? ?? 'amount',
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      minPurchase: (json['min_purchase'] as num?)?.toDouble() ?? 0,
      maxDiscount: (json['max_discount'] as num?)?.toDouble() ?? 0,
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'] as String)
          : null,
      expireDate: json['expire_date'] != null
          ? DateTime.tryParse(json['expire_date'] as String)
          : null,
      isActive: json['status'] == 1 || json['is_active'] == true,
    );
  }

  @override
  List<Object?> get props => [
    id,
    code,
    title,
    discountType,
    discount,
    minPurchase,
    maxDiscount,
    startDate,
    expireDate,
    isActive,
  ];
}

/// Coupon apply result
class CouponResult extends Equatable {
  final bool success;
  final Coupon? coupon;
  final double discountAmount;
  final String? message;

  const CouponResult({
    required this.success,
    this.coupon,
    this.discountAmount = 0,
    this.message,
  });

  factory CouponResult.fromJson(Map<String, dynamic> json) {
    return CouponResult(
      success: json['success'] == true || json['coupon'] != null,
      coupon: json['coupon'] != null
          ? Coupon.fromJson(json['coupon'] as Map<String, dynamic>)
          : null,
      discountAmount: (json['discount'] as num?)?.toDouble() ?? 0,
      message: json['message'] as String?,
    );
  }

  factory CouponResult.error(String message) {
    return CouponResult(success: false, message: message);
  }

  @override
  List<Object?> get props => [success, coupon, discountAmount, message];
}
