import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class MenuItemModel {
  final String id;
  final String title;
  final IconData icon;
  final Color color;
  final Color bg;
  final String? route;
  final List<String> allowedRoles;
  final bool isEnabled;

  const MenuItemModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.color,
    required this.bg,
    this.route,
    this.allowedRoles = const [],
    this.isEnabled = true,
  });

  bool isVisibleForRole(String role) {
    if (!isEnabled) return false;
    if (allowedRoles.isEmpty) return true;
    final normalized = role.toLowerCase();
    return allowedRoles.any(
      (r) =>
          r.toLowerCase() == normalized || normalized.contains(r.toLowerCase()),
    );
  }

  // Pre-configured default list of all available menus in SIKESAN Mobile
  static List<MenuItemModel> defaultMenus() {
    return [
      const MenuItemModel(
        id: 'top_up',
        title: 'Top Up Saldo',
        icon: Icons.arrow_upward_rounded,
        color: AppColors.primary,
        bg: AppColors.primarySurface,
        allowedRoles: [
          'Wali Santri',
          'Super Admin',
          'Admin',
          'Bendahara',
          'Kasir',
        ],
      ),
      const MenuItemModel(
        id: 'rek_wali_asrama',
        title: 'Rekening Wali Asrama',
        icon: Icons.apartment_rounded,
        color: AppColors.iconBlue,
        bg: Color(0xFFDBEAFE),
        allowedRoles: ['Staff Kesantrian', 'Super Admin', 'Admin', 'Bendahara'],
      ),
      const MenuItemModel(
        id: 'infak',
        title: 'Infak Kesantrian',
        icon: Icons.favorite_outline_rounded,
        color: AppColors.iconOrange,
        bg: Color(0xFFFFEDD5),
        allowedRoles: ['Wali Santri', 'Super Admin', 'Admin', 'Bendahara'],
      ),
      const MenuItemModel(
        id: 'rek_kesantrian',
        title: 'Rekening Kesantrian',
        icon: Icons.account_balance_rounded,
        color: AppColors.iconPurple,
        bg: Color(0xFFEDE9FE),
        allowedRoles: ['Staff Kesantrian', 'Super Admin', 'Admin', 'Bendahara'],
      ),
      const MenuItemModel(
        id: 'uang_keluar',
        title: 'Uang Keluar',
        icon: Icons.arrow_downward_rounded,
        color: AppColors.expense,
        bg: AppColors.expenseSurface,
        allowedRoles: ['Kasir', 'Super Admin', 'Admin', 'Bendahara'],
      ),
      const MenuItemModel(
        id: 'data_santri',
        title: 'Data Santri',
        icon: Icons.people_rounded,
        color: AppColors.iconBlue,
        bg: Color(0xFFDBEAFE),
        allowedRoles: ['Staff Kesantrian', 'Super Admin', 'Admin', 'Bendahara'],
      ),
      const MenuItemModel(
        id: 'sistem_kasir',
        title: 'Sistem Kasir',
        icon: Icons.shopping_cart_rounded,
        color: Color(0xFF0D9488),
        bg: Color(0xFFCCFBF1),
        allowedRoles: ['Kasir', 'Super Admin', 'Admin'],
      ),
      const MenuItemModel(
        id: 'kwitansi',
        title: 'Kwitansi Digital',
        icon: Icons.receipt_long_rounded,
        color: Color(0xFF059669),
        bg: Color(0xFFD1FAE5),
        allowedRoles: [
          'Wali Santri',
          'Kasir',
          'Super Admin',
          'Admin',
          'Bendahara',
        ],
      ),
      const MenuItemModel(
        id: 'bayar_spp',
        title: 'Bayar SPP',
        icon: Icons.account_balance_wallet_rounded,
        color: Color(0xFF0D9488),
        bg: Color(0xFFCCFBF1),
        allowedRoles: ['Wali Santri', 'Super Admin', 'Admin', 'Bendahara'],
      ),
      const MenuItemModel(
        id: 'akun_staff',
        title: 'Akun Staff',
        icon: Icons.person_rounded,
        color: AppColors.iconBlue,
        bg: Color(0xFFDBEAFE),
        allowedRoles: ['Super Admin', 'Admin', 'Bendahara'],
      ),
      const MenuItemModel(
        id: 'settings',
        title: 'Settings',
        icon: Icons.settings_rounded,
        color: AppColors.textSecondary,
        bg: Color(0xFFF1F5F9),
        allowedRoles: ['Super Admin', 'Admin'],
      ),
    ];
  }
}
