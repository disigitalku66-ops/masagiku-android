/// Add to Cart Bottom Bar Widget
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddToCartBottomBar extends StatelessWidget {
  final double price;
  final double? originalPrice;
  final int quantity;
  final bool isInStock;
  final bool isLoading;
  final bool canAddToCart;
  final VoidCallback? onAddToCart;
  final VoidCallback? onBuyNow;
  final VoidCallback? onChat;

  const AddToCartBottomBar({
    super.key,
    required this.price,
    this.originalPrice,
    this.quantity = 1,
    this.isInStock = true,
    this.isLoading = false,
    this.canAddToCart = true,
    this.onAddToCart,
    this.onBuyNow,
    this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Chat button
          if (onChat != null)
            Container(
              margin: const EdgeInsets.only(right: 12),
              child: IconButton(
                onPressed: onChat,
                style: IconButton.styleFrom(
                  side: BorderSide(color: Colors.grey[300]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: Icon(
                  Icons.chat_bubble_outline,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
          // Price section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (originalPrice != null && originalPrice! > price)
                  Text(
                    currencyFormat.format(originalPrice! * quantity),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                Text(
                  currencyFormat.format(price * quantity),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (quantity > 1)
                  Text(
                    '${currencyFormat.format(price)} × $quantity',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          // Action buttons
          Row(
            children: [
              // Add to cart button
              _ActionButton(
                label: 'Keranjang',
                icon: Icons.shopping_cart_outlined,
                isOutlined: true,
                isLoading: isLoading,
                isEnabled: isInStock && canAddToCart,
                onPressed: onAddToCart,
              ),
              const SizedBox(width: 8),
              // Buy now button
              _ActionButton(
                label: 'Beli',
                icon: Icons.flash_on,
                isOutlined: false,
                isLoading: isLoading,
                isEnabled: isInStock && canAddToCart,
                onPressed: onBuyNow,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isOutlined;
  final bool isLoading;
  final bool isEnabled;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.isOutlined,
    this.isLoading = false,
    this.isEnabled = true,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: isEnabled && !isLoading ? onPressed : null,
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: isEnabled ? primaryColor : Colors.grey[300]!),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: isLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: primaryColor,
                ),
              )
            : Icon(icon, size: 18),
        label: Text(label),
      );
    }

    return ElevatedButton.icon(
      onPressed: isEnabled && !isLoading ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey[300],
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
      icon: isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : Icon(icon, size: 18),
      label: Text(label),
    );
  }
}

/// Out of Stock Banner
class OutOfStockBanner extends StatelessWidget {
  final VoidCallback? onNotifyMe;

  const OutOfStockBanner({super.key, this.onNotifyMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Stok Habis',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Produk ini sedang tidak tersedia',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (onNotifyMe != null)
            ElevatedButton.icon(
              onPressed: onNotifyMe,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.notifications_outlined, size: 18),
              label: const Text('Beritahu Saya'),
            ),
        ],
      ),
    );
  }
}
