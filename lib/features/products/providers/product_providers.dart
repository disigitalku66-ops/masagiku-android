/// Product Providers (Riverpod)
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../home/data/models/product_model.dart';
import '../data/models/product_detail_model.dart';
import '../data/services/product_api_service.dart';
import '../data/repositories/product_repository.dart';
import '../../../core/providers/core_providers.dart';

/// Product API Service Provider
final productApiServiceProvider = Provider<ProductApiService>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return ProductApiService(dio);
});

/// Product Repository Provider
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final apiService = ref.watch(productApiServiceProvider);
  return ProductRepository(apiService);
});

/// Product Detail State
class ProductDetailState {
  final bool isLoading;
  final ProductDetail? productDetail;
  final String? errorMessage;
  final bool isWishlisted;
  final Map<String, String> selectedVariants;
  final int quantity;

  const ProductDetailState({
    this.isLoading = false,
    this.productDetail,
    this.errorMessage,
    this.isWishlisted = false,
    this.selectedVariants = const {},
    this.quantity = 1,
  });

  ProductDetailState copyWith({
    bool? isLoading,
    ProductDetail? productDetail,
    String? errorMessage,
    bool? isWishlisted,
    Map<String, String>? selectedVariants,
    int? quantity,
  }) {
    return ProductDetailState(
      isLoading: isLoading ?? this.isLoading,
      productDetail: productDetail ?? this.productDetail,
      errorMessage: errorMessage,
      isWishlisted: isWishlisted ?? this.isWishlisted,
      selectedVariants: selectedVariants ?? this.selectedVariants,
      quantity: quantity ?? this.quantity,
    );
  }

  /// Get current price based on selected variants
  double get currentPrice {
    if (productDetail == null) return 0;
    // For now, use effective price (can be extended for variant pricing)
    return productDetail!.product.effectivePrice;
  }

  /// Get total price (current price * quantity)
  double get totalPrice => currentPrice * quantity;

  /// Check if all required variants are selected
  bool get allVariantsSelected {
    if (productDetail?.product.variants == null) return true;
    return productDetail!.product.variants!.every(
      (variant) => selectedVariants.containsKey(variant.name),
    );
  }
}

/// Product Detail Notifier
class ProductDetailNotifier extends StateNotifier<ProductDetailState> {
  final ProductRepository _repository;

  ProductDetailNotifier(this._repository) : super(const ProductDetailState());

  /// Load product detail by slug
  Future<void> loadProduct(String slug) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final response = await _repository.getProductDetail(slug);

    if (response.success && response.data != null) {
      final detail = response.data!;

      // Initialize variant selections with first option
      Map<String, String> initialVariants = {};
      if (detail.product.variants != null) {
        for (final variant in detail.product.variants!) {
          if (variant.options.isNotEmpty) {
            initialVariants[variant.name] = variant.options.first;
          }
        }
      }

      state = state.copyWith(
        isLoading: false,
        productDetail: detail,
        isWishlisted: detail.product.isWishlisted,
        selectedVariants: initialVariants,
        quantity: 1,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message ?? 'Gagal memuat detail produk',
      );
    }
  }

  /// Update selected variant
  void selectVariant(String variantName, String option) {
    final newVariants = Map<String, String>.from(state.selectedVariants);
    newVariants[variantName] = option;
    state = state.copyWith(selectedVariants: newVariants);
  }

  /// Update quantity
  void updateQuantity(int quantity) {
    if (quantity < 1) return;
    final maxStock = state.productDetail?.product.stock ?? 1;
    if (quantity > maxStock) quantity = maxStock;
    state = state.copyWith(quantity: quantity);
  }

  /// Increment quantity
  void incrementQuantity() {
    updateQuantity(state.quantity + 1);
  }

  /// Decrement quantity
  void decrementQuantity() {
    updateQuantity(state.quantity - 1);
  }

  /// Toggle wishlist
  Future<void> toggleWishlist() async {
    if (state.productDetail == null) return;

    final productId = state.productDetail!.product.id;
    final response = await _repository.toggleWishlist(productId);

    if (response.success) {
      state = state.copyWith(
        isWishlisted: response.data ?? !state.isWishlisted,
      );
    }
  }

  /// Get selected variant string for cart
  String getSelectedVariantString() {
    if (state.selectedVariants.isEmpty) return '';
    return state.selectedVariants.entries
        .map((e) => '${e.key}: ${e.value}')
        .join(', ');
  }
}

