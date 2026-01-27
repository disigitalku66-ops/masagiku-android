/// Order Detail Screen
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../providers/order_providers.dart';
import '../widgets/order_product_item.dart';
import 'order_review_screen.dart';

class OrderDetailScreen extends ConsumerStatefulWidget {
  final int orderId;

  const OrderDetailScreen({super.key, required this.orderId});

  @override
  ConsumerState<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends ConsumerState<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(orderDetailProvider(widget.orderId).notifier)
          .loadOrder(widget.orderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(orderDetailProvider(widget.orderId));
    final order = state.order;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
          ? Center(child: Text(state.errorMessage!))
          : order == null
          ? const Center(child: Text('Pesanan tidak ditemukan'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Banner
                  _StatusBanner(status: order.orderStatus),
                  const SizedBox(height: 16),

                  // Order Info
                  _SectionCard(
                    title: 'Info Pesanan',
                    children: [
                      _InfoRow(
                        'No. Pesanan',
                        '#${order.orderGroupId ?? order.id}',
                      ),
                      _InfoRow(
                        'Tanggal',
                        DateFormat(
                          'dd MMM yyyy, HH:mm',
                        ).format(order.createdAt ?? DateTime.now()),
                      ),
                      _InfoRow(
                        'Status Pembayaran',
                        order.paymentStatus == 'paid' ? 'Lunas' : 'Belum Lunas',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Shipping Info
                  if (order.shippingAddress != null)
                    _SectionCard(
                      title: 'Alamat Pengiriman',
                      children: [
                        Text(
                          order.shippingAddress!.contactPersonName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.shippingAddress!.phone,
                          style: const TextStyle(
                            color: MasagiColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.shippingAddress!.fullAddress,
                          style: const TextStyle(
                            color: MasagiColors.textSecondary,
                          ),
                        ),
                      ],
                    )
                  else
                    const _SectionCard(
                      title: 'Alamat Pengiriman',
                      children: [
                        Text(
                          'Informasi alamat tidak tersedia',
                          style: TextStyle(
                            color: MasagiColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),

                  // Order Items
                  _SectionCard(
                    title: 'Produk',
                    children: [
                      OrderProductItem(
                        name: 'Contoh Produk (Data belum tersedia)',
                        price: order.orderAmount,
                        quantity: 1,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Payment Summary
                  _SectionCard(
                    title: 'Rincian Pembayaran',
                    children: [
                      _InfoRow(
                        'Subtotal',
                        _formatPrice(
                          order.orderAmount -
                              order.shippingCost +
                              order.discountAmount,
                        ),
                      ),
                      _InfoRow(
                        'Ongkos Kirim',
                        _formatPrice(order.shippingCost),
                      ),
                      if (order.discountAmount > 0)
                        _InfoRow(
                          'Diskon',
                          '-${_formatPrice(order.discountAmount)}',
                          color: MasagiColors.success,
                        ),
                      const Divider(),
                      _InfoRow(
                        'Total Belanja',
                        _formatPrice(order.orderAmount),
                        isBold: true,
                        color: MasagiColors.primary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Action Buttons
                  if (order.orderStatus == 'pending')
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () =>
                            _showCancelDialog(context, order.id, ref),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: MasagiColors.error,
                          side: const BorderSide(color: MasagiColors.error),
                        ),
                        child: const Text('Batalkan Pesanan'),
                      ),
                    ),

                  if (order.orderStatus == 'shipped' ||
                      order.orderStatus == 'out_for_delivery')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          context.push('/order/${order.id}/tracking');
                        },
                        child: const Text('Lacak Pesanan'),
                      ),
                    ),

                  if (order.orderStatus == 'delivered')
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () {
                            context.push('/order/${order.id}/refund');
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: MasagiColors.error,
                          ),
                          child: const Text('Ajukan Pengembalian'),
                        ),
                      ),
                    ),

                  if (order.orderStatus == 'delivered' ||
                      order.orderStatus == 'finished')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => OrderReviewScreen(
                                orderId: order.id,
                                productId: 1, // Mock
                                productName: 'Produk Pesanan #${order.id}',
                                productImage:
                                    'https://placeholder.com/150', // Mock
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MasagiColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Beri Ulasan'),
                      ),
                    ),
                ],
              ),
            ),
    );
  }

  String _formatPrice(double price) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(price);
  }

  void _showCancelDialog(BuildContext context, int orderId, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Batalkan Pesanan?'),
        content: const Text('Apakah Anda yakin ingin membatalkan pesanan ini?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Tidak'),
          ),
          TextButton(
            onPressed: () async {
              context.pop(); // Close dialog
              final success = await ref
                  .read(orderDetailProvider(orderId).notifier)
                  .cancelOrder(orderId);

              if (context.mounted) {
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Pesanan berhasil dibatalkan'),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gagal membatalkan pesanan')),
                  );
                }
              }
            },
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String status;

  const _StatusBanner({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        text = 'Menunggu Konfirmasi';
        icon = Icons.access_time;
        break;
      case 'confirmed':
        color = Colors.blue;
        text = 'Pesanan Dikonfirmasi';
        icon = Icons.check_circle_outline;
        break;
      case 'processing':
        color = Colors.blue;
        text = 'Pesanan Sedang Diproses';
        icon = Icons.inventory_2_outlined;
        break;
      case 'out_for_delivery':
        color = Colors.purple;
        text = 'Pesanan Dalam Pengiriman';
        icon = Icons.local_shipping_outlined;
        break;
      case 'delivered':
        color = Colors.green;
        text = 'Pesanan Selesai';
        icon = Icons.check_circle;
        break;
      case 'canceled':
        color = Colors.red;
        text = 'Pesanan Dibatalkan';
        icon = Icons.cancel_outlined;
        break;
      default:
        color = Colors.grey;
        text = status;
        icon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: MasagiColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? color;

  const _InfoRow(this.label, this.value, {this.isBold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: MasagiColors.textSecondary),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? MasagiColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
