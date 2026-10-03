import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../widget/profile_header.dart';
import '../widget/profile_menu_tile.dart';
import '../widget/profile_theme_toggle.dart';
import '../widget/profile_logout_button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState.user;
    final userName = user?.name.isNotEmpty == true ? user!.name : 'Pengguna';
    final userRole = user?.role.isNotEmpty == true
        ? user!.role.toUpperCase()
        : 'WALI SANTRI';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            ProfileHeader(userName: userName, userRole: userRole),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 20,
                  ),
                  child: Column(
                    children: [
                      ProfileMenuTile(
                        icon: Icons.person_outline_rounded,
                        iconBg: AppColors.primarySurface,
                        iconColor: AppColors.primary,
                        title: 'Informasi Akun',
                        subtitle: 'Lihat dan ubah informasi akun',
                        onTap: () {
                          AppSnackBar.showInfo(
                            context,
                            'Halaman Informasi Akun segera hadir.',
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      ProfileMenuTile(
                        icon: Icons.lock_outline_rounded,
                        iconBg: const Color(0xFFF3E8FF),
                        iconColor: AppColors.iconPurple,
                        title: 'Ubah Password',
                        subtitle: 'Perbarui password akun',
                        onTap: () {
                          AppSnackBar.showInfo(
                            context,
                            'Halaman Ubah Password segera hadir.',
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      ProfileMenuTile(
                        icon: Icons.help_outline_rounded,
                        iconBg: const Color(0xFFE0F2FE),
                        iconColor: AppColors.iconBlue,
                        title: 'Bantuan',
                        subtitle: 'Panduan penggunaan aplikasi',
                        onTap: () {
                          AppSnackBar.showInfo(
                            context,
                            'Pusat Bantuan segera hadir.',
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      ProfileThemeToggle(
                        isDarkMode: _isDarkMode,
                        onChanged: (val) => setState(() => _isDarkMode = val),
                      ),
                      const SizedBox(height: 20),
                      const ProfileLogoutButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
