/// Order Product Item Widget
library;

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/colors.dart';
import '../../../../core/constants/app_constants.dart';
// import '../../data/models/order_model.dart'; // Will use OrderItem later if available

class OrderProductItem extends StatelessWidget {
  final String name;
  final String? image;
  final String? variant;
  final double price;
  final int quantity;
  final VoidCallback? onTap;

  const OrderProductItem({
    super.key,
    required this.name,
    this.image,
    this.variant,
    required this.price,
    required this.quantity,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        color: Colors.transparent,
        child: Row(
          children: [
            // Product Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                border: Border.all(color: MasagiColors.divider),
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
                child: image != null
                    ? CachedNetworkImage(
                        imageUrl: image!,
                        fit: BoxFit.cover,
                        placeholder: (context, url) =>
                            Container(color: MasagiColors.surfaceVariant),
                        errorWidget: (context, url, error) => const Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey,
                          size: 20,
                        ),
                      )
                    : Container(
                        color: MasagiColors.surfaceVariant,
                        child: const Icon(
                          Icons.image_not_supported_outlined,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (variant != null && variant!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      variant!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: MasagiColors.textSecondary,
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${quantity}x',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        _formatPrice(price),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    // Simple formatter, use intl in production
    return 'Rp ${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }
}
