import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  static const List<({String title, String subtitle, IconData icon})> _roles = [
    (
      title: 'Admin',
      subtitle: 'Masuk sebagai Admin',
      icon: Icons.manage_accounts_rounded,
    ),
    (
      title: 'Bendahara',
      subtitle: 'Masuk sebagai Bendahara',
      icon: Icons.savings_outlined,
    ),
    (
      title: 'Kesantrian',
      subtitle: 'Masuk sebagai Kesantrian',
      icon: Icons.school_outlined,
    ),
    (
      title: 'Kasir',
      subtitle: 'Masuk sebagai Kasir',
      icon: Icons.point_of_sale_rounded,
    ),
    (
      title: 'Wali Asrama',
      subtitle: 'Masuk sebagai Wali Asrama',
      icon: Icons.home_outlined,
    ),
    (
      title: 'Wali Santri',
      subtitle: 'Masuk sebagai Wali Santri',
      icon: Icons.person_rounded,
    ),
  ];

  Widget _buildRoleCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Navigasi langsung ke form login dengan role yang dipilih
          context.push('/login', extra: title);
        },
        borderRadius: BorderRadius.circular(16),
        splashColor: const Color(0xFF059669).withValues(alpha: 0.1),
        highlightColor: const Color(0xFF059669).withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F7EE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF059669),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCardContainer(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Small Badge SIKESAN
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F7EE),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.account_balance_wallet_rounded,
                  size: 13,
                  color: Color(0xFF059669),
                ),
                const SizedBox(width: 5),
                Text(
                  'SIKESAN',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF059669),
                    letterSpacing: 0.6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Title
          Text(
            'Pilih Role Anda',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 6),

          // Subtitle
          Text(
            'Silakan pilih peran sesuai hak akses untuk melanjutkan ke halaman login.',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF64748B),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 22),

          // 6 Role Cards (2 columns x 3 rows)
          Row(
            children: [
              Expanded(
                child: _buildRoleCard(
                  context: context,
                  title: _roles[0].title,
                  subtitle: _roles[0].subtitle,
                  icon: _roles[0].icon,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildRoleCard(
                  context: context,
                  title: _roles[1].title,
                  subtitle: _roles[1].subtitle,
                  icon: _roles[1].icon,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildRoleCard(
                  context: context,
                  title: _roles[2].title,
                  subtitle: _roles[2].subtitle,
                  icon: _roles[2].icon,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildRoleCard(
                  context: context,
                  title: _roles[3].title,
                  subtitle: _roles[3].subtitle,
                  icon: _roles[3].icon,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildRoleCard(
                  context: context,
                  title: _roles[4].title,
                  subtitle: _roles[4].subtitle,
                  icon: _roles[4].icon,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildRoleCard(
                  context: context,
                  title: _roles[5].title,
                  subtitle: _roles[5].subtitle,
                  icon: _roles[5].icon,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF2FAF6),
              Color(0xFFE8F7F0),
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 580),
                child: _buildRoleCardContainer(context),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
