/// Product Detail Screen
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../../app/routes.dart';
import '../../cart/providers/cart_providers.dart';
import '../../compare/providers/compare_provider.dart';
import '../data/models/product_detail_model.dart';
import '../providers/product_providers.dart';
import '../../../shared/widgets/product_card.dart';
import 'widgets/image_gallery.dart';
import 'widgets/variant_selector.dart';
import 'widgets/reviews_section.dart';
import 'widgets/add_to_cart_bar.dart';

class ProductDetailScreen extends ConsumerStatefulWidget {
  final String slug;

  const ProductDetailScreen({super.key, required this.slug});

  @override
  ConsumerState<ProductDetailScreen> createState() =>
      _ProductDetailScreenState();
}

class _ProductDetailScreenState extends ConsumerState<ProductDetailScreen> {
  bool _isAddingToCart = false;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productDetailProvider(widget.slug));
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    if (state.isLoading && state.productDetail == null) {
      return Scaffold(
        appBar: AppBar(leading: const BackButton()),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (state.errorMessage != null && state.productDetail == null) {
      return Scaffold(
        appBar: AppBar(
          leading: const BackButton(),
          title: const Text('Detail Produk'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                state.errorMessage!,
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  ref
                      .read(productDetailProvider(widget.slug).notifier)
                      .loadProduct(widget.slug);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    final detail = state.productDetail!;
    final product = detail.product;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            pinned: true,
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            actions: [
              // Share Button
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () => _shareProduct(product.name, product.slug),
                  icon: const Icon(Icons.share),
                ),
              ),
              // Compare Button
              Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () => _addToCompare(context),
                  icon: Icon(
                    Icons.compare_arrows,
                    color:
                        ref
                            .watch(compareProvider)
                            .any((p) => p.product.id == product.id)
                        ? Theme.of(context).primaryColor
                        : null,
                  ),
                  tooltip: 'Bandingkan',
                ),
              ),
              // Wishlist Button
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {
                    ref
                        .read(productDetailProvider(widget.slug).notifier)
                        .toggleWishlist();
                  },
                  icon: Icon(
                    state.isWishlisted ? Icons.favorite : Icons.favorite_border,
                    color: state.isWishlisted ? Colors.red : null,
                  ),
                ),
              ),
            ],
          ),
          // Image Gallery
          SliverToBoxAdapter(
            child: ImageGallery(
              images: product.images,
              thumbnail: product.thumbnail,
              height: MediaQuery.of(context).size.width,
            ),
          ),
          // Product Info
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        currencyFormat.format(product.effectivePrice),
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (product.hasDiscount) ...[
                        const SizedBox(width: 8),
                        Text(
                          currencyFormat.format(product.price),
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.grey[500],
                                decoration: TextDecoration.lineThrough,
                              ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '-${product.discountPercent}%',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Product Name
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Stats Row
                  Row(
                    children: [
                      // Rating
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber[50],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (product.reviewCount > 0) ...[
                              Text(
                                ' (${product.reviewCount})',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Sold count
                      if (product.soldCount > 0)
                        Text(
                          'Terjual ${_formatCount(product.soldCount)}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      const Spacer(),
                      // Stock info
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: product.isInStock
                              ? Colors.green[50]
                              : Colors.red[50],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.isInStock
                              ? 'Stok: ${product.stock}'
                              : 'Stok Habis',
                          style: TextStyle(
                            color: product.isInStock
                                ? Colors.green[700]
                                : Colors.red[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Divider
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          // Variants
          if (product.variants != null && product.variants!.isNotEmpty)
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pilih Varian',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    VariantSelector(
                      variants: product.variants!,
                      selectedVariants: state.selectedVariants,
                      onVariantSelected: (name, option) {
                        ref
                            .read(productDetailProvider(widget.slug).notifier)
                            .selectVariant(name, option);
                      },
                    ),
                  ],
                ),
              ),
            ),
          // Quantity
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: QuantitySelector(
                quantity: state.quantity,
                maxQuantity: product.stock,
                onChanged: (qty) {
                  ref
                      .read(productDetailProvider(widget.slug).notifier)
                      .updateQuantity(qty);
                },
              ),
            ),
          ),
          // Divider
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          // Shop Info
          if (detail.shop != null)
            SliverToBoxAdapter(child: _ShopInfoCard(shop: detail.shop!)),
          // Divider
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          // Description
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Deskripsi Produk',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ExpandableDescription(
                    description: product.description ?? 'Tidak ada deskripsi',
                  ),
                ],
              ),
            ),
          ),
          // Specifications
          if (detail.specifications.isNotEmpty) ...[
            const SliverToBoxAdapter(child: SizedBox(height: 8)),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Spesifikasi Produk',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...detail.specifications.map(
                      (spec) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 120,
                              child: Text(
                                spec.key,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                spec.value,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          // Divider
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          // Reviews Section
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: ReviewsSection(
                summary: detail.reviews.isNotEmpty
                    ? ReviewSummary(
                        averageRating: product.rating,
                        totalReviews: product.reviewCount,
                      )
                    : null,
                reviews: detail.reviews,
                maxPreviewCount: 3,
                onViewAll: () => _showAllReviews(context, product.id),
              ),
            ),
          ),
          // Divider
          const SliverToBoxAdapter(child: SizedBox(height: 8)),
          // Related Products
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Produk Terkait',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _RelatedProducts(productId: product.id),
                ],
              ),
            ),
          ),
          // Bottom padding for cart bar
          SliverToBoxAdapter(
            child: SizedBox(height: MediaQuery.of(context).padding.bottom + 80),
          ),
        ],
      ),
      bottomNavigationBar: product.isInStock
          ? AddToCartBottomBar(
              price: state.currentPrice,
              originalPrice: product.hasDiscount ? product.price : null,
              quantity: state.quantity,
              isInStock: product.isInStock,
              isLoading: _isAddingToCart,
              canAddToCart: state.allVariantsSelected,
              onAddToCart: () => _addToCart(context),
              onBuyNow: () => _buyNow(),
              onChat: () => _openChat(context, detail.shop?.id),
            )
          : OutOfStockBanner(onNotifyMe: () => _notifyWhenAvailable(context)),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}jt';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}rb';
    }
    return count.toString();
  }

  void _shareProduct(String name, String? slug) {
    final url = 'https://masagiku.com/product/${slug ?? ''}';
    Share.share('Lihat $name di Masagiku!\n$url');
  }

  Future<void> _addToCart(BuildContext context) async {
    final state = ref.read(productDetailProvider(widget.slug));
    final product = state.productDetail;

    if (product == null) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Produk tidak ditemukan')));
      }
      return;
    }

    setState(() => _isAddingToCart = true);

    try {
      final success = await ref
          .read(cartProvider.notifier)
          .addToCart(
            productId: product.product.id,
            quantity: state.quantity,
            // variant: _selectedVariants // Add variant generic support if needed
          );

      if (!context.mounted) return;

      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menambahkan ke keranjang')),
        );
        setState(() => _isAddingToCart = false);
        return;
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
      setState(() => _isAddingToCart = false);
      return;
    }

    setState(() => _isAddingToCart = false);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Produk ditambahkan ke keranjang'),
        action: SnackBarAction(
          label: 'Lihat',
          onPressed: () {
            context.go('/keranjang');
          },
        ),
      ),
    );
  }

  Future<void> _buyNow() async {
    setState(() => _isAddingToCart = true);

    try {
      // 1. Add to cart
      final success = await ref
          .read(cartProvider.notifier)
          .addToCart(
            productId: ref
                .read(productDetailProvider(widget.slug))
                .productDetail!
                .product
                .id,
            quantity: ref.read(productDetailProvider(widget.slug)).quantity,
          );

      if (!mounted) return;

      if (success) {
        // 2. Navigate to checkout
        setState(() => _isAddingToCart = false);
        context.push(AppRoutes.checkout);
      } else {
        setState(() => _isAddingToCart = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memproses pembelian langsung')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAddingToCart = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  void _addToCompare(BuildContext context) {
    final state = ref.read(productDetailProvider(widget.slug));
    final product = state.productDetail;
    if (product == null) return;

    final error = ref.read(compareProvider.notifier).addToCompare(product);

    if (error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    } else {
      final compareList = ref.read(compareProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ditambahkan ke perbandingan (${compareList.length}/3)',
          ),
          action: SnackBarAction(
            label: 'Bandingkan',
            onPressed: () => context.push(AppRoutes.compare),
          ),
        ),
      );
    }
  }

  void _openChat(BuildContext context, int? shopId) {
    if (shopId == null) return;
    // Note: Chat navigation to be implemented in Phase 8.3
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Membuka chat...')));
  }

  void _showAllReviews(BuildContext context, int productId) {
    // Note: Full reviews screen to be implemented later
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Menampilkan semua ulasan...')),
    );
  }

  void _notifyWhenAvailable(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Anda akan diberitahu saat produk tersedia'),
      ),
    );
  }
}

