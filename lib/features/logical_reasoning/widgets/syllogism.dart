import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';

class SyllogismWidget extends StatelessWidget {
  const SyllogismWidget({
    super.key,
    required this.premise1,
    required this.premise2,
    required this.options,
    required this.onAnswer,
  });

  final String premise1;
  final String premise2;
  final List<String> options;
  final ValueChanged<String> onAnswer;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'What can we conclude?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 24),

        // Premises
        _buildPremise(context, 'Premise 1', premise1),
        const SizedBox(height: 12),
        _buildPremise(context, 'Premise 2', premise2),

        const SizedBox(height: 8),
        Icon(
          Icons.arrow_downward_rounded,
          color: AppColors.logicalReasoning,
          size: 28,
        ),
        const SizedBox(height: 8),

        Text(
          'Conclusion:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.logicalReasoning,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 16),

        // Options
        ...options.map((option) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => onAnswer(option),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  side: BorderSide(
                    color: AppColors.logicalReasoning.withValues(alpha: 0.3),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  option,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildPremise(BuildContext context, String label, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.logicalReasoning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.logicalReasoning.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.logicalReasoning,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    ).animate().fadeIn().slideX(begin: -0.05, duration: 300.ms);
  }
}
