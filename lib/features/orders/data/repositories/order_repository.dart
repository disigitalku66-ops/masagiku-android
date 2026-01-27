/// Order Repository
library;

import '../../../../core/network/api_response.dart';
import '../../../cart/data/services/order_api_service.dart';
import '../models/order_model.dart';

class OrderRepository {
  final OrderApiService _apiService;

  OrderRepository(this._apiService);

  /// Get order list
  Future<PaginatedResponse<Order>> getOrders({
    int page = 1,
    int perPage = 10,
    String? status,
  }) {
    return _apiService.getOrders(page: page, perPage: perPage, status: status);
  }

  /// Get order by ID
  Future<ApiResponse<Order>> getOrderById(int orderId) {
    return _apiService.getOrderById(orderId);
  }

  /// Track order
  Future<ApiResponse<OrderTracking>> trackOrder(String orderId) {
    return _apiService.trackOrder(orderId);
  }

  /// Cancel order
  Future<ApiResponse<void>> cancelOrder(int orderId) {
    return _apiService.cancelOrder(orderId);
  }

  /// Request refund
  Future<ApiResponse<void>> requestRefund({
    required int orderId,
    required String reason,
    String? note,
  }) {
    return _apiService.requestRefund(
      orderId: orderId,
      reason: reason,
      note: note,
    );
  }
}
