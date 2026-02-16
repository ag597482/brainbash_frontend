import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../models/quiz_category.dart';
import '../../../models/quiz_session.dart';
import '../../../providers/quiz_provider.dart';
import '../../../providers/timer_provider.dart';
import '../widgets/countdown_timer.dart';
import '../widgets/progress_bar.dart';
import '../../processing_speed/widgets/arithmetic_challenge.dart';
import '../../working_memory/widgets/number_recall.dart';
import '../../logical_reasoning/widgets/number_sequence.dart';
import '../../math_reasoning/widgets/multi_step_arithmetic.dart';
import '../../reaction_time/widgets/tap_target.dart';
import '../../attention_control/widgets/stroop_test.dart';

class QuizScreen extends ConsumerStatefulWidget {
  const QuizScreen({super.key, required this.category});

  final QuizCategory category;

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final session = ref.read(quizSessionProvider);
      if (session != null && session.status == SessionStatus.notStarted) {
        ref.read(quizSessionProvider.notifier).startSession();
        ref.read(elapsedTimerProvider.notifier).start();

        if (_hasCountdown) {
          ref.read(countdownTimerProvider.notifier).start(_getTimeLimitSeconds());
        }
      }
    });
  }

  bool get _hasCountdown {
    switch (widget.category) {
      case QuizCategory.processingSpeed:
      case QuizCategory.logicalReasoning:
      case QuizCategory.mathReasoning:
      case QuizCategory.attentionControl:
        return true;
      case QuizCategory.workingMemory:
      case QuizCategory.reactionTime:
      case QuizCategory.consistencyScore:
        return false;
    }
  }

  int _getTimeLimitSeconds() {
    final session = ref.read(quizSessionProvider);
    final question = session?.currentQuestion;
    if (question?.timeLimitMs != null) {
      return (question!.timeLimitMs! / 1000).ceil();
    }
    return 30;
  }

  void _onAnswer(String answer) {
    final elapsed = ref.read(elapsedTimerProvider.notifier).stop();
    ref.read(quizSessionProvider.notifier).recordAnswer(answer, elapsed);

    final session = ref.read(quizSessionProvider);
    if (session != null && session.isComplete) {
      _onComplete();
    } else {
      ref.read(elapsedTimerProvider.notifier).restart();
      if (_hasCountdown) {
        ref.read(countdownTimerProvider.notifier).start(_getTimeLimitSeconds());
      }
    }
  }

  void _onComplete() {
    final result = ref.read(quizSessionProvider.notifier).buildResult();
    if (result != null) {
      ref.read(latestResultProvider.notifier).state = result;
      ref.read(quizSessionProvider.notifier).submitResult();
    }
    ref.read(countdownTimerProvider.notifier).reset();
    ref.read(elapsedTimerProvider.notifier).stop();
    context.go('/quiz/${widget.category.slug}/result');
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(quizSessionProvider);
    final countdown = ref.watch(countdownTimerProvider);

    if (session == null) {
      return const Scaffold(
        body: Center(child: Text('No active session')),
      );
    }

    // Auto-complete if countdown expired
    if (_hasCountdown && countdown <= 0 && ref.read(countdownTimerProvider.notifier).isExpired) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _onAnswer('');
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.label),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            ref.read(quizSessionProvider.notifier).abandon();
            ref.read(countdownTimerProvider.notifier).reset();
            ref.read(elapsedTimerProvider.notifier).stop();
            context.go('/');
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress
              QuizProgressBar(
                current: session.currentIndex + 1,
                total: session.totalQuestions,
                color: widget.category.color,
              ),

              if (_hasCountdown) ...[
                const SizedBox(height: 12),
                CountdownTimerWidget(
                  remainingSeconds: countdown,
                  totalSeconds: ref.read(countdownTimerProvider.notifier).totalSeconds,
                  color: widget.category.color,
                ),
              ],

              const SizedBox(height: 24),

              // Quiz body — delegated to category-specific widget
              Expanded(
                child: _buildCategoryWidget(session),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryWidget(QuizSession session) {
    final question = session.currentQuestion;
    if (question == null) return const SizedBox.shrink();

    switch (widget.category) {
      case QuizCategory.processingSpeed:
        return ArithmeticChallenge(
          question: question,
          onAnswer: _onAnswer,
        );

      case QuizCategory.workingMemory:
        return NumberRecallWidget(
          question: question,
          onAnswer: _onAnswer,
        );

      case QuizCategory.logicalReasoning:
        return NumberSequenceWidget(
          question: question,
          onAnswer: _onAnswer,
        );

      case QuizCategory.mathReasoning:
        return MultiStepArithmeticWidget(
          question: question,
          onAnswer: _onAnswer,
        );

      case QuizCategory.reactionTime:
        return TapTargetWidget(
          question: question,
          onAnswer: _onAnswer,
          onReactionTime: (ms) {
            final elapsed = ms;
            ref.read(quizSessionProvider.notifier).recordAnswer('tapped', elapsed);
            final s = ref.read(quizSessionProvider);
            if (s != null && s.isComplete) {
              _onComplete();
            }
          },
        );

      case QuizCategory.attentionControl:
        return StroopTestWidget(
          question: question,
          onAnswer: _onAnswer,
        );

      case QuizCategory.consistencyScore:
        return const Center(child: Text('Consistency is a derived metric'));
    }
  }
}
