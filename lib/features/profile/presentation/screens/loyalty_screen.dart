import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class LoyaltyScreen extends StatelessWidget {
  const LoyaltyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Masagi Points')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [MasagiColors.primaryGold, Color(0xFFFFCA28)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: MasagiColors.primaryGold.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Poin Anda',
                    style: TextStyle(
                      color: MasagiColors.textOnGold,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '100', // Example
                    style: TextStyle(
                      color: MasagiColors.textOnGold,
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Member Gold',
                      style: TextStyle(
                        color: MasagiColors.textOnGold,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const ListTile(
              leading: Icon(
                Icons.star_outline,
                color: MasagiColors.primaryGold,
              ),
              title: Text('Cara mendapatkan poin'),
              trailing: Icon(Icons.chevron_right),
            ),
            const Divider(),
            const ListTile(
              leading: Icon(
                Icons.card_giftcard,
                color: MasagiColors.primaryGold,
              ),
              title: Text('Tukar poin'),
              trailing: Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }
}
