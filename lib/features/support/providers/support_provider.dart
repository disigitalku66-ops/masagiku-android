import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/ticket_model.dart';

// Mock data generator
final supportTicketsProvider = FutureProvider.autoDispose<List<Ticket>>((
  ref,
) async {
  // Simulate network delay
  await Future.delayed(const Duration(seconds: 1));

  return [
    Ticket(
      id: 'T-001',
      userId: 'user-1',
      subject: 'Pesanan belum sampai',
      category: 'Pesanan',
      description:
          'Saya memesan barang 3 hari lalu tapi status masih diproses.',
      status: TicketStatus.inProgress,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Ticket(
      id: 'T-002',
      userId: 'user-1',
      subject: 'Bagaimana cara ubah alamat?',
      category: 'Akun',
      description: 'Saya ingin mengubah alamat pengiriman utama saya.',
      status: TicketStatus.resolved,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      updatedAt: DateTime.now().subtract(const Duration(days: 4)),
    ),
  ];
});

class SupportNotifier extends StateNotifier<AsyncValue<void>> {
  SupportNotifier() : super(const AsyncValue.data(null));

  Future<void> createTicket(
    String subject,
    String category,
    String description,
  ) async {
    state = const AsyncValue.loading();
    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Success
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final supportActionProvider =
    StateNotifierProvider<SupportNotifier, AsyncValue<void>>((ref) {
      return SupportNotifier();
    });
