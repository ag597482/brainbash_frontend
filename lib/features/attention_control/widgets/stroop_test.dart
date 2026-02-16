import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../models/question.dart';
import '../../../core/theme/app_colors.dart';

class StroopTestWidget extends StatelessWidget {
  const StroopTestWidget({
    super.key,
    required this.question,
    required this.onAnswer,
  });

  final Question question;
  final ValueChanged<String> onAnswer;

  static const _colorMap = {
    'Red': Colors.red,
    'Blue': Colors.blue,
    'Green': Colors.green,
    'Yellow': Colors.amber,
  };

  @override
  Widget build(BuildContext context) {
    final displayColorValue = question.metadata['displayColor'] as int?;
    final displayColor =
        displayColorValue != null ? Color(displayColorValue) : Colors.black;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'What COLOR is this word displayed in?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          '(Ignore what the word says)',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.attentionControl,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 40),

        // Stroop word
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            question.prompt,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: displayColor,
            ),
          ),
        ).animate().fadeIn(duration: 200.ms).scale(
              begin: const Offset(0.8, 0.8),
              duration: 300.ms,
              curve: Curves.elasticOut,
            ),

        const SizedBox(height: 40),

        // Color buttons
        GridView.count(
          shrinkWrap: true,
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.5,
          physics: const NeverScrollableScrollPhysics(),
          children: (question.options ?? _colorMap.keys.toList()).map((colorName) {
            final buttonColor = _colorMap[colorName] ?? Colors.grey;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onAnswer(colorName),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: buttonColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: buttonColor.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    colorName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: buttonColor,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
