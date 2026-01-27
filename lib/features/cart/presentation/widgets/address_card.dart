/// Address Card Widget
library;

import 'package:flutter/material.dart';
import '../../data/models/address_model.dart';

class AddressCard extends StatelessWidget {
  final ShippingAddress address;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const AddressCard({
    super.key,
    required this.address,
    this.isSelected = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = const Color(0xFFf49d2a);

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? primaryColor : theme.dividerColor,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selection indicator
              if (onTap != null)
                Padding(
                  padding: const EdgeInsets.only(right: 12, top: 2),
                  child: Icon(
                    isSelected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: isSelected ? primaryColor : theme.hintColor,
                    size: 22,
                  ),
                ),

              // Address info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Type Badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            address.contactPersonName,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        _buildTypeBadge(theme),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Phone
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 14,
                          color: theme.hintColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          address.phone,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Full Address
                    Text(
                      address.fullAddress,
                      style: theme.textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Default badge
                    if (address.isDefault) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Alamat Utama',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Actions
              if (showActions && (onEdit != null || onDelete != null))
                Column(
                  children: [
                    if (onEdit != null)
                      IconButton(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 20),
                        style: IconButton.styleFrom(
                          foregroundColor: theme.hintColor,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(36, 36),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    if (onDelete != null && !address.isDefault)
                      IconButton(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline, size: 20),
                        style: IconButton.styleFrom(
                          foregroundColor: Colors.red.shade400,
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(36, 36),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeBadge(ThemeData theme) {
    IconData icon;
    Color bgColor;

    switch (address.addressType.toLowerCase()) {
      case 'home':
        icon = Icons.home_outlined;
        bgColor = Colors.blue.shade50;
        break;
      case 'office':
        icon = Icons.work_outline;
        bgColor = Colors.green.shade50;
        break;
      default:
        icon = Icons.location_on_outlined;
        bgColor = Colors.grey.shade100;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.hintColor),
          const SizedBox(width: 4),
          Text(
            address.addressTypeLabel,
            style: theme.textTheme.labelSmall?.copyWith(color: theme.hintColor),
          ),
        ],
      ),
    );
  }
}

/// Compact address card for checkout
class AddressCardCompact extends StatelessWidget {
  final ShippingAddress? address;
  final VoidCallback? onTap;
  final VoidCallback? onChange;

  const AddressCardCompact({
    super.key,
    this.address,
    this.onTap,
    this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = const Color(0xFFf49d2a);

    if (address == null) {
      return Card(
        margin: EdgeInsets.zero,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: theme.dividerColor),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(
                  Icons.add_location_alt_outlined,
                  color: primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tambah Alamat Pengiriman',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(Icons.chevron_right, color: theme.hintColor),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, color: primaryColor, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          address!.contactPersonName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          address!.phone,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.hintColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      address!.fullAddress,
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (onChange != null)
                TextButton(
                  onPressed: onChange,
                  child: Text('Ganti', style: TextStyle(color: primaryColor)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
