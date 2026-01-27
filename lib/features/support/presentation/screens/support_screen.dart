import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/colors.dart';
import '../../providers/support_provider.dart';
import '../../data/models/ticket_model.dart';
import '../../../../app/routes.dart';

class SupportScreen extends ConsumerWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketsAsync = ref.watch(supportTicketsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bantuan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('${AppRoutes.support}/buat'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildQuickActions(),
            const Divider(thickness: 8, color: Colors.black12),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: const Text(
                'Tiket Saya',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            ticketsAsync.when(
              data: (tickets) {
                if (tickets.isEmpty) {
                  return const Center(child: Text('Belum ada tiket bantuan'));
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    final ticket = tickets[index];
                    return _TicketCard(ticket: ticket);
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
            const Divider(thickness: 8, color: Colors.black12),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: const Text(
                'FAQ',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildFaqItem('Cara melakukan pemesanan'),
            _buildFaqItem('Metode pembayaran yang tersedia'),
            _buildFaqItem('Kebijakan pengembalian barang'),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildActionItem(Icons.chat_bubble_outline, 'Chat CS', () {}),
          _buildActionItem(Icons.email_outlined, 'Email', () {}),
          _buildActionItem(Icons.phone_outlined, 'Call Center', () {}),
        ],
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: MasagiColors.primaryGold.withValues(alpha: 0.1),
            child: Icon(icon, color: MasagiColors.primaryGold),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String title) {
    return ExpansionTile(
      title: Text(title),
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }
}

class _TicketCard extends StatelessWidget {
  final Ticket ticket;

  const _TicketCard({required this.ticket});

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusText;

    switch (ticket.status) {
      case TicketStatus.open:
        statusColor = Colors.blue;
        statusText = 'Baru';
        break;
      case TicketStatus.inProgress:
        statusColor = Colors.orange;
        statusText = 'Diproses';
        break;
      case TicketStatus.resolved:
        statusColor = Colors.green;
        statusText = 'Selesai';
        break;
      case TicketStatus.closed:
        statusColor = Colors.grey;
        statusText = 'Ditutup';
        break;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '#${ticket.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(color: statusColor, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              ticket.subject,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              ticket.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat('dd MMM yyyy, HH:mm').format(ticket.createdAt),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
