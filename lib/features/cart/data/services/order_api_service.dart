/// Order API Service
library;

import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../../core/network/api_response.dart';
import '../../../orders/data/models/order_model.dart';

class OrderApiService {
  final Dio _dio;
  static const String _basePath = '/customer/order';

  OrderApiService(this._dio);

  /// Place order with COD payment
  Future<ApiResponse<PlaceOrderResult>> placeOrder({
    required int addressId,
    int? billingAddressId,
    String? orderNote,
  }) async {
    try {
      // Encrypt order data as required by API
      final orderData = {
        'address_id': addressId,
        if (billingAddressId != null) 'billing_address_id': billingAddressId,
        if (orderNote != null && orderNote.isNotEmpty) 'order_note': orderNote,
      };

      final encryptedData = base64Encode(utf8.encode(json.encode(orderData)));

      final response = await _dio.get(
        '$_basePath/place',
        queryParameters: {'encrypted_data': encryptedData},
      );
      final data = response.data;

      if (data['status'] == 'success') {
        return ApiResponse<PlaceOrderResult>(
          success: true,
          data: PlaceOrderResult(
            success: true,
            message: data['message'] as String? ?? 'Pesanan berhasil dibuat',
            orderId: data['order_id']?.toString(),
            orderGroupId: data['order_group_id']?.toString(),
          ),
        );
      }

      return ApiResponse<PlaceOrderResult>(
        success: false,
        message: data['message'] as String? ?? 'Gagal membuat pesanan',
        data: PlaceOrderResult(
          success: false,
          message: data['message'] as String? ?? 'Gagal membuat pesanan',
        ),
      );
    } on DioException catch (e) {
      final message =
          e.response?.data?['message'] as String? ??
          e.message ??
          'Gagal membuat pesanan';
      return ApiResponse<PlaceOrderResult>(
        success: false,
        message: message,
        data: PlaceOrderResult(success: false, message: message),
      );
    }
  }

  /// Get order list
  Future<PaginatedResponse<Order>> getOrders({
    int page = 1,
    int perPage = 10,
    String? status,
  }) async {
    try {
      final response = await _dio.get(
        '/customer/order/list',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (status != null) 'status': status,
        },
      );
      final data = response.data;

      List<Order> orders = [];
      if (data is List) {
        orders = data
            .map((e) => Order.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (data['data'] is List) {
        orders = (data['data'] as List)
            .map((e) => Order.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      final meta = data['meta'] ?? data;
      final currentPage = meta['current_page'] as int? ?? page;
      final lastPage = meta['last_page'] as int? ?? 1;
      final total = meta['total'] as int? ?? orders.length;

      return PaginatedResponse<Order>(
        success: true,
        data: orders,
        currentPage: currentPage,
        totalCount: total,
        perPage: perPage,
        hasMorePages: currentPage < lastPage,
      );
    } on DioException catch (e) {
      return PaginatedResponse<Order>(
        success: false,
        message:
            e.response?.data?['message'] as String? ??
            e.message ??
            'Gagal memuat pesanan',
        data: [],
        currentPage: page,
        totalCount: 0,
        perPage: perPage,
        hasMorePages: false,
      );
    }
  }

  /// Get order by ID
  Future<ApiResponse<Order>> getOrderById(int orderId) async {
    try {
      final response = await _dio.get(
        '/customer/order/get-order-by-id',
        queryParameters: {'order_id': orderId},
      );
      final data = response.data;

      if (data is Map<String, dynamic>) {
        return ApiResponse<Order>(success: true, data: Order.fromJson(data));
      }

      return ApiResponse<Order>(
        success: false,
        message: 'Pesanan tidak ditemukan',
      );
    } on DioException catch (e) {
      return ApiResponse<Order>(
        success: false,
        message:
            e.response?.data?['message'] as String? ??
            e.message ??
            'Gagal memuat pesanan',
      );
    }
  }

  /// Track order
  Future<ApiResponse<OrderTracking>> trackOrder(String orderId) async {
    try {
      final response = await _dio.get(
        '/order/track',
        queryParameters: {'order_id': orderId},
      );
      final data = response.data;

      return ApiResponse<OrderTracking>(
        success: true,
        data: OrderTracking.fromJson(data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse<OrderTracking>(
        success: false,
        message:
            e.response?.data?['message'] as String? ??
            e.message ??
            'Gagal melacak pesanan',
      );
    }
  }

  /// Cancel order
  Future<ApiResponse<void>> cancelOrder(int orderId) async {
    try {
      final response = await _dio.get(
        '/order/cancel-order',
        queryParameters: {'order_id': orderId},
      );
      final data = response.data;

      if (response.statusCode == 200) {
        return ApiResponse<void>(
          success: true,
          message: data is String ? data : 'Pesanan berhasil dibatalkan',
        );
      }

      return ApiResponse<void>(
        success: false,
        message: data is String ? data : 'Gagal membatalkan pesanan',
      );
    } on DioException catch (e) {
      return ApiResponse<void>(
        success: false,
        message:
            e.response?.data?['message'] as String? ??
            e.message ??
            'Gagal membatalkan pesanan',
      );
    }
  }

  /// Request refund
  Future<ApiResponse<void>> requestRefund({
    required int orderId,
    required String reason,
    String? note,
  }) async {
    try {
      final response = await _dio.post(
        '/customer/order/refund-store',
        data: {
          'order_id': orderId,
          'refund_reason': reason, // Example param
          'refund_note': note,
        },
      );
      final data = response.data;

      if (data['status'] == true || data['success'] == true) {
        return ApiResponse<void>(
          success: true,
          message:
              data['message'] as String? ??
              'Permintaan pengembalian dana berhasil dikirim',
        );
      }

      return ApiResponse<void>(
        success: false,
        message:
            data['message'] as String? ??
            'Gagal mengirim permintaan pengembalian dana',
      );
    } on DioException catch (e) {
      return ApiResponse<void>(
        success: false,
        message:
            e.response?.data?['message'] as String? ??
            e.message ??
            'Gagal mengirim permintaan pengembalian dana',
      );
    }
  }
}
