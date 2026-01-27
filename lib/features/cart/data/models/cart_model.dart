/// Cart Models
library;

import 'package:equatable/equatable.dart';
import '../../../../features/home/data/models/product_model.dart';

/// Cart Item from API response
class CartItem extends Equatable {
  final int id;
  final int productId;
  final int customerId;
  final String cartGroupId;
  final int quantity;
  final double price;
  final double tax;
  final double discount;
  final String? variant;
  final String? color;
  final Product? product;
  final Seller? seller;
  final int currentStock;
  final int minimumOrderQty;

  // Computed fields
  final MinimumOrderAmountInfo? minimumOrderAmountInfo;
  final FreeDeliveryInfo? freeDeliveryInfo;

  const CartItem({
    required this.id,
    required this.productId,
    required this.customerId,
    required this.cartGroupId,
    required this.quantity,
    required this.price,
    this.tax = 0,
    this.discount = 0,
    this.variant,
    this.color,
    this.product,
    this.seller,
    this.currentStock = 0,
    this.minimumOrderQty = 1,
    this.minimumOrderAmountInfo,
    this.freeDeliveryInfo,
  });

  /// Price after discount
  double get unitPrice => price - discount;

  /// Subtotal for this item
  double get subtotal => unitPrice * quantity;

  /// Total with tax
  double get total => subtotal + (tax * quantity);

  /// Check if quantity is valid
  bool get isValidQuantity =>
      quantity >= minimumOrderQty && quantity <= currentStock;

  /// Check if out of stock
  bool get isOutOfStock => currentStock <= 0;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      customerId: json['customer_id'] as int,
      cartGroupId: json['cart_group_id'] as String,
      quantity: json['quantity'] as int? ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      tax: (json['tax'] as num?)?.toDouble() ?? 0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      variant: json['variant'] as String?,
      color: json['color'] as String?,
      product: json['product'] != null
          ? Product.fromJson(json['product'] as Map<String, dynamic>)
          : null,
      seller: json['seller'] != null
          ? Seller.fromJson(json['seller'] as Map<String, dynamic>)
          : null,
      currentStock: json['current_stock'] as int? ?? 0,
      minimumOrderQty: json['minimum_order_qty'] as int? ?? 1,
      minimumOrderAmountInfo: json['minimum_order_amount_info'] != null
          ? MinimumOrderAmountInfo.fromJson(
              json['minimum_order_amount_info'] as Map<String, dynamic>,
            )
          : null,
      freeDeliveryInfo: json['free_delivery_order_amount'] != null
          ? FreeDeliveryInfo.fromJson(
              json['free_delivery_order_amount'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  CartItem copyWith({
    int? id,
    int? productId,
    int? customerId,
    String? cartGroupId,
    int? quantity,
    double? price,
    double? tax,
    double? discount,
    String? variant,
    String? color,
    Product? product,
    Seller? seller,
    int? currentStock,
    int? minimumOrderQty,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      customerId: customerId ?? this.customerId,
      cartGroupId: cartGroupId ?? this.cartGroupId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      tax: tax ?? this.tax,
      discount: discount ?? this.discount,
      variant: variant ?? this.variant,
      color: color ?? this.color,
      product: product ?? this.product,
      seller: seller ?? this.seller,
      currentStock: currentStock ?? this.currentStock,
      minimumOrderQty: minimumOrderQty ?? this.minimumOrderQty,
    );
  }

  @override
  List<Object?> get props => [
    id,
    productId,
    customerId,
    cartGroupId,
    quantity,
    price,
    tax,
    discount,
    variant,
    color,
    product,
    seller,
  ];
}

/// Seller information for cart grouping
class Seller extends Equatable {
  final int id;
  final String name;
  final Shop? shop;

  const Seller({required this.id, required this.name, this.shop});

  factory Seller.fromJson(Map<String, dynamic> json) {
    return Seller(
      id: json['id'] as int,
      name: json['name'] as String? ?? json['f_name'] as String? ?? 'Seller',
      shop: json['shop'] != null
          ? Shop.fromJson(json['shop'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [id, name, shop];
}

/// Shop information
class Shop extends Equatable {
  final int id;
  final String name;
  final String? image;

  const Shop({required this.id, required this.name, this.image});

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      image: json['image'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name, image];
}

/// Minimum order amount info
class MinimumOrderAmountInfo extends Equatable {
  final int status; // 0 = not met, 1 = met
  final double amount;
  final double currentAmount;

  const MinimumOrderAmountInfo({
    this.status = 1,
    this.amount = 0,
    this.currentAmount = 0,
  });

  bool get isMet => status == 1;
  double get remaining => amount - currentAmount;

  factory MinimumOrderAmountInfo.fromJson(Map<String, dynamic> json) {
    return MinimumOrderAmountInfo(
      status: json['status'] as int? ?? 1,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      currentAmount: (json['current_amount'] as num?)?.toDouble() ?? 0,
    );
  }

  @override
  List<Object?> get props => [status, amount, currentAmount];
}

/// Free delivery info
class FreeDeliveryInfo extends Equatable {
  final int status; // 0 = not applicable, 1 = applicable
  final double amount;
  final double percentage;
  final double shippingCostSaved;

  const FreeDeliveryInfo({
    this.status = 0,
    this.amount = 0,
    this.percentage = 0,
    this.shippingCostSaved = 0,
  });

  bool get isApplicable => status == 1;

  factory FreeDeliveryInfo.fromJson(Map<String, dynamic> json) {
    return FreeDeliveryInfo(
      status: json['status'] as int? ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0,
      shippingCostSaved: (json['shipping_cost_saved'] as num?)?.toDouble() ?? 0,
    );
  }

  @override
  List<Object?> get props => [status, amount, percentage, shippingCostSaved];
}

/// Cart grouped by seller
class CartGroup extends Equatable {
  final String cartGroupId;
  final Seller? seller;
  final List<CartItem> items;
  final MinimumOrderAmountInfo? minimumOrderAmountInfo;
  final FreeDeliveryInfo? freeDeliveryInfo;

  const CartGroup({
    required this.cartGroupId,
    this.seller,
    required this.items,
    this.minimumOrderAmountInfo,
    this.freeDeliveryInfo,
  });

  /// Subtotal for this group
  double get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);

  /// Total tax for this group
  double get totalTax =>
      items.fold(0, (sum, item) => sum + (item.tax * item.quantity));

  /// Total items count
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  /// Check if minimum order is met
  bool get isMinimumOrderMet => minimumOrderAmountInfo?.isMet ?? true;

  @override
  List<Object?> get props => [cartGroupId, seller, items];
}

/// Add to cart request
class AddToCartRequest {
  final int productId;
  final int quantity;
  final String? variant;
  final String? color;
  final Map<String, dynamic>? choices;

  const AddToCartRequest({
    required this.productId,
    required this.quantity,
    this.variant,
    this.color,
    this.choices,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': productId,
      'quantity': quantity,
      if (variant != null) 'variant': variant,
      if (color != null) 'color': color,
      if (choices != null) 'choices': choices,
    };
  }
}

/// Update cart request
class UpdateCartRequest {
  final int cartItemId;
  final int quantity;

  const UpdateCartRequest({required this.cartItemId, required this.quantity});

  Map<String, dynamic> toJson() {
    return {'key': cartItemId, 'quantity': quantity};
  }
}
