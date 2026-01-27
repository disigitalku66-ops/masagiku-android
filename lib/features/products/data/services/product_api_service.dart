/// Product API Service
library;

import 'package:dio/dio.dart';
import '../models/product_detail_model.dart';
import '../../../home/data/models/product_model.dart';
import '../../../../core/network/api_response.dart';

class ProductApiService {
  final Dio _dio;
  static const String _basePath = '/products';

  ProductApiService(this._dio);

  /// Get product detail by slug
  Future<ApiResponse<ProductDetail>> getProductDetail(String slug) async {
    try {
      final response = await _dio.get('$_basePath/details/$slug');
      final data = response.data;

      if (data['success'] == true && data['data'] != null) {
        return ApiResponse<ProductDetail>(
          success: true,
          data: ProductDetail.fromJson(data['data'] as Map<String, dynamic>),
          message: data['message'] as String?,
        );
      }

      return ApiResponse<ProductDetail>(
        success: false,
        message: data['message'] as String? ?? 'Failed to load product',
      );
    } on DioException catch (e) {
      return ApiResponse<ProductDetail>(
        success: false,
        message:
            e.response?.data?['message'] as String? ??
            e.message ??
            'Network error',
      );
    }
  }

  /// Get product reviews
  Future<PaginatedResponse<ProductReview>> getProductReviews(
    int productId, {
    int page = 1,
    int perPage = 10,
    int? rating, // Filter by rating (1-5)
  }) async {
    try {
      final response = await _dio.get(
        '$_basePath/reviews/$productId',
        queryParameters: {
          'page': page,
          'per_page': perPage,
          if (rating != null) 'rating': rating,
        },
      );
      final data = response.data;

      if (data['success'] == true) {
        final reviewsData = data['data'];
        List<ProductReview> reviews = [];

        if (reviewsData is List) {
          reviews = reviewsData
              .map((e) => ProductReview.fromJson(e as Map<String, dynamic>))
              .toList();
        } else if (reviewsData is Map && reviewsData['data'] != null) {
          reviews = (reviewsData['data'] as List)
              .map((e) => ProductReview.fromJson(e as Map<String, dynamic>))
              .toList();
        }

        // Extract pagination info
        final meta = data['meta'] ?? data['data'];
        final currentPage = meta?['current_page'] as int? ?? page;
        final lastPage = meta?['last_page'] as int? ?? 1;
        final total = meta?['total'] as int? ?? reviews.length;

        return PaginatedResponse<ProductReview>(
          success: true,
          data: reviews,
          currentPage: currentPage,
          totalCount: total,
          perPage: perPage,
          hasMorePages: currentPage < lastPage,
        );
      }

      return PaginatedResponse<ProductReview>(
        success: false,
        message: data['message'] as String? ?? 'Failed to load reviews',
        data: [],
        currentPage: page,
        totalCount: 0,
        perPage: perPage,
        hasMorePages: false,
      );
    } on DioException catch (e) {
      return PaginatedResponse<ProductReview>(
        success: false,
        message:
            e.response?.data?['message'] as String? ??
            e.message ??
            'Network error',
        data: [],
        currentPage: page,
        totalCount: 0,
        perPage: perPage,
        hasMorePages: false,
      );
    }
  }

  /// Get review summary statistics
  Future<ApiResponse<ReviewSummary>> getReviewSummary(int productId) async {
    try {
      final response = await _dio.get('$_basePath/rating/$productId');
      final data = response.data;

      if (data['success'] == true && data['data'] != null) {
        return ApiResponse<ReviewSummary>(
          success: true,
          data: ReviewSummary.fromJson(data['data'] as Map<String, dynamic>),
        );
      }

      return ApiResponse<ReviewSummary>(
        success: false,
        message: data['message'] as String? ?? 'Failed to load review summary',
      );
    } on DioException catch (e) {
      return ApiResponse<ReviewSummary>(
        success: false,
        message:
            e.response?.data?['message'] as String? ??
            e.message ??
            'Network error',
      );
    }
  }

