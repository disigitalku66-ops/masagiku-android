/// Home API Service
library;

import 'package:dio/dio.dart';
import '../models/banner_model.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../../../../core/network/api_response.dart';

class HomeApiService {
  final Dio _dio;

  HomeApiService(this._dio);

  /// Get home banners
  Future<ApiResponse<List<Banner>>> getBanners() async {
    try {
      final response = await _dio.get('/config');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final bannerList = data['banners'] as List? ?? [];

        return ApiResponse(
          success: true,
          data: bannerList
              .map((e) => Banner.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      }

      return ApiResponse(success: false, message: 'Gagal memuat banner');
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data?['message'] ?? 'Gagal memuat banner',
      );
    }
  }

  /// Get all categories
  Future<ApiResponse<List<Category>>> getCategories() async {
    try {
      final response = await _dio.get('/categories');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final categoryList =
            data['data'] as List? ?? data['categories'] as List? ?? [];

        return ApiResponse(
          success: true,
          data: categoryList
              .map((e) => Category.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      }

      return ApiResponse(success: false, message: 'Gagal memuat kategori');
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data?['message'] ?? 'Gagal memuat kategori',
      );
    }
  }

  /// Get featured products
  Future<ApiResponse<List<Product>>> getFeaturedProducts({
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/products/featured',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final productList =
            data['products'] as List? ?? data['data'] as List? ?? [];

        return ApiResponse(
          success: true,
          data: productList
              .map((e) => Product.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      }

      return ApiResponse(
        success: false,
        message: 'Gagal memuat produk unggulan',
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data?['message'] ?? 'Gagal memuat produk unggulan',
      );
    }
  }

  /// Get latest products
  Future<ApiResponse<List<Product>>> getLatestProducts({int limit = 10}) async {
    try {
      final response = await _dio.get(
        '/products/latest',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final productList =
            data['products'] as List? ?? data['data'] as List? ?? [];

        return ApiResponse(
          success: true,
          data: productList
              .map((e) => Product.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      }

      return ApiResponse(
        success: false,
        message: 'Gagal memuat produk terbaru',
      );
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data?['message'] ?? 'Gagal memuat produk terbaru',
      );
    }
  }

  /// Get flash deal products
  Future<ApiResponse<List<Product>>> getFlashDeals() async {
    try {
      final response = await _dio.get('/flash-deals');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final productList =
            data['products'] as List? ?? data['data'] as List? ?? [];

        return ApiResponse(
          success: true,
          data: productList
              .map((e) => Product.fromJson(e as Map<String, dynamic>))
              .toList(),
        );
      }

      return ApiResponse(success: false, message: 'Gagal memuat flash deals');
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data?['message'] ?? 'Gagal memuat flash deals',
      );
    }
  }

  /// Get products by category
  Future<PaginatedResponse<Product>> getProductsByCategory({
    required int categoryId,
    int page = 1,
    int limit = 20,
    String? sortBy,
  }) async {
    try {
      final response = await _dio.get(
        '/categories/products/$categoryId',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (sortBy != null) 'sort_by': sortBy,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        // API response structure for category products:
        // usually { data: [products], ... } or just [products] inside data
        final productList =
            data['products'] as List? ?? data['data'] as List? ?? [];

        return PaginatedResponse(
          success: true,
          data: productList
              .map((e) => Product.fromJson(e as Map<String, dynamic>))
              .toList(), // Fixed: Removed extra argument if any
          totalCount: data['total_size'] as int? ?? data['total'] as int? ?? 0,
          currentPage: page,
          perPage: limit,
        );
      }

      return PaginatedResponse(success: false, message: 'Gagal memuat produk');
    } on DioException catch (e) {
      return PaginatedResponse(
        success: false,
        message: e.response?.data?['message'] ?? 'Gagal memuat produk',
      );
    }
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
    try {
      final response = await _dio.get(
        '/products/search',
        queryParameters: {
          'name': query,
          'page': page,
          'limit': limit,
          if (categoryId != null) 'category_id': categoryId,
          if (minPrice != null) 'min_price': minPrice,
          if (maxPrice != null) 'max_price': maxPrice,
          if (sortBy != null) 'sort_by': sortBy,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final productList =
            data['products'] as List? ?? data['data'] as List? ?? [];

        return PaginatedResponse(
          success: true,
          data: productList
              .map((e) => Product.fromJson(e as Map<String, dynamic>))
              .toList(),
          totalCount: data['total_size'] as int? ?? data['total'] as int? ?? 0,
          currentPage: page,
          perPage: limit,
        );
      }

      return PaginatedResponse(success: false, message: 'Gagal mencari produk');
    } on DioException catch (e) {
      return PaginatedResponse(
        success: false,
        message: e.response?.data?['message'] ?? 'Gagal mencari produk',
      );
    }
  }

  /// Get product detail
  Future<ApiResponse<Product>> getProductDetail(String slug) async {
    try {
      final response = await _dio.get('/products/details/$slug');

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final productData = data['product'] ?? data['data'] ?? data;

        return ApiResponse(
          success: true,
          data: Product.fromJson(productData as Map<String, dynamic>),
        );
      }

      return ApiResponse(success: false, message: 'Produk tidak ditemukan');
    } on DioException catch (e) {
      return ApiResponse(
        success: false,
        message: e.response?.data?['message'] ?? 'Produk tidak ditemukan',
      );
    }
  }
}
