import 'package:flutter/material.dart';
import '../../../core/utils/currency_formatter.dart';

/// Komponen Ringkasan Total Tagihan SPP
/// Memenuhi TASK-CONC-02 untuk modularitas UI
class SppBillSummaryCard extends StatelessWidget {
  final int selectedMonthsCount;
  final num rate;
  final num totalAmount;

  const SppBillSummaryCard({
    super.key,
    required this.selectedMonthsCount,
    required this.rate,
    required this.totalAmount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1FE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E3FD)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Tagihan',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo.shade900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                selectedMonthsCount == 0
                    ? 'Belum ada bulan dipilih'
                    : '$selectedMonthsCount bulan x ${CurrencyFormatter.format(rate)}',
                style: TextStyle(fontSize: 11, color: Colors.indigo.shade600),
              ),
            ],
          ),
          Text(
            CurrencyFormatter.format(totalAmount),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: Color(0xFF5B58EB),
            ),
          ),
        ],
      ),
    );
  }
}
