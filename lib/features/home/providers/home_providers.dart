/// Home Providers (Riverpod)
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/banner_model.dart';
import '../data/models/category_model.dart';
import '../data/models/product_model.dart';
import '../data/services/home_api_service.dart';
import '../data/repositories/home_repository.dart';
import '../../../core/providers/core_providers.dart';

/// Home API Service Provider
final homeApiServiceProvider = Provider<HomeApiService>((ref) {
  final dio = ref.watch(dioClientProvider).dio;
  return HomeApiService(dio);
});

/// Home Repository Provider
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final apiService = ref.watch(homeApiServiceProvider);
  return HomeRepository(apiService);
});

/// Home State
class HomeState {
  final bool isLoading;
  final List<Banner> banners;
  final List<Category> categories;
  final List<Product> featuredProducts;
  final List<Product> latestProducts;
  final List<Product> flashDeals;
  final String? errorMessage;

  const HomeState({
    this.isLoading = false,
    this.banners = const [],
    this.categories = const [],
    this.featuredProducts = const [],
    this.latestProducts = const [],
    this.flashDeals = const [],
    this.errorMessage,
  });

  HomeState copyWith({
    bool? isLoading,
    List<Banner>? banners,
    List<Category>? categories,
    List<Product>? featuredProducts,
    List<Product>? latestProducts,
    List<Product>? flashDeals,
    String? errorMessage,
  }) {
    return HomeState(
      isLoading: isLoading ?? this.isLoading,
      banners: banners ?? this.banners,
      categories: categories ?? this.categories,
      featuredProducts: featuredProducts ?? this.featuredProducts,
      latestProducts: latestProducts ?? this.latestProducts,
      flashDeals: flashDeals ?? this.flashDeals,
      errorMessage: errorMessage,
    );
  }
}

/// Home Notifier
class HomeNotifier extends StateNotifier<HomeState> {
  final HomeRepository _repository;

  HomeNotifier(this._repository) : super(const HomeState()) {
    loadHomeData();
  }

  Future<void> loadHomeData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Load all data in parallel
      final results = await Future.wait([
        _repository.getBanners(),
        _repository.getCategories(),
        _repository.getFeaturedProducts(limit: 10),
        _repository.getLatestProducts(limit: 10),
        _repository.getFlashDeals(),
      ]);

      state = state.copyWith(
        isLoading: false,
        banners: results[0].data as List<Banner>? ?? [],
        categories: results[1].data as List<Category>? ?? [],
        featuredProducts: results[2].data as List<Product>? ?? [],
        latestProducts: results[3].data as List<Product>? ?? [],
        flashDeals: results[4].data as List<Product>? ?? [],
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memuat data: $e',
      );
    }
  }

  Future<void> refresh() async {
    await loadHomeData();
  }
}

/// Home Provider
final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return HomeNotifier(repository);
});

/// Banners Provider
final bannersProvider = Provider<List<Banner>>((ref) {
  return ref.watch(homeProvider).banners;
});

/// Categories Provider
final categoriesProvider = Provider<List<Category>>((ref) {
  return ref.watch(homeProvider).categories;
});

/// Featured Products Provider
final featuredProductsProvider = Provider<List<Product>>((ref) {
  return ref.watch(homeProvider).featuredProducts;
});

/// Search State
class SearchState {
  final bool isLoading;
  final String query;
  final List<Product> results;
  final int currentPage;
  final int totalCount;
  final bool hasMore;
  final String? errorMessage;
  final double? minPrice;
  final double? maxPrice;
  final String? sortBy; // 'newest', 'price_asc', 'price_desc', 'popular'
  final int? categoryId;

  const SearchState({
    this.isLoading = false,
    this.query = '',
    this.results = const [],
    this.currentPage = 1,
    this.totalCount = 0,
    this.hasMore = false,
    this.errorMessage,
    this.minPrice,
    this.maxPrice,
    this.sortBy,
    this.categoryId,
  });

  SearchState copyWith({
    bool? isLoading,
    String? query,
    List<Product>? results,
    int? currentPage,
    int? totalCount,
    bool? hasMore,
    String? errorMessage,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    int? categoryId,
  }) {
    return SearchState(
      isLoading: isLoading ?? this.isLoading,
      query: query ?? this.query,
      results: results ?? this.results,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      sortBy: sortBy ?? this.sortBy,
      categoryId: categoryId ?? this.categoryId,
    );
  }
}

/// Search Notifier
class SearchNotifier extends StateNotifier<SearchState> {
  final HomeRepository _repository;

