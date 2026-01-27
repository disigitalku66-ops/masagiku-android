/// Product Grid Section Widget
library;

import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../../../shared/widgets/product_card.dart';
import '../../../../core/constants/app_constants.dart';

class ProductGridSection extends StatelessWidget {
  final String title;
  final List<Product> products;
  final Function(Product)? onProductTap;
  final Function(Product)? onWishlistTap;
  final VoidCallback? onViewAll;
  final bool isLoading;

  const ProductGridSection({
    super.key,
    required this.title,
    required this.products,
    this.onProductTap,
    this.onWishlistTap,
    this.onViewAll,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingMd,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: const Text('Lihat Semua'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Products Grid
        if (isLoading)
          _buildLoadingGrid()
        else if (products.isEmpty)
          _buildEmptyState()
        else
          _buildProductGrid(),
      ],
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.68,
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
          isWishlisted: product.isWishlisted,
          onTap: onProductTap != null ? () => onProductTap!(product) : null,
          onWishlistTap: onWishlistTap != null
              ? () => onWishlistTap!(product)
              : null,
        );
      },
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.68,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return const ProductCardSkeleton();
      },
    );
  }

  Widget _buildEmptyState() {
    return const SizedBox(
      height: 200,
      child: Center(
        child: Text('Tidak ada produk', style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}

/// Horizontal Product List Section
class ProductListSection extends StatelessWidget {
  final String title;
  final List<Product> products;
  final Function(Product)? onProductTap;
  final Function(Product)? onWishlistTap;
  final VoidCallback? onViewAll;
  final bool isLoading;

  const ProductListSection({
    super.key,
    required this.title,
    required this.products,
    this.onProductTap,
    this.onWishlistTap,
    this.onViewAll,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingMd,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: const Text('Lihat Semua'),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Products List
        SizedBox(
          height: 260,
          child: isLoading
              ? _buildLoadingList()
              : products.isEmpty
              ? const Center(child: Text('Tidak ada produk'))
              : _buildProductList(),
        ),
      ],
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Container(
          width: 160,
          margin: const EdgeInsets.only(right: 12),
          child: ProductCard(
            id: product.id.toString(),
            name: product.name,
            imageUrl: product.thumbnail ?? '',
            price: product.price,
            discountPrice: product.discountPrice,
            discountPercent: product.discountPercent,
            rating: product.rating,
            reviewCount: product.reviewCount,
            isWishlisted: product.isWishlisted,
            onTap: onProductTap != null ? () => onProductTap!(product) : null,
            onWishlistTap: onWishlistTap != null
                ? () => onWishlistTap!(product)
                : null,
          ),
        );
      },
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          width: 160,
          margin: const EdgeInsets.only(right: 12),
          child: const ProductCardSkeleton(),
        );
      },
    );
  }
}
