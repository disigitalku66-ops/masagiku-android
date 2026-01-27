/// Add/Edit Address Screen
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/checkout_providers.dart';
import '../data/models/address_model.dart';

class AddAddressScreen extends ConsumerStatefulWidget {
  final int? addressId; // null for add, set for edit

  const AddAddressScreen({super.key, this.addressId});

  @override
  ConsumerState<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends ConsumerState<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _addressController;
  late final TextEditingController _cityController;
  late final TextEditingController _zipController;
  late final TextEditingController _stateController;

  String _addressType = 'home';
  bool _isLoading = false;
  ShippingAddress? _existingAddress;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _zipController = TextEditingController();
    _stateController = TextEditingController();

    // Load existing address for edit mode
    if (widget.addressId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadExistingAddress();
      });
    }
  }

  void _loadExistingAddress() {
    final addressState = ref.read(addressProvider);
    _existingAddress = addressState.addresses
        .cast<ShippingAddress?>()
        .firstWhere((a) => a?.id == widget.addressId, orElse: () => null);

    if (_existingAddress != null) {
      setState(() {
        _nameController.text = _existingAddress!.contactPersonName;
        _phoneController.text = _existingAddress!.phone;
        _emailController.text = _existingAddress!.email ?? '';
        _addressController.text = _existingAddress!.address;
        _cityController.text = _existingAddress!.city ?? '';
        _zipController.text = _existingAddress!.zip ?? '';
        _stateController.text = _existingAddress!.state ?? '';
        _addressType = _existingAddress!.addressType;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _zipController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.addressId != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Alamat' : 'Tambah Alamat')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Address Type
            Text(
              'Tipe Alamat',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            _buildAddressTypeSelector(theme),

            const SizedBox(height: 24),

            // Contact Person Name
            _buildTextField(
              controller: _nameController,
              label: 'Nama Penerima',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nama penerima wajib diisi';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Phone
            _buildTextField(
              controller: _phoneController,
              label: 'Nomor Telepon',
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Nomor telepon wajib diisi';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Email (optional)
            _buildTextField(
              controller: _emailController,
              label: 'Email (opsional)',
              keyboardType: TextInputType.emailAddress,
            ),

            const SizedBox(height: 16),

            // Address
            _buildTextField(
              controller: _addressController,
              label: 'Alamat Lengkap',
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Alamat wajib diisi';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // City and Zip
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    controller: _cityController,
                    label: 'Kota',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Kota wajib diisi';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: _buildTextField(
                    controller: _zipController,
                    label: 'Kode Pos',
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // State/Province
            _buildTextField(controller: _stateController, label: 'Provinsi'),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFf49d2a),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(isEditing ? 'Simpan Perubahan' : 'Simpan Alamat'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressTypeSelector(ThemeData theme) {
    final types = [
      ('home', Icons.home_outlined, 'Rumah'),
      ('office', Icons.work_outline, 'Kantor'),
      ('other', Icons.location_on_outlined, 'Lainnya'),
    ];

    return Row(
      children: [
        for (int i = 0; i < types.length; i++) ...[
          if (i > 0) const SizedBox(width: 12),
          Expanded(
            child: _buildTypeChip(
              type: types[i].$1,
              icon: types[i].$2,
              label: types[i].$3,
              isSelected: _addressType == types[i].$1,
              theme: theme,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTypeChip({
    required String type,
    required IconData icon,
    required String label,
    required bool isSelected,
    required ThemeData theme,
  }) {
    final primaryColor = const Color(0xFFf49d2a);

    return InkWell(
      onTap: () => setState(() => _addressType = type),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? primaryColor : theme.hintColor),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected ? primaryColor : theme.hintColor,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFf49d2a)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final request = AddressRequest(
      id: widget.addressId,
      contactPersonName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      addressType: _addressType,
      address: _addressController.text.trim(),
      city: _cityController.text.trim().isEmpty
          ? null
          : _cityController.text.trim(),
      zip: _zipController.text.trim().isEmpty
          ? null
          : _zipController.text.trim(),
      state: _stateController.text.trim().isEmpty
          ? null
          : _stateController.text.trim(),
    );

    final success = widget.addressId != null
        ? await ref.read(addressProvider.notifier).updateAddress(request)
        : await ref.read(addressProvider.notifier).addAddress(request);

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.addressId != null
                ? 'Alamat berhasil diperbarui'
                : 'Alamat berhasil ditambahkan',
          ),
          backgroundColor: Colors.green,
        ),
      );
      context.pop();
    } else {
      final error = ref.read(addressProvider).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Gagal menyimpan alamat'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
