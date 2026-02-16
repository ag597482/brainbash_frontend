import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AnswerOptions extends StatelessWidget {
  const AnswerOptions({
    super.key,
    required this.options,
    required this.onSelected,
    this.selectedAnswer,
    this.correctAnswer,
    this.showResult = false,
    this.color,
  });

  final List<String> options;
  final ValueChanged<String> onSelected;
  final String? selectedAnswer;
  final String? correctAnswer;
  final bool showResult;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: options.map((option) {
        final isSelected = option == selectedAnswer;
        final isCorrect = option == correctAnswer;
        final accentColor = color ?? AppColors.primary;

        Color bgColor;
        Color borderColor;
        Color textColor;

        if (showResult && isSelected && isCorrect) {
          bgColor = AppColors.success.withValues(alpha: 0.12);
          borderColor = AppColors.success;
          textColor = AppColors.success;
        } else if (showResult && isSelected && !isCorrect) {
          bgColor = AppColors.error.withValues(alpha: 0.12);
          borderColor = AppColors.error;
          textColor = AppColors.error;
        } else if (showResult && isCorrect) {
          bgColor = AppColors.success.withValues(alpha: 0.08);
          borderColor = AppColors.success.withValues(alpha: 0.5);
          textColor = AppColors.success;
        } else if (isSelected) {
          bgColor = accentColor.withValues(alpha: 0.12);
          borderColor = accentColor;
          textColor = accentColor;
        } else {
          bgColor = Theme.of(context).cardTheme.color ?? Colors.white;
          borderColor = AppColors.border;
          textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: showResult ? null : () => onSelected(option),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderColor, width: 1.5),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      option,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: textColor,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                    ),
                  ),
                  if (showResult && isSelected && isCorrect)
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.success, size: 22),
                  if (showResult && isSelected && !isCorrect)
                    const Icon(Icons.cancel_rounded,
                        color: AppColors.error, size: 22),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
