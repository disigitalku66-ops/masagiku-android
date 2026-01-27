import 'package:masagiku_app/core/network/api_response.dart';
import 'package:masagiku_app/features/products/data/services/product_api_service.dart';
import 'package:masagiku_app/features/home/data/models/product_model.dart';

class WishlistRepository {
  final ProductApiService _apiService;

  WishlistRepository(this._apiService);

  /// Fetch user wishlist
  Future<ApiResponse<List<Product>>> getWishlist({
    int page = 1,
    int perPage = 10,
  }) async {
    return _apiService.getWishlistProducts(page: page, perPage: perPage);
  }

  /// Remove or Add to wishlist (Toggle)
  Future<ApiResponse<bool>> toggleWishlist(int productId) async {
    return _apiService.toggleWishlist(productId);
  }
}
