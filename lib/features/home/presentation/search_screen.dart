/// Search Screen
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../app/routes.dart';
import '../../../shared/widgets/product_card.dart';
import '../providers/home_providers.dart';
import 'widgets/search_filter_sheet.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(searchProvider.notifier).loadMore();
    }
  }

  void _onSearch(String query) {
    if (query.isNotEmpty) {
      ref.read(searchProvider.notifier).search(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      backgroundColor: MasagiColors.background,
      appBar: AppBar(
        backgroundColor: MasagiColors.background,
        titleSpacing: 0,
        title: Container(
          height: 44,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: MasagiColors.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _focusNode,
            textInputAction: TextInputAction.search,
            onSubmitted: _onSearch,
            decoration: InputDecoration(
              hintText: 'Cari produk...',
              prefixIcon: const Icon(
                Icons.search,
                color: MasagiColors.textSecondary,
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(searchProvider.notifier).clear();
                        setState(() {});
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) => setState(() {}),
          ),
        ),
      ),
      body: _buildBody(searchState),
    );
  }

  Widget _buildBody(SearchState state) {
    if (state.query.isEmpty) {
      return _buildInitialState();
    }

    if (state.isLoading && state.results.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.results.isEmpty) {
      return _buildErrorState(state.errorMessage!);
    }

    if (state.results.isEmpty) {
      return _buildEmptyState();
    }

    return _buildResults(state);
  }

  Widget _buildInitialState() {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pencarian Populer',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildSearchChip('Elektronik'),
              _buildSearchChip('Fashion'),
              _buildSearchChip('Makanan'),
              _buildSearchChip('Kesehatan'),
              _buildSearchChip('Kecantikan'),
              _buildSearchChip('Olahraga'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchChip(String label) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        _searchController.text = label;
        _onSearch(label);
      },
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: MasagiColors.error),
          const SizedBox(height: 16),
          Text(message),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => _onSearch(_searchController.text),
            child: const Text('Coba Lagi'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 64,
            color: MasagiColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'Produk tidak ditemukan',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Coba kata kunci lain',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: MasagiColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildResults(SearchState state) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(AppConstants.spacingMd),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${state.totalCount} produk ditemukan',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: MasagiColors.textSecondary,
                ),
              ),
              // Filter button
              OutlinedButton.icon(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => const SearchFilterSheet(),
                  );
                },
                icon: const Icon(Icons.tune, size: 18),
                label: const Text('Filter'),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(AppConstants.spacingMd),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.68,
            ),
            itemCount: state.results.length + (state.isLoading ? 2 : 0),
            itemBuilder: (context, index) {
              if (index >= state.results.length) {
                return const ProductCardSkeleton();
              }

              final product = state.results[index];
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
                onTap: () {
                  context.push(
                    AppRoutes.productDetailPath(
                      product.slug ?? product.id.toString(),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