  SearchNotifier(this._repository) : super(const SearchState());

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = const SearchState();
      return;
    }

    state = state.copyWith(
      isLoading: true,
      query: query,
      currentPage: 1,
      errorMessage: null,
    );

    final response = await _repository.searchProducts(
      query: query,
      page: 1,
      minPrice: state.minPrice,
      maxPrice: state.maxPrice,
      sortBy: state.sortBy,
      categoryId: state.categoryId,
    );

    if (response.success) {
      state = state.copyWith(
        isLoading: false,
        results: response.data ?? [],
        totalCount: response.totalCount ?? 0,
        hasMore: (response.data?.length ?? 0) >= 20,
      );
    } else {
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
  }

  Future<void> applyFilters({
    double? minPrice,
    double? maxPrice,
    String? sortBy,
    int? categoryId,
  }) async {
    state = state.copyWith(
      minPrice: minPrice,
      maxPrice: maxPrice,
      sortBy: sortBy,
      categoryId: categoryId,
    );
    // Reload search with new filters if query exists
    if (state.query.isNotEmpty) {
      await search(state.query);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    final nextPage = state.currentPage + 1;
    final response = await _repository.searchProducts(
      query: state.query,
      page: nextPage,
      minPrice: state.minPrice,
      maxPrice: state.maxPrice,
      sortBy: state.sortBy,
      categoryId: state.categoryId,
    );

    if (response.success) {
      state = state.copyWith(
        isLoading: false,
        results: [...state.results, ...response.data ?? []],
        currentPage: nextPage,
        hasMore: (response.data?.length ?? 0) >= 20,
      );
    } else {
      state = state.copyWith(isLoading: false);
    }
  }

  void clear() {
    state = const SearchState();
  }
}

/// Search Provider
final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((
  ref,
) {
  final repository = ref.watch(homeRepositoryProvider);
  return SearchNotifier(repository);
});

/// Category Products State
class CategoryProductsState {
  final bool isLoading;
  final int? categoryId;
  final List<Product> products;
  final int currentPage;
  final int totalCount;
  final bool hasMore;
  final String? errorMessage;

  const CategoryProductsState({
    this.isLoading = false,
    this.categoryId,
    this.products = const [],
    this.currentPage = 1,
    this.totalCount = 0,
    this.hasMore = false,
    this.errorMessage,
  });

  CategoryProductsState copyWith({
    bool? isLoading,
    int? categoryId,
    List<Product>? products,
    int? currentPage,
    int? totalCount,
    bool? hasMore,
    String? errorMessage,
  }) {
    return CategoryProductsState(
      isLoading: isLoading ?? this.isLoading,
      categoryId: categoryId ?? this.categoryId,
      products: products ?? this.products,
      currentPage: currentPage ?? this.currentPage,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: errorMessage,
    );
  }
}

/// Category Products Notifier
class CategoryProductsNotifier extends StateNotifier<CategoryProductsState> {
  final HomeRepository _repository;

  CategoryProductsNotifier(this._repository)
    : super(const CategoryProductsState());

  Future<void> loadProducts(int categoryId) async {
    state = state.copyWith(
      isLoading: true,
      categoryId: categoryId,
      currentPage: 1,
      products: [],
      errorMessage: null,
    );

    final response = await _repository.getProductsByCategory(
      categoryId: categoryId,
      page: 1,
    );

    if (response.success) {
      state = state.copyWith(
        isLoading: false,
        products: response.data ?? [],
        totalCount: response.totalCount ?? 0,
        hasMore: (response.data?.length ?? 0) >= 20,
      );
    } else {
      state = state.copyWith(isLoading: false, errorMessage: response.message);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore || state.categoryId == null) return;

    state = state.copyWith(isLoading: true);

    final nextPage = state.currentPage + 1;
    final response = await _repository.getProductsByCategory(
      categoryId: state.categoryId!,
      page: nextPage,
    );

    if (response.success) {
      state = state.copyWith(
        isLoading: false,
        products: [...state.products, ...response.data ?? []],
        currentPage: nextPage,
        hasMore: (response.data?.length ?? 0) >= 20,
      );
    } else {
      state = state.copyWith(isLoading: false);
    }
  }
}

/// Category Products Provider
final categoryProductsProvider =
    StateNotifierProvider<CategoryProductsNotifier, CategoryProductsState>((
      ref,
    ) {
      final repository = ref.watch(homeRepositoryProvider);
      return CategoryProductsNotifier(repository);
    });
