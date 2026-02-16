import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';

class SymbolMatchingWidget extends StatefulWidget {
  const SymbolMatchingWidget({
    super.key,
    required this.onResult,
  });

  final ValueChanged<bool> onResult;

  @override
  State<SymbolMatchingWidget> createState() => _SymbolMatchingWidgetState();
}

class _SymbolMatchingWidgetState extends State<SymbolMatchingWidget> {
  static const _symbols = ['★', '♦', '♠', '♣', '♥', '●', '▲', '■', '◆', '○'];
  final _random = Random();
  late String _targetSymbol;
  late List<String> _grid;
  late int _matchCount;

  @override
  void initState() {
    super.initState();
    _generateRound();
  }

  void _generateRound() {
    _targetSymbol = _symbols[_random.nextInt(_symbols.length)];
    _matchCount = _random.nextInt(4) + 2;
    _grid = List.generate(12, (i) {
      if (i < _matchCount) return _targetSymbol;
      return _symbols.where((s) => s != _targetSymbol).elementAt(
        _random.nextInt(_symbols.length - 1),
      );
    })..shuffle();
  }

  int _selectedCount = 0;

  void _onSymbolTap(int index) {
    if (_grid[index] == _targetSymbol) {
      setState(() {
        _selectedCount++;
        if (_selectedCount >= _matchCount) {
          widget.onResult(true);
        }
      });
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
          'Find all: $_targetSymbol',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          '$_selectedCount / $_matchCount found',
          style: Theme.of(context).textTheme.bodyMedium,
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
          itemCount: _grid.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => _onSymbolTap(index),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.processingSpeed.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.processingSpeed.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  _grid[index],
                  style: const TextStyle(fontSize: 28),
                ),
              ),
            ).animate().fadeIn(delay: Duration(milliseconds: 50 * index));
          },
        ),
      ],
    );
  }
}
