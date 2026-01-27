import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:masagiku_app/shared/widgets/buttons.dart';
import 'package:masagiku_app/core/widgets/custom_snackbar.dart';
import 'package:masagiku_app/shared/widgets/inputs.dart';
import 'package:masagiku_app/features/products/providers/product_providers.dart';

class OrderReviewScreen extends ConsumerStatefulWidget {
  final int orderId;
  final int productId;
  final String productName;
  final String productImage;

  const OrderReviewScreen({
    super.key,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.productImage,
  });

  @override
  ConsumerState<OrderReviewScreen> createState() => _OrderReviewScreenState();
}

class _OrderReviewScreenState extends ConsumerState<OrderReviewScreen> {
  double _rating = 5.0;
  final TextEditingController _commentController = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitReview() async {
    if (_commentController.text.isEmpty) {
      CustomSnackbar.show(
        context,
        message: 'Mohon tulis ulasan Anda',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final repository = ref.read(productRepositoryProvider);
      final result = await repository.submitReview(
        productId: widget.productId,
        orderId: widget.orderId,
        rating: _rating,
        comment: _commentController.text,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (result.success) {
          CustomSnackbar.show(
            context,
            message: 'Ulasan berhasil dikirim',
            isError: false,
          );
          context.pop(true); // Return success
        } else {
          CustomSnackbar.show(
            context,
            message: result.message ?? 'Gagal mengirim ulasan',
            isError: true,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        CustomSnackbar.show(
          context,
          message: 'Terjadi kesalahan: $e',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Beri Ulasan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Info
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.productImage,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const Icon(Icons.image_not_supported),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    widget.productName,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Rating
            const Text(
              'Berikan Rating',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  onPressed: () {
                    setState(() {
                      _rating = index + 1.0;
                    });
                  },
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 40,
                  ),
                );
              }),
            ),
            Center(
              child: Text(
                '${_rating.toInt()}/5',
                style: const TextStyle(fontSize: 16),
              ),
            ),

            const SizedBox(height: 24),

            // Comment
            const Text(
              'Tulis Ulasan (*)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              controller: _commentController,
              hint: 'Bagaimana kualitas produk ini?',
              maxLines: 4,
            ),

            const SizedBox(height: 32),

            // Submit Button
            PrimaryButton(
              text: 'Kirim Ulasan',
              isLoading: _isLoading,
              onPressed: _submitReview,
            ),
          ],
        ),
      ),
    );
  }
}
