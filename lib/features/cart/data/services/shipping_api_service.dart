/// Shipping API Service
library;

import 'package:dio/dio.dart';
import '../models/shipping_model.dart';
import '../../../../core/network/api_response.dart';

class ShippingApiService {
  final Dio _dio;
  static const String _basePath = '/shipping-method';

  ShippingApiService(this._dio);

  /// Get shipping methods by seller
  /// [sellerId] - Seller ID
  /// [sellerIs] - 'admin' for in-house, 'seller' for vendor
  Future<ApiResponse<List<ShippingMethod>>> getShippingMethods({
    required int sellerId,
    required String sellerIs,
  }) async {
    try {
      final response = await _dio.get(
        '$_basePath/by-seller/$sellerId/$sellerIs',
      );
      final data = response.data;

      if (data is List) {
        final methods = data
            .map((e) => ShippingMethod.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiResponse<List<ShippingMethod>>(success: true, data: methods);
      }

      if (data['data'] is List) {
        final methods = (data['data'] as List)
            .map((e) => ShippingMethod.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiResponse<List<ShippingMethod>>(success: true, data: methods);
      }

      return ApiResponse<List<ShippingMethod>>(success: true, data: []);
    } on DioException catch (e) {
      return ApiResponse<List<ShippingMethod>>(
        success: false,
        message:
            e.response?.data?['message'] as String? ??
            e.message ??
            'Gagal memuat metode pengiriman',
      );
    }
  }

  /// Choose shipping method for order
  Future<ApiResponse<void>> chooseShippingMethod({
    required String cartGroupId,
    required int shippingMethodId,
  }) async {
    try {
      await _dio.post(
        '$_basePath/choose-for-order',
        data: {'cart_group_id': cartGroupId, 'id': shippingMethodId},
      );
      return ApiResponse<void>(success: true);
    } on DioException catch (e) {
      return ApiResponse<void>(
        success: false,
        message:
            e.response?.data?['message'] as String? ??
            e.message ??
            'Gagal memilih metode pengiriman',
      );
    }
  }

  /// Get chosen shipping methods
  Future<ApiResponse<List<ChosenShipping>>> getChosenShippingMethods() async {
    try {
      final response = await _dio.get('$_basePath/chosen');
      final data = response.data;

      if (data is List) {
        final chosen = data
            .map((e) => ChosenShipping.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiResponse<List<ChosenShipping>>(success: true, data: chosen);
      }

      return ApiResponse<List<ChosenShipping>>(success: true, data: []);
    } on DioException catch (e) {
      return ApiResponse<List<ChosenShipping>>(
        success: false,
        message:
            e.response?.data?['message'] as String? ??
            e.message ??
            'Gagal memuat metode pengiriman terpilih',
      );
    }
  }

  /// Get shipping type info
  Future<ApiResponse<ShippingTypeInfo>> getShippingType() async {
    try {
      final response = await _dio.get('$_basePath/check-shipping-type');
      final data = response.data;

      return ApiResponse<ShippingTypeInfo>(
        success: true,
        data: ShippingTypeInfo.fromJson(data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse<ShippingTypeInfo>(
        success: false,
        message:
            e.response?.data?['message'] as String? ??
            e.message ??
            'Gagal memuat info pengiriman',
      );
    }
  }
}
