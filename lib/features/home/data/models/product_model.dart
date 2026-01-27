/// Product model
library;

import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final int id;
  final String name;
  final String? slug;
  final String? description;
  final String? thumbnail;
  final List<String> images;
  final double price;
  final double? discountPrice;
  final int? discountPercent;
  final String? discountType;
  final int stock;
  final String? unit;
  final int? categoryId;
  final String? categoryName;
  final int? brandId;
  final String? brandName;
  final double rating;
  final int reviewCount;
  final int soldCount;
  final bool isFeatured;
  final bool isFlashDeal;
  final bool isWishlisted;
  final DateTime? createdAt;
  final List<ProductVariant>? variants;

  const Product({
    required this.id,
    required this.name,
    this.slug,
    this.description,
    this.thumbnail,
    this.images = const [],
    required this.price,
    this.discountPrice,
    this.discountPercent,
    this.discountType,
    this.stock = 0,
    this.unit,
    this.categoryId,
    this.categoryName,
    this.brandId,
    this.brandName,
    this.rating = 0,
    this.reviewCount = 0,
    this.soldCount = 0,
    this.isFeatured = false,
    this.isFlashDeal = false,
    this.isWishlisted = false,
    this.createdAt,
    this.variants,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Parse images
    List<String> imageList = [];
    if (json['images'] != null) {
      if (json['images'] is List) {
        imageList = (json['images'] as List)
            .map((e) => e is String ? e : (e['image'] ?? '').toString())
            .toList();
      }
    }

    // Calculate discount percent
    final unitPrice = (json['unit_price'] as num?)?.toDouble() ?? 0;
    final discount = (json['discount'] as num?)?.toDouble() ?? 0;
    final discountType = json['discount_type'] as String?;

    double? discountedPrice;
    int? discountPct;

    if (discount > 0) {
      if (discountType == 'percent') {
        discountPct = discount.toInt();
        discountedPrice = unitPrice * (1 - discount / 100);
      } else {
        discountedPrice = unitPrice - discount;
        discountPct = ((discount / unitPrice) * 100).toInt();
      }
    }

    return Product(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String?,
      description: json['details'] as String? ?? json['description'] as String?,
      thumbnail: json['thumbnail'] as String?,
      images: imageList,
      price: unitPrice,
      discountPrice: discountedPrice,
      discountPercent: discountPct,
      discountType: discountType,
      stock: json['current_stock'] as int? ?? json['stock'] as int? ?? 0,
      unit: json['unit'] as String?,
      categoryId: json['category_id'] as int?,
      categoryName: json['category']?['name'] as String?,
      brandId: json['brand_id'] as int?,
      brandName: json['brand']?['name'] as String?,
      rating:
          (json['rating']?[0]?['average'] as num?)?.toDouble() ??
          (json['average_rating'] as num?)?.toDouble() ??
          0,
      reviewCount:
          json['rating']?[0]?['count'] as int? ??
          json['reviews_count'] as int? ??
          0,
      soldCount: json['sold_count'] as int? ?? 0,
      isFeatured: json['featured'] == 1 || json['is_featured'] == true,
      isFlashDeal: json['flash_deal'] == 1 || json['is_flash_deal'] == true,
      isWishlisted:
          json['wishlist_status'] == 1 || json['is_wishlisted'] == true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      variants: json['choice_options'] != null
          ? (json['choice_options'] as List)
                .map((e) => ProductVariant.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'slug': slug,
      'description': description,
      'thumbnail': thumbnail,
      'images': images,
      'unit_price': price,
      'discount_price': discountPrice,
      'discount_percent': discountPercent,
      'stock': stock,
      'unit': unit,
      'category_id': categoryId,
      'brand_id': brandId,
      'rating': rating,
      'reviews_count': reviewCount,
      'sold_count': soldCount,
      'is_featured': isFeatured,
      'is_flash_deal': isFlashDeal,
      'is_wishlisted': isWishlisted,
    };
  }

  bool get hasDiscount => discountPrice != null && discountPrice! < price;
  double get effectivePrice => discountPrice ?? price;
  bool get isInStock => stock > 0;

  Product copyWith({
    int? id,
    String? name,
    String? slug,
    String? description,
    String? thumbnail,
    List<String>? images,
    double? price,
    double? discountPrice,
    int? discountPercent,
    String? discountType,
    int? stock,
    String? unit,
    int? categoryId,
    String? categoryName,
    int? brandId,
    String? brandName,
    double? rating,
    int? reviewCount,
    int? soldCount,
    bool? isFeatured,
    bool? isFlashDeal,
    bool? isWishlisted,
    DateTime? createdAt,
    List<ProductVariant>? variants,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      description: description ?? this.description,
      thumbnail: thumbnail ?? this.thumbnail,
      images: images ?? this.images,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      discountPercent: discountPercent ?? this.discountPercent,
      discountType: discountType ?? this.discountType,
      stock: stock ?? this.stock,
      unit: unit ?? this.unit,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      brandId: brandId ?? this.brandId,
      brandName: brandName ?? this.brandName,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      soldCount: soldCount ?? this.soldCount,
      isFeatured: isFeatured ?? this.isFeatured,
      isFlashDeal: isFlashDeal ?? this.isFlashDeal,
      isWishlisted: isWishlisted ?? this.isWishlisted,
      createdAt: createdAt ?? this.createdAt,
      variants: variants ?? this.variants,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    description,
    thumbnail,
    images,
    price,
    discountPrice,
    discountPercent,
    stock,
    unit,
    categoryId,
    brandId,
    rating,
    reviewCount,
    soldCount,
    isFeatured,
    isFlashDeal,
    isWishlisted,
    variants,
  ];
}

/// Product variant (color, size, etc)
class ProductVariant extends Equatable {
  final String name;
  final String title;
  final List<String> options;

  const ProductVariant({
    required this.name,
    required this.title,
    required this.options,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      name: json['name'] as String? ?? '',
      title: json['title'] as String? ?? '',
      options: json['options'] != null
          ? (json['options'] as List).map((e) => e.toString()).toList()
          : [],
    );
  }

  @override
  List<Object?> get props => [name, title, options];
}
