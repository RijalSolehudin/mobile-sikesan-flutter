import 'package:flutter/material.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/spp_models.dart';

/// Komponen Grid 12 Bulan untuk tagihan SPP (Status Lunas & FIFO Selection)
/// Memenuhi TASK-CONC-02 untuk modularitas UI
class SppMonthGridSelector extends StatelessWidget {
  final int selectedYear;
  final int? selectedStudentId;
  final Set<int> selectedMonths;
  final List<SppBillModel> bills;
  final bool isLoadingBills;
  final ValueChanged<int> onMonthTapped;

  static const List<String> monthNamesShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  const SppMonthGridSelector({
    super.key,
    required this.selectedYear,
    required this.selectedStudentId,
    required this.selectedMonths,
    required this.bills,
    required this.isLoadingBills,
    required this.onMonthTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Pilihan Bulan',
              style: AppTypography.itemTitle.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const Text(
              ' *',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            if (isLoadingBills) ...[
              const SizedBox(width: 10),
              const SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: 12,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.6,
          ),
          itemBuilder: (context, index) {
            final monthNumber = index + 1;
            final monthName = monthNamesShort[index];

            final bill = bills.firstWhere(
              (b) =>
                  b.periodYear == selectedYear && b.periodMonth == monthNumber,
              orElse: () => SppBillModel(
                id: '',
                studentId: selectedStudentId ?? 0,
                periodMonth: monthNumber,
                periodYear: selectedYear,
                amountBilled: 750000,
                status: 'UNPAID',
              ),
            );

            final isPaid = bill.isPaid;
            final isPending = bill.isPending;
            final isSelected = selectedMonths.contains(monthNumber);

            if (isPaid) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF10B981),
                    width: 1.2,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      monthName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF047857),
                      ),
                    ),
                    const Positioned(
                      right: 8,
                      child: Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              );
            }

            if (isPending) {
              return Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 218, 216, 253),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFF5B58EB),
                    width: 1.2,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Text(
                      monthName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF5B58EB),
                      ),
                    ),
                    const Positioned(
                      right: 8,
                      child: Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: Color(0xFF5B58EB),
                      ),
                    ),
                  ],
                ),
              );
            }

            return GestureDetector(
              onTap: () => onMonthTapped(monthNumber),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF5B58EB) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF5B58EB)
                        : const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(
                              0xFF5B58EB,
                            ).withValues(alpha: 0.25),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  monthName,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 8),

        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.info_outline_rounded,
              size: 14,
              color: Color(0xFF3B82F6),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                'Pilih bulan tagihan. Hijau: Lunas. Ungu: Menunggu Verifikasi.',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.blue.shade700,
                  height: 1.3,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
