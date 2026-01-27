/// Category Grid Widget
library;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/models/category_model.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';

class CategoryGrid extends StatelessWidget {
  final List<Category> categories;
  final Function(Category)? onTap;
  final int maxItems;
  final bool showViewAll;
  final VoidCallback? onViewAll;

  const CategoryGrid({
    super.key,
    required this.categories,
    this.onTap,
    this.maxItems = 8,
    this.showViewAll = true,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final displayCategories = categories.take(maxItems).toList();

    if (displayCategories.isEmpty) {
      return _buildPlaceholder();
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
        itemCount:
            displayCategories.length +
            (showViewAll && categories.length > maxItems ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == displayCategories.length) {
            return _buildViewAllItem();
          }
          return _buildCategoryItem(displayCategories[index]);
        },
      ),
    );
  }

  Widget _buildCategoryItem(Category category) {
    return GestureDetector(
      onTap: onTap != null ? () => onTap!(category) : null,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: MasagiColors.gold50,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                border: Border.all(color: MasagiColors.gold100),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  AppConstants.radiusMedium - 1,
                ),
                child: category.icon != null || category.image != null
                    ? CachedNetworkImage(
                        imageUrl: category.icon ?? category.image ?? '',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => const Center(
                          child: Icon(
                            Icons.category_outlined,
                            color: MasagiColors.primaryGold,
                            size: 28,
                          ),
                        ),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.category_outlined,
                          color: MasagiColors.primaryGold,
                          size: 28,
                        ),
                      )
                    : const Icon(
                        Icons.category_outlined,
                        color: MasagiColors.primaryGold,
                        size: 28,
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              category.name,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildViewAllItem() {
    return GestureDetector(
      onTap: onViewAll,
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: MasagiColors.surfaceVariant,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                border: Border.all(color: MasagiColors.divider),
              ),
              child: const Icon(
                Icons.grid_view_rounded,
                color: MasagiColors.textSecondary,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Lihat Semua',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: MasagiColors.primaryGold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingMd),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            width: 80,
            margin: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: MasagiColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 50,
                  height: 12,
                  decoration: BoxDecoration(
                    color: MasagiColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
