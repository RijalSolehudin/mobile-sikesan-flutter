import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/bill_history_model.dart';
import '../../spp/widget/pay_spp_modal.dart';
import '../../infaq/widget/pay_infaq_modal.dart';

class BillHistoryTile extends StatelessWidget {
  final BillHistoryModel bill;

  const BillHistoryTile({super.key, required this.bill});

  void _handleBillTap(BuildContext context) {
    if (bill.isUnpaid) {
      if (bill.billType == 'SPP') {
        PaySppModal.show(context);
      } else if (bill.billType == 'INFAQ') {
        PayInfaqModal.show(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Silakan hubungi bendahara untuk ${bill.title}.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else if (bill.isPending) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Pembayaran ${bill.title} sedang diverifikasi oleh admin / bendahara.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tagihan ${bill.title} untuk ${bill.studentName} sudah Lunas.',
          ),
          backgroundColor: AppColors.primaryDark,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Color iconBg;
    Color iconColor;
    IconData iconData;

    if (bill.billType == 'SPP') {
      iconBg = const Color(0xFFEFF6FF);
      iconColor = const Color(0xFF2563EB);
      iconData = Icons.calendar_month_rounded;
    } else if (bill.billType == 'INFAQ') {
      iconBg = const Color(0xFFECFDF5);
      iconColor = const Color(0xFF059669);
      iconData = Icons.volunteer_activism_rounded;
    } else {
      iconBg = const Color(0xFFF5F3FF);
      iconColor = const Color(0xFF7C3AED);
      iconData = Icons.school_rounded;
    }

    Color badgeBg;
    Color badgeText;
    IconData badgeIcon;

    if (bill.isPaid) {
      badgeBg = const Color(0xFFDCFCE7);
      badgeText = const Color(0xFF15803D);
      badgeIcon = Icons.check_circle_rounded;
    } else if (bill.isPending) {
      badgeBg = const Color(0xFFFEF3C7);
      badgeText = const Color(0xFFB45309);
      badgeIcon = Icons.schedule_rounded;
    } else {
      badgeBg = const Color(0xFFFEE2E2);
      badgeText = const Color(0xFFB91C1C);
      badgeIcon = Icons.error_outline_rounded;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _handleBillTap(context),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(iconData, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bill.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.itemTitle.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${bill.studentName} • ${bill.studentClass}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.itemSubtitle.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    CurrencyFormatter.format(bill.amountBilled),
                    style: AppTypography.itemTitle.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(badgeIcon, size: 11, color: badgeText),
                        const SizedBox(width: 3.5),
                        Text(
                          bill.statusLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: badgeText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
