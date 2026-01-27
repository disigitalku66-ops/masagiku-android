/// Checkout Screen
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/cart_providers.dart';
import '../providers/checkout_providers.dart';
import '../data/models/cart_model.dart';
import 'widgets/address_card.dart';
import 'widgets/shipping_option_card.dart';
import 'widgets/coupon_input.dart';
import 'widgets/cart_summary.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _orderNoteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });
  }

  @override
  void dispose() {
    _orderNoteController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    // Load addresses
    await ref.read(addressProvider.notifier).loadAddresses();

    // Load shipping methods for each cart group
    final cartState = ref.read(cartProvider);
    for (final group in cartState.groupedItems) {
      final sellerId = group.seller?.id ?? 1;
      final sellerIs = group.seller?.id != null ? 'seller' : 'admin';
      await ref
          .read(shippingProvider.notifier)
          .loadShippingMethods(
            cartGroupId: group.cartGroupId,
            sellerId: sellerId,
            sellerIs: sellerIs,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final addressState = ref.watch(addressProvider);
    final shippingState = ref.watch(shippingProvider);
    final checkoutState = ref.watch(checkoutProvider);
    final canCheckout = ref.watch(canCheckoutProvider);
    final grandTotal = ref.watch(checkoutGrandTotalProvider);

    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: addressState.isLoading || shippingState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shipping Address Section
                  _buildSectionHeader('Alamat Pengiriman', theme),
                  const SizedBox(height: 12),
                  AddressCardCompact(
                    address: addressState.selectedAddress,
                    onTap: () => _goToAddressSelection(),
                    onChange: () => _goToAddressSelection(),
                  ),

                  const SizedBox(height: 24),

                  // Order Items Section
                  _buildSectionHeader(
                    'Pesanan (${cartState.totalItems} item)',
                    theme,
                  ),
                  const SizedBox(height: 12),
                  _buildOrderItems(cartState, theme),

                  const SizedBox(height: 24),

                  // Shipping Method Section
                  _buildSectionHeader('Metode Pengiriman', theme),
                  const SizedBox(height: 12),
                  _buildShippingMethods(cartState, shippingState, theme),

                  const SizedBox(height: 24),

                  // Coupon Section
                  _buildSectionHeader('Kupon', theme),
                  const SizedBox(height: 12),
                  CouponInput(
                    onApply: (code) =>
                        ref.read(cartProvider.notifier).applyCoupon(code),
                    onRemove: cartState.appliedCoupon != null
                        ? () => ref.read(cartProvider.notifier).removeCoupon()
                        : null,
                    appliedCoupon: cartState.appliedCoupon?.coupon?.code,
                    discountAmount: cartState.couponDiscount,
                  ),

                  const SizedBox(height: 24),

                  // Order Note
                  _buildSectionHeader('Catatan Pesanan (opsional)', theme),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _orderNoteController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Tambahkan catatan untuk pesanan...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.dividerColor),
                      ),
                    ),
                    onChanged: (value) {
                      ref.read(checkoutProvider.notifier).setOrderNote(value);
                    },
                  ),

                  const SizedBox(height: 24),

                  // Payment Method (COD Only)
                  _buildSectionHeader('Metode Pembayaran', theme),
                  const SizedBox(height: 12),
                  _buildPaymentMethod(theme),

                  const SizedBox(height: 24),

                  // Order Summary
                  CartSummary(
                    subtotal: cartState.subtotal,
                    tax: cartState.totalTax,
                    shipping: shippingState.totalShippingCost,
                    discount: cartState.couponDiscount,
                    couponCode: cartState.appliedCoupon?.coupon?.code,
                    showShipping: true,
                  ),

                  const SizedBox(height: 100), // Space for bottom bar
                ],
              ),
            ),
      bottomNavigationBar: _buildBottomBar(
        checkoutState: checkoutState,
        canCheckout: canCheckout,
        grandTotal: grandTotal,
        theme: theme,
        currencyFormat: currencyFormat,
        addressId: addressState.selectedAddress?.id,
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget _buildOrderItems(CartState cartState, ThemeData theme) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            for (int i = 0; i < cartState.groupedItems.length; i++) ...[
              if (i > 0) const Divider(height: 24),
              _buildGroupItems(cartState.groupedItems[i], theme),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGroupItems(CartGroup group, ThemeData theme) {
    final sellerName =
        group.seller?.shop?.name ?? group.seller?.name ?? 'Masagiku Official';
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Seller name
        Row(
          children: [
            Icon(Icons.store_outlined, size: 16, color: theme.hintColor),
            const SizedBox(width: 6),
            Text(
              sellerName,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Items
        for (final item in group.items) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product name and variant
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product?.name ?? 'Produk',
                      style: theme.textTheme.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.variant != null && item.variant!.isNotEmpty)
                      Text(
                        item.variant!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                  ],
                ),
              ),

              // Quantity and Price
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${item.quantity}x',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                  Text(
                    currencyFormat.format(item.subtotal),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildShippingMethods(
    CartState cartState,
    ShippingState shippingState,
    ThemeData theme,
  ) {
    final groupedItems = cartState.groupedItems;

    if (groupedItems.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: [
        for (int i = 0; i < groupedItems.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          _buildSellerShipping(groupedItems[i], shippingState, theme),
        ],
      ],
    );
  }

  Widget _buildSellerShipping(
    CartGroup group,
    ShippingState shippingState,
    ThemeData theme,
  ) {
    final methods = shippingState.methodsByGroup[group.cartGroupId] ?? [];
    final selectedId = shippingState.selectedMethodByGroup[group.cartGroupId];
    final sellerName =
        group.seller?.shop?.name ?? group.seller?.name ?? 'Masagiku Official';

    if (methods.isEmpty) {
      return Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.dividerColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: theme.hintColor),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Tidak ada metode pengiriman tersedia untuk $sellerName',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SellerShippingGroup(
      sellerName: sellerName,
      methods: methods,
      selectedMethodId: selectedId ?? methods.first.id,
      onMethodSelected: (methodId) {
        ref
            .read(shippingProvider.notifier)
            .selectShippingMethod(
              cartGroupId: group.cartGroupId,
              methodId: methodId,
            );
      },
    );
  }

  Widget _buildPaymentMethod(ThemeData theme) {
    final primaryColor = const Color(0xFFf49d2a);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: primaryColor, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.radio_button_checked, color: primaryColor, size: 22),
            const SizedBox(width: 12),
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.payments_outlined, color: primaryColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bayar di Tempat (COD)',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Bayar saat pesanan tiba',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar({
    required CheckoutState checkoutState,
    required bool canCheckout,
    required double grandTotal,
    required ThemeData theme,
    required NumberFormat currencyFormat,
    required int? addressId,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Total
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Bayar',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                  Text(
                    currencyFormat.format(grandTotal),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFf49d2a),
                    ),
                  ),
                ],
              ),
            ),

            // Place Order Button
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: canCheckout && !checkoutState.isPlacingOrder
                    ? () => _placeOrder(addressId!)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFf49d2a),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: checkoutState.isPlacingOrder
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Pesan Sekarang'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToAddressSelection() {
    context.push('/pemesanan/alamat');
  }

  Future<void> _placeOrder(int addressId) async {
    final success = await ref
        .read(checkoutProvider.notifier)
        .placeOrder(addressId: addressId);

    if (!mounted) return;

    if (success) {
      final orderResult = ref.read(checkoutProvider).orderResult;
      _showSuccessDialog(orderResult?.orderId ?? '');
    } else {
      final error = ref.read(checkoutProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Gagal membuat pesanan'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessDialog(String orderId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Pesanan Berhasil!',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Pesanan Anda telah dibuat.\nSilakan siapkan pembayaran saat pesanan tiba.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).hintColor,
              ),
            ),
            if (orderId.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'ID Pesanan: $orderId',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Clear cart and navigate to home
                ref.read(cartProvider.notifier).clearCart();
                ref.read(checkoutProvider.notifier).reset();
                ref.read(shippingProvider.notifier).reset();
                context.go('/beranda');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFf49d2a),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Lanjut Belanja'),
            ),
          ),
        ],
      ),
    );
  }
}