  /// Get related products
  Future<ApiResponse<List<Product>>> getRelatedProducts(int productId) async {
    try {
      final response = await _dio.get('$_basePath/related-products/$productId');
      final data = response.data;

      if (data['success'] == true) {
        final productsData = data['data'];
        List<Product> products = [];

        if (productsData is List) {
          products = productsData
              .map((e) => Product.fromJson(e as Map<String, dynamic>))
              .toList();
        }

        return ApiResponse<List<Product>>(success: true, data: products);
      }

      return ApiResponse<List<Product>>(
        success: false,
        message:
            data['message'] as String? ?? 'Failed to load related products',
      );
    } on DioException catch (e) {
      return ApiResponse<List<Product>>(
        success: false,
        message:
            e.response?.data?['message'] as String? ??
            e.message ??
            'Network error',
      );
    }
  }

  /// Add/Remove product from wishlist
  Future<ApiResponse<bool>> toggleWishlist(int productId) async {
    try {
      final response = await _dio.post(
        '/customer/wish-list/add', // Temporary: Use add, might need toggle logic check later
        data: {'product_id': productId},
      );
      final data = response.data;

      if (data['success'] == true) {
        final isWishlisted =
            data['data']?['is_wishlisted'] == true ||
            data['message']?.toString().toLowerCase().contains('added') == true;
        return ApiResponse<bool>(
          success: true,
          data: isWishlisted,
          message: data['message'] as String?,
        );
      }

      return ApiResponse<bool>(
        success: false,
        message: data['message'] as String? ?? 'Failed to update wishlist',
      );
    } on DioException catch (e) {
      return ApiResponse<bool>(
        success: false,
        message:
            e.response?.data?['message'] as String? ??
            e.message ??
            'Network error',
      );
    }
  }

  /// Submit a product review
  Future<ApiResponse<ProductReview>> submitReview({
    required int productId,
    required int orderId,
    required double rating,
    String? comment,
    List<String>? images,
  }) async {
    try {
      final response = await _dio.post(
        '$_basePath/reviews/submit',
        data: {
          'order_id': orderId,
          'rating': rating.toInt(),
          if (comment != null) 'comment': comment,
          if (images != null && images.isNotEmpty) 'images': images,
        },
      );
      final data = response.data;

      if (data['success'] == true && data['data'] != null) {
        return ApiResponse<ProductReview>(
          success: true,
          data: ProductReview.fromJson(data['data'] as Map<String, dynamic>),
          message: data['message'] as String?,
        );
      }

      return ApiResponse<ProductReview>(
        success: false,
        message: data['message'] as String? ?? 'Failed to submit review',
      );
    } on DioException catch (e) {
      return ApiResponse<ProductReview>(
        success: false,
        message:
            e.response?.data?['message'] as String? ??
            e.message ??
            'Network error',
      );
    }
  }

  /// Get wishlist products
  Future<ApiResponse<List<Product>>> getWishlistProducts({
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await _dio.get(
        '/customer/wish-list',
        queryParameters: {'page': page, 'per_page': perPage},
      );
      final data = response.data;

      if (data['success'] == true) {
        final productsData = data['data'];
        List<Product> products = [];

        // Handle different data structures (array directly or inside data key)
        var listData = productsData;
        if (productsData is Map && productsData.containsKey('data')) {
          listData = productsData['data'];
        }

        if (listData is List) {
          products = listData
              .map((e) => Product.fromJson(e as Map<String, dynamic>))
              .toList();
        }

        return ApiResponse<List<Product>>(
          success: true,
          data: products,
          message: data['message'] as String?,
        );
      }

      return ApiResponse<List<Product>>(
        success: false,
        message: data['message'] as String? ?? 'Failed to load wishlist',
      );
    } on DioException catch (e) {
      return ApiResponse<List<Product>>(
        success: false,
        message:
            e.response?.data?['message'] as String? ??
            e.message ??
            'Network error',
      );
    }
  }
}
