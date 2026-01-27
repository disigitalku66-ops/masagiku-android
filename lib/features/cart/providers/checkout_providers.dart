/// Checkout Providers (Riverpod)
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/address_model.dart';
import '../data/models/shipping_model.dart';

import '../data/repositories/cart_repository.dart';
import '../../orders/data/models/order_model.dart';
import 'cart_providers.dart';

// ==================== ADDRESS STATE ====================

class AddressState {
  final bool isLoading;
  final List<ShippingAddress> addresses;
  final int? selectedAddressId;
  final String? errorMessage;

  const AddressState({
    this.isLoading = false,
    this.addresses = const [],
    this.selectedAddressId,
    this.errorMessage,
  });

  /// Get selected address
  ShippingAddress? get selectedAddress {
    if (selectedAddressId == null) return null;
    return addresses.cast<ShippingAddress?>().firstWhere(
      (a) => a?.id == selectedAddressId,
      orElse: () => null,
    );
  }

  /// Get default address
  ShippingAddress? get defaultAddress {
    return addresses.cast<ShippingAddress?>().firstWhere(
      (a) => a?.isDefault == true,
      orElse: () => addresses.isNotEmpty ? addresses.first : null,
    );
  }

  AddressState copyWith({
    bool? isLoading,
    List<ShippingAddress>? addresses,
    int? selectedAddressId,
    String? errorMessage,
    bool clearError = false,
    bool clearSelectedAddress = false,
  }) {
    return AddressState(
      isLoading: isLoading ?? this.isLoading,
      addresses: addresses ?? this.addresses,
      selectedAddressId: clearSelectedAddress
          ? null
          : (selectedAddressId ?? this.selectedAddressId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// ==================== ADDRESS NOTIFIER ====================

class AddressNotifier extends StateNotifier<AddressState> {
  final CartRepository _repository;

  AddressNotifier(this._repository) : super(const AddressState());

  /// Load addresses
  Future<void> loadAddresses() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final response = await _repository.getAddresses();

    if (response.success && response.data != null) {
      final addresses = response.data!;
      state = state.copyWith(
        isLoading: false,
        addresses: addresses,
        selectedAddressId:
            state.selectedAddressId ??
            addresses
                .cast<ShippingAddress?>()
                .firstWhere((a) => a?.isDefault == true, orElse: () => null)
                ?.id ??
            (addresses.isNotEmpty ? addresses.first.id : null),
      );
    } else {
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
  }

  /// Select address
  void selectAddress(int addressId) {
    state = state.copyWith(selectedAddressId: addressId);
  }

  /// Add new address
  Future<bool> addAddress(AddressRequest request) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final response = await _repository.addAddress(request);

    if (response.success) {
      await loadAddresses();
      return true;
    }

    state = state.copyWith(isLoading: false, errorMessage: response.message);
    return false;
  }

  /// Update address
  Future<bool> updateAddress(AddressRequest request) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final response = await _repository.updateAddress(request);

    if (response.success) {
      await loadAddresses();
      return true;
    }

    state = state.copyWith(isLoading: false, errorMessage: response.message);
    return false;
  }

  /// Delete address
  Future<bool> deleteAddress(int id) async {
    final response = await _repository.deleteAddress(id);

    if (response.success) {
      final updatedAddresses = state.addresses
          .where((a) => a.id != id)
          .toList();
      state = state.copyWith(
        addresses: updatedAddresses,
        selectedAddressId: state.selectedAddressId == id
            ? null
            : state.selectedAddressId,
      );
      return true;
    }

    state = state.copyWith(errorMessage: response.message);
    return false;
  }
}

// ==================== SHIPPING STATE ====================

class ShippingState {
  final bool isLoading;
  final Map<String, List<ShippingMethod>>
  methodsByGroup; // cartGroupId -> methods
  final Map<String, int> selectedMethodByGroup; // cartGroupId -> methodId
  final String? errorMessage;

  const ShippingState({
    this.isLoading = false,
    this.methodsByGroup = const {},
    this.selectedMethodByGroup = const {},
    this.errorMessage,
  });

  /// Total shipping cost
  double get totalShippingCost {
    double total = 0;
    for (final entry in selectedMethodByGroup.entries) {
      final methods = methodsByGroup[entry.key] ?? [];
      final selected = methods.cast<ShippingMethod?>().firstWhere(
        (m) => m?.id == entry.value,
        orElse: () => null,
      );
      if (selected != null) {
        total += selected.cost;
      }
    }
    return total;
  }

  /// Check if all groups have shipping selected
  bool get allGroupsHaveShipping {
    return methodsByGroup.keys.every(
      (groupId) => selectedMethodByGroup.containsKey(groupId),
    );
  }

  ShippingState copyWith({
    bool? isLoading,
    Map<String, List<ShippingMethod>>? methodsByGroup,
    Map<String, int>? selectedMethodByGroup,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ShippingState(
      isLoading: isLoading ?? this.isLoading,
      methodsByGroup: methodsByGroup ?? this.methodsByGroup,
      selectedMethodByGroup:
          selectedMethodByGroup ?? this.selectedMethodByGroup,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// ==================== SHIPPING NOTIFIER ====================

class ShippingNotifier extends StateNotifier<ShippingState> {
  final CartRepository _repository;

  ShippingNotifier(this._repository) : super(const ShippingState());

  /// Load shipping methods for a cart group
  Future<void> loadShippingMethods({
    required String cartGroupId,
    required int sellerId,
    required String sellerIs,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final response = await _repository.getShippingMethods(
      sellerId: sellerId,
      sellerIs: sellerIs,
    );

    if (response.success && response.data != null) {
      final updatedMethods = Map<String, List<ShippingMethod>>.from(
        state.methodsByGroup,
      );
      updatedMethods[cartGroupId] = response.data!;

      // Auto-select first method if none selected
      final updatedSelected = Map<String, int>.from(
        state.selectedMethodByGroup,
      );
      if (!updatedSelected.containsKey(cartGroupId) &&
          response.data!.isNotEmpty) {
        updatedSelected[cartGroupId] = response.data!.first.id;
      }

      state = state.copyWith(
        isLoading: false,
        methodsByGroup: updatedMethods,
        selectedMethodByGroup: updatedSelected,
      );
    } else {
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
  }

  /// Select shipping method for a group
  Future<void> selectShippingMethod({
    required String cartGroupId,
    required int methodId,
  }) async {
    final updatedSelected = Map<String, int>.from(state.selectedMethodByGroup);
    updatedSelected[cartGroupId] = methodId;
    state = state.copyWith(selectedMethodByGroup: updatedSelected);

    // Sync with server
    await _repository.chooseShippingMethod(
      cartGroupId: cartGroupId,
      shippingMethodId: methodId,
    );
  }

  /// Reset shipping state
  void reset() {
    state = const ShippingState();
  }
}

// ==================== CHECKOUT STATE ====================

class CheckoutState {
  final bool isPlacingOrder;
  final String? orderNote;
  final PlaceOrderResult? orderResult;
  final String? errorMessage;

  const CheckoutState({
    this.isPlacingOrder = false,
    this.orderNote,
    this.orderResult,
    this.errorMessage,
  });

  CheckoutState copyWith({
    bool? isPlacingOrder,
    String? orderNote,
    PlaceOrderResult? orderResult,
    String? errorMessage,
    bool clearError = false,
    bool clearOrderNote = false,
  }) {
    return CheckoutState(
      isPlacingOrder: isPlacingOrder ?? this.isPlacingOrder,
      orderNote: clearOrderNote ? null : (orderNote ?? this.orderNote),
      orderResult: orderResult ?? this.orderResult,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// ==================== CHECKOUT NOTIFIER ====================

class CheckoutNotifier extends StateNotifier<CheckoutState> {
  final CartRepository _repository;

  CheckoutNotifier(this._repository) : super(const CheckoutState());

  /// Set order note
  void setOrderNote(String note) {
    state = state.copyWith(orderNote: note);
  }

  /// Place order
  Future<bool> placeOrder({
    required int addressId,
    int? billingAddressId,
  }) async {
    state = state.copyWith(isPlacingOrder: true, clearError: true);

    final response = await _repository.placeOrder(
      addressId: addressId,
      billingAddressId: billingAddressId,
      orderNote: state.orderNote,
    );

    if (response.success && response.data != null && response.data!.success) {
      state = state.copyWith(isPlacingOrder: false, orderResult: response.data);
      return true;
    }

    state = state.copyWith(
      isPlacingOrder: false,
      errorMessage: response.data?.message ?? response.message,
    );
    return false;
  }

  /// Reset checkout state
  void reset() {
    state = const CheckoutState();
  }
}

// ==================== PROVIDERS ====================

final addressProvider = StateNotifierProvider<AddressNotifier, AddressState>((
  ref,
) {
  final repository = ref.watch(cartRepositoryProvider);
  return AddressNotifier(repository);
});

final shippingProvider = StateNotifierProvider<ShippingNotifier, ShippingState>(
  (ref) {
    final repository = ref.watch(cartRepositoryProvider);
    return ShippingNotifier(repository);
  },
);

final checkoutProvider = StateNotifierProvider<CheckoutNotifier, CheckoutState>(
  (ref) {
    final repository = ref.watch(cartRepositoryProvider);
    return CheckoutNotifier(repository);
  },
);

// ==================== COMPUTED PROVIDERS ====================

/// Checkout grand total
final checkoutGrandTotalProvider = Provider<double>((ref) {
  final cartState = ref.watch(cartProvider);
  final shippingState = ref.watch(shippingProvider);

  final subtotal = cartState.subtotal;
  final tax = cartState.totalTax;
  final shipping = shippingState.totalShippingCost;
  final couponDiscount = cartState.couponDiscount;

  return subtotal + tax + shipping - couponDiscount;
});

/// Can proceed to checkout
final canCheckoutProvider = Provider<bool>((ref) {
  final cartState = ref.watch(cartProvider);
  final addressState = ref.watch(addressProvider);
  final shippingState = ref.watch(shippingProvider);

  return !cartState.isEmpty &&
      !cartState.hasOutOfStockItems &&
      addressState.selectedAddress != null &&
      shippingState.allGroupsHaveShipping;
});
