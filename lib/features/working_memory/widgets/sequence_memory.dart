import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SequenceMemoryWidget extends StatefulWidget {
  const SequenceMemoryWidget({
    super.key,
    required this.sequenceLength,
    required this.onResult,
  });

  final int sequenceLength;
  final ValueChanged<bool> onResult;

  @override
  State<SequenceMemoryWidget> createState() => _SequenceMemoryWidgetState();
}

class _SequenceMemoryWidgetState extends State<SequenceMemoryWidget> {
  static const _gridSize = 9;
  final _random = Random();
  late List<int> _sequence;
  int _showIndex = -1;
  bool _isShowingSequence = true;
  final List<int> _userSequence = [];
  int _userTapIndex = 0;

  @override
  void initState() {
    super.initState();
    _generateSequence();
    _playSequence();
  }

  void _generateSequence() {
    _sequence = List.generate(widget.sequenceLength, (_) => _random.nextInt(_gridSize));
  }

  Future<void> _playSequence() async {
    await Future.delayed(const Duration(milliseconds: 600));
    for (int i = 0; i < _sequence.length; i++) {
      if (!mounted) return;
      setState(() => _showIndex = i);
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      setState(() => _showIndex = -1);
      await Future.delayed(const Duration(milliseconds: 300));
    }
    if (mounted) {
      setState(() => _isShowingSequence = false);
    }
  }

  void _onTileTap(int index) {
    if (_isShowingSequence) return;

    _userSequence.add(index);
    final expected = _sequence[_userTapIndex];

    if (index != expected) {
      widget.onResult(false);
      return;
    }

    _userTapIndex++;
    if (_userTapIndex >= _sequence.length) {
      widget.onResult(true);
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _isShowingSequence ? 'Watch the sequence...' : 'Repeat the sequence!',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemCount: _gridSize,
          itemBuilder: (context, index) {
            final isHighlighted =
                _isShowingSequence && _showIndex >= 0 && _sequence[_showIndex] == index;
            final isUserTapped = !_isShowingSequence && _userSequence.contains(index);

            return GestureDetector(
              onTap: () => _onTileTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isHighlighted
                      ? AppColors.workingMemory
                      : isUserTapped
                          ? AppColors.workingMemory.withValues(alpha: 0.3)
                          : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isHighlighted
                        ? AppColors.workingMemory
                        : Theme.of(context).colorScheme.outlineVariant,
                    width: isHighlighted ? 2 : 1,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        if (!_isShowingSequence)
          Text(
            '$_userTapIndex / ${_sequence.length}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.workingMemory,
                  fontWeight: FontWeight.w600,
                ),
          ),
      ],
    );
  }
}
