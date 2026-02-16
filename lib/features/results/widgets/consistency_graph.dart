import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../core/theme/app_colors.dart';

class ConsistencyGraph extends StatelessWidget {
  const ConsistencyGraph({
    super.key,
    required this.responseTimes,
  });

  final List<double> responseTimes;

  @override
  Widget build(BuildContext context) {
    if (responseTimes.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        child: Text(
          'No data yet',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
    }

    final spots = responseTimes.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value);
    }).toList();

    final maxY = responseTimes.reduce((a, b) => a > b ? a : b) * 1.2;
    final minY = 0.0;

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: maxY / 4,
            getDrawingHorizontalLine: (value) => FlLine(
              color: AppColors.border.withValues(alpha: 0.3),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.round()}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: AppColors.textHint,
                        ),
                  );
                },
              ),
            ),
            bottomTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.consistencyScore,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: AppColors.consistencyScore,
                    strokeWidth: 1.5,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.consistencyScore.withValues(alpha: 0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
