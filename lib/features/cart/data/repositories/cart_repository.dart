/// Cart Repository
library;

import '../models/cart_model.dart';
import '../models/address_model.dart';
import '../models/shipping_model.dart';
import '../models/coupon_model.dart';
import '../services/cart_api_service.dart';
import '../services/address_api_service.dart';
import '../services/shipping_api_service.dart';
import '../services/order_api_service.dart';
import '../../../../core/network/api_response.dart';
import '../../../orders/data/models/order_model.dart';

class CartRepository {
  final CartApiService _cartApiService;
  final AddressApiService _addressApiService;
  final ShippingApiService _shippingApiService;
  final OrderApiService _orderApiService;

  CartRepository({
    required CartApiService cartApiService,
    required AddressApiService addressApiService,
    required ShippingApiService shippingApiService,
    required OrderApiService orderApiService,
  }) : _cartApiService = cartApiService,
       _addressApiService = addressApiService,
       _shippingApiService = shippingApiService,
       _orderApiService = orderApiService;

  // ==================== CART ====================

  /// Get cart items
  Future<ApiResponse<List<CartItem>>> getCart() {
    return _cartApiService.getCart();
  }

  /// Add item to cart
  Future<ApiResponse<void>> addToCart(AddToCartRequest request) {
    return _cartApiService.addToCart(request);
  }

  /// Update cart item quantity
  Future<ApiResponse<void>> updateCartItem(UpdateCartRequest request) {
    return _cartApiService.updateCart(request);
  }

  /// Remove item from cart
  Future<ApiResponse<void>> removeFromCart(int cartItemId) {
    return _cartApiService.removeFromCart(cartItemId);
  }

  /// Clear all cart items
  Future<ApiResponse<void>> clearCart() {
    return _cartApiService.clearCart();
  }

  /// Apply coupon code
  Future<ApiResponse<CouponResult>> applyCoupon(String code) {
    return _cartApiService.applyCoupon(code);
  }

  /// Get available coupons
  Future<ApiResponse<List<Coupon>>> getCoupons() {
    return _cartApiService.getCoupons();
  }

  // ==================== ADDRESS ====================

  /// Get all addresses
  Future<ApiResponse<List<ShippingAddress>>> getAddresses() {
    return _addressApiService.getAddresses();
  }

  /// Get address by ID
  Future<ApiResponse<ShippingAddress>> getAddress(int id) {
    return _addressApiService.getAddress(id);
  }

  /// Add new address
  Future<ApiResponse<ShippingAddress>> addAddress(AddressRequest request) {
    return _addressApiService.addAddress(request);
  }

  /// Update address
  Future<ApiResponse<ShippingAddress>> updateAddress(AddressRequest request) {
    return _addressApiService.updateAddress(request);
  }

  /// Delete address
  Future<ApiResponse<void>> deleteAddress(int id) {
    return _addressApiService.deleteAddress(id);
  }

  // ==================== SHIPPING ====================

  /// Get shipping methods for seller
  Future<ApiResponse<List<ShippingMethod>>> getShippingMethods({
    required int sellerId,
    required String sellerIs,
  }) {
    return _shippingApiService.getShippingMethods(
      sellerId: sellerId,
      sellerIs: sellerIs,
    );
  }

  /// Choose shipping method
  Future<ApiResponse<void>> chooseShippingMethod({
    required String cartGroupId,
    required int shippingMethodId,
  }) {
    return _shippingApiService.chooseShippingMethod(
      cartGroupId: cartGroupId,
      shippingMethodId: shippingMethodId,
    );
  }

  /// Get chosen shipping methods
  Future<ApiResponse<List<ChosenShipping>>> getChosenShippingMethods() {
    return _shippingApiService.getChosenShippingMethods();
  }

  /// Get shipping type info
  Future<ApiResponse<ShippingTypeInfo>> getShippingType() {
    return _shippingApiService.getShippingType();
  }

  // ==================== ORDER ====================

  /// Place order with COD
  Future<ApiResponse<PlaceOrderResult>> placeOrder({
    required int addressId,
    int? billingAddressId,
    String? orderNote,
  }) {
    return _orderApiService.placeOrder(
      addressId: addressId,
      billingAddressId: billingAddressId,
      orderNote: orderNote,
    );
  }

  /// Get orders list
  Future<PaginatedResponse<Order>> getOrders({
    int page = 1,
    int perPage = 10,
    String? status,
  }) {
    return _orderApiService.getOrders(
      page: page,
      perPage: perPage,
      status: status,
    );
  }

  /// Get order by ID
  Future<ApiResponse<Order>> getOrderById(int orderId) {
    return _orderApiService.getOrderById(orderId);
  }

  /// Track order
  Future<ApiResponse<OrderTracking>> trackOrder(String orderId) {
    return _orderApiService.trackOrder(orderId);
  }

  /// Cancel order
  Future<ApiResponse<void>> cancelOrder(int orderId) {
    return _orderApiService.cancelOrder(orderId);
  }
}
