import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/colors.dart';
import '../../../../shared/widgets/product_card.dart';
import '../../providers/wishlist_providers.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistState = ref.watch(wishlistProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(wishlistProvider.notifier).loadWishlist();
            },
          ),
        ],
      ),
      body: wishlistState.when(
        data: (products) {
          if (products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.favorite_border,
                    size: 64,
                    color: MasagiColors.textTertiary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Belum ada produk impian',
                    style: TextStyle(
                      fontSize: 16,
                      color: MasagiColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Cari Produk'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(wishlistProvider.notifier).loadWishlist();
            },
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
                  id: product.id.toString(),
                  name: product.name,
                  imageUrl: product.thumbnail ?? '',
                  price: product.price,
                  discountPrice: product.discountPrice,
                  discountPercent: product.discountPercent,
                  rating: product.rating,
                  reviewCount: product.reviewCount,
                  isWishlisted: true, // Always true in wishlist screen
                  onTap: () {
                    context.push('/product/${product.slug ?? product.id}');
                  },
                  onWishlistTap: () {
                    // Remove from wishlist
                    ref
                        .read(wishlistProvider.notifier)
                        .removeFromWishlist(product.id);
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: MasagiColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Gagal memuat wishlist',
                style: const TextStyle(color: MasagiColors.textSecondary),
              ),
              TextButton(
                onPressed: () {
                  ref.read(wishlistProvider.notifier).loadWishlist();
                },
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
