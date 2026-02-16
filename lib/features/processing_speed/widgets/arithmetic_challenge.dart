import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../models/question.dart';
import '../../../core/theme/app_colors.dart';

class ArithmeticChallenge extends StatelessWidget {
  const ArithmeticChallenge({
    super.key,
    required this.question,
    required this.onAnswer,
  });

  final Question question;
  final ValueChanged<String> onAnswer;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Big math expression
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            color: AppColors.processingSpeed.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            question.prompt,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                ),
            textAlign: TextAlign.center,
          ),
        ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.9, 0.9), duration: 200.ms),

        const SizedBox(height: 32),

        // Answer grid (2x2)
        if (question.options != null)
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 2.2,
            physics: const NeverScrollableScrollPhysics(),
            children: question.options!.map((option) {
              return _OptionButton(
                label: option,
                onTap: () => onAnswer(option),
                color: AppColors.processingSpeed,
              );
            }).toList(),
          ),
      ],
    );
  }
}

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.label,
    required this.onTap,
    required this.color,
  });

  final String label;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ),
    );
  }
}
