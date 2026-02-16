import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class MetricTile extends StatelessWidget {
  const MetricTile({
    super.key,
    required this.label,
    required this.value,
    this.unit = '',
    this.icon,
    this.color,
  });

  final String label;
  final String value;
  final String unit;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tileColor = color ?? AppColors.primary;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tileColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: tileColor.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Icon(icon, size: 20, color: tileColor),
          if (icon != null) const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: tileColor,
                    ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: tileColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
