/// Shipping Method Model
library;

import 'package:equatable/equatable.dart';

/// Shipping Method
class ShippingMethod extends Equatable {
  final int id;
  final int creatorId;
  final String creatorType; // admin, seller
  final String title;
  final double cost;
  final int duration; // in days
  final bool isActive;

  const ShippingMethod({
    required this.id,
    required this.creatorId,
    this.creatorType = 'admin',
    required this.title,
    required this.cost,
    this.duration = 0,
    this.isActive = true,
  });

  /// Duration text
  String get durationText {
    if (duration <= 0) return 'Estimasi tidak tersedia';
    if (duration == 1) return '1 hari';
    return '$duration hari';
  }

  factory ShippingMethod.fromJson(Map<String, dynamic> json) {
    return ShippingMethod(
      id: json['id'] as int,
      creatorId: json['creator_id'] as int? ?? 0,
      creatorType: json['creator_type'] as String? ?? 'admin',
      title: json['title'] as String? ?? '',
      cost: (json['cost'] as num?)?.toDouble() ?? 0,
      duration: json['duration'] as int? ?? 0,
      isActive: json['status'] == 1 || json['is_active'] == true,
    );
  }

  @override
  List<Object?> get props => [
    id,
    creatorId,
    creatorType,
    title,
    cost,
    duration,
    isActive,
  ];
}

/// Chosen shipping method for a cart group
class ChosenShipping extends Equatable {
  final String cartGroupId;
  final int shippingMethodId;
  final double shippingCost;

  const ChosenShipping({
    required this.cartGroupId,
    required this.shippingMethodId,
    required this.shippingCost,
  });

  factory ChosenShipping.fromJson(Map<String, dynamic> json) {
    return ChosenShipping(
      cartGroupId: json['cart_group_id'] as String,
      shippingMethodId: json['shipping_method_id'] as int,
      shippingCost: (json['shipping_cost'] as num?)?.toDouble() ?? 0,
    );
  }

  @override
  List<Object?> get props => [cartGroupId, shippingMethodId, shippingCost];
}

/// Shipping type info
class ShippingTypeInfo extends Equatable {
  final String shippingType; // order_wise, category_wise, product_wise
  final bool inHouseDelivery;
  final bool sellerShipping;

  const ShippingTypeInfo({
    this.shippingType = 'order_wise',
    this.inHouseDelivery = true,
    this.sellerShipping = false,
  });

  factory ShippingTypeInfo.fromJson(Map<String, dynamic> json) {
    return ShippingTypeInfo(
      shippingType: json['shipping_type'] as String? ?? 'order_wise',
      inHouseDelivery: json['inhouse_delivery'] == 1,
      sellerShipping: json['seller_shipping'] == 1,
    );
  }

  @override
  List<Object?> get props => [shippingType, inHouseDelivery, sellerShipping];
}
