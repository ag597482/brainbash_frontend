import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../models/quiz_category.dart';
import '../../../providers/stats_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../widgets/radar_chart.dart';
import '../widgets/consistency_graph.dart';

/// Toggle for dashboard: show Avg score or Max score from /api/user/stats.
final dashboardScoreModeProvider =
    StateProvider<bool>((ref) => false); // false = Avg, true = Max

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final apiStatsAsync = ref.watch(apiUserStatsProvider);
    final userStatsAsync = ref.watch(userStatsProvider);
    final consistencyScore = ref.watch(consistencyScoreProvider);
    final overallScore = ref.watch(overallScoreProvider);
    final useMaxScore = ref.watch(dashboardScoreModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Brain Dashboard'),
      ),
      body: SafeArea(
        child: apiStatsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (apiStats) {
            final scores = <QuizCategory, double>{};
            if (apiStats != null) {
              for (final cat in QuizCategory.playable) {
                final stats = apiStats.categoryScores[cat];
                scores[cat] = useMaxScore
                    ? (stats?.maxScore ?? 0)
                    : (stats?.avgScore ?? 0);
              }
            } else {
              final profile = userStatsAsync.valueOrNull;
              for (final cat in QuizCategory.playable) {
                scores[cat] = profile?.categoryStats[cat]?.lastScore ?? 0;
              }
            }

            final profile = userStatsAsync.valueOrNull;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overall score banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Overall Brain Score',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(color: Colors.white70),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                overallScore > 0
                                    ? '${overallScore.round()}/100'
                                    : 'Take quizzes to build your score',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.psychology_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: -0.1),

                  const SizedBox(height: 24),

                  // Avg / Max toggle
                  Row(
                    children: [
                      Text(
                        'Cognitive Profile',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ToggleChip(
                              label: 'Avg',
                              selected: !useMaxScore,
                              onTap: () =>
                                  ref.read(dashboardScoreModeProvider.notifier).state = false,
                            ),
                            _ToggleChip(
                              label: 'Max',
                              selected: useMaxScore,
                              onTap: () =>
                                  ref.read(dashboardScoreModeProvider.notifier).state = true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardTheme.color,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: BrainRadarChart(scores: scores),
                  ).animate(delay: 200.ms).fadeIn(),

                  const SizedBox(height: 24),

                  // Category breakdown (uses same Avg/Max as toggle)
                  Text(
                    'Category Scores',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  ...QuizCategory.playable.asMap().entries.map((entry) {
                    final index = entry.key;
                    final cat = entry.value;
                    final score = scores[cat] ?? 0;
                    final catStats = apiStats?.categoryScores[cat];
                    final avgScore = catStats?.avgScore ?? 0;
                    final maxScore = catStats?.maxScore ?? 0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _CategoryScoreRow(
                        category: cat,
                        score: score,
                        showMode: true,
                        useMaxScore: useMaxScore,
                        avgScore: avgScore,
                        maxScore: maxScore,
                        attempts: profile?.categoryStats[cat]?.totalAttempts ?? 0,
                        bestScore: profile?.categoryStats[cat]?.bestScore ?? 0,
                      ),
                    )
                        .animate(delay: Duration(milliseconds: 100 * index))
                        .fadeIn()
                        .slideX(begin: -0.05);
                  }),

                  const SizedBox(height: 24),

                  // Consistency section
                  Text(
                    'Consistency Score',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
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
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: AppColors.consistencyScore
                                    .withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.auto_graph_rounded,
                                color: AppColors.consistencyScore,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              consistencyScore > 0
                                  ? '${consistencyScore.round()}/100'
                                  : 'Not enough data',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.consistencyScore,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Measures how stable your performance is across all tasks. '
                          'Lower variance = higher consistency.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 16),
                        ConsistencyGraph(
                          responseTimes:
                              profile?.allResponseTimes ?? [],
                        ),
                      ],
                    ),
                  ).animate(delay: 800.ms).fadeIn(),

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ToggleChip extends StatelessWidget {
  const _ToggleChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected
          ? AppColors.primary.withValues(alpha: 0.15)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? AppColors.primary : null,
                ),
          ),
        ),
      ),
    );
  }
}

class _CategoryScoreRow extends StatelessWidget {
  const _CategoryScoreRow({
    required this.category,
    required this.score,
    this.showMode = false,
    this.useMaxScore = false,
    this.avgScore = 0,
    this.maxScore = 0,
    this.attempts = 0,
    this.bestScore = 0,
  });

  final QuizCategory category;
  final double score;
  final bool showMode;
  final bool useMaxScore;
  final double avgScore;
  final double maxScore;
  final int attempts;
  final double bestScore;

  @override
  Widget build(BuildContext context) {
    String subtitle;
    if (showMode) {
      subtitle = useMaxScore
          ? 'Max: ${maxScore.round()}'
          : 'Avg: ${avgScore.round()}';
      if (attempts > 0) {
        subtitle += ' · $attempts attempts';
      }
    } else {
      subtitle = attempts > 0
          ? '$attempts attempts · Best: ${bestScore.round()}'
          : 'Not attempted';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: category.color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              category.icon,
              color: category.color,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.label,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: category.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              score > 0 ? '${score.round()}' : '--',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: category.color,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
