/// Cart Summary Widget
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CartSummary extends StatelessWidget {
  final double subtotal;
  final double tax;
  final double shipping;
  final double discount;
  final String? couponCode;
  final VoidCallback? onRemoveCoupon;
  final bool showShipping;

  const CartSummary({
    super.key,
    required this.subtotal,
    this.tax = 0,
    this.shipping = 0,
    this.discount = 0,
    this.couponCode,
    this.onRemoveCoupon,
    this.showShipping = true,
  });

  double get grandTotal => subtotal + tax + shipping - discount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Ringkasan Belanja',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 16),

            // Subtotal
            _SummaryRow(
              label: 'Subtotal',
              value: currencyFormat.format(subtotal),
            ),

            // Tax
            if (tax > 0)
              _SummaryRow(label: 'Pajak', value: currencyFormat.format(tax)),

            // Shipping
            if (showShipping)
              _SummaryRow(
                label: 'Ongkir',
                value: shipping > 0
                    ? currencyFormat.format(shipping)
                    : 'Gratis',
                valueColor: shipping == 0 ? Colors.green : null,
              ),

            // Discount
            if (discount > 0) ...[
              _SummaryRow(
                label: couponCode != null ? 'Diskon ($couponCode)' : 'Diskon',
                value: '-${currencyFormat.format(discount)}',
                valueColor: Colors.green,
                trailing: onRemoveCoupon != null
                    ? GestureDetector(
                        onTap: onRemoveCoupon,
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Colors.grey,
                        ),
                      )
                    : null,
              ),
            ],

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 12),

            // Grand Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
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
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  final Widget? trailing;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: valueColor,
                ),
              ),
              if (trailing != null) ...[const SizedBox(width: 4), trailing!],
            ],
          ),
        ],
      ),
    );
  }
}
