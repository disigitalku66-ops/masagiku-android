/// Variant Selector Widget
library;

import 'package:flutter/material.dart';
import '../../../home/data/models/product_model.dart';

class VariantSelector extends StatelessWidget {
  final List<ProductVariant> variants;
  final Map<String, String> selectedVariants;
  final Function(String variantName, String option) onVariantSelected;

  const VariantSelector({
    super.key,
    required this.variants,
    required this.selectedVariants,
    required this.onVariantSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: variants.map((variant) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Variant Title
              Text(
                variant.title.isNotEmpty ? variant.title : variant.name,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              // Variant Options
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: variant.options.map((option) {
                  final isSelected = selectedVariants[variant.name] == option;
                  return _VariantChip(
                    label: option,
                    isSelected: isSelected,
                    onTap: () => onVariantSelected(variant.name, option),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _VariantChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _VariantChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    // Check if this might be a color variant
    final isColorVariant = _isColorName(label);
    final variantColor = isColorVariant ? _getColorFromName(label) : null;

    // Color variant chip
    if (variantColor != null) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: variantColor,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? primaryColor : Colors.grey[300]!,
              width: isSelected ? 3 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: isSelected
              ? Icon(
                  Icons.check,
                  color: _isLightColor(variantColor)
                      ? Colors.black87
                      : Colors.white,
                  size: 20,
                )
              : null,
        ),
      );
    }

    // Text variant chip
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey[300]!,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  bool _isColorName(String name) {
    final colorNames = [
      'merah',
      'red',
      'biru',
      'blue',
      'hijau',
      'green',
      'kuning',
      'yellow',
      'hitam',
      'black',
      'putih',
      'white',
      'abu',
      'grey',
      'gray',
      'pink',
      'ungu',
      'purple',
      'orange',
      'coklat',
      'brown',
      'navy',
      'maroon',
      'cream',
      'krem',
      'beige',
      'gold',
      'emas',
      'silver',
      'perak',
    ];
    return colorNames.any((c) => name.toLowerCase().contains(c));
  }

  Color? _getColorFromName(String name) {
    final lowerName = name.toLowerCase();

    if (lowerName.contains('merah') || lowerName.contains('red')) {
      return Colors.red;
    } else if (lowerName.contains('biru') || lowerName.contains('blue')) {
      return Colors.blue;
    } else if (lowerName.contains('hijau') || lowerName.contains('green')) {
      return Colors.green;
    } else if (lowerName.contains('kuning') || lowerName.contains('yellow')) {
      return Colors.yellow;
    } else if (lowerName.contains('hitam') || lowerName.contains('black')) {
      return Colors.black;
    } else if (lowerName.contains('putih') || lowerName.contains('white')) {
      return Colors.white;
    } else if (lowerName.contains('abu') ||
        lowerName.contains('grey') ||
        lowerName.contains('gray')) {
      return Colors.grey;
    } else if (lowerName.contains('pink')) {
      return Colors.pink;
    } else if (lowerName.contains('ungu') || lowerName.contains('purple')) {
      return Colors.purple;
    } else if (lowerName.contains('orange')) {
      return Colors.orange;
    } else if (lowerName.contains('coklat') || lowerName.contains('brown')) {
      return Colors.brown;
    } else if (lowerName.contains('navy')) {
      return const Color(0xFF001F54);
    } else if (lowerName.contains('maroon')) {
      return const Color(0xFF800000);
    } else if (lowerName.contains('cream') ||
        lowerName.contains('krem') ||
        lowerName.contains('beige')) {
      return const Color(0xFFF5F5DC);
    } else if (lowerName.contains('gold') || lowerName.contains('emas')) {
      return const Color(0xFFFFD700);
    } else if (lowerName.contains('silver') || lowerName.contains('perak')) {
      return const Color(0xFFC0C0C0);
    }

    return null;
  }

  bool _isLightColor(Color color) {
    return color.computeLuminance() > 0.5;
  }
}

/// Quantity Selector Widget
class QuantitySelector extends StatelessWidget {
  final int quantity;
  final int maxQuantity;
  final Function(int) onChanged;
  final bool showLabel;

  const QuantitySelector({
    super.key,
    required this.quantity,
    this.maxQuantity = 999,
    required this.onChanged,
    this.showLabel = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (showLabel) ...[
          Text(
            'Jumlah',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
        ],
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Minus button
              _QuantityButton(
                icon: Icons.remove,
                onTap: quantity > 1 ? () => onChanged(quantity - 1) : null,
              ),
              // Quantity display
              Container(
                constraints: const BoxConstraints(minWidth: 48),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  quantity.toString(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Plus button
              _QuantityButton(
                icon: Icons.add,
                onTap: quantity < maxQuantity
                    ? () => onChanged(quantity + 1)
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QuantityButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          size: 20,
          color: onTap != null
              ? Theme.of(context).primaryColor
              : Colors.grey[400],
        ),
      ),
    );
  }
}
