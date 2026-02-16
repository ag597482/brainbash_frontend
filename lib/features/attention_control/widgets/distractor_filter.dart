import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';

class DistractorFilterWidget extends StatefulWidget {
  const DistractorFilterWidget({
    super.key,
    required this.targetLetter,
    required this.onResult,
  });

  final String targetLetter;
  final ValueChanged<bool> onResult;

  @override
  State<DistractorFilterWidget> createState() => _DistractorFilterWidgetState();
}

class _DistractorFilterWidgetState extends State<DistractorFilterWidget> {
  final _random = Random();
  late List<_LetterItem> _items;
  int _foundCount = 0;
  int _targetCount = 0;

  @override
  void initState() {
    super.initState();
    _generateGrid();
  }

  void _generateGrid() {
    const allLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final distractors = allLetters.replaceAll(widget.targetLetter.toUpperCase(), '');
    _targetCount = 3 + _random.nextInt(4);

    _items = List.generate(20, (i) {
      if (i < _targetCount) {
        return _LetterItem(
          letter: widget.targetLetter.toUpperCase(),
          isTarget: true,
          found: false,
        );
      }
      return _LetterItem(
        letter: distractors[_random.nextInt(distractors.length)],
        isTarget: false,
        found: false,
      );
    })..shuffle();
  }

  void _onItemTap(int index) {
    final item = _items[index];
    if (item.found) return;

    if (item.isTarget) {
      setState(() {
        _items[index] = item.copyWith(found: true);
        _foundCount++;
      });
      if (_foundCount >= _targetCount) {
        widget.onResult(true);
      }
    } else {
      widget.onResult(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Find all the "${widget.targetLetter.toUpperCase()}" letters',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          '$_foundCount / $_targetCount found',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.attentionControl,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: _items.length,
          itemBuilder: (context, index) {
            final item = _items[index];
            return GestureDetector(
              onTap: () => _onItemTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: item.found
                      ? AppColors.success.withValues(alpha: 0.2)
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: item.found ? AppColors.success : Theme.of(context).colorScheme.outlineVariant,
                    width: item.found ? 2 : 1,
                  ),
                ),
                child: Text(
                  item.letter,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: item.found
                        ? AppColors.success
                        : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: Duration(milliseconds: 30 * index));
          },
        ),
      ],
    );
  }
}

class _LetterItem {
  const _LetterItem({
    required this.letter,
    required this.isTarget,
    required this.found,
  });

  final String letter;
  final bool isTarget;
  final bool found;

  _LetterItem copyWith({bool? found}) {
    return _LetterItem(
      letter: letter,
      isTarget: isTarget,
      found: found ?? this.found,
    );
  }
}
