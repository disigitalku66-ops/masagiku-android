/// Forgot Password Screen
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/inputs.dart';
import '../providers/auth_providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendReset() async {
    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref
          .read(forgotPasswordProvider.notifier)
          .sendResetLink(_emailController.text.trim());

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Link reset password telah dikirim ke email Anda'),
            backgroundColor: MasagiColors.success,
          ),
        );
        context.pop();
      } else if (mounted) {
        final error = ref.read(forgotPasswordProvider).errorMessage;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error ?? 'Gagal mengirim reset password')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fpState = ref.watch(forgotPasswordProvider);
    final isLoading = fpState.isLoading;

    return Scaffold(
      backgroundColor: MasagiColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: isLoading ? null : () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.spacingLg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 24),

                // Icon
                Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: MasagiColors.gold50,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.lock_reset,
                      color: MasagiColors.primaryGold,
                      size: 40,
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Title
                Text(
                  'Lupa Kata Sandi?',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Masukkan email atau nomor HP yang terdaftar. Kami akan mengirimkan link untuk reset kata sandi.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: MasagiColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Email/Phone Field
                CustomTextField(
                  label: 'Email atau Nomor HP',
                  hint: 'Masukkan email atau nomor HP',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  enabled: !isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email atau nomor HP wajib diisi';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                // Submit Button
                PrimaryButton(
                  text: 'Kirim Link Reset',
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _handleSendReset,
                ),

                const SizedBox(height: 24),

                // Back to Login
                Center(
                  child: TextButton.icon(
                    onPressed: isLoading ? null : () => context.pop(),
                    icon: const Icon(Icons.arrow_back, size: 16),
                    label: const Text('Kembali ke Login'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
