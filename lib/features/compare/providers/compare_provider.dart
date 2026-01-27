import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../products/data/models/product_detail_model.dart';

/// Provider for the list of products in comparison
final compareProvider =
    StateNotifierProvider<CompareNotifier, List<ProductDetail>>(
      (ref) => CompareNotifier(),
    );

class CompareNotifier extends StateNotifier<List<ProductDetail>> {
  CompareNotifier() : super([]);

  static const int maxCompareItems = 3;

  /// Add a product to comparison list
  /// Returns validation message if fails, null if success
  String? addToCompare(ProductDetail product) {
    if (state.length >= maxCompareItems) {
      return 'Maksimal $maxCompareItems produk untuk dibandingkan';
    }

    if (state.any((p) => p.product.id == product.product.id)) {
      return 'Produk sudah ada dalam perbandingan';
    }

    // Optional: Check category compatibility
    if (state.isNotEmpty) {
      final firstCategory = state.first.product.categoryId;
      if (product.product.categoryId != firstCategory) {
        return 'Hanya dapat membandingkan produk dari kategori yang sama';
      }
    }

    state = [...state, product];
    return null;
  }

  void removeFromCompare(int productId) {
    state = state.where((p) => p.product.id != productId).toList();
  }

  void clearCompare() {
    state = [];
  }

  bool isComparing(int productId) {
    return state.any((p) => p.product.id == productId);
  }
}