/// Shop Info Card
class _ShopInfoCard extends StatelessWidget {
  final Shop shop;

  const _ShopInfoCard({required this.shop});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          // Shop logo
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              image: shop.logo != null
                  ? DecorationImage(
                      image: NetworkImage(shop.logo!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: shop.logo == null
                ? const Icon(Icons.store, color: Colors.grey)
                : null,
          ),
          const SizedBox(width: 12),
          // Shop info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        shop.name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (shop.isVerified) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.verified,
                        size: 16,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 14, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '${shop.rating.toStringAsFixed(1)} • ${shop.productCount} produk',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Visit shop button
          OutlinedButton(
            onPressed: () {
              context.push(AppRoutes.shopPath(shop.id));
            },
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Theme.of(context).primaryColor),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text('Kunjungi'),
          ),
        ],
      ),
    );
  }
}

/// Expandable Description
class _ExpandableDescription extends StatefulWidget {
  final String description;
  final int maxLines = 3;

  const _ExpandableDescription({required this.description});

  @override
  State<_ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<_ExpandableDescription> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedCrossFade(
          firstChild: Text(
            widget.description,
            maxLines: widget.maxLines,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
          secondChild: Text(
            widget.description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(height: 1.6),
          ),
          crossFadeState: _isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
        if (widget.description.length > 200)
          TextButton(
            onPressed: () => setState(() => _isExpanded = !_isExpanded),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              _isExpanded ? 'Tampilkan lebih sedikit' : 'Selengkapnya',
            ),
          ),
      ],
    );
  }
}

/// Related Products Widget
class _RelatedProducts extends ConsumerWidget {
  final int productId;

  const _RelatedProducts({required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final relatedAsync = ref.watch(relatedProductsProvider(productId));

    return relatedAsync.when(
      data: (products) {
        if (products.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Tidak ada produk terkait',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          );
        }

        return SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return SizedBox(
                width: 160,
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < products.length - 1 ? 12 : 0,
                  ),
                  child: ProductCard(
                    id: product.id.toString(),
                    name: product.name,
                    imageUrl: product.thumbnail ?? '',
                    price: product.price,
                    discountPrice: product.discountPrice,
                    discountPercent: product.discountPercent,
                    rating: product.rating,
                    onTap: () {
                      context.push('/product/${product.slug ?? product.id}');
                    },
                  ),
                ),
              );
            },
          ),
        );
      },
      loading: () => const SizedBox(
        height: 220,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }
}
