/// Order Providers
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../cart/providers/cart_providers.dart'; // import orderApiServiceProvider
import '../data/repositories/order_repository.dart';
import '../data/models/order_model.dart';

/// Order Repository Provider
final orderRepositoryProvider = Provider<OrderRepository>((ref) {
  final apiService = ref.watch(orderApiServiceProvider);
  return OrderRepository(apiService);
});

/// Order List State
class OrderListState {
  final bool isLoading;
  final bool isLoadingMore;
  final List<Order> orders;
  final String? errorMessage;
  final int currentPage;
  final bool hasMore;
  final String
  statusFilter; // 'all', 'pending', 'shipping', 'completed', 'canceled'

  const OrderListState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.orders = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.hasMore = true,
    this.statusFilter = 'all',
  });

  OrderListState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<Order>? orders,
    String? errorMessage,
    int? currentPage,
    bool? hasMore,
    String? statusFilter,
  }) {
    return OrderListState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      orders: orders ?? this.orders,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      statusFilter: statusFilter ?? this.statusFilter,
    );
  }
}

/// Order List Notifier
class OrderListNotifier extends StateNotifier<OrderListState> {
  final OrderRepository _repository;

  OrderListNotifier(this._repository) : super(const OrderListState());

  /// Load orders
  Future<void> loadOrders({bool refresh = false, String? status}) async {
    if (refresh) {
      state = state.copyWith(
        isLoading: true,
        currentPage: 1,
        orders: [],
        hasMore: true,
        errorMessage: null,
        statusFilter: status ?? state.statusFilter,
      );
    } else {
      if (!state.hasMore || state.isLoadingMore) return;
      state = state.copyWith(isLoadingMore: true);
    }

    final filterStatus = (status ?? state.statusFilter) == 'all'
        ? null
        : (status ?? state.statusFilter);
    final page = refresh ? 1 : state.currentPage + 1;

    final response = await _repository.getOrders(
      page: page,
      status: filterStatus,
    );

    if (response.success) {
      final newOrders = response.data ?? [];
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        orders: refresh ? newOrders : [...state.orders, ...newOrders],
        currentPage: response.currentPage,
        hasMore: response.hasMorePages,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        errorMessage: response.message,
      );
    }
  }

  /// Change filter
  void setFilter(String status) {
    if (state.statusFilter != status) {
      loadOrders(refresh: true, status: status);
    }
  }
}

/// Order List Provider
final orderListProvider =
    StateNotifierProvider<OrderListNotifier, OrderListState>((ref) {
      final repository = ref.watch(orderRepositoryProvider);
      return OrderListNotifier(repository);
    });

/// Order Detail State
class OrderDetailState {
  final bool isLoading;
  final Order? order;
  final OrderTracking? tracking;
  final String? errorMessage;

  const OrderDetailState({
    this.isLoading = false,
    this.order,
    this.tracking,
    this.errorMessage,
  });

  OrderDetailState copyWith({
    bool? isLoading,
    Order? order,
    OrderTracking? tracking,
    String? errorMessage,
  }) {
    return OrderDetailState(
      isLoading: isLoading ?? this.isLoading,
      order: order ?? this.order,
      tracking: tracking ?? this.tracking,
      errorMessage: errorMessage,
    );
  }
}

/// Order Detail Notifier
class OrderDetailNotifier extends StateNotifier<OrderDetailState> {
  final OrderRepository _repository;

  OrderDetailNotifier(this._repository) : super(const OrderDetailState());

  Future<void> loadOrder(int orderId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final response = await _repository.getOrderById(orderId);

    if (response.success && response.data != null) {
      state = state.copyWith(isLoading: false, order: response.data);

      // Load tracking if order is shipped
      // if (['shipped', 'out_for_delivery', 'delivered'].contains(response.data!.orderStatus)) {
      //   loadTracking(response.data!.orderGroupId ?? '');
      // }
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message ?? 'Gagal memuat pesanan',
      );
    }
  }

  Future<void> loadTracking(String orderId) async {
    final response = await _repository.trackOrder(orderId);
    if (response.success) {
      state = state.copyWith(tracking: response.data);
    }
  }

  Future<bool> cancelOrder(int orderId) async {
    final response = await _repository.cancelOrder(orderId);
    if (response.success) {
      await loadOrder(orderId); // Refresh order
      return true;
    }
    return false;
  }

  Future<bool> requestRefund(int orderId, String reason, String? note) async {
    final response = await _repository.requestRefund(
      orderId: orderId,
      reason: reason,
      note: note,
    );
    if (response.success) {
      await loadOrder(orderId);
      return true;
    } else {
      state = state.copyWith(errorMessage: response.message);
    }
    return false;
  }
}

/// Order Detail Provider (Family)
final orderDetailProvider =
    StateNotifierProvider.family<OrderDetailNotifier, OrderDetailState, int>((
      ref,
      orderId,
    ) {
      final repository = ref.watch(orderRepositoryProvider);
      final notifier = OrderDetailNotifier(repository);
      notifier.loadOrder(orderId);
      return notifier;
    });
