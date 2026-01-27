/// Register Screen with Riverpod
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/buttons.dart';
import '../../../shared/widgets/inputs.dart';
import '../../../app/routes.dart';
import '../providers/auth_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _referralController = TextEditingController();
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _referralController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Anda harus menyetujui syarat dan ketentuan'),
          ),
        );
        return;
      }

      final success = await ref
          .read(authProvider.notifier)
          .register(
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            email: _emailController.text.trim(),
            phone: _phoneController.text.trim(),
            password: _passwordController.text,
            passwordConfirmation: _confirmPasswordController.text,
            referralCode: _referralController.text.isEmpty
                ? null
                : _referralController.text.trim(),
          );

      if (success && mounted) {
        // Navigate to OTP verification or main
        context.go(AppRoutes.main);
      } else if (mounted) {
        final error = ref.read(authProvider).errorMessage;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error ?? 'Registrasi gagal')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.isLoading;

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
                // Title
                Text(
                  'Buat Akun',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Daftar untuk mulai berbelanja',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: MasagiColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 32),

                // First Name Field
                CustomTextField(
                  label: 'Nama Depan',
                  hint: 'Masukkan nama depan',
                  controller: _firstNameController,
                  keyboardType: TextInputType.name,
                  prefixIcon: const Icon(Icons.person_outline),
                  enabled: !isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama depan wajib diisi';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Last Name Field
                CustomTextField(
                  label: 'Nama Belakang',
                  hint: 'Masukkan nama belakang',
                  controller: _lastNameController,
                  keyboardType: TextInputType.name,
                  prefixIcon: const Icon(Icons.person_outline),
                  enabled: !isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama belakang wajib diisi';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Email Field
                CustomTextField(
                  label: 'Email',
                  hint: 'Masukkan email',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: const Icon(Icons.email_outlined),
                  enabled: !isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email wajib diisi';
                    }
                    if (!value.contains('@')) {
                      return 'Email tidak valid';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Phone Field
                CustomTextField(
                  label: 'Nomor HP',
                  hint: 'Contoh: 08123456789',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefixIcon: const Icon(Icons.phone_outlined),
                  enabled: !isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nomor HP wajib diisi';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Password Field
                CustomTextField(
                  label: 'Kata Sandi',
                  hint: 'Minimal 8 karakter',
                  controller: _passwordController,
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outline),
                  enabled: !isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kata sandi wajib diisi';
                    }
                    if (value.length < 8) {
                      return 'Kata sandi minimal 8 karakter';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Confirm Password Field
                CustomTextField(
                  label: 'Konfirmasi Kata Sandi',
                  hint: 'Ulangi kata sandi',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  prefixIcon: const Icon(Icons.lock_outline),
                  textInputAction: TextInputAction.done,
                  enabled: !isLoading,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Konfirmasi kata sandi wajib diisi';
                    }
                    if (value != _passwordController.text) {
                      return 'Kata sandi tidak cocok';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // Referral Code (Optional)
                CustomTextField(
                  label: 'Kode Referal (Opsional)',
                  hint: 'Masukkan kode referal',
                  controller: _referralController,
                  prefixIcon: const Icon(Icons.card_giftcard_outlined),
                  enabled: !isLoading,
                ),

                const SizedBox(height: 24),

                // Terms Checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _agreeToTerms,
                        onChanged: isLoading
                            ? null
                            : (value) {
                                setState(() => _agreeToTerms = value ?? false);
                              },
                        activeColor: MasagiColors.primaryGold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: GestureDetector(
                        onTap: isLoading
                            ? null
                            : () => setState(
                                () => _agreeToTerms = !_agreeToTerms,
                              ),
                        child: RichText(
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodySmall,
                            children: const [
                              TextSpan(text: 'Saya menyetujui '),
                              TextSpan(
                                text: 'Syarat dan Ketentuan',
                                style: TextStyle(
                                  color: MasagiColors.primaryGold,
                                ),
                              ),
                              TextSpan(text: ' serta '),
                              TextSpan(
                                text: 'Kebijakan Privasi',
                                style: TextStyle(
                                  color: MasagiColors.primaryGold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Register Button
                PrimaryButton(
                  text: 'Daftar',
                  isLoading: isLoading,
                  onPressed: isLoading ? null : _handleRegister,
                ),

                const SizedBox(height: 24),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Sudah punya akun? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: isLoading ? null : () => context.pop(),
                      child: const Text('Masuk'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
