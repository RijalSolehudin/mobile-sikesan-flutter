import 'package:flutter/material.dart';
import '../../../core/utils/currency_formatter.dart';

/// Komponen Tombol Submit Pembayaran SPP (Loading State & Disabled State)
/// Memenuhi TASK-CONC-02 untuk modularitas UI
class SppSubmitButton extends StatelessWidget {
  final bool isSubmitting;
  final bool isEnabled;
  final num totalAmount;
  final VoidCallback onSubmit;

  const SppSubmitButton({
    super.key,
    required this.isSubmitting,
    required this.isEnabled,
    required this.totalAmount,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: (!isEnabled || isSubmitting) ? null : onSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF5B58EB),
          disabledBackgroundColor: const Color(0xFFCBD5E1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: isSubmitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Text(
                !isEnabled
                    ? 'Pilih Bulan Tagihan'
                    : 'Bayar ${CurrencyFormatter.format(totalAmount)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
