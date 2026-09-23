import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class CustomCurvedBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomCurvedBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.only(top: 10, bottom: 12),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(0, Icons.home_rounded, 'Beranda'),
            _buildNavItem(1, Icons.history_rounded, 'Mutasi'),
            _buildNavItem(2, Icons.info_outline_rounded, 'Informasi'),
            _buildNavItem(3, Icons.chat_bubble_outline_rounded, 'CS SIKESAN'),
            _buildNavItem(4, Icons.person_outline_rounded, 'Profil'),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: AppColors.primary,
                  size: 22,
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  icon,
                  color: AppColors.textWhite,
                  size: 24,
                ),
              ),
            const SizedBox(height: 3),
            Text(
              label,
              style: AppTypography.badgeText.copyWith(
                color: isSelected ? AppColors.textWhite : AppColors.textWhite.withValues(alpha: 0.9),
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
