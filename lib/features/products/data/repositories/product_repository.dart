/// Product Repository
library;

import '../../../home/data/models/product_model.dart';
import '../../../../core/network/api_response.dart';
import '../models/product_detail_model.dart';
import '../services/product_api_service.dart';

class ProductRepository {
  final ProductApiService _apiService;

  ProductRepository(this._apiService);

  /// Get product detail by slug
  Future<ApiResponse<ProductDetail>> getProductDetail(String slug) {
    return _apiService.getProductDetail(slug);
  }

  /// Get product reviews with pagination
  Future<PaginatedResponse<ProductReview>> getProductReviews(
    int productId, {
    int page = 1,
    int perPage = 10,
    int? rating,
  }) {
    return _apiService.getProductReviews(
      productId,
      page: page,
      perPage: perPage,
      rating: rating,
    );
  }

  /// Get review summary statistics
  Future<ApiResponse<ReviewSummary>> getReviewSummary(int productId) {
    return _apiService.getReviewSummary(productId);
  }

  /// Get related products
  Future<ApiResponse<List<Product>>> getRelatedProducts(int productId) {
    return _apiService.getRelatedProducts(productId);
  }

  /// Toggle wishlist status
  Future<ApiResponse<bool>> toggleWishlist(int productId) {
    return _apiService.toggleWishlist(productId);
  }

  /// Submit product review
  Future<ApiResponse<ProductReview>> submitReview({
    required int productId,
    required int orderId,
    required double rating,
    String? comment,
    List<String>? images,
  }) {
    return _apiService.submitReview(
      productId: productId,
      orderId: orderId,
      rating: rating,
      comment: comment,
      images: images,
    );
  }
}
