/// Product card widget
library;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/app_constants.dart';

class ProductCard extends StatelessWidget {
  final String? id;
  final String name;
  final String imageUrl;
  final double price;
  final double? originalPrice;
  final double? discountPrice;
  final int? discountPercent;
  final double? rating;
  final int? reviewCount;
  final bool isWishlisted;
  final VoidCallback? onTap;
  final VoidCallback? onWishlistTap;
  final VoidCallback? onAddToCart;

  const ProductCard({
    super.key,
    this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.originalPrice,
    this.discountPrice,
    this.discountPercent,
    this.rating,
    this.reviewCount,
    this.isWishlisted = false,
    this.onTap,
    this.onWishlistTap,
    this.onAddToCart,
  });

  String _formatPrice(double price) {
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

  int? get calculatedDiscountPercent {
    if (discountPercent != null) return discountPercent;
    final original = originalPrice ?? price;
    final current = discountPrice ?? price;
    if (original <= current) return null;
    return (((original - current) / original) * 100).round();
  }

  double get effectivePrice => discountPrice ?? price;
  double? get effectiveOriginalPrice {
    if (discountPrice != null && discountPrice! < price) return price;
    return originalPrice;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: MasagiColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          border: Border.all(color: MasagiColors.divider, width: 1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image with wishlist button
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: MasagiColors.surfaceVariant,
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: MasagiColors.surfaceVariant,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        size: 32,
                      ),
                    ),
                  ),
                ),
                // Discount badge
                if (calculatedDiscountPercent != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: MasagiColors.error,
                        borderRadius: BorderRadius.circular(
                          AppConstants.radiusSmall,
                        ),
                      ),
                      child: Text(
                        '-$calculatedDiscountPercent%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                // Wishlist button
                if (onWishlistTap != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onWishlistTap,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          isWishlisted ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: isWishlisted
                              ? MasagiColors.error
                              : MasagiColors.textTertiary,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Expanded(
                      child: Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: MasagiColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Rating
                    if (rating != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: MasagiColors.primaryGold,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            rating!.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 12,
                              color: MasagiColors.textSecondary,
                            ),
                          ),
                          if (reviewCount != null) ...[
                            Text(
                              ' ($reviewCount)',
                              style: const TextStyle(
                                fontSize: 12,
                                color: MasagiColors.textTertiary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    const SizedBox(height: 4),
                    // Price
                    if (effectiveOriginalPrice != null &&
                        effectiveOriginalPrice! > effectivePrice) ...[
                      Text(
                        _formatPrice(effectiveOriginalPrice!),
                        style: const TextStyle(
                          fontSize: 11,
                          color: MasagiColors.textTertiary,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                    ],
                    Text(
                      _formatPrice(effectivePrice),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: MasagiColors.primaryGold,
                      ),
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
}

/// Skeleton loading placeholder for product card
class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MasagiColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        border: Border.all(color: MasagiColors.divider, width: 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image placeholder
          AspectRatio(
            aspectRatio: 1,
            child: Container(color: MasagiColors.surfaceVariant),
          ),
          // Content placeholder
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: MasagiColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 14,
                    width: 80,
                    decoration: BoxDecoration(
                      color: MasagiColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 16,
                    width: 60,
                    decoration: BoxDecoration(
                      color: MasagiColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
