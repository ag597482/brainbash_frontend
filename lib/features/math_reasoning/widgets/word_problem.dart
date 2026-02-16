import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';

class WordProblemWidget extends StatefulWidget {
  const WordProblemWidget({
    super.key,
    required this.problem,
    required this.onAnswer,
  });

  final String problem;
  final ValueChanged<String> onAnswer;

  @override
  State<WordProblemWidget> createState() => _WordProblemWidgetState();
}

class _WordProblemWidgetState extends State<WordProblemWidget> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.mathReasoning.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            widget.problem,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 18,
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          ),
        ).animate().fadeIn(),
        const SizedBox(height: 32),
        TextField(
          controller: _controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
          decoration: InputDecoration(
            hintText: 'Your answer',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.mathReasoning.withValues(alpha: 0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.mathReasoning,
                width: 2,
              ),
            ),
          ),
          onSubmitted: (value) => widget.onAnswer(value),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => widget.onAnswer(_controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mathReasoning,
            ),
            child: const Text('Submit Answer'),
          ),
        ),
      ],
    );
  }
}
