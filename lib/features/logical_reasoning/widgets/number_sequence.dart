import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../models/question.dart';
import '../../../core/theme/app_colors.dart';

class NumberSequenceWidget extends StatelessWidget {
  const NumberSequenceWidget({
    super.key,
    required this.question,
    required this.onAnswer,
  });

  final Question question;
  final ValueChanged<String> onAnswer;

  @override
  Widget build(BuildContext context) {
    final parts = question.prompt.split('\n');
    final title = parts.isNotEmpty ? parts[0] : 'What comes next?';
    final sequence = parts.length > 1 ? parts[1] : question.prompt;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 16),

        // Sequence display
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.logicalReasoning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.logicalReasoning.withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            sequence,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
            textAlign: TextAlign.center,
          ),
        ).animate().fadeIn(duration: 300.ms),

        const SizedBox(height: 32),

        // Options
        if (question.options != null)
          ...question.options!.map((option) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => onAnswer(option),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: AppColors.logicalReasoning.withValues(alpha: 0.3),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    option,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}
