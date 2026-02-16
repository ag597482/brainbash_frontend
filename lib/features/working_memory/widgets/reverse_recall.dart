import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/constants/quiz_constants.dart';

class ReverseRecallWidget extends StatefulWidget {
  const ReverseRecallWidget({
    super.key,
    required this.digits,
    required this.onResult,
  });

  final String digits;
  final ValueChanged<bool> onResult;

  @override
  State<ReverseRecallWidget> createState() => _ReverseRecallWidgetState();
}

class _ReverseRecallWidgetState extends State<ReverseRecallWidget> {
  bool _showing = true;
  String _userInput = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    final displayTime = widget.digits.length * QuizConstants.workingMemoryDisplayTimeMs;
    _timer = Timer(Duration(milliseconds: displayTime + 500), () {
      if (mounted) {
        setState(() => _showing = false);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onDigitPress(String digit) {
    setState(() => _userInput += digit);
  }

  void _onBackspace() {
    if (_userInput.isNotEmpty) {
      setState(() => _userInput = _userInput.substring(0, _userInput.length - 1));
    }
  }

  void _onSubmit() {
    final reversed = widget.digits.split('').reversed.join('');
    widget.onResult(_userInput == reversed);
  }

  @override
  Widget build(BuildContext context) {
    if (_showing) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Remember these numbers',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ll enter them in REVERSE order',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 32),
          Text(
            widget.digits.split('').join('  '),
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 8,
                  color: AppColors.workingMemory,
                ),
          ).animate().fadeIn(),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Enter in REVERSE order',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.warning,
                fontWeight: FontWeight.w700,
              ),
        ).animate().fadeIn(),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.workingMemory.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _userInput.isEmpty ? '_ ' * widget.digits.length : _userInput.split('').join('  '),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: 4,
                ),
          ),
        ),
        const SizedBox(height: 24),
        // Number pad
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: [
            for (int i = 1; i <= 9; i++)
              _buildKey('$i', () => _onDigitPress('$i')),
            _buildKey('⌫', _onBackspace, isAction: true),
            _buildKey('0', () => _onDigitPress('0')),
            _buildKey('✓', _onSubmit, isAction: true),
          ],
        ),
      ],
    );
  }

  Widget _buildKey(String label, VoidCallback onTap, {bool isAction = false}) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 60,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isAction
                ? AppColors.workingMemory.withValues(alpha: 0.12)
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: isAction ? 18 : 20,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
