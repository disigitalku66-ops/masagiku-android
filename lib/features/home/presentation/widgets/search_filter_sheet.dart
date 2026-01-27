import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/colors.dart';
import '../../providers/home_providers.dart';

class SearchFilterSheet extends ConsumerStatefulWidget {
  const SearchFilterSheet({super.key});

  @override
  ConsumerState<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends ConsumerState<SearchFilterSheet> {
  late SearchState _searchState;

  double _minPrice = 0;
  double _maxPrice = 10000000; // 10jt max for UI slider

  String? _selectedSort;
  int? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _searchState = ref.read(searchProvider);

    _minPrice = _searchState.minPrice ?? 0;
    _maxPrice = _searchState.maxPrice ?? 10000000;
    _selectedSort = _searchState.sortBy;
    _selectedCategory = _searchState.categoryId;
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: MasagiColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                'Filter',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  setState(() {
                    _minPrice = 0;
                    _maxPrice = 10000000;
                    _selectedSort = null;
                    _selectedCategory = null;
                  });
                },
                child: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Sort By
          const Text('Urutkan', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildSortChip('Terbaru', 'newest'),
              _buildSortChip('Terlaris', 'popular'),
              _buildSortChip('Harga Terendah', 'price_asc'),
              _buildSortChip('Harga Tertinggi', 'price_desc'),
            ],
          ),
          const SizedBox(height: 16),

          // Categories
          const Text('Kategori', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: categories.map((category) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category.name),
                    selected: _selectedCategory == category.id,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = selected ? category.id : null;
                      });
                    },
                    selectedColor: MasagiColors.primary.withValues(alpha: 0.1),
                    checkmarkColor: MasagiColors.primary,
                    labelStyle: TextStyle(
                      color: _selectedCategory == category.id
                          ? MasagiColors.primary
                          : MasagiColors.textPrimary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Price Range
          const Text(
            'Rentang Harga',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          RangeSlider(
            values: RangeValues(_minPrice, _maxPrice),
            min: 0,
            max: 10000000,
            divisions: 100,
            labels: RangeLabels(
              'Rp${_minPrice.toInt()}',
              'Rp${_maxPrice.toInt()}',
            ),
            activeColor: MasagiColors.primary,
            onChanged: (values) {
              setState(() {
                _minPrice = values.start;
                _maxPrice = values.end;
              });
            },
          ),

          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(searchProvider.notifier)
                  .applyFilters(
                    minPrice: _minPrice > 0 ? _minPrice : null,
                    maxPrice: _maxPrice < 10000000 ? _maxPrice : null,
                    sortBy: _selectedSort,
                    categoryId: _selectedCategory,
                  );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: MasagiColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Terapkan Filter'),
          ),
        ],
      ),
    );
  }

  Widget _buildSortChip(String label, String value) {
    final isSelected = _selectedSort == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedSort = selected ? value : null;
        });
      },
      selectedColor: MasagiColors.primary.withValues(alpha: 0.1),
      labelStyle: TextStyle(
        color: isSelected ? MasagiColors.primary : MasagiColors.textPrimary,
      ),
    );
  }
}
