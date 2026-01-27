/// Product Detail Models
library;

import 'package:equatable/equatable.dart';
import '../../../home/data/models/product_model.dart';

/// Extended Product Detail with shop, reviews, and related products
class ProductDetail extends Equatable {
  final Product product;
  final Shop? shop;
  final List<ProductReview> reviews;
  final List<Product> relatedProducts;
  final List<ProductSpecification> specifications;
  final String? shippingInfo;
  final String? returnPolicy;

  const ProductDetail({
    required this.product,
    this.shop,
    this.reviews = const [],
    this.relatedProducts = const [],
    this.specifications = const [],
    this.shippingInfo,
    this.returnPolicy,
  });

  factory ProductDetail.fromJson(Map<String, dynamic> json) {
    return ProductDetail(
      product: Product.fromJson(json),
      shop: json['shop'] != null
          ? Shop.fromJson(json['shop'] as Map<String, dynamic>)
          : null,
      reviews: json['reviews'] != null
          ? (json['reviews'] as List)
                .map((e) => ProductReview.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
      relatedProducts: json['related_products'] != null
          ? (json['related_products'] as List)
                .map((e) => Product.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
      specifications: json['specifications'] != null
          ? (json['specifications'] as List)
                .map(
                  (e) =>
                      ProductSpecification.fromJson(e as Map<String, dynamic>),
                )
                .toList()
          : [],
      shippingInfo: json['shipping_info'] as String?,
      returnPolicy: json['return_policy'] as String?,
    );
  }

  @override
  List<Object?> get props => [
    product,
    shop,
    reviews,
    relatedProducts,
    specifications,
    shippingInfo,
    returnPolicy,
  ];
}

/// Shop/Seller information
class Shop extends Equatable {
  final int id;
  final String name;
  final String? logo;
  final String? address;
  final double rating;
  final int reviewCount;
  final int productCount;
  final int followerCount;
  final bool isVerified;
  final DateTime? joinedAt;

  const Shop({
    required this.id,
    required this.name,
    this.logo,
    this.address,
    this.rating = 0,
    this.reviewCount = 0,
    this.productCount = 0,
    this.followerCount = 0,
    this.isVerified = false,
    this.joinedAt,
  });

  factory Shop.fromJson(Map<String, dynamic> json) {
    return Shop(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      logo: json['logo'] as String?,
      address: json['address'] as String?,
      rating:
          (json['rating'] as num?)?.toDouble() ??
          (json['average_rating'] as num?)?.toDouble() ??
          0,
      reviewCount: json['review_count'] as int? ?? 0,
      productCount:
          json['product_count'] as int? ?? json['products_count'] as int? ?? 0,
      followerCount:
          json['follower_count'] as int? ??
          json['followers_count'] as int? ??
          0,
      isVerified: json['verified'] == 1 || json['is_verified'] == true,
      joinedAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    logo,
    address,
    rating,
    reviewCount,
    productCount,
    followerCount,
    isVerified,
    joinedAt,
  ];
}

/// Product Review
class ProductReview extends Equatable {
  final int id;
  final int productId;
  final int userId;
  final String userName;
  final String? userAvatar;
  final double rating;
  final String? comment;
  final List<String> images;
  final String? reply;
  final DateTime? createdAt;

  const ProductReview({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.rating,
    this.comment,
    this.images = const [],
    this.reply,
    this.createdAt,
  });

  factory ProductReview.fromJson(Map<String, dynamic> json) {
    // Parse images
    List<String> imageList = [];
    if (json['images'] != null || json['attachment'] != null) {
      final rawImages = json['images'] ?? json['attachment'];
      if (rawImages is List) {
        imageList = rawImages.map((e) => e.toString()).toList();
      } else if (rawImages is String && rawImages.isNotEmpty) {
        imageList = rawImages.split(',');
      }
    }

    return ProductReview(
      id: json['id'] as int,
      productId: json['product_id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? json['customer_id'] as int? ?? 0,
      userName:
          json['user_name'] as String? ??
          json['customer']?['name'] as String? ??
          json['customer']?['f_name'] as String? ??
          'Customer',
      userAvatar:
          json['user_avatar'] as String? ??
          json['customer']?['avatar'] as String? ??
          json['customer']?['image'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      comment: json['comment'] as String?,
      images: imageList,
      reply: json['reply'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
    id,
    productId,
    userId,
    userName,
    userAvatar,
    rating,
    comment,
    images,
    reply,
    createdAt,
  ];
}

/// Product Specification (e.g., Weight, Dimensions)
class ProductSpecification extends Equatable {
  final String key;
  final String value;

  const ProductSpecification({required this.key, required this.value});

  factory ProductSpecification.fromJson(Map<String, dynamic> json) {
    return ProductSpecification(
      key: json['key'] as String? ?? json['name'] as String? ?? '',
      value: json['value'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [key, value];
}

/// Review Summary Statistics
class ReviewSummary extends Equatable {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution; // 5 -> count, 4 -> count, etc

  const ReviewSummary({
    this.averageRating = 0,
    this.totalReviews = 0,
    this.ratingDistribution = const {},
  });

  factory ReviewSummary.fromJson(Map<String, dynamic> json) {
    Map<int, int> distribution = {};

    // Parse rating distribution from various formats
    for (int i = 1; i <= 5; i++) {
      distribution[i] =
          json['$i'] as int? ??
          json['star_$i'] as int? ??
          json['rating_$i'] as int? ??
          0;
    }

    return ReviewSummary(
      averageRating:
          (json['average'] as num?)?.toDouble() ??
          (json['average_rating'] as num?)?.toDouble() ??
          0,
      totalReviews: json['total'] as int? ?? json['total_reviews'] as int? ?? 0,
      ratingDistribution: distribution,
    );
  }

  double getPercentage(int star) {
    if (totalReviews == 0) return 0;
    return (ratingDistribution[star] ?? 0) / totalReviews * 100;
  }

  @override
  List<Object?> get props => [averageRating, totalReviews, ratingDistribution];
}
