import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../products/data/models/product_detail_model.dart';
import '../../../home/data/models/product_model.dart';
import '../../providers/shop_provider.dart';
import '../../../../app/routes.dart';

/// Shop Detail Screen
/// Shows shop information and products
class ShopScreen extends ConsumerWidget {
  final int shopId;
  final Shop? initialShop;

  const ShopScreen({super.key, required this.shopId, this.initialShop});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch shop products
    final productsAsync = ref.watch(shopProductsProvider(shopId));

    // Watch shop details if initialShop is null, otherwise just use initialShop (but we might want to refresh it)
    // Actually, let's watch the details provider anyway to get mostly fresh data or if we navigated via ID only
    final shopAsync = ref.watch(shopDetailsProvider(shopId));

    return Scaffold(
      body: shopAsync.when(
        data: (shop) => _ShopContent(
          shop: shop,
          productsAsync: productsAsync,
          shopId: shopId,
        ),
        loading: () => initialShop != null
            ? _ShopContent(
                shop: initialShop!,
                productsAsync: productsAsync,
                shopId: shopId,
              )
            : const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error loading shop: $error')),
      ),
    );
  }
}

class _ShopContent extends ConsumerWidget {
  final Shop shop;
  final AsyncValue<List<Product>> productsAsync;
  final int shopId;

  const _ShopContent({
    required this.shop,
    required this.productsAsync,
    required this.shopId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomScrollView(
      slivers: [
        // Shop Header
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: _ShopHeader(shop: shop, shopId: shopId),
          ),
          title: Text(shop.name),
          actions: [
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: () {},
              tooltip: 'Bagikan',
            ),
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () => context.push(AppRoutes.productSearch),
              tooltip: 'Cari',
            ),
          ],
        ),

        // Shop Stats
        SliverToBoxAdapter(child: _ShopStats(shop: shop)),

        // Shop Actions
        SliverToBoxAdapter(child: _ShopActions(shopId: shopId)),

        // Products Section Header
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Produk Toko',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        // Products Grid
        productsAsync.when(
          data: (products) => products.isEmpty
              ? const SliverFillRemaining(
                  child: Center(child: Text('Belum ada produk')),
                )
              : SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) =>
                          _ProductCard(product: products[index]),
                      childCount: products.length,
                    ),
                  ),
                ),
          loading: () => const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 16),
                  Text('Error: $error'),
                  TextButton(
                    onPressed: () =>
                        ref.invalidate(shopProductsProvider(shopId)),
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Shop Header with logo and background
class _ShopHeader extends StatelessWidget {
  final Shop? shop;
  final int shopId;

  const _ShopHeader({this.shop, required this.shopId});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // Shop Logo
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: shop?.logo != null
                  ? ClipOval(
                      child: Image.network(
                        shop!.logo!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            _buildPlaceholder(shop?.name ?? 'T'),
                      ),
                    )
                  : _buildPlaceholder(shop?.name ?? 'T'),
            ),
            const SizedBox(height: 12),
            // Shop Name
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  shop?.name ?? 'Toko #$shopId',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (shop?.isVerified == true) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.verified, color: Colors.white, size: 20),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(String name) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : 'T',
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}

/// Shop Statistics Row
class _ShopStats extends StatelessWidget {
  final Shop? shop;

  const _ShopStats({this.shop});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _StatItem(
            icon: Icons.star,
            value: shop?.rating.toStringAsFixed(1) ?? '-',
            label: 'Rating',
            iconColor: Colors.amber,
          ),
          _StatItem(
            icon: Icons.inventory_2_outlined,
            value: _formatNumber(shop?.productCount ?? 0),
            label: 'Produk',
          ),
          _StatItem(
            icon: Icons.people_outline,
            value: _formatNumber(shop?.followerCount ?? 0),
            label: 'Pengikut',
          ),
          _StatItem(
            icon: Icons.rate_review_outlined,
            value: _formatNumber(shop?.reviewCount ?? 0),
            label: 'Ulasan',
          ),
        ],
      ),
    );
  }

  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}jt';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}rb';
    }
    return number.toString();
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? iconColor;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor ?? Colors.grey[600], size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }
}

/// Shop Action Buttons
class _ShopActions extends StatelessWidget {
  final int shopId;

  const _ShopActions({required this.shopId});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                // Note: Follow functionality - future implementation
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mengikuti toko...')),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Ikuti'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Go to Chat Room directly
                // We need to generate a roomId based on shopId.
                // For now, let's just use shopId as part of a dummy roomId or logic.
                // Ideally we should create a room first via API then navigate.
                // For mock, we'll navigate to /chat/shop-{shopId}
                context.push(AppRoutes.chatRoomPath('shop-$shopId'));
              },
              icon: const Icon(Icons.chat_bubble_outline),
              label: const Text('Chat'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Product Card for Grid
class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final slug = product.slug;
        if (slug != null) {
          context.push(AppRoutes.productDetailPath(slug));
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                color: Colors.grey[100],
                child: product.thumbnail != null
                    ? Image.network(
                        product.thumbnail!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const Center(
                          child: Icon(
                            Icons.image,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(Icons.image, size: 48, color: Colors.grey),
                      ),
              ),
            ),
            // Product Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'Rp ${_formatPrice(product.price)}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    if (product.rating > 0)
                      Row(
                        children: [
                          const Icon(Icons.star, size: 12, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            product.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (product.soldCount > 0) ...[
                            Text(
                              ' | ${product.soldCount} terjual',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+$)'), (m) => '${m[1]}.');
  }
}
