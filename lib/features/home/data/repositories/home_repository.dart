/// Home Repository
library;

import '../models/banner_model.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../services/home_api_service.dart';
import '../../../../core/network/api_response.dart';

class HomeRepository {
  final HomeApiService _apiService;

  HomeRepository(this._apiService);

  /// Get banners
  Future<ApiResponse<List<Banner>>> getBanners() async {
    return await _apiService.getBanners();
  }

  /// Get categories
  Future<ApiResponse<List<Category>>> getCategories() async {
    return await _apiService.getCategories();
  }

  /// Get featured products
  Future<ApiResponse<List<Product>>> getFeaturedProducts({
    int limit = 10,
  }) async {
    return await _apiService.getFeaturedProducts(limit: limit);
  }

  /// Get latest products
  Future<ApiResponse<List<Product>>> getLatestProducts({int limit = 10}) async {
    return await _apiService.getLatestProducts(limit: limit);
  }

  /// Get flash deals
  Future<ApiResponse<List<Product>>> getFlashDeals() async {
    return await _apiService.getFlashDeals();
  }

  /// Get products by category
  Future<PaginatedResponse<Product>> getProductsByCategory({
    required int categoryId,
    int page = 1,
    int limit = 20,
    String? sortBy,
  }) async {
    return await _apiService.getProductsByCategory(
      categoryId: categoryId,
      page: page,
      limit: limit,
      sortBy: sortBy,
    );
  }

  /// Search products
  Future<PaginatedResponse<Product>> searchProducts({
    required String query,
    int page = 1,
    int limit = 20,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
  }) async {
    return await _apiService.searchProducts(
      query: query,
      page: page,
      limit: limit,
      categoryId: categoryId,
      minPrice: minPrice,
      maxPrice: maxPrice,
      sortBy: sortBy,
    );
  }

  /// Get product detail
  Future<ApiResponse<Product>> getProductDetail(String slug) async {
    return await _apiService.getProductDetail(slug);
  }
}
