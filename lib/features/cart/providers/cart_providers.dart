/// Cart Providers (Riverpod)
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/cart_model.dart';
import '../data/models/coupon_model.dart';
import '../data/services/cart_api_service.dart';
import '../data/services/address_api_service.dart';
import '../data/services/shipping_api_service.dart';
import '../data/services/order_api_service.dart';
import '../data/repositories/cart_repository.dart';
import '../../../core/network/dio_client.dart';

// ==================== SERVICE PROVIDERS ====================

final cartApiServiceProvider = Provider<CartApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return CartApiService(dio);
});

final addressApiServiceProvider = Provider<AddressApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return AddressApiService(dio);
});

final shippingApiServiceProvider = Provider<ShippingApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return ShippingApiService(dio);
});

final orderApiServiceProvider = Provider<OrderApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return OrderApiService(dio);
});

// ==================== REPOSITORY PROVIDER ====================

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepository(
    cartApiService: ref.watch(cartApiServiceProvider),
    addressApiService: ref.watch(addressApiServiceProvider),
    shippingApiService: ref.watch(shippingApiServiceProvider),
    orderApiService: ref.watch(orderApiServiceProvider),
  );
});

// ==================== CART STATE ====================

class CartState {
  final bool isLoading;
  final List<CartItem> items;
  final String? errorMessage;
  final CouponResult? appliedCoupon;

  const CartState({
    this.isLoading = false,
    this.items = const [],
    this.errorMessage,
    this.appliedCoupon,
  });

  /// Group items by seller
  List<CartGroup> get groupedItems {
    final Map<String, List<CartItem>> grouped = {};

    for (final item in items) {
      if (!grouped.containsKey(item.cartGroupId)) {
        grouped[item.cartGroupId] = [];
      }
      grouped[item.cartGroupId]!.add(item);
    }

    return grouped.entries.map((entry) {
      final items = entry.value;
      final firstItem = items.first;

      return CartGroup(
        cartGroupId: entry.key,
        seller: firstItem.seller,
        items: items,
        minimumOrderAmountInfo: firstItem.minimumOrderAmountInfo,
        freeDeliveryInfo: firstItem.freeDeliveryInfo,
      );
    }).toList();
  }

  /// Total items count
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  /// Subtotal (before shipping and discount)
  double get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);

  /// Total tax
  double get totalTax =>
      items.fold(0, (sum, item) => sum + (item.tax * item.quantity));

  /// Coupon discount
  double get couponDiscount => appliedCoupon?.discountAmount ?? 0;

  /// Check if cart is empty
  bool get isEmpty => items.isEmpty;

  /// Check if has any out of stock item
  bool get hasOutOfStockItems => items.any((item) => item.isOutOfStock);

  CartState copyWith({
    bool? isLoading,
    List<CartItem>? items,
    String? errorMessage,
    CouponResult? appliedCoupon,
    bool clearError = false,
    bool clearCoupon = false,
  }) {
    return CartState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      appliedCoupon: clearCoupon ? null : (appliedCoupon ?? this.appliedCoupon),
    );
  }
}

// ==================== CART NOTIFIER ====================

class CartNotifier extends StateNotifier<CartState> {
  final CartRepository _repository;

  CartNotifier(this._repository) : super(const CartState());

  /// Load cart from API
  Future<void> loadCart() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final response = await _repository.getCart();

    if (response.success && response.data != null) {
      state = state.copyWith(isLoading: false, items: response.data!);
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message ?? 'Gagal memuat keranjang',
      );
    }
  }

  /// Add item to cart
  Future<bool> addToCart({
    required int productId,
    required int quantity,
    String? variant,
    String? color,
  }) async {
    final response = await _repository.addToCart(
      AddToCartRequest(
        productId: productId,
        quantity: quantity,
        variant: variant,
        color: color,
      ),
    );

    if (response.success) {
      await loadCart(); // Refresh cart
      return true;
    }

    state = state.copyWith(errorMessage: response.message);
    return false;
  }

  /// Update item quantity
  Future<bool> updateQuantity(int cartItemId, int quantity) async {
    // Optimistic update
    final updatedItems = state.items.map((item) {
      if (item.id == cartItemId) {
        return item.copyWith(quantity: quantity);
      }
      return item;
    }).toList();

    state = state.copyWith(items: updatedItems);

    final response = await _repository.updateCartItem(
      UpdateCartRequest(cartItemId: cartItemId, quantity: quantity),
    );

    if (!response.success) {
      await loadCart(); // Revert on failure
      state = state.copyWith(errorMessage: response.message);
      return false;
    }

    return true;
  }

  /// Increment item quantity
  Future<bool> incrementQuantity(int cartItemId) async {
    final item = state.items.firstWhere(
      (item) => item.id == cartItemId,
      orElse: () => throw Exception('Item not found'),
    );

    if (item.quantity >= item.currentStock) {
      state = state.copyWith(errorMessage: 'Stok tidak mencukupi');
      return false;
    }

    return updateQuantity(cartItemId, item.quantity + 1);
  }

  /// Decrement item quantity
  Future<bool> decrementQuantity(int cartItemId) async {
    final item = state.items.firstWhere(
      (item) => item.id == cartItemId,
      orElse: () => throw Exception('Item not found'),
    );

    if (item.quantity <= item.minimumOrderQty) {
      return false;
    }

    return updateQuantity(cartItemId, item.quantity - 1);
  }

  /// Remove item from cart
  Future<bool> removeItem(int cartItemId) async {
    // Optimistic update
    final updatedItems = state.items
        .where((item) => item.id != cartItemId)
        .toList();
    state = state.copyWith(items: updatedItems);

    final response = await _repository.removeFromCart(cartItemId);

    if (!response.success) {
      await loadCart(); // Revert on failure
      state = state.copyWith(errorMessage: response.message);
      return false;
    }

    return true;
  }

  /// Clear all items
  Future<bool> clearCart() async {
    final response = await _repository.clearCart();

    if (response.success) {
      state = state.copyWith(items: [], clearCoupon: true);
      return true;
    }

    state = state.copyWith(errorMessage: response.message);
    return false;
  }

  /// Apply coupon
  Future<bool> applyCoupon(String code) async {
    final response = await _repository.applyCoupon(code);

    if (response.success && response.data != null && response.data!.success) {
      state = state.copyWith(appliedCoupon: response.data);
      return true;
    }

    state = state.copyWith(
      errorMessage:
          response.data?.message ?? response.message ?? 'Kupon tidak valid',
    );
    return false;
  }

  /// Remove coupon
  void removeCoupon() {
    state = state.copyWith(clearCoupon: true);
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

// ==================== CART PROVIDER ====================

final cartProvider = StateNotifierProvider<CartNotifier, CartState>((ref) {
  final repository = ref.watch(cartRepositoryProvider);
  return CartNotifier(repository);
});

// ==================== COMPUTED PROVIDERS ====================

/// Cart items count
final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).totalItems;
});

/// Cart subtotal
final cartSubtotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).subtotal;
});

/// Cart is empty
final cartIsEmptyProvider = Provider<bool>((ref) {
  return ref.watch(cartProvider).isEmpty;
});
