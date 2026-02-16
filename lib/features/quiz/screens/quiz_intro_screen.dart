import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../models/quiz_category.dart';
import '../../../models/question.dart';
import '../../../providers/quiz_provider.dart';
import '../../../core/constants/quiz_constants.dart';
import '../../../core/theme/app_colors.dart';

/// Generates local demo questions for a given category.
List<Question> _generateDemoQuestions(QuizCategory category) {
  final random = Random();

  switch (category) {
    case QuizCategory.processingSpeed:
      return List.generate(QuizConstants.processingSpeedQuestionCount, (i) {
        final a = random.nextInt(20) + 1;
        final b = random.nextInt(20) + 1;
        final ops = ['+', '-', '×'];
        final op = ops[random.nextInt(ops.length)];
        int answer;
        switch (op) {
          case '+':
            answer = a + b;
          case '-':
            answer = a - b;
          default:
            answer = a * b;
        }
        final wrong1 = answer + random.nextInt(5) + 1;
        final wrong2 = answer - random.nextInt(5) - 1;
        final wrong3 = answer + random.nextInt(10) - 5;
        final options = {answer.toString(), wrong1.toString(), wrong2.toString(), wrong3.toString()}.toList()..shuffle();
        if (!options.contains(answer.toString())) {
          options[0] = answer.toString();
          options.shuffle();
        }
        return Question(
          id: 'ps_$i',
          category: category,
          type: QuestionType.multipleChoice,
          prompt: '$a $op $b = ?',
          options: options.take(4).toList(),
          correctAnswer: answer.toString(),
          timeLimitMs: QuizConstants.processingSpeedTimeLimitMs,
        );
      });

    case QuizCategory.workingMemory:
      return List.generate(8, (i) {
        final length = QuizConstants.workingMemoryStartLength + i;
        final digits = List.generate(length, (_) => random.nextInt(10).toString()).join('');
        return Question(
          id: 'wm_$i',
          category: category,
          type: QuestionType.sequenceRecall,
          prompt: digits,
          correctAnswer: digits,
          metadata: {'sequenceLength': length},
        );
      });

    case QuizCategory.logicalReasoning:
      final sequences = [
        (['2', '4', '6', '8', '?'], '10', ['9', '10', '11', '12']),
        (['1', '4', '9', '16', '?'], '25', ['20', '25', '30', '36']),
        (['3', '6', '12', '24', '?'], '48', ['36', '48', '50', '72']),
        (['1', '1', '2', '3', '5', '?'], '8', ['6', '7', '8', '10']),
        (['2', '6', '18', '54', '?'], '162', ['108', '162', '180', '216']),
        (['100', '81', '64', '49', '?'], '36', ['25', '36', '42', '30']),
        (['1', '3', '6', '10', '?'], '15', ['12', '14', '15', '18']),
        (['5', '10', '20', '40', '?'], '80', ['60', '70', '80', '100']),
        (['1', '8', '27', '64', '?'], '125', ['100', '125', '150', '216']),
        (['2', '3', '5', '7', '11', '?'], '13', ['12', '13', '14', '15']),
      ];
      return List.generate(min(QuizConstants.logicalReasoningQuestionCount, sequences.length), (i) {
        final (seq, answer, opts) = sequences[i];
        return Question(
          id: 'lr_$i',
          category: category,
          type: QuestionType.multipleChoice,
          prompt: 'What comes next?\n${seq.join(', ')}',
          options: opts,
          correctAnswer: answer,
          timeLimitMs: QuizConstants.logicalReasoningTimeLimitSeconds * 1000,
        );
      });

    case QuizCategory.mathReasoning:
      final problems = [
        ('If you buy 3 apples at \$2 each and 2 oranges at \$3 each, how much do you spend?', '12', ['\$10', '\$11', '\$12', '\$15']),
        ('A train travels 120km in 2 hours. What is its speed in km/h?', '60', ['40', '60', '80', '120']),
        ('What is 15% of 200?', '30', ['20', '25', '30', '35']),
        ('If x + 7 = 15, what is x?', '8', ['6', '7', '8', '9']),
        ('A rectangle has length 8 and width 5. What is its area?', '40', ['30', '35', '40', '45']),
        ('What is 3/4 + 1/2?', '5/4', ['1', '5/4', '3/2', '7/4']),
        ('If 2x - 4 = 10, what is x?', '7', ['5', '6', '7', '8']),
        ('A circle has radius 7. What is its diameter?', '14', ['7', '14', '21', '49']),
      ];
      return List.generate(min(QuizConstants.mathReasoningQuestionCount, problems.length), (i) {
        final (prompt, answer, opts) = problems[i];
        return Question(
          id: 'mr_$i',
          category: category,
          type: QuestionType.multipleChoice,
          prompt: prompt,
          options: opts,
          correctAnswer: answer,
          timeLimitMs: QuizConstants.mathReasoningTimeLimitSeconds * 1000,
        );
      });

    case QuizCategory.reactionTime:
      return List.generate(QuizConstants.reactionTimeTrials, (i) {
        return Question(
          id: 'rt_$i',
          category: category,
          type: QuestionType.tapTarget,
          prompt: 'Tap as soon as the target appears!',
          correctAnswer: 'tapped',
          metadata: {
            'minDelayMs': QuizConstants.reactionTimeMinDelayMs,
            'maxDelayMs': QuizConstants.reactionTimeMaxDelayMs,
          },
        );
      });

    case QuizCategory.attentionControl:
      final stroopItems = [
        ('RED', Colors.blue.toARGB32(), 'Blue'),
        ('BLUE', Colors.red.toARGB32(), 'Red'),
        ('GREEN', Colors.yellow.toARGB32(), 'Yellow'),
        ('YELLOW', Colors.green.toARGB32(), 'Green'),
        ('RED', Colors.green.toARGB32(), 'Green'),
        ('BLUE', Colors.yellow.toARGB32(), 'Yellow'),
        ('GREEN', Colors.red.toARGB32(), 'Red'),
        ('YELLOW', Colors.blue.toARGB32(), 'Blue'),
        ('RED', Colors.red.toARGB32(), 'Red'),
        ('BLUE', Colors.blue.toARGB32(), 'Blue'),
        ('GREEN', Colors.green.toARGB32(), 'Green'),
        ('YELLOW', Colors.yellow.toARGB32(), 'Yellow'),
        ('RED', Colors.yellow.toARGB32(), 'Yellow'),
        ('BLUE', Colors.green.toARGB32(), 'Green'),
        ('GREEN', Colors.blue.toARGB32(), 'Blue'),
        ('YELLOW', Colors.red.toARGB32(), 'Red'),
        ('RED', Colors.blue.toARGB32(), 'Blue'),
        ('GREEN', Colors.yellow.toARGB32(), 'Yellow'),
        ('BLUE', Colors.red.toARGB32(), 'Red'),
        ('YELLOW', Colors.green.toARGB32(), 'Green'),
      ];
      return List.generate(min(QuizConstants.attentionControlTrials, stroopItems.length), (i) {
        final (word, colorValue, colorName) = stroopItems[i];
        return Question(
          id: 'ac_$i',
          category: category,
          type: QuestionType.stroopColor,
          prompt: word,
          options: ['Red', 'Blue', 'Green', 'Yellow'],
          correctAnswer: colorName,
          metadata: {'displayColor': colorValue},
        );
      });

    case QuizCategory.consistencyScore:
      return [];
  }
}

