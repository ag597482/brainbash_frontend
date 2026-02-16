import 'package:flutter/material.dart';
import '../../../models/question.dart';
import '../../../core/theme/app_colors.dart';

class QuestionWidget extends StatelessWidget {
  const QuestionWidget({
    super.key,
    required this.question,
    this.color,
  });

  final Question question;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: (color ?? AppColors.primary).withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            question.prompt,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
