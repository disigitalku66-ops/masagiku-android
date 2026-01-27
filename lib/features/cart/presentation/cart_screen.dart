/// Cart Screen
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/cart_providers.dart';
import '../data/models/cart_model.dart';
import 'widgets/cart_item_card.dart';
import 'widgets/cart_summary.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  @override
  void initState() {
    super.initState();
    // Load cart data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cartProvider.notifier).loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartState = ref.watch(cartProvider);
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang'),
        actions: [
          if (cartState.items.isNotEmpty)
            IconButton(
              onPressed: _showClearCartDialog,
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Kosongkan Keranjang',
            ),
        ],
      ),
      body: cartState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartState.items.isEmpty
          ? _buildEmptyState(theme)
          : _buildCartContent(cartState, theme),
      bottomNavigationBar: cartState.items.isEmpty || cartState.isLoading
          ? null
          : _buildBottomBar(cartState, theme, currencyFormat),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 100,
              color: theme.hintColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'Keranjang Kosong',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada produk di keranjang.\nYuk mulai belanja!',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.shopping_bag_outlined),
              label: const Text('Mulai Belanja'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFf49d2a),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartContent(CartState cartState, ThemeData theme) {
    final groupedItems = cartState.groupedItems;

    return RefreshIndicator(
      onRefresh: () => ref.read(cartProvider.notifier).loadCart(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: groupedItems.length + 1, // +1 for summary
        itemBuilder: (context, index) {
          if (index < groupedItems.length) {
            return _buildSellerGroup(groupedItems[index], theme);
          }
          // Summary card at the end
          return Padding(
            padding: const EdgeInsets.only(top: 16),
            child: CartSummary(
              subtotal: cartState.subtotal,
              tax: cartState.totalTax,
              discount: cartState.couponDiscount,
              couponCode: cartState.appliedCoupon?.coupon?.code,
              onRemoveCoupon: cartState.appliedCoupon != null
                  ? () => ref.read(cartProvider.notifier).removeCoupon()
                  : null,
              showShipping: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildSellerGroup(CartGroup group, ThemeData theme) {
    final sellerName =
        group.seller?.shop?.name ?? group.seller?.name ?? 'Masagiku Official';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Seller Header
          Row(
            children: [
              Icon(Icons.store_outlined, size: 18, color: theme.hintColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  sellerName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (!group.isMinimumOrderMet &&
                  group.minimumOrderAmountInfo != null)
                _buildMinimumOrderWarning(group.minimumOrderAmountInfo!, theme),
            ],
          ),
          const SizedBox(height: 12),

          // Cart Items
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: group.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = group.items[index];
              return CartItemCard(
                item: item,
                onIncrement: () =>
                    ref.read(cartProvider.notifier).incrementQuantity(item.id),
                onDecrement: () =>
                    ref.read(cartProvider.notifier).decrementQuantity(item.id),
                onRemove: () => _showRemoveItemDialog(item),
                onTap: () {
                  if (item.product?.slug != null) {
                    context.push('/product/${item.product!.slug}');
                  }
                },
              );
            },
          ),

          // Free Delivery Progress
          if (group.freeDeliveryInfo != null &&
              !group.freeDeliveryInfo!.isApplicable)
            _buildFreeDeliveryProgress(group.freeDeliveryInfo!, theme),
        ],
      ),
    );
  }

  Widget _buildMinimumOrderWarning(
    MinimumOrderAmountInfo info,
    ThemeData theme,
  ) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        'Min. ${currencyFormat.format(info.amount)}',
        style: theme.textTheme.labelSmall?.copyWith(
          color: Colors.orange.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildFreeDeliveryProgress(FreeDeliveryInfo info, ThemeData theme) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_shipping_outlined,
                  size: 16,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tambah ${currencyFormat.format(info.amount - (info.amount * info.percentage / 100))} lagi untuk GRATIS ONGKIR',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: info.percentage / 100,
                backgroundColor: Colors.blue.withValues(alpha: 0.1),
                valueColor: AlwaysStoppedAnimation(Colors.blue.shade400),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar(
    CartState cartState,
    ThemeData theme,
    NumberFormat currencyFormat,
  ) {
    final hasOutOfStock = cartState.hasOutOfStockItems;

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
                    'Total',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                  Text(
                    currencyFormat.format(cartState.subtotal),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFFf49d2a),
                    ),
                  ),
                ],
              ),
            ),

            // Checkout Button
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: hasOutOfStock ? null : _goToCheckout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFf49d2a),
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (hasOutOfStock) ...[
                      const Icon(Icons.warning_outlined, size: 18),
                      const SizedBox(width: 8),
                      const Text('Cek Stok'),
                    ] else ...[
                      const Text('Checkout'),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${cartState.totalItems}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToCheckout() {
    context.push('/checkout');
  }

  void _showRemoveItemDialog(CartItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Item?'),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${item.product?.name ?? 'item ini'}" dari keranjang?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(cartProvider.notifier).removeItem(item.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kosongkan Keranjang?'),
        content: const Text(
          'Semua item di keranjang akan dihapus. Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(cartProvider.notifier).clearCart();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Kosongkan'),
          ),
        ],
      ),
    );
  }
}
