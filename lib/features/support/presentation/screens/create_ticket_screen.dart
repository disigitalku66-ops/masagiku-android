import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/support_provider.dart';

class CreateTicketScreen extends ConsumerStatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  ConsumerState<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends ConsumerState<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _subjectController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedCategory = 'Pesanan';

  final List<String> _categories = [
    'Pesanan',
    'Akun',
    'Pembayaran',
    'Pengiriman',
    'Produk',
    'Lainnya',
  ];

  @override
  void dispose() {
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submitTicket() async {
    if (_formKey.currentState!.validate()) {
      await ref
          .read(supportActionProvider.notifier)
          .createTicket(
            _subjectController.text,
            _selectedCategory,
            _descriptionController.text,
          );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Tiket berhasil dibuat')));
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final supportState = ref.watch(supportActionProvider);
    final isLoading = supportState is AsyncLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Buat Tiket Baru')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(value: category, child: Text(category));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Subjek',
                border: OutlineInputBorder(),
                hintText: 'Contoh: Pesanan belum sampai',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Subjek tidak boleh kosong';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Deskripsi Masalah',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Deskripsi tidak boleh kosong';
                }
                if (value.length < 10) {
                  return 'Deskripsi terlalu pendek (min 10 karakter)';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : _submitTicket,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Kirim Tiket'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
