import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widget/role_selection_card.dart';
import '../widget/role_selection_header.dart';

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
          const RoleSelectionHeader(),
          const SizedBox(height: 22),

          // 6 Role Cards (2 columns x 3 rows)
          Row(
            children: [
              Expanded(
                child: RoleSelectionCard(
                  title: _roles[0].title,
                  subtitle: _roles[0].subtitle,
                  icon: _roles[0].icon,
                  onTap: () => context.push('/login', extra: _roles[0].title),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RoleSelectionCard(
                  title: _roles[1].title,
                  subtitle: _roles[1].subtitle,
                  icon: _roles[1].icon,
                  onTap: () => context.push('/login', extra: _roles[1].title),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: RoleSelectionCard(
                  title: _roles[2].title,
                  subtitle: _roles[2].subtitle,
                  icon: _roles[2].icon,
                  onTap: () => context.push('/login', extra: _roles[2].title),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RoleSelectionCard(
                  title: _roles[3].title,
                  subtitle: _roles[3].subtitle,
                  icon: _roles[3].icon,
                  onTap: () => context.push('/login', extra: _roles[3].title),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: RoleSelectionCard(
                  title: _roles[4].title,
                  subtitle: _roles[4].subtitle,
                  icon: _roles[4].icon,
                  onTap: () => context.push('/login', extra: _roles[4].title),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RoleSelectionCard(
                  title: _roles[5].title,
                  subtitle: _roles[5].subtitle,
                  icon: _roles[5].icon,
                  onTap: () => context.push('/login', extra: _roles[5].title),
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
            colors: [Color(0xFFF2FAF6), Color(0xFFE8F7F0)],
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
