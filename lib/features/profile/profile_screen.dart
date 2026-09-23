import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/avatar_icon.dart';
import '../auth/bloc/auth_bloc.dart';

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
    final userRole = user?.role.isNotEmpty == true ? user!.role.toUpperCase() : 'WALI SANTRI';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Green Profile Header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
              ),
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
              child: Column(
                children: [
                  // Title
                  Center(
                    child: Text(
                      'PROFIL SAYA',
                      style: AppTypography.headerTitle.copyWith(
                        fontSize: 16,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Avatar with Camera Edit Badge
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      const MosqueAvatar(size: 90),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: AppColors.primary,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // User name & Role badge
                  Text(userName, style: AppTypography.headerTitle.copyWith(fontSize: 20)),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      userRole,
                      style: AppTypography.badgeText.copyWith(
                        color: Colors.white,
                        letterSpacing: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Profile Menus Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                children: [
                  _buildMenuTile(
                    icon: Icons.person_outline_rounded,
                    iconBg: AppColors.primarySurface,
                    iconColor: AppColors.primary,
                    title: 'Informasi Akun',
                    subtitle: 'Lihat dan ubah informasi akun',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),

                  _buildMenuTile(
                    icon: Icons.lock_outline_rounded,
                    iconBg: const Color(0xFFF3E8FF),
                    iconColor: AppColors.iconPurple,
                    title: 'Ubah Password',
                    subtitle: 'Perbarui password akun',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),

                  _buildMenuTile(
                    icon: Icons.help_outline_rounded,
                    iconBg: const Color(0xFFE0F2FE),
                    iconColor: AppColors.iconBlue,
                    title: 'Bantuan',
                    subtitle: 'Panduan penggunaan aplikasi',
                    onTap: () {},
                  ),
                  const SizedBox(height: 12),

                  // Mode Tampilan Toggle Card
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.wb_sunny_outlined, color: AppColors.iconOrange, size: 22),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Mode Tampilan', style: AppTypography.itemTitle),
                              const SizedBox(height: 2),
                              Text(
                                _isDarkMode ? 'Mode Gelap' : 'Mode Terang',
                                style: AppTypography.itemSubtitle,
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isDarkMode,
                          activeThumbColor: AppColors.primary,
                          onChanged: (val) => setState(() => _isDarkMode = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Solid Red Logout Button Card
                  GestureDetector(
                    onTap: () {
                      _showLogoutDialog(context);
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: BoxDecoration(
                        color: AppColors.expense,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.expense.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.logout_rounded, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Logout',
                                  style: AppTypography.itemTitle.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Keluar dari akun Anda',
                                  style: AppTypography.itemSubtitle.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTypography.itemTitle),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTypography.itemSubtitle),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Konfirmasi Logout'),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi SIKESAN?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.expense,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
