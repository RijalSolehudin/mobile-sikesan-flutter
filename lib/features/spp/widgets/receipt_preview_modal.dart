import 'package:flutter/material.dart';
import '../../../core/services/receipt_pdf_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/spp_models.dart';

class ReceiptPreviewModal extends StatelessWidget {
  final SppReceiptModel receipt;

  const ReceiptPreviewModal({
    super.key,
    required this.receipt,
  });

  static Future<void> show(BuildContext context, SppReceiptModel receipt) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReceiptPreviewModal(receipt: receipt),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isApproved = receipt.status.toUpperCase() == 'APPROVED';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Kwitansi Pembayaran',
                    style: AppTypography.headerTitle.copyWith(
                      fontSize: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    receipt.receiptNumber,
                    style: AppTypography.itemSubtitle.copyWith(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded, size: 20, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Struk Digital Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Badge Status
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pondok Pesantren SIKESAN',
                      style: AppTypography.itemTitle.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: isApproved ? const Color(0xFFECFDF5) : const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isApproved ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                        ),
                      ),
                      child: Text(
                        isApproved ? 'LUNAS' : 'MENUNGGU VERIFIKASI',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: isApproved ? const Color(0xFF047857) : const Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 12),

                // Data Santri
                _buildRow('Santri', receipt.studentName),
                const SizedBox(height: 4),
                _buildRow('NIS / Kelas', '${receipt.studentNis} • ${receipt.studentClass}'),
                const SizedBox(height: 4),
                _buildRow('Waktu', '${receipt.paymentDate} • ${receipt.paymentTime}'),
                const SizedBox(height: 4),
                _buildRow('Metode', receipt.paymentMethod.toUpperCase()),
                const SizedBox(height: 12),

                // Daftar Bulan
                Text(
                  'Rincian Bulan SPP:',
                  style: AppTypography.itemTitle.copyWith(fontSize: 11.5, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 6),
                ...receipt.bills.map((b) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('• ${b.monthName} ${b.year}', style: AppTypography.itemSubtitle.copyWith(fontSize: 11)),
                          Text(
                            CurrencyFormatter.format(b.amount),
                            style: AppTypography.itemTitle.copyWith(fontSize: 11.5, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 12),
                const Divider(height: 1, color: Color(0xFFE2E8F0)),
                const SizedBox(height: 12),

                // Total
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Dibayar',
                      style: AppTypography.itemTitle.copyWith(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    Text(
                      CurrencyFormatter.format(receipt.totalPaidAmount),
                      style: AppTypography.itemTitle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF5B58EB),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Two Action Buttons: Unduh PDF & Print PDF
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await ReceiptPdfService.downloadReceipt(receipt);
                  },
                  icon: const Icon(Icons.download_rounded, size: 18, color: Color(0xFF5B58EB)),
                  label: const Text(
                    'Unduh PDF',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF5B58EB),
                      fontSize: 13,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFF5B58EB), width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await ReceiptPdfService.printReceipt(receipt);
                  },
                  icon: const Icon(Icons.print_rounded, size: 18, color: Colors.white),
                  label: const Text(
                    'Print PDF',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5B58EB),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.itemSubtitle.copyWith(fontSize: 11)),
        Text(
          value,
          style: AppTypography.itemTitle.copyWith(fontSize: 11.5, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
