import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../models/question.dart';
import '../../../core/theme/app_colors.dart';

class TapTargetWidget extends StatefulWidget {
  const TapTargetWidget({
    super.key,
    required this.question,
    required this.onAnswer,
    required this.onReactionTime,
  });

  final Question question;
  final ValueChanged<String> onAnswer;
  final ValueChanged<int> onReactionTime;

  @override
  State<TapTargetWidget> createState() => _TapTargetWidgetState();
}

class _TapTargetWidgetState extends State<TapTargetWidget> {
  final _random = Random();
  bool _showTarget = false;
  bool _waiting = true;
  bool _tooEarly = false;
  Stopwatch? _stopwatch;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    _startRound();
  }

  @override
  void didUpdateWidget(TapTargetWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      _startRound();
    }
  }

  void _startRound() {
    _delayTimer?.cancel();
    setState(() {
      _showTarget = false;
      _waiting = true;
      _tooEarly = false;
    });

    final minDelay = widget.question.metadata['minDelayMs'] as int? ?? 1000;
    final maxDelay = widget.question.metadata['maxDelayMs'] as int? ?? 5000;
    final delay = minDelay + _random.nextInt(maxDelay - minDelay);

    _delayTimer = Timer(Duration(milliseconds: delay), () {
      if (mounted) {
        setState(() {
          _showTarget = true;
          _waiting = false;
        });
        _stopwatch = Stopwatch()..start();
      }
    });
  }

  void _onTap() {
    if (_waiting && !_showTarget) {
      // Tapped too early
      setState(() => _tooEarly = true);
      _delayTimer?.cancel();
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) _startRound();
      });
      return;
    }

    if (_showTarget && _stopwatch != null) {
      _stopwatch!.stop();
      final reactionMs = _stopwatch!.elapsedMilliseconds;
      setState(() {
        _showTarget = false;
      });
      widget.onReactionTime(reactionMs);
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_tooEarly) ...[
              Icon(
                Icons.warning_rounded,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Too early! Wait for the target.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ] else if (_waiting && !_showTarget) ...[
              Text(
                'Wait for the green target...',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 32),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).colorScheme.outlineVariant,
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.hourglass_top_rounded,
                    size: 40,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ] else if (_showTarget) ...[
              Text(
                'TAP NOW!',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.success,
                    ),
              ),
              const SizedBox(height: 32),
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.touch_app_rounded,
                    size: 56,
                    color: Colors.white,
                  ),
                ),
              )
                  .animate(onPlay: (c) => c.repeat(reverse: true))
                  .scale(
                    begin: const Offset(1, 1),
                    end: const Offset(1.1, 1.1),
                    duration: 500.ms,
                  ),
            ],
          ],
        ),
      ),
    );
  }
}
