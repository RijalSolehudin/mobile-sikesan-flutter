import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import 'bloc/auth_bloc.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap masukkan username dan password Anda'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
          AuthLoginRequested(
            username: username,
            password: password,
          ),
        );
  }

  void _fillSampleCredentials(String username, String password) {
    setState(() {
      _usernameController.text = username;
      _passwordController.text = password;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Gagal masuk akun'),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state.isLoading;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SingleChildScrollView(
            child: Column(
              children: [
                // Top Green Hero Section
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [AppColors.primaryDark, AppColors.primary],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 76, 24, 36),
                  child: Column(
                    children: [
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
                          color: AppColors.primary,
                          size: 34,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'SIKESAN Mobile',
                        style: AppTypography.headerTitle.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sistem Keuangan Santri Terintegrasi',
                        style: AppTypography.headerSubtitle.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                ),

                // Login Form Container
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Masuk ke Akun Anda', style: AppTypography.sectionTitle.copyWith(fontSize: 18)),
                      const SizedBox(height: 6),
                      Text(
                        'Gunakan username dan password yang diberikan oleh admin pesantren.',
                        style: AppTypography.itemSubtitle,
                      ),
                      const SizedBox(height: 24),

                      // Username Input
                      Text('Username', style: AppTypography.itemTitle.copyWith(fontSize: 13)),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: _usernameController,
                        hintText: 'Masukkan username',
                        prefixIcon: const Icon(Icons.person_outline_rounded, color: AppColors.textMuted, size: 20),
                        enabled: !isLoading,
                      ),
                      const SizedBox(height: 16),

                      // Password Input
                      Text('Password', style: AppTypography.itemTitle.copyWith(fontSize: 13)),
                      const SizedBox(height: 8),
                      CustomTextField(
                        controller: _passwordController,
                        hintText: 'Masukkan password',
                        obscureText: _obscurePassword,
                        enabled: !isLoading,
                        prefixIcon: const Icon(Icons.lock_outline_rounded, color: AppColors.textMuted, size: 20),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                            color: AppColors.textMuted,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: CustomButton(
                          text: 'Masuk Sekarang',
                          isLoading: isLoading,
                          onPressed: isLoading ? null : _handleLogin,
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Quick Test / Demo Credentials Shortcut
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Text(
                                  'Akun Uji Coba Cepat (Presets)',
                                  style: AppTypography.itemTitle.copyWith(fontSize: 12),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                ActionChip(
                                  label: const Text('Wali Santri', style: TextStyle(fontSize: 11)),
                                  backgroundColor: Colors.white,
                                  onPressed: () => _fillSampleCredentials('wali_123', 'password123'),
                                ),
                                ActionChip(
                                  label: const Text('Kasir', style: TextStyle(fontSize: 11)),
                                  backgroundColor: Colors.white,
                                  onPressed: () => _fillSampleCredentials('kasir_utama', 'password123'),
                                ),
                                ActionChip(
                                  label: const Text('Bendahara', style: TextStyle(fontSize: 11)),
                                  backgroundColor: Colors.white,
                                  onPressed: () => _fillSampleCredentials('bendahara_pesantren', 'password123'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
