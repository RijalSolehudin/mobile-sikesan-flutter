import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/spp_models.dart';

/// Komponen Bagian Metode Pembayaran SPP (Rekening Bank, QRIS, & Upload Bukti)
/// Memenuhi TASK-CONC-02 untuk modularitas UI
class SppPaymentMethodSection extends StatelessWidget {
  final bool isGuardian;
  final String selectedPaymentMethod;
  final ValueChanged<String> onPaymentMethodChanged;
  final List<BankAccountModel> bankAccounts;
  final Uint8List? proofBytes;
  final String? proofFilename;
  final void Function(String number, String bank) onCopyAccount;
  final VoidCallback onShowQris;
  final VoidCallback onPickProof;

  const SppPaymentMethodSection({
    super.key,
    required this.isGuardian,
    required this.selectedPaymentMethod,
    required this.onPaymentMethodChanged,
    required this.bankAccounts,
    required this.proofBytes,
    required this.proofFilename,
    required this.onCopyAccount,
    required this.onShowQris,
    required this.onPickProof,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Metode Pembayaran',
              style: AppTypography.itemTitle.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (isGuardian) ...[
          // Grid 3 Rekening Bank
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bankAccounts.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              final acc = bankAccounts[index];
              return GestureDetector(
                onTap: () => onCopyAccount(acc.accountNumber, acc.bankName),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF5B58EB).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          acc.bankName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 11,
                            color: Color(0xFF5B58EB),
                          ),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        acc.accountNumber,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        acc.accountHolder,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 9, color: Colors.grey),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.copy_rounded,
                            size: 10,
                            color: Color(0xFF5B58EB),
                          ),
                          SizedBox(width: 2),
                          Text(
                            'Salin',
                            style: TextStyle(
                              fontSize: 8.5,
                              color: Color(0xFF5B58EB),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),

          // Divider QRIS
          Row(
            children: const [
              Expanded(child: Divider(color: Color(0xFFE2E8F0))),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  'atau bayar via QRIS',
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
              Expanded(child: Divider(color: Color(0xFFE2E8F0))),
            ],
          ),
          const SizedBox(height: 12),

          // Card QRIS
          GestureDetector(
            onTap: onShowQris,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFCBD5E1)),
                    ),
                    child: const Icon(
                      Icons.qr_code_scanner_rounded,
                      size: 24,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'QRIS Pesantren SIKESAN',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Klik untuk scan barcode dari BCA, Mandiri, GoPay, Dana, dll.',
                          style: TextStyle(fontSize: 10.5, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Upload Bukti Pembayaran
          _buildProofUploadBox(),
        ] else ...[
          // Non-wali: Tunai Kasir vs Transfer
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onPaymentMethodChanged('TRANSFER'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selectedPaymentMethod == 'TRANSFER'
                          ? const Color(0xFFF0F1FE)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selectedPaymentMethod == 'TRANSFER'
                            ? const Color(0xFF5B58EB)
                            : const Color(0xFFE2E8F0),
                        width: selectedPaymentMethod == 'TRANSFER' ? 1.5 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Transfer Bank / QRIS',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: selectedPaymentMethod == 'TRANSFER'
                              ? const Color(0xFF5B58EB)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => onPaymentMethodChanged('CASH'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: selectedPaymentMethod == 'CASH'
                          ? const Color(0xFFF0F1FE)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selectedPaymentMethod == 'CASH'
                            ? const Color(0xFF5B58EB)
                            : const Color(0xFFE2E8F0),
                        width: selectedPaymentMethod == 'CASH' ? 1.5 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        'Tunai di Kasir',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.bold,
                          color: selectedPaymentMethod == 'CASH'
                              ? const Color(0xFF5B58EB)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (selectedPaymentMethod == 'TRANSFER') ...[
            const SizedBox(height: 16),
            _buildProofUploadBox(),
          ],
        ],
      ],
    );
  }

  Widget _buildProofUploadBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Bukti Pembayaran',
              style: AppTypography.itemTitle.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: onPickProof,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: proofBytes != null
                    ? const Color(0xFF10B981)
                    : const Color(0xFFCBD5E1),
              ),
            ),
            child: proofBytes != null
                ? Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          proofBytes!,
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bukti Foto Terpilih',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              proofFilename ?? 'Bukti transfer',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10.5,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          size: 18,
                          color: Color(0xFF5B58EB),
                        ),
                        onPressed: onPickProof,
                      ),
                    ],
                  )
                : Column(
                    children: const [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 30,
                        color: Color(0xFF5B58EB),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Unggah Bukti Transfer / Struk',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Format JPG, PNG, atau Screenshot (Maks. 5MB)',
                        style: TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}