/// Product Detail Provider (family - by slug)
final productDetailProvider =
    StateNotifierProvider.family<
      ProductDetailNotifier,
      ProductDetailState,
      String
    >((ref, slug) {
      final repository = ref.watch(productRepositoryProvider);
      final notifier = ProductDetailNotifier(repository);
      notifier.loadProduct(slug);
      return notifier;
    });

/// Reviews State
class ReviewsState {
  final bool isLoading;
  final bool isLoadingMore;
  final List<ProductReview> reviews;
  final ReviewSummary? summary;
  final String? errorMessage;
  final int currentPage;
  final bool hasMore;
  final int? filterRating;

  const ReviewsState({
    this.isLoading = false,
    this.isLoadingMore = false,
    this.reviews = const [],
    this.summary,
    this.errorMessage,
    this.currentPage = 1,
    this.hasMore = true,
    this.filterRating,
  });

  ReviewsState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    List<ProductReview>? reviews,
    ReviewSummary? summary,
    String? errorMessage,
    int? currentPage,
    bool? hasMore,
    int? filterRating,
  }) {
    return ReviewsState(
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      reviews: reviews ?? this.reviews,
      summary: summary ?? this.summary,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      filterRating: filterRating,
    );
  }
}

/// Reviews Notifier
class ReviewsNotifier extends StateNotifier<ReviewsState> {
  final ProductRepository _repository;
  final int _productId;

  ReviewsNotifier(this._repository, this._productId)
    : super(const ReviewsState());

  /// Load reviews and summary
  Future<void> loadReviews({int? rating}) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      filterRating: rating,
    );

    // Load reviews and summary in parallel
    final results = await Future.wait([
      _repository.getProductReviews(_productId, rating: rating),
      _repository.getReviewSummary(_productId),
    ]);

    final reviewsResponse = results[0] as dynamic;
    final summaryResponse = results[1] as dynamic;

    if (reviewsResponse.success) {
      state = state.copyWith(
        isLoading: false,
        reviews: reviewsResponse.data as List<ProductReview>,
        currentPage: reviewsResponse.currentPage,
        hasMore: reviewsResponse.hasMorePages,
        summary: summaryResponse.success
            ? summaryResponse.data as ReviewSummary
            : null,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: reviewsResponse.message ?? 'Gagal memuat ulasan',
      );
    }
  }

  /// Load more reviews
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoadingMore) return;

    state = state.copyWith(isLoadingMore: true);

    final response = await _repository.getProductReviews(
      _productId,
      page: state.currentPage + 1,
      rating: state.filterRating,
    );

    if (response.success) {
      state = state.copyWith(
        isLoadingMore: false,
        reviews: [...state.reviews, ...(response.data ?? [])],
        currentPage: response.currentPage,
        hasMore: response.hasMorePages,
      );
    } else {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  /// Filter by rating
  void filterByRating(int? rating) {
    loadReviews(rating: rating);
  }
}

/// Reviews Provider (family - by product id)
final reviewsProvider =
    StateNotifierProvider.family<ReviewsNotifier, ReviewsState, int>((
      ref,
      productId,
    ) {
      final repository = ref.watch(productRepositoryProvider);
      final notifier = ReviewsNotifier(repository, productId);
      notifier.loadReviews();
      return notifier;
    });

/// Related Products Provider
final relatedProductsProvider = FutureProvider.family<List<Product>, int>((
  ref,
  productId,
) async {
  final repository = ref.watch(productRepositoryProvider);
  final response = await repository.getRelatedProducts(productId);
  return response.data ?? [];
});