class QuizIntroScreen extends ConsumerWidget {
  const QuizIntroScreen({super.key, required this.category});

  final QuizCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Back button
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  onPressed: () => context.pop(),
                ),
              ),

              const Spacer(),

              // Category icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: category.color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  category.icon,
                  size: 64,
                  color: category.color,
                ),
              )
                  .animate()
                  .scale(
                      begin: const Offset(0.5, 0.5),
                      duration: 500.ms,
                      curve: Curves.elasticOut)
                  .fadeIn(duration: 300.ms),

              const SizedBox(height: 32),

              // Title
              Text(
                category.label,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                textAlign: TextAlign.center,
              ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.2),

              const SizedBox(height: 12),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  category.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                  textAlign: TextAlign.center,
                ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),
              ),

              const SizedBox(height: 32),

              // Info chips
              _buildInfoChips(context),

              const Spacer(),

              // Start button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    final questions = _generateDemoQuestions(category);
                    ref
                        .read(quizSessionProvider.notifier)
                        .initSession(category, questions);
                    context.go('/quiz/${category.slug}/play');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: category.color,
                  ),
                  child: const Text(
                    'Start Challenge',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
              ).animate(delay: 500.ms).fadeIn().slideY(begin: 0.3),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChips(BuildContext context) {
    final chips = <(IconData, String)>[];

    switch (category) {
      case QuizCategory.processingSpeed:
        chips.addAll([
          (Icons.help_outline_rounded, '${QuizConstants.processingSpeedQuestionCount} questions'),
          (Icons.timer_outlined, '5s per question'),
        ]);
      case QuizCategory.workingMemory:
        chips.addAll([
          (Icons.help_outline_rounded, '8 rounds'),
          (Icons.trending_up_rounded, 'Increasing difficulty'),
        ]);
      case QuizCategory.logicalReasoning:
        chips.addAll([
          (Icons.help_outline_rounded, '${QuizConstants.logicalReasoningQuestionCount} questions'),
          (Icons.timer_outlined, '45s per question'),
        ]);
      case QuizCategory.mathReasoning:
        chips.addAll([
          (Icons.help_outline_rounded, '${QuizConstants.mathReasoningQuestionCount} questions'),
          (Icons.timer_outlined, '60s per question'),
        ]);
      case QuizCategory.reactionTime:
        chips.addAll([
          (Icons.help_outline_rounded, '${QuizConstants.reactionTimeTrials} trials'),
          (Icons.touch_app_rounded, 'Tap quickly!'),
        ]);
      case QuizCategory.attentionControl:
        chips.addAll([
          (Icons.help_outline_rounded, '${QuizConstants.attentionControlTrials} trials'),
          (Icons.palette_rounded, 'Name the color'),
        ]);
      case QuizCategory.consistencyScore:
        break;
    }

    return Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: chips.map((chip) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: category.color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: category.color.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(chip.$1, size: 16, color: category.color),
              const SizedBox(width: 6),
              Text(
                chip.$2,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: category.color,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        );
      }).toList(),
    ).animate(delay: 400.ms).fadeIn();
  }
}
