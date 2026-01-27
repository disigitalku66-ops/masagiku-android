import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:masagiku_app/features/home/data/models/product_model.dart';
import 'package:masagiku_app/features/products/providers/product_providers.dart';
import '../data/repositories/wishlist_repository.dart';

/// Wishlist repository provider
final wishlistRepositoryProvider = Provider<WishlistRepository>((ref) {
  final apiService = ref.read(productApiServiceProvider);
  return WishlistRepository(apiService);
});

/// Wishlist state provider
final wishlistProvider =
    StateNotifierProvider<WishlistNotifier, AsyncValue<List<Product>>>((ref) {
      final repository = ref.read(wishlistRepositoryProvider);
      return WishlistNotifier(repository);
    });

class WishlistNotifier extends StateNotifier<AsyncValue<List<Product>>> {
  final WishlistRepository _repository;

  WishlistNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadWishlist();
  }

  Future<void> loadWishlist() async {
    try {
      state = const AsyncValue.loading();
      final response = await _repository.getWishlist();

      if (response.success && response.data != null) {
        state = AsyncValue.data(response.data!);
      } else {
        state = AsyncValue.error(
          response.message ?? 'Gagal memuat wishlist',
          StackTrace.current,
        );
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> removeFromWishlist(int productId) async {
    // Optimistic update
    final previousState = state;
    if (state.hasValue) {
      state = AsyncValue.data(
        state.value!.where((p) => p.id != productId).toList(),
      );
    }

    try {
      final response = await _repository.toggleWishlist(productId);
      if (response.success) {
        return true;
      } else {
        // Revert if failed
        state = previousState;
        return false;
      }
    } catch (e) {
      state = previousState;
      return false;
    }
  }
}
