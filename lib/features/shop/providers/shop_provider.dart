import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../products/data/models/product_detail_model.dart';
import '../../home/data/models/product_model.dart';

// Mock generator for Shop Details
final shopDetailsProvider = FutureProvider.family<Shop, int>((
  ref,
  shopId,
) async {
  // Simulate network delay
  await Future.delayed(const Duration(seconds: 1));

  // Return mock shop data
  return Shop(
    id: shopId,
    name: 'Toko Masagi #$shopId',
    logo: 'https://via.placeholder.com/150',
    address: 'Jl. Contoh No. 123, Bandung',
    rating: 4.8,
    reviewCount: 150,
    productCount: 42,
    followerCount: 1200,
    isVerified: true,
    joinedAt: DateTime.now().subtract(const Duration(days: 365)),
  );
});

// Mock generator for Shop Products
final shopProductsProvider = FutureProvider.family<List<Product>, int>((
  ref,
  shopId,
) async {
  // Simulate network delay
  await Future.delayed(const Duration(seconds: 1));

  // Return list of mock products
  return List.generate(
    10,
    (index) => Product(
      id: index + 100,
      name: 'Produk Toko $shopId - Item #${index + 1}',
      slug: 'produk-toko-$shopId-$index',
      price: (index + 1) * 50000.0,
      thumbnail: 'https://via.placeholder.com/200',
      rating: 4.5,
      soldCount: index * 10,
      discountPercent: index % 3 == 0 ? 10 : 0,
      // sellerName: 'Toko Masagi #$shopId',
      // sellerId: shopId,
    ),
  );
});
