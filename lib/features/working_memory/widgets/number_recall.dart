import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../models/question.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/constants/quiz_constants.dart';

class NumberRecallWidget extends StatefulWidget {
  const NumberRecallWidget({
    super.key,
    required this.question,
    required this.onAnswer,
  });

  final Question question;
  final ValueChanged<String> onAnswer;

  @override
  State<NumberRecallWidget> createState() => _NumberRecallWidgetState();
}

class _NumberRecallWidgetState extends State<NumberRecallWidget> {
  bool _showing = true;
  String _userInput = '';
  int _currentDigitIndex = 0;
  Timer? _displayTimer;

  @override
  void initState() {
    super.initState();
    _startDisplay();
  }

  @override
  void didUpdateWidget(NumberRecallWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      setState(() {
        _showing = true;
        _userInput = '';
        _currentDigitIndex = 0;
      });
      _startDisplay();
    }
  }

  void _startDisplay() {
    _displayTimer?.cancel();
    _currentDigitIndex = 0;
    _showing = true;

    final digits = widget.question.prompt;

    _displayTimer = Timer.periodic(
      Duration(milliseconds: QuizConstants.workingMemoryDisplayTimeMs),
      (timer) {
        if (_currentDigitIndex < digits.length - 1) {
          setState(() => _currentDigitIndex++);
        } else {
          timer.cancel();
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() => _showing = false);
            }
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _displayTimer?.cancel();
    super.dispose();
  }

  void _onDigitPress(String digit) {
    setState(() {
      _userInput += digit;
    });
  }

  void _onBackspace() {
    if (_userInput.isNotEmpty) {
      setState(() {
        _userInput = _userInput.substring(0, _userInput.length - 1);
      });
    }
  }

  void _onSubmit() {
    widget.onAnswer(_userInput);
    setState(() {
      _userInput = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final digits = widget.question.prompt;
    final seqLength = digits.length;

    if (_showing) {
      return _buildShowPhase(digits);
    }
    return _buildRecallPhase(seqLength);
  }

  Widget _buildShowPhase(String digits) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxBoxWidth = ((constraints.maxWidth - 16) / digits.length) - 8;
        final boxWidth = maxBoxWidth.clamp(32.0, 48.0);
        final boxHeight = boxWidth * 1.15;
        final fontSize = boxWidth * 0.5;

        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
            Text(
              'Remember these numbers',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '${digits.length} digits',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.workingMemory,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 32),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 6,
              children: List.generate(digits.length, (i) {
                final isActive = i <= _currentDigitIndex;
                return Container(
                  width: boxWidth,
                  height: boxHeight,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.workingMemory.withValues(alpha: 0.15)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isActive
                          ? AppColors.workingMemory
                          : Theme.of(context).colorScheme.outlineVariant,
                      width: isActive ? 2 : 1,
                    ),
                  ),
                  child: Text(
                    isActive ? digits[i] : '',
                    style: TextStyle(
                      fontSize: fontSize,
                      fontWeight: FontWeight.w800,
                      color: AppColors.workingMemory,
                    ),
                  ),
                ).animate(delay: Duration(milliseconds: i * 200)).fadeIn();
              }),
            ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRecallPhase(int seqLength) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxSlotWidth = ((constraints.maxWidth - 48) / seqLength) - 8;
        final slotWidth = maxSlotWidth.clamp(28.0, 36.0);
        final slotHeight = slotWidth * 1.2;
        final slotFontSize = slotWidth * 0.5;

        return SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Enter the numbers in order',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ).animate().fadeIn(),
              const SizedBox(height: 24),

              // Input display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.workingMemory.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.workingMemory.withValues(alpha: 0.3)),
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6,
                  runSpacing: 6,
                  children: List.generate(seqLength, (i) {
                    final hasDigit = i < _userInput.length;
                    return Container(
                      width: slotWidth,
                      height: slotHeight,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: hasDigit
                            ? AppColors.workingMemory.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border(
                          bottom: BorderSide(
                            color: hasDigit
                                ? AppColors.workingMemory
                                : Theme.of(context).colorScheme.outlineVariant,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        hasDigit ? _userInput[i] : '',
                        style: TextStyle(
                          fontSize: slotFontSize,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 24),

              // Number pad
              _buildNumberPad(),

              const SizedBox(height: 16),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _userInput.length == seqLength ? _onSubmit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.workingMemory,
                  ),
                  child: const Text('Submit'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNumberPad() {
    return Column(
      children: [
        for (int row = 0; row < 3; row++)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int col = 1; col <= 3; col++)
                _numKey('${row * 3 + col}'),
            ],
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _numKey('', icon: Icons.backspace_rounded, onTap: _onBackspace),
            _numKey('0'),
            _numKey('', icon: Icons.check_rounded, onTap: _onSubmit),
          ],
        ),
      ],
    );
  }

  Widget _numKey(String digit, {IconData? icon, VoidCallback? onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap ?? (digit.isNotEmpty ? () => _onDigitPress(digit) : null),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 64,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: icon != null
                ? Icon(icon, size: 22, color: colorScheme.onSurface)
                : Text(
                    digit,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                  ),
          ),
        ),
      ),
    );
  }
}
