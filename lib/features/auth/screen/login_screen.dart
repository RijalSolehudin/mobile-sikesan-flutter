import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../bloc/auth_bloc.dart';
import '../widget/login_branding_card.dart';
import '../widget/login_form.dart';

class LoginScreen extends StatefulWidget {
  final String? initialRole;

  const LoginScreen({super.key, this.initialRole});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late String _selectedRole;

  final Map<String, ({String title, String description, IconData icon})>
  _rolesData = {
    'Admin': (
      title: 'Admin',
      description: 'Akses penuh ke seluruh fitur dan pengaturan sistem.',
      icon: Icons.manage_accounts_rounded,
    ),
    'Bendahara': (
      title: 'Bendahara',
      description:
          'Pengelolaan keuangan, kasir, verifikasi tagihan, dan laporan pembukuan.',
      icon: Icons.savings_outlined,
    ),
    'Kesantrian': (
      title: 'Kesantrian',
      description:
          'Pengelolaan kegiatan santri, perizinan, dan kedisiplinan santri.',
      icon: Icons.school_outlined,
    ),
    'Kasir': (
      title: 'Kasir',
      description:
          'Layanan kasir langsung untuk pembayaran SPP dan tabungan santri.',
      icon: Icons.point_of_sale_rounded,
    ),
    'Wali Asrama': (
      title: 'Wali Asrama',
      description:
          'Pembinaan santri asrama, absensi harian, dan monitoring kamar.',
      icon: Icons.home_outlined,
    ),
    'Wali Santri': (
      title: 'Wali Santri',
      description:
          'Akses informasi keuangan santri, pembayaran tagihan, dan saldo dompet.',
      icon: Icons.person_rounded,
    ),
  };

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole ?? 'Admin';
    if (!_rolesData.containsKey(_selectedRole)) {
      _selectedRole = 'Admin';
    }
  }

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
      AppSnackBar.showError(
        context,
        'Harap masukkan username dan password Anda',
      );
      return;
    }

    context.read<AuthBloc>().add(
      AuthLoginRequested(username: username, password: password),
    );
  }

  void _handleBackToRole() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      context.go('/role-selection');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        state.whenOrNull(
          failure: (message) {
            AppSnackBar.showError(context, message);
          },
        );
      },
      builder: (context, state) {
        final isLoading = state.isLoading;
        final currentRoleData =
            _rolesData[_selectedRole] ?? _rolesData['Admin']!;

        return LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 850;

            if (isWide) {
              return Scaffold(
                backgroundColor: const Color(0xFFF0FDF4),
                body: SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 36,
                      ),
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1080),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Expanded(
                              flex: 5,
                              child: LoginBrandingCard(isWide: true),
                            ),
                            const SizedBox(width: 32),
                            Expanded(
                              flex: 6,
                              child: LoginForm(
                                roleData: currentRoleData,
                                isLoading: isLoading,
                                isWide: true,
                                usernameController: _usernameController,
                                passwordController: _passwordController,
                                onSubmit: _handleLogin,
                                onBackToRole: _handleBackToRole,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }

            return Scaffold(
              backgroundColor: const Color(0xFFF0FDF4),
              body: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const LoginBrandingCard(isWide: false),
                      const SizedBox(height: 14),
                      LoginForm(
                        roleData: currentRoleData,
                        isLoading: isLoading,
                        isWide: false,
                        usernameController: _usernameController,
                        passwordController: _passwordController,
                        onSubmit: _handleLogin,
                        onBackToRole: _handleBackToRole,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
