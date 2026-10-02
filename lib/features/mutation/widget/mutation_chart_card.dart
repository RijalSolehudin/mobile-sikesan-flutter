import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

class MutationChartCard extends StatelessWidget {
  final String timeRange;

  const MutationChartCard({
    super.key,
    required this.timeRange,
  });

  static FlLine _getLine(double value) {
    return const FlLine(color: AppColors.borderLight, strokeWidth: 1);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Statistik Transaksi',
                style: AppTypography.itemTitle.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Row(
                  children: [
                    Text(
                      timeRange,
                      style: AppTypography.badgeText.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: _getLine,
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 32,
                      getTitlesWidget: (value, meta) {
                        switch (value.toInt()) {
                          case 0:
                            return const Text(
                              '0k',
                              style: TextStyle(
                                fontSize: 9,
                                color: AppColors.textMuted,
                              ),
                            );
                          case 7:
                            return const Text(
                              '7.5k',
                              style: TextStyle(
                                fontSize: 9,
                                color: AppColors.textMuted,
                              ),
                            );
                          case 15:
                            return const Text(
                              '15k',
                              style: TextStyle(
                                fontSize: 9,
                                color: AppColors.textMuted,
                              ),
                            );
                          case 22:
                            return const Text(
                              '22.5k',
                              style: TextStyle(
                                fontSize: 9,
                                color: AppColors.textMuted,
                              ),
                            );
                          case 30:
                            return const Text(
                              '30k',
                              style: TextStyle(
                                fontSize: 9,
                                color: AppColors.textMuted,
                              ),
                            );
                        }
                        return const SizedBox();
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (val, meta) => Text(
                        val.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 9,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 1,
                maxX: 10,
                minY: 0,
                maxY: 30,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(1, 0),
                      FlSpot(2, 0),
                      FlSpot(3, 0),
                      FlSpot(4, 0),
                      FlSpot(5, 0),
                      FlSpot(6, 2),
                      FlSpot(7, 22),
                      FlSpot(8, 0),
                      FlSpot(9, 0),
                      FlSpot(10, 4),
                    ],
                    isCurved: true,
                    color: AppColors.expense,
                    barWidth: 2,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.expense.withValues(
                            alpha: 0.35,
                          ),
                          AppColors.expense.withValues(
                            alpha: 0.0,
                          ),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
