/// Cart API Service
library;

import 'package:dio/dio.dart';
import '../models/cart_model.dart';
import '../models/coupon_model.dart';
import '../../../../core/network/api_response.dart';

class CartApiService {
  final Dio _dio;
  static const String _basePath = '/cart';

  CartApiService(this._dio);

  /// Get cart items
  Future<ApiResponse<List<CartItem>>> getCart() async {
    try {
      final response = await _dio.get(_basePath);
      final data = response.data;

      if (data is List) {
        final items = data
            .map((e) => CartItem.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiResponse<List<CartItem>>(success: true, data: items);
      }

      return ApiResponse<List<CartItem>>(success: true, data: []);
    } on DioException catch (e) {
      return ApiResponse<List<CartItem>>(
        success: false,
        message:
            e.response?.data?['message'] as String? ??
            e.message ??
            'Gagal memuat keranjang',
      );
    }
  }

  /// Add item to cart
  Future<ApiResponse<void>> addToCart(AddToCartRequest request) async {
    try {
      final response = await _dio.post(
        '$_basePath/add',
        data: request.toJson(),
      );
      final data = response.data;

      if (data['errors'] != null) {
        final errors = data['errors'] as List;
        final message = errors.isNotEmpty
            ? errors.first['message'] as String? ??
                  'Gagal menambahkan ke keranjang'
            : 'Gagal menambahkan ke keranjang';
        return ApiResponse<void>(success: false, message: message);
      }

      return ApiResponse<void>(
        success: true,
        message:
            data['message'] as String? ?? 'Berhasil ditambahkan ke keranjang',
      );
    } on DioException catch (e) {
      return ApiResponse<void>(
        success: false,
        message:
            e.response?.data?['message'] as String? ??
            e.message ??
            'Gagal menambahkan ke keranjang',
      );
    }
  }

  /// Update cart item quantity
  Future<ApiResponse<void>> updateCart(UpdateCartRequest request) async {
    try {
      final response = await _dio.put(
        '$_basePath/update',
        data: request.toJson(),
      );
      final data = response.data;

      if (data['errors'] != null) {
        final errors = data['errors'] as List;
        final message = errors.isNotEmpty
            ? errors.first['message'] as String? ?? 'Gagal mengupdate keranjang'
            : 'Gagal mengupdate keranjang';
        return ApiResponse<void>(success: false, message: message);
      }

      return ApiResponse<void>(success: true);
    } on DioException catch (e) {
      return ApiResponse<void>(
        success: false,
        message:
            e.response?.data?['message'] as String? ??
            e.message ??
            'Gagal mengupdate keranjang',
      );
    }
  }

  /// Remove item from cart
  Future<ApiResponse<void>> removeFromCart(int cartItemId) async {
    try {
      await _dio.delete('$_basePath/remove', data: {'key': cartItemId});
      return ApiResponse<void>(success: true, message: 'Item berhasil dihapus');
    } on DioException catch (e) {
      return ApiResponse<void>(
        success: false,
        message:
            e.response?.data?['message'] as String? ??
            e.message ??
            'Gagal menghapus item',
      );
    }
  }

  /// Clear all items from cart
  Future<ApiResponse<void>> clearCart() async {
    try {
      await _dio.delete('$_basePath/remove-all');
      return ApiResponse<void>(
        success: true,
        message: 'Keranjang berhasil dikosongkan',
      );
    } on DioException catch (e) {
      return ApiResponse<void>(
        success: false,
        message:
            e.response?.data?['message'] as String? ??
            e.message ??
            'Gagal mengosongkan keranjang',
      );
    }
  }

  /// Apply coupon
  Future<ApiResponse<CouponResult>> applyCoupon(String code) async {
    try {
      final response = await _dio.get(
        '/coupon/apply',
        queryParameters: {'code': code},
      );
      final data = response.data;

      if (data['coupon'] != null) {
        return ApiResponse<CouponResult>(
          success: true,
          data: CouponResult.fromJson(data as Map<String, dynamic>),
        );
      }

      return ApiResponse<CouponResult>(
        success: false,
        message: data['message'] as String? ?? 'Kupon tidak valid',
        data: CouponResult.error(
          data['message'] as String? ?? 'Kupon tidak valid',
        ),
      );
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] as String? ??
          e.message ??
          'Gagal menggunakan kupon';
      return ApiResponse<CouponResult>(
        success: false,
        message: message,
        data: CouponResult.error(message),
      );
    }
  }

  /// Get available coupons
  Future<ApiResponse<List<Coupon>>> getCoupons() async {
    try {
      final response = await _dio.get('/coupon/list');
      final data = response.data;

      if (data is List) {
        final coupons = data
            .map((e) => Coupon.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiResponse<List<Coupon>>(success: true, data: coupons);
      } else if (data['data'] is List) {
        final coupons = (data['data'] as List)
            .map((e) => Coupon.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiResponse<List<Coupon>>(success: true, data: coupons);
      }

      return ApiResponse<List<Coupon>>(success: true, data: []);
    } on DioException catch (e) {
      return ApiResponse<List<Coupon>>(
        success: false,
        message:
            e.response?.data?['message'] as String? ??
            e.message ??
            'Gagal memuat kupon',
      );
    }
  }
}
