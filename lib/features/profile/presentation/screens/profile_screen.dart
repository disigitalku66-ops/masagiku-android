import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../app/routes.dart';
import '../../../../core/constants/colors.dart';
import '../../../auth/providers/auth_providers.dart';
import '../widgets/profile_menu_item.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(authProvider);
    final user = userState.user;
    final isLoggedIn = user != null;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header / App Bar
          SliverAppBar(
            pinned: true,
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [MasagiColors.primary, MasagiColors.primaryNavy],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    // Avatar
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        backgroundImage: isLoggedIn && user.image != null
                            ? CachedNetworkImageProvider(user.image!)
                            : null,
                        child: !isLoggedIn || user.image == null
                            ? Icon(
                                isLoggedIn
                                    ? Icons.person
                                    : Icons.person_outline,
                                size: 40,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Name
                    Text(
                      isLoggedIn ? user.name : 'Tamu',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Email/Phone
                    if (isLoggedIn)
                      Text(
                        user.email.isNotEmpty
                            ? user.email
                            : (user.phone ?? '-'),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: ElevatedButton(
                          onPressed: () => context.go(AppRoutes.login),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: MasagiColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text('Masuk / Daftar'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Menu List
          SliverList(
            delegate: SliverChildListDelegate([
              const SizedBox(height: 16),

              if (isLoggedIn) ...[
                // Account Section
                _SectionHeader(title: 'Akun Saya'),

                ProfileMenuItem(
                  icon: Icons.person_outline,
                  title: 'Edit Profil',
                  onTap: () => context.push(AppRoutes.editProfile),
                ),
                ProfileMenuItem(
                  icon: Icons.location_on_outlined,
                  title: 'Alamat Saya',
                  onTap: () => context.push(AppRoutes.addresses),
                ),

                const Divider(height: 32),

                // Transaction Section
                _SectionHeader(title: 'Transaksi'),

                ProfileMenuItem(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Pesanan Saya',
                  onTap: () => context.push(AppRoutes.orders),
                ),
                ProfileMenuItem(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Dompet Saya',
                  onTap: () => context.push(AppRoutes.wallet),
                ),
                ProfileMenuItem(
                  icon: Icons.loyalty_outlined,
                  title: 'Masagi Point (Coming Soon)',
                  onTap: () => context.push(AppRoutes.loyalty),
                  iconColor: Colors.amber,
                ),

                const Divider(height: 32),
              ],

              // General Section
              _SectionHeader(title: 'Umum'),

              ProfileMenuItem(
                icon: Icons.settings_outlined,
                title: 'Pengaturan',
                onTap: () => context.push(AppRoutes.settings),
              ),
              ProfileMenuItem(
                icon: Icons.help_outline,
                title: 'Bantuan & Dukungan',
                onTap: () => context.push(AppRoutes.support),
              ),

              if (isLoggedIn) ...[
                const Divider(height: 32),
                ProfileMenuItem(
                  icon: Icons.logout,
                  title: 'Keluar',
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Keluar Aplikasi?'),
                        content: const Text(
                          'Apakah Anda yakin ingin keluar dari akun ini?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text(
                              'Keluar',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) {
                        context.go(AppRoutes.login);
                      }
                    }
                  },
                  textColor: Colors.red,
                  iconColor: Colors.red,
                  showArrow: false,
                ),
              ],

              const SizedBox(height: 40),
              Center(
                child: Text(
                  'Versi 1.0.0',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ),
              const SizedBox(height: 40),
            ]),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: MasagiColors.textSecondary,
        ),
      ),
    );
  }
}
