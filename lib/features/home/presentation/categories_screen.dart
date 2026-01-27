/// Categories Screen
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../app/routes.dart';
import '../providers/home_providers.dart';

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final homeState = ref.watch(homeProvider);
    final categories = homeState.categories;

    return Scaffold(
      backgroundColor: MasagiColors.background,
      appBar: AppBar(
        title: const Text('Kategori'),
        backgroundColor: MasagiColors.background,
      ),
      body: homeState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : categories.isEmpty
          ? _buildEmptyState(context)
          : _buildCategoryList(context, categories),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.category_outlined,
            size: 64,
            color: MasagiColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Tidak ada kategori',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryList(BuildContext context, List categories) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppConstants.spacingMd),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return _CategoryCard(category: category);
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final dynamic category;

  const _CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    final hasChildren =
        category.children != null && category.children!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
        side: BorderSide(color: MasagiColors.divider.withValues(alpha: 0.5)),
      ),
      child: hasChildren
          ? ExpansionTile(
              leading: _buildCategoryIcon(),
              title: Text(
                category.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${category.productsCount} produk',
                style: const TextStyle(fontSize: 12),
              ),
              children: category.children!.map<Widget>((child) {
                return ListTile(
                  contentPadding: const EdgeInsets.only(left: 72, right: 16),
                  title: Text(child.name),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    context.push(
                      AppRoutes.categoryProductsPath(child.id.toString()),
                    );
                  },
                );
              }).toList(),
            )
          : ListTile(
              leading: _buildCategoryIcon(),
              title: Text(
                category.name,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${category.productsCount} produk',
                style: const TextStyle(fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                context.push(
                  AppRoutes.categoryProductsPath(category.id.toString()),
                );
              },
            ),
    );
  }

  Widget _buildCategoryIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: MasagiColors.gold50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: category.icon != null || category.image != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: category.icon ?? category.image ?? '',
                fit: BoxFit.cover,
                placeholder: (context, url) => const Icon(
                  Icons.category_outlined,
                  color: MasagiColors.primaryGold,
                ),
                errorWidget: (context, url, error) => const Icon(
                  Icons.category_outlined,
                  color: MasagiColors.primaryGold,
                ),
              ),
            )
          : const Icon(
              Icons.category_outlined,
              color: MasagiColors.primaryGold,
            ),
    );
  }
}
