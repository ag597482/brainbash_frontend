import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class QuizProgressBar extends StatelessWidget {
  const QuizProgressBar({
    super.key,
    required this.current,
    required this.total,
    this.color,
  });

  final int current;
  final int total;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? current / total : 0.0;
    final barColor = color ?? AppColors.primary;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Question $current of $total',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            Text(
              '${(progress * 100).round()}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: barColor,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: barColor.withValues(alpha: 0.12),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
