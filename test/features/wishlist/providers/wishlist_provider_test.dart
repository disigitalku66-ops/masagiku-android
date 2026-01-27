import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:masagiku_app/core/network/api_response.dart';
import 'package:masagiku_app/features/home/data/models/product_model.dart';
import 'package:masagiku_app/features/wishlist/data/repositories/wishlist_repository.dart';
import 'package:masagiku_app/features/wishlist/providers/wishlist_providers.dart';

// Manual Mock Implementation
class MockWishlistRepository extends Mock implements WishlistRepository {
  @override
  Future<ApiResponse<List<Product>>> getWishlist({
    int page = 1,
    int perPage = 10,
  }) {
    return super.noSuchMethod(
      Invocation.method(#getWishlist, [], {#page: page, #perPage: perPage}),
      returnValue: Future.value(
        ApiResponse<List<Product>>(success: true, data: []),
      ),
      returnValueForMissingStub: Future.value(
        ApiResponse<List<Product>>(success: true, data: []),
      ),
    );
  }

  @override
  Future<ApiResponse<bool>> toggleWishlist(int? productId) {
    return super.noSuchMethod(
      Invocation.method(#toggleWishlist, [productId]),
      returnValue: Future.value(ApiResponse<bool>(success: true, data: true)),
      returnValueForMissingStub: Future.value(
        ApiResponse<bool>(success: true, data: true),
      ),
    );
  }
}

void main() {
  late MockWishlistRepository mockRepository;
  late WishlistNotifier notifier;

  setUp(() {
    mockRepository = MockWishlistRepository();
    // Initialize notifier. Note: Constructor calls loadWishlist immediately.
    notifier = WishlistNotifier(mockRepository);
  });

  group('WishlistNotifier', () {
    final tProduct = Product(id: 1, name: 'Test Product', price: 10000);
    final tProducts = [tProduct];

    test('initial state check', () {
      expect(notifier, isA<WishlistNotifier>());
      // We can't strictly check 'loading' because the async call in constructor might result in
      // a microtask that changes state before we can check, or vice versa.
      // But we can check that it's an AsyncValue.
      expect(notifier.state, isA<AsyncValue<List<Product>>>());
    });

    test('loadWishlist should update state with data on success', () async {
      // Arrange
      when(
        mockRepository.getWishlist(),
      ).thenAnswer((_) async => ApiResponse(success: true, data: tProducts));

      // Act
      await notifier.loadWishlist();

      // Assert
      expect(notifier.state, AsyncValue.data(tProducts));
      // Verify called at least once (could be from constructor + explicit call)
      verify(mockRepository.getWishlist()).called(greaterThan(0));
    });

    test(
      'removeFromWishlist should remove item from state on success',
      () async {
        // Arrange
        // 1. Setup initial data
        when(
          mockRepository.getWishlist(),
        ).thenAnswer((_) async => ApiResponse(success: true, data: tProducts));
        await notifier.loadWishlist(); // Populate state with [tProduct]

        // 2. Setup toggle behavior
        when(
          mockRepository.toggleWishlist(1),
        ).thenAnswer((_) async => ApiResponse(success: true, data: false));

        // Act
        final result = await notifier.removeFromWishlist(1);

        // Assert
        expect(result, true);
        // State should be empty after removal
        expect(notifier.state.value, isEmpty);
        verify(mockRepository.toggleWishlist(1));
      },
    );

    test('removeFromWishlist should revert state on failure', () async {
      // Arrange
      when(
        mockRepository.getWishlist(),
      ).thenAnswer((_) async => ApiResponse(success: true, data: tProducts));
      await notifier.loadWishlist(); // State has [tProduct]

      when(
        mockRepository.toggleWishlist(1),
      ).thenAnswer((_) async => ApiResponse(success: false, message: 'Error'));

      // Act
      final result = await notifier.removeFromWishlist(1);

      // Assert
      expect(result, false);
      // State should still contain tProduct
      expect(notifier.state.value, contains(tProduct));
      verify(mockRepository.toggleWishlist(1));
    });
  });
}
