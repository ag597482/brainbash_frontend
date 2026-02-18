import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../models/quiz_category.dart';
import '../../../providers/quiz_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/metric_tile.dart';
import '../widgets/consistency_graph.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key, required this.category});

  final QuizCategory category;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(latestResultProvider);

    if (result == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No results available'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Go Home'),
              ),
            ],
          ),
        ),
      );
    }

    final score = result.normalizedScore;
    final grade = _getGrade(score);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 16),

              // Score circle
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      category.color.withValues(alpha: 0.2),
                      category.color.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(
                    color: category.color,
                    width: 4,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${score.round()}',
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                fontSize: 48,
                                fontWeight: FontWeight.w900,
                                color: category.color,
                              ),
                    ),
                    Text(
                      '/100',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: category.color,
                          ),
                    ),
                  ],
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    duration: 600.ms,
                    curve: Curves.elasticOut,
                  )
                  .fadeIn(duration: 300.ms),

              const SizedBox(height: 20),

              // Grade
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: grade.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  grade.label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: grade.color,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.2),

              const SizedBox(height: 12),
              Text(
                category.label,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ).animate(delay: 400.ms).fadeIn(),

              const SizedBox(height: 32),

              // Metrics grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.15,
                children: [
                  MetricTile(
                    label: 'Questions',
                    value: '${result.totalQuestions}',
                    icon: Icons.help_outline_rounded,
                    color: category.color,
                  ),
                  MetricTile(
                    label: 'Correct',
                    value: '${result.correctAnswers}',
                    unit: '/${result.totalQuestions}',
                    icon: Icons.check_circle_outline_rounded,
                    color: AppColors.success,
                  ),
                  MetricTile(
                    label: 'Accuracy',
                    value: '${result.accuracyPercent.round()}',
                    unit: '%',
                    icon: Icons.gps_fixed_rounded,
                    color: _getAccuracyColor(result.accuracyPercent),
                  ),
                  MetricTile(
                    label: 'Avg Time',
                    value: '${result.avgResponseTimeMs.round()}',
                    unit: 'ms',
                    icon: Icons.timer_outlined,
                    color: AppColors.reactionTime,
                  ),
                ],
              ).animate(delay: 500.ms).fadeIn(),

              const SizedBox(height: 24),

              // Response time chart
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Response Times',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ConsistencyGraph(responseTimes: result.responseTimes),
                  ],
                ),
              ).animate(delay: 600.ms).fadeIn().slideY(begin: 0.1),

              const SizedBox(height: 32),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => context.go('/'),
                      icon: const Icon(Icons.home_rounded),
                      label: const Text('Home'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref.read(quizSessionProvider.notifier).clear();
                        context.go('/quiz/${category.slug}/intro');
                      },
                      icon: const Icon(Icons.replay_rounded),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: category.color,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ).animate(delay: 700.ms).fadeIn(),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  _Grade _getGrade(double score) {
    if (score >= 90) return _Grade('Exceptional!', AppColors.success);
    if (score >= 75) return _Grade('Great Job!', AppColors.primary);
    if (score >= 60) return _Grade('Good Effort', AppColors.secondary);
    if (score >= 40) return _Grade('Keep Trying', AppColors.warning);
    return _Grade('Needs Practice', AppColors.error);
  }

  Color _getAccuracyColor(double accuracy) {
    if (accuracy >= 90) return AppColors.success;
    if (accuracy >= 70) return AppColors.primary;
    if (accuracy >= 50) return AppColors.warning;
    return AppColors.error;
  }
}

class _Grade {
  const _Grade(this.label, this.color);
  final String label;
  final Color color;
}
