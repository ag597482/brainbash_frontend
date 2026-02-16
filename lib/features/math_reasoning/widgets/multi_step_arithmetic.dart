import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../models/question.dart';
import '../../../core/theme/app_colors.dart';

class MultiStepArithmeticWidget extends StatelessWidget {
  const MultiStepArithmeticWidget({
    super.key,
    required this.question,
    required this.onAnswer,
  });

  final Question question;
  final ValueChanged<String> onAnswer;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Problem display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.mathReasoning.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.mathReasoning.withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              question.prompt,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    height: 1.6,
                  ),
              textAlign: TextAlign.center,
            ),
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: 32),

          // Options
          if (question.options != null)
            ...question.options!.asMap().entries.map((entry) {
              final index = entry.key;
              final option = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => onAnswer(option),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 20),
                      side: BorderSide(
                        color: AppColors.mathReasoning.withValues(alpha: 0.3),
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color:
                                AppColors.mathReasoning.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            String.fromCharCode(65 + index), // A, B, C, D
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
                                  color: AppColors.mathReasoning,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          option,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
                  .animate(delay: Duration(milliseconds: 100 * index))
                  .fadeIn()
                  .slideX(begin: 0.05);
            }),
        ],
      ),
    );
  }
}
