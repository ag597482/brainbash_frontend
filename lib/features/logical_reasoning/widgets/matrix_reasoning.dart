import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';

class MatrixReasoningWidget extends StatelessWidget {
  const MatrixReasoningWidget({
    super.key,
    required this.onAnswer,
  });

  final ValueChanged<int> onAnswer;

  @override
  Widget build(BuildContext context) {
    // 3x3 grid with a pattern. Last cell is "?"
    // Simple pattern: shapes rotating colors
    final colors = [
      AppColors.processingSpeed,
      AppColors.workingMemory,
      AppColors.logicalReasoning,
      AppColors.mathReasoning,
      AppColors.reactionTime,
      AppColors.attentionControl,
      AppColors.primary,
      AppColors.secondary,
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Which pattern completes the grid?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 24),

        // 3x3 matrix
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: 9,
          itemBuilder: (context, index) {
            if (index == 8) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.logicalReasoning,
                    width: 2,
                    strokeAlign: BorderSide.strokeAlignInside,
                  ),
                ),
                child: Center(
                  child: Text(
                    '?',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.logicalReasoning,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: colors[index % colors.length].withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colors[index % colors.length].withValues(alpha: 0.3),
                ),
              ),
              child: Center(
                child: Icon(
                  [
                    Icons.circle,
                    Icons.square_rounded,
                    Icons.change_history_rounded,
                    Icons.circle,
                    Icons.square_rounded,
                    Icons.change_history_rounded,
                    Icons.circle,
                    Icons.square_rounded,
                  ][index],
                  color: colors[index % colors.length],
                  size: 32,
                ),
              ),
            ).animate().fadeIn(delay: Duration(milliseconds: 80 * index));
          },
        ),

        const SizedBox(height: 24),

        // Answer options
        Row(
          children: List.generate(4, (i) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: i > 0 ? 8 : 0),
                child: GestureDetector(
                  onTap: () => onAnswer(i),
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.change_history_rounded,
                        color: colors[(i + 2) % colors.length],
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
