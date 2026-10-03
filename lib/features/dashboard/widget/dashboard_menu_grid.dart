import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/menu_item_model.dart';
import '../../spp/widget/pay_spp_modal.dart';
import '../../wallet/widget/top_up_modal.dart';
import '../../wallet/widget/withdraw_modal.dart';
import '../../infaq/widget/pay_infaq_modal.dart';
import '../../../core/widgets/app_snackbar.dart';

class DashboardMenuGrid extends StatelessWidget {
  final List<MenuItemModel> displayedMenus;
  final bool isMenuExpanded;
  final bool isWide;
  final int crossAxisCount;
  final double childAspectRatio;
  final int totalMenuCount;
  final VoidCallback onToggleExpanded;

  const DashboardMenuGrid({
    super.key,
    required this.displayedMenus,
    required this.isMenuExpanded,
    required this.isWide,
    required this.crossAxisCount,
    required this.childAspectRatio,
    required this.totalMenuCount,
    required this.onToggleExpanded,
  });

  void _handleMenuTap(BuildContext context, MenuItemModel menu) {
    final titleLower = menu.title.toLowerCase();
    if (titleLower.contains('spp')) {
      PaySppModal.show(context);
    } else if (menu.id == 'top_up' || titleLower.contains('top up')) {
      TopUpModal.show(context);
    } else if (menu.id == 'uang_keluar' ||
        titleLower.contains('uang keluar') ||
        titleLower.contains('tarik')) {
      WithdrawModal.show(context);
    } else if (menu.id == 'infak' ||
        titleLower.contains('infak') ||
        titleLower.contains('infaq')) {
      PayInfaqModal.show(context);
    } else if (menu.id == 'kwitansi' || titleLower.contains('kwitansi')) {
      context.push('/home/kwitansi');
    } else {
      AppSnackBar.showInfo(context, 'Menu ${menu.title} sedang disiapkan.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Menu Utama Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Menu Utama', style: AppTypography.sectionTitle),
            if (!isWide && totalMenuCount > 8)
              GestureDetector(
                onTap: onToggleExpanded,
                child: Row(
                  children: [
                    Text(
                      isMenuExpanded ? 'Lihat Lebih Sedikit' : 'Lihat Semua',
                      style: AppTypography.itemSubtitle.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Icon(
                      isMenuExpanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppColors.primary,
                      size: 18,
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Menu Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayedMenus.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 10,
            childAspectRatio: childAspectRatio,
          ),
          itemBuilder: (context, index) {
            final menu = displayedMenus[index];
            return GestureDetector(
              onTap: () => _handleMenuTap(context, menu),
              child: Column(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: menu.bg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(menu.icon, color: menu.color, size: 24),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    menu.title,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.itemTitle.copyWith(
                      fontSize: 10.5,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
