/// Coupon List Screen
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/coupon_provider.dart';
import '../../providers/cart_providers.dart';
import '../../data/models/coupon_model.dart';

class CouponListScreen extends ConsumerWidget {
  const CouponListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final couponsAsync = ref.watch(availableCouponsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Pilih Kupon')),
      body: couponsAsync.when(
        data: (coupons) {
          if (coupons.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_offer_outlined,
                    size: 64,
                    color: theme.disabledColor,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Belum ada kupon tersedia',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.hintColor,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: coupons.length,
            separatorBuilder: (_, _) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final coupon = coupons[index];
              return _CouponCard(coupon: coupon);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) =>
            Center(child: Text('Gagal memuat kupon: $error')),
      ),
    );
  }
}

class _CouponCard extends ConsumerWidget {
  final Coupon coupon;

  const _CouponCard({required this.coupon});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cartState = ref.watch(cartProvider);
    final isApplied = cartState.appliedCoupon?.coupon?.code == coupon.code;

    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isApplied
            ? BorderSide(color: Colors.green.shade500, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: () => _applyCoupon(context, ref),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFf49d2a).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.local_offer,
                      color: Color(0xFFf49d2a),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          coupon.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          coupon.code,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.hintColor,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isApplied)
                    const Icon(Icons.check_circle, color: Colors.green)
                  else
                    ElevatedButton(
                      onPressed: () => _applyCoupon(context, ref),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFf49d2a),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        minimumSize: const Size(60, 36),
                      ),
                      child: const Text('Pakai'),
                    ),
                ],
              ),
              const Divider(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    coupon.discountType == 'percentage'
                        ? 'Diskon ${coupon.discount.toStringAsFixed(0)}%'
                        : 'Potongan ${currencyFormat.format(coupon.discount)}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (coupon.expireDate != null)
                    Text(
                      'Berlaku s/d ${DateFormat('dd MMM yyyy').format(coupon.expireDate!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.hintColor,
                      ),
                    ),
                ],
              ),
              if (coupon.minPurchase > 0) ...[
                const SizedBox(height: 4),
                Text(
                  'Min. Belanja ${currencyFormat.format(coupon.minPurchase)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.hintColor,
                    fontSize: 11,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _applyCoupon(BuildContext context, WidgetRef ref) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final success = await ref
        .read(cartProvider.notifier)
        .applyCoupon(coupon.code);

    // Hide loading
    if (context.mounted) {
      Navigator.pop(context); // Pop dialog

      if (success) {
        context.pop(); // Pop screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Kupon ${coupon.code} berhasil dipasang'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final error = ref.read(cartProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Gagal memasang kupon'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
