import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../models/quiz_category.dart';
import '../../../core/theme/app_colors.dart';

class BrainRadarChart extends StatelessWidget {
  const BrainRadarChart({
    super.key,
    required this.scores,
  });

  /// Map of category -> normalized score (0-100).
  final Map<QuizCategory, double> scores;

  @override
  Widget build(BuildContext context) {
    final categories = QuizCategory.playable;
    final dataEntries = categories.map((c) {
      return RadarEntry(value: scores[c] ?? 0);
    }).toList();

    return SizedBox(
      height: 280,
      child: RadarChart(
        RadarChartData(
          radarShape: RadarShape.polygon,
          tickCount: 4,
          ticksTextStyle: const TextStyle(fontSize: 0),
          tickBorderData: BorderSide(
            color: AppColors.border.withValues(alpha: 0.3),
          ),
          gridBorderData: BorderSide(
            color: AppColors.border.withValues(alpha: 0.3),
          ),
          borderData: FlBorderData(show: false),
          radarBorderData: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.3),
          ),
          titlePositionPercentageOffset: 0.15,
          titleTextStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ) ??
              const TextStyle(fontSize: 10),
          getTitle: (index, angle) {
            if (index < categories.length) {
              return RadarChartTitle(
                text: categories[index].label.split(' ').first,
              );
            }
            return const RadarChartTitle(text: '');
          },
          dataSets: [
            RadarDataSet(
              dataEntries: dataEntries,
              fillColor: AppColors.primary.withValues(alpha: 0.15),
              borderColor: AppColors.primary,
              borderWidth: 2,
              entryRadius: 3,
            ),
          ],
        ),
      ),
    );
  }
}
