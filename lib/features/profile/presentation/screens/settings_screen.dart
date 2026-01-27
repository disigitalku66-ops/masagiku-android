import 'package:flutter/material.dart';
import '../../../../core/constants/colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Notifikasi'),
            subtitle: const Text('Terima update status pesanan dan promo'),
            value: _notificationsEnabled,
            onChanged: (val) => setState(() => _notificationsEnabled = val),
            activeThumbColor: MasagiColors.primaryGold,
          ),
          const Divider(),
          ListTile(
            title: const Text('Bahasa'),
            subtitle: const Text('Indonesia'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Note: Language selection pending next phase
            },
          ),
          ListTile(
            title: const Text('Kebijakan Privasi'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Note: Open Privacy Policy pending next phase
            },
          ),
          ListTile(
            title: const Text('Syarat & Ketentuan'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Note: Open Terms pending next phase
            },
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Versi Aplikasi 1.0.0',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
