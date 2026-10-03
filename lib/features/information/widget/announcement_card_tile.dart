import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/announcement_model.dart';

class AnnouncementCardTile extends StatelessWidget {
  final AnnouncementModel announcement;
  final VoidCallback? onTap;

  const AnnouncementCardTile({
    super.key,
    required this.announcement,
    this.onTap,
  });

  Color _getCategoryColor() {
    switch (announcement.category) {
      case 'SPP':
        return const Color(0xFF3B82F6);
      case 'Infak':
        return const Color(0xFFF59E0B);
      case 'Uang Saku':
        return AppColors.primary;
      default:
        return const Color(0xFF64748B);
    }
  }

  Color _getCategoryBg() {
    switch (announcement.category) {
      case 'SPP':
        return const Color(0xFFEFF6FF);
      case 'Infak':
        return const Color(0xFFFFFBEB);
      case 'Uang Saku':
        return AppColors.primarySurface;
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  Color _getStatusColor() {
    switch (announcement.status) {
      case 'published':
        return AppColors.income;
      case 'draft':
        return const Color(0xFF94A3B8);
      case 'scheduled':
        return const Color(0xFF3B82F6);
      case 'expired':
        return AppColors.expense;
      case 'archived':
        return const Color(0xFF64748B);
      default:
        return const Color(0xFF94A3B8);
    }
  }

  String _getStatusLabel() {
    switch (announcement.status) {
      case 'published':
        return 'Dipublikasikan';
      case 'draft':
        return 'Draft';
      case 'scheduled':
        return 'Terjadwal';
      case 'expired':
        return 'Expired';
      case 'archived':
        return 'Diarsipkan';
      default:
        return announcement.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd MMM yyyy, HH:mm').format(
      announcement.publishedAt,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderLight),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Category badge + Status badge + Important
            Row(
              children: [
                // Category badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getCategoryBg(),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    announcement.category,
                    style: AppTypography.badgeText.copyWith(
                      color: _getCategoryColor(),
                      fontSize: 10,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getStatusLabel(),
                    style: AppTypography.badgeText.copyWith(
                      color: _getStatusColor(),
                      fontSize: 10,
                    ),
                  ),
                ),
                const Spacer(),
                if (announcement.isImportant)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.expenseSurface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.priority_high_rounded,
                          size: 12,
                          color: AppColors.expense,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          'Penting',
                          style: AppTypography.badgeText.copyWith(
                            color: AppColors.expense,
                            fontSize: 9,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Title
            Text(
              announcement.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.itemTitle.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 6),

            // Content preview
            Text(
              announcement.content,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.itemSubtitle.copyWith(
                fontSize: 12,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),

            // Footer: Author + Date
            Row(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.person_outlined,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    announcement.authorName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.badgeText.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.access_time_rounded,
                  size: 13,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 4),
                Text(
                  dateStr,
                  style: AppTypography.badgeText.copyWith(
                    color: Colors.grey.shade400,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
