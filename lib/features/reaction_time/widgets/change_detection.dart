import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class ChangeDetectionWidget extends StatefulWidget {
  const ChangeDetectionWidget({
    super.key,
    required this.onReactionTime,
  });

  final ValueChanged<int> onReactionTime;

  @override
  State<ChangeDetectionWidget> createState() => _ChangeDetectionWidgetState();
}

class _ChangeDetectionWidgetState extends State<ChangeDetectionWidget> {
  final _random = Random();
  static const _gridSize = 16;
  late List<Color> _colors;
  int _changedIndex = -1;
  bool _changed = false;
  Stopwatch? _stopwatch;
  Timer? _changeTimer;

  static const _palette = [
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
    _generateGrid();
    _scheduleChange();
  }

  void _generateGrid() {
    _colors = List.generate(_gridSize, (_) => _palette[_random.nextInt(_palette.length)]);
  }

  void _scheduleChange() {
    final delay = 1500 + _random.nextInt(3000);
    _changeTimer = Timer(Duration(milliseconds: delay), () {
      if (mounted) {
        _changedIndex = _random.nextInt(_gridSize);
        final currentColor = _colors[_changedIndex];
        final newColor = _palette.where((c) => c != currentColor).elementAt(
          _random.nextInt(_palette.length - 1),
        );
        setState(() {
          _colors[_changedIndex] = newColor;
          _changed = true;
        });
        _stopwatch = Stopwatch()..start();
      }
    });
  }

  void _onTileTap(int index) {
    if (!_changed) return;
    if (index == _changedIndex && _stopwatch != null) {
      _stopwatch!.stop();
      widget.onReactionTime(_stopwatch!.elapsedMilliseconds);
    }
  }

  @override
  void dispose() {
    _changeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _changed ? 'Tap the tile that changed!' : 'Watch carefully...',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: _changed ? AppColors.reactionTime : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: _gridSize,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _onTileTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: _colors[index],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
