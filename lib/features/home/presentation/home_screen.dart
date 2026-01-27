/// Home Screen with Riverpod integration
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../app/routes.dart';
import '../providers/home_providers.dart';
import 'widgets/banner_carousel.dart';
import 'widgets/category_grid.dart';
import 'widgets/product_section.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);

    return Scaffold(
      backgroundColor: MasagiColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: MasagiColors.primaryGold,
          onRefresh: () => ref.read(homeProvider.notifier).refresh(),
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                floating: true,
                backgroundColor: MasagiColors.background,
                elevation: 0,
                title: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: MasagiColors.primaryGradient,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.shopping_bag,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Masagiku',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: MasagiColors.primaryGold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => context.push(AppRoutes.productSearch),
                  ),
                  IconButton(
                    icon: Stack(
                      children: [
                        const Icon(Icons.notifications_outlined),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: MasagiColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: const Text(
                              '3',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    onPressed: () {
                      // Navigate to notifications
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              // Content
              if (homeState.isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (homeState.errorMessage != null)
                SliverFillRemaining(
                  child: _buildErrorState(
                    context,
                    ref,
                    homeState.errorMessage!,
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildListDelegate([
                    const SizedBox(height: 8),

                    // Banners
                    BannerCarousel(
                      banners: homeState.banners,
                      onTap: (banner) {
                        if (banner.resourceType == 'product' &&
                            banner.resourceId != null) {
                          context.push(
                            AppRoutes.productDetailPath(banner.resourceId!),
                          );
                        } else if (banner.resourceType == 'category' &&
                            banner.resourceId != null) {
                          context.push(
                            AppRoutes.categoryProductsPath(banner.resourceId!),
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 24),

                    // Categories
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.spacingMd,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Kategori',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          TextButton(
                            onPressed: () => context.push(AppRoutes.categories),
                            child: const Text('Lihat Semua'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    CategoryGrid(
                      categories: homeState.categories,
                      onTap: (category) {
                        context.push(
                          AppRoutes.categoryProductsPath(
                            category.id.toString(),
                          ),
                        );
                      },
                      onViewAll: () => context.push(AppRoutes.categories),
                    ),

                    const SizedBox(height: 24),

                    // Flash Deals (if available)
                    if (homeState.flashDeals.isNotEmpty) ...[
                      ProductListSection(
                        title: '⚡ Flash Deals',
                        products: homeState.flashDeals,
                        onProductTap: (product) {
                          context.push(
                            AppRoutes.productDetailPath(
                              product.slug ?? product.id.toString(),
                            ),
                          );
                        },
                        onViewAll: () {
                          // Navigate to flash deals
                        },
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Featured Products
                    ProductListSection(
                      title: '🌟 Produk Unggulan',
                      products: homeState.featuredProducts,
                      onProductTap: (product) {
                        context.push(
                          AppRoutes.productDetailPath(
                            product.slug ?? product.id.toString(),
                          ),
                        );
                      },
                      onViewAll: () {
                        // Navigate to featured products
                      },
                    ),

                    const SizedBox(height: 24),

                    // Latest Products
                    ProductGridSection(
                      title: '🆕 Produk Terbaru',
                      products: homeState.latestProducts,
                      onProductTap: (product) {
                        context.push(
                          AppRoutes.productDetailPath(
                            product.slug ?? product.id.toString(),
                          ),
                        );
                      },
                      onViewAll: () {
                        // Navigate to new arrivals
                      },
                    ),

                    const SizedBox(height: 24),
                  ]),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: MasagiColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Terjadi Kesalahan',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: MasagiColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => ref.read(homeProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }
}
