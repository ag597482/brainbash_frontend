import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CountdownTimerWidget extends StatelessWidget {
  const CountdownTimerWidget({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    this.color,
  });

  final int remainingSeconds;
  final int totalSeconds;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final progress = totalSeconds > 0 ? remainingSeconds / totalSeconds : 0.0;
    final isLow = remainingSeconds <= 5;
    final barColor = isLow ? AppColors.error : (color ?? AppColors.primary);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 18,
                  color: barColor,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTime(remainingSeconds),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: barColor,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ],
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

  String _formatTime(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m > 0) {
      return '$m:${s.toString().padLeft(2, '0')}';
    }
    return '${s}s';
  }
}
