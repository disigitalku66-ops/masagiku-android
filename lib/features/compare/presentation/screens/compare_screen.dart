import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../app/routes.dart';
import '../../../products/data/models/product_detail_model.dart';
import '../../providers/compare_provider.dart';

class CompareScreen extends ConsumerWidget {
  const CompareScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compareList = ref.watch(compareProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bandingkan Produk'),
        actions: [
          if (compareList.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () =>
                  ref.read(compareProvider.notifier).clearCompare(),
              tooltip: 'Hapus Semua',
            ),
        ],
      ),
      body: compareList.isEmpty
          ? _buildEmptyState(context)
          : _buildComparisonTable(context, ref, compareList),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.compare_arrows, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Produk',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan produk dari halaman detail untuk membandingkan',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go(AppRoutes.home),
              icon: const Icon(Icons.search),
              label: const Text('Cari Produk'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonTable(
    BuildContext context,
    WidgetRef ref,
    List<ProductDetail> products,
  ) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return SingleChildScrollView(
      child: Column(
        children: [
          // Product Headers
          _buildProductHeaders(context, ref, products),
          const Divider(),

          // Comparison Rows
          _buildComparisonRow(
            context,
            'Harga',
            products
                .map((p) => currencyFormat.format(p.product.price))
                .toList(),
            isHighlighted: true,
          ),
          _buildComparisonRow(
            context,
            'Rating',
            products
                .map((p) => '${p.product.rating.toStringAsFixed(1)} ⭐')
                .toList(),
          ),
          _buildComparisonRow(
            context,
            'Terjual',
            products.map((p) => '${p.product.soldCount}').toList(),
          ),
          _buildComparisonRow(
            context,
            'Stok',
            products.map((p) => '${p.product.stock}').toList(),
          ),
          if (products.any((p) => p.product.brandName != null))
            _buildComparisonRow(
              context,
              'Brand',
              products.map((p) => p.product.brandName ?? '-').toList(),
            ),
          if (products.any((p) => p.product.categoryName != null))
            _buildComparisonRow(
              context,
              'Kategori',
              products.map((p) => p.product.categoryName ?? '-').toList(),
            ),
          const Divider(),
          _buildDescriptionRow(context, products),
        ],
      ),
    );
  }

  Widget _buildProductHeaders(
    BuildContext context,
    WidgetRef ref,
    List<ProductDetail> products,
  ) {
    return SizedBox(
      height: 200,
      child: Row(
        children: products.map((product) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.product.thumbnail ?? '',
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.image_not_supported, size: 60),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Product Name
                  Text(
                    product.product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  // Remove Button
                  TextButton(
                    onPressed: () => ref
                        .read(compareProvider.notifier)
                        .removeFromCompare(product.product.id),
                    child: const Text('Hapus', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildComparisonRow(
    BuildContext context,
    String label,
    List<String> values, {
    bool isHighlighted = false,
  }) {
    return Container(
      color: isHighlighted
          ? Theme.of(context).primaryColor.withValues(alpha: 0.05)
          : null,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          ...values.map((value) {
            return Expanded(
              child: Text(
                value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: isHighlighted
                      ? FontWeight.bold
                      : FontWeight.normal,
                  color: isHighlighted
                      ? Theme.of(context).primaryColor
                      : Colors.black87,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDescriptionRow(
    BuildContext context,
    List<ProductDetail> products,
  ) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Deskripsi',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: products.map((product) {
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    product.product.description ?? '-',
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
