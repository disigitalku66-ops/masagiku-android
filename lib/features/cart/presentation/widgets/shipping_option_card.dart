/// Shipping Option Card Widget
library;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/models/shipping_model.dart';

class ShippingOptionCard extends StatelessWidget {
  final ShippingMethod method;
  final bool isSelected;
  final VoidCallback? onTap;

  const ShippingOptionCard({
    super.key,
    required this.method,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = const Color(0xFFf49d2a);
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? primaryColor : theme.dividerColor,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Selection indicator
              Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_off,
                color: isSelected ? primaryColor : theme.hintColor,
                size: 22,
              ),
              const SizedBox(width: 12),

              // Shipping icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.local_shipping_outlined,
                  color: primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),

              // Shipping info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      method.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (method.duration > 0)
                      Text(
                        'Estimasi ${method.durationText}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.hintColor,
                        ),
                      ),
                  ],
                ),
              ),

              // Price
              Text(
                method.cost > 0 ? currencyFormat.format(method.cost) : 'Gratis',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: method.cost == 0 ? Colors.green : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Seller Shipping Group
class SellerShippingGroup extends StatelessWidget {
  final String sellerName;
  final String? sellerImage;
  final List<ShippingMethod> methods;
  final int selectedMethodId;
  final ValueChanged<int> onMethodSelected;

  const SellerShippingGroup({
    super.key,
    required this.sellerName,
    this.sellerImage,
    required this.methods,
    required this.selectedMethodId,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Seller header
        Row(
          children: [
            Icon(Icons.store_outlined, size: 16, color: theme.hintColor),
            const SizedBox(width: 8),
            Text(
              sellerName,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Shipping methods
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: methods.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final method = methods[index];
            return ShippingOptionCard(
              method: method,
              isSelected: method.id == selectedMethodId,
              onTap: () => onMethodSelected(method.id),
            );
          },
        ),
      ],
    );
  }
}
