import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';

class PatternRecognitionWidget extends StatefulWidget {
  const PatternRecognitionWidget({
    super.key,
    required this.onResult,
  });

  final ValueChanged<bool> onResult;

  @override
  State<PatternRecognitionWidget> createState() => _PatternRecognitionWidgetState();
}

class _PatternRecognitionWidgetState extends State<PatternRecognitionWidget> {
  final _random = Random();
  late List<Color> _pattern;
  late int _oddOneOutIndex;
  static const _colors = [
    AppColors.processingSpeed,
    AppColors.workingMemory,
    AppColors.logicalReasoning,
    AppColors.mathReasoning,
    AppColors.reactionTime,
    AppColors.attentionControl,
  ];

  @override
  void initState() {
    super.initState();
    _generatePattern();
  }

  void _generatePattern() {
    final mainColor = _colors[_random.nextInt(_colors.length)];
    final oddColor = _colors.where((c) => c != mainColor).elementAt(
      _random.nextInt(_colors.length - 1),
    );
    _oddOneOutIndex = _random.nextInt(9);
    _pattern = List.generate(9, (i) {
      return i == _oddOneOutIndex ? oddColor : mainColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Tap the odd one out',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 32),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
          ),
          itemCount: 9,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                widget.onResult(index == _oddOneOutIndex);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: _pattern[index],
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ).animate().fadeIn(delay: Duration(milliseconds: 80 * index)).scale(
                  begin: const Offset(0.8, 0.8),
                  duration: 300.ms,
                );
          },
        ),
      ],
    );
  }
}
