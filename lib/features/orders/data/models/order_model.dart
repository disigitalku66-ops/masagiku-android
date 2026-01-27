/// Order Models
library;

import 'package:equatable/equatable.dart';
import '../../../cart/data/models/address_model.dart';

/// Place order result
class PlaceOrderResult extends Equatable {
  final bool success;
  final String message;
  final String? orderId;
  final String? orderGroupId;

  const PlaceOrderResult({
    required this.success,
    required this.message,
    this.orderId,
    this.orderGroupId,
  });

  @override
  List<Object?> get props => [success, message, orderId, orderGroupId];
}

/// Order model
class Order extends Equatable {
  final int id;
  final String? orderGroupId;
  final int customerId;
  final double orderAmount;
  final double discountAmount;
  final double shippingCost;
  final String orderStatus;
  final String paymentStatus;
  final String paymentMethod;
  final String? orderNote;
  final ShippingAddress? shippingAddress;
  final DateTime? createdAt;

  const Order({
    required this.id,
    this.orderGroupId,
    required this.customerId,
    required this.orderAmount,
    this.discountAmount = 0,
    this.shippingCost = 0,
    required this.orderStatus,
    required this.paymentStatus,
    required this.paymentMethod,
    this.orderNote,
    this.shippingAddress,
    this.createdAt,
  });

  /// Order status label in Indonesian
  String get orderStatusLabel {
    switch (orderStatus) {
      case 'pending':
        return 'Menunggu';
      case 'confirmed':
        return 'Dikonfirmasi';
      case 'processing':
        return 'Diproses';
      case 'out_for_delivery':
        return 'Dalam Pengiriman';
      case 'delivered':
        return 'Selesai';
      case 'returned':
        return 'Dikembalikan';
      case 'failed':
        return 'Gagal';
      case 'canceled':
        return 'Dibatalkan';
      default:
        return orderStatus;
    }
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as int,
      orderGroupId: json['order_group_id'] as String?,
      customerId: json['customer_id'] as int? ?? 0,
      orderAmount: (json['order_amount'] as num?)?.toDouble() ?? 0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0,
      shippingCost: (json['shipping_cost'] as num?)?.toDouble() ?? 0,
      orderStatus: json['order_status'] as String? ?? 'pending',
      paymentStatus: json['payment_status'] as String? ?? 'unpaid',
      paymentMethod: json['payment_method'] as String? ?? 'cash_on_delivery',
      shippingAddress: json['shipping_address'] != null
          ? ShippingAddress.fromJson(
              json['shipping_address'] as Map<String, dynamic>,
            )
          : null,
      orderNote: json['order_note'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    orderGroupId,
    customerId,
    orderAmount,
    discountAmount,
    shippingCost,
    orderStatus,
    paymentStatus,
    paymentMethod,
    orderNote,
    createdAt,
  ];
}

/// Order tracking model
class OrderTracking extends Equatable {
  final String orderStatus;
  final List<TrackingStep> steps;

  const OrderTracking({required this.orderStatus, this.steps = const []});

  factory OrderTracking.fromJson(Map<String, dynamic> json) {
    return OrderTracking(
      orderStatus: json['order_status'] as String? ?? 'pending',
      steps: json['tracking'] != null
          ? (json['tracking'] as List)
                .map((e) => TrackingStep.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
    );
  }

  @override
  List<Object?> get props => [orderStatus, steps];
}

/// Tracking step
class TrackingStep extends Equatable {
  final String status;
  final String? note;
  final DateTime? timestamp;

  const TrackingStep({required this.status, this.note, this.timestamp});

  factory TrackingStep.fromJson(Map<String, dynamic> json) {
    return TrackingStep(
      status: json['status'] as String? ?? '',
      note: json['note'] as String?,
      timestamp: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [status, note, timestamp];
}
