/// Address Selection Screen
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/checkout_providers.dart';
import 'widgets/address_card.dart';

class AddressSelectionScreen extends ConsumerWidget {
  final bool isSelectionMode;

  const AddressSelectionScreen({super.key, this.isSelectionMode = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressState = ref.watch(addressProvider);
    final theme = Theme.of(context);
    final primaryColor = const Color(0xFFf49d2a);

    return Scaffold(
      appBar: AppBar(
        title: Text(isSelectionMode ? 'Pilih Alamat' : 'Alamat Saya'),
      ),
      body: addressState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : addressState.addresses.isEmpty
          ? _buildEmptyState(context, theme)
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: addressState.addresses.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final address = addressState.addresses[index];
                final isSelected =
                    isSelectionMode &&
                    address.id == addressState.selectedAddressId;

                return AddressCard(
                  address: address,
                  isSelected: isSelected,
                  onTap: () {
                    if (isSelectionMode) {
                      ref
                          .read(addressProvider.notifier)
                          .selectAddress(address.id);
                      context.pop();
                    } else {
                      // In management mode, tap could open edit or details.
                      // For now, let's just open edit.
                      context.push('ubah/${address.id}');
                    }
                  },
                  onEdit: () =>
                      context.push('ubah/${address.id}'), // Relative path
                  onDelete: address.isDefault
                      ? null
                      : () => _showDeleteDialog(context, ref, address.id),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('tambah'), // Relative path
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Tambah Alamat'),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 80,
              color: theme.hintColor.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'Belum Ada Alamat',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tambahkan alamat pengiriman untuk melanjutkan checkout',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.push('tambah'),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Alamat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFf49d2a),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, int addressId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Alamat?'),
        content: const Text('Apakah Anda yakin ingin menghapus alamat ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(addressProvider.notifier).deleteAddress(addressId);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
