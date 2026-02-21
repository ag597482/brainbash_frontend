import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../models/quiz_category.dart';
import '../../../providers/stats_provider.dart';
import '../widgets/stats_summary.dart';
import '../widgets/category_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/auth_provider.dart';
import '../../../widgets/google_logo.dart';

/// When guest taps Dashboard or Leaderboard, show sign-in dialog. Otherwise navigate.
void _onScoresTap(BuildContext context, WidgetRef ref, {required bool toLeaderboard}) {
  final isGuest = ref.read(authProvider).isGuest;
  if (!isGuest) {
    if (toLeaderboard) {
      context.push('/leaderboard');
    } else {
      context.push('/dashboard');
    }
    return;
  }
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Sign in to view scores'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Create an account or sign in with Google to see your Brain Dashboard, leaderboard, and save your progress.',
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              ref.read(authProvider.notifier).loginWithGoogle();
            },
            icon: const GoogleLogo(size: 20),
            label: const Text('Continue with Google'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
          ),
        ],
      ),
    ),
  );
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(userStatsProvider);
    final consistencyScore = ref.watch(consistencyScoreProvider);
    final playableCategories = QuizCategory.playable;

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App bar
            SliverAppBar(
              floating: true,
              title: Tooltip(
                message: 'Long press to change API base URL',
                child: GestureDetector(
                  onLongPress: () => context.push('/settings'),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/brainbash_logo.png',
                        width: 32,
                        height: 32,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'BrainBash',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.emoji_events_rounded),
                  onPressed: () => _onScoresTap(context, ref, toLeaderboard: true),
                  tooltip: 'Leaderboard',
                ),
                IconButton(
                  icon: const Icon(Icons.bar_chart_rounded),
                  onPressed: () => _onScoresTap(context, ref, toLeaderboard: false),
                  tooltip: 'Dashboard',
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded),
                  onPressed: () {
                    ref.read(authProvider.notifier).logout();
                  },
                  tooltip: 'Logout',
                ),
              ],
            ),

            // Stats summary
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: const StatsSummary()
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: -0.1, duration: 500.ms),
              ),
            ),

            // Section title
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Text(
                  'Choose a Challenge',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ),

            // Category grid
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.98,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final category = playableCategories[index];
                    final categoryStats = statsAsync.whenData(
                      (profile) => profile?.categoryStats[category],
                    );

                    return CategoryCard(
                      category: category,
                      stats: categoryStats.value,
                      animationDelay: Duration(milliseconds: 100 * index),
                      onTap: () {
                        context.push('/quiz/${category.slug}/intro');
                      },
                    );
                  },
                  childCount: playableCategories.length,
                ),
              ),
            ),

            // Consistency score card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: GestureDetector(
                  onTap: () => _onScoresTap(context, ref, toLeaderboard: false),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.consistencyScore.withValues(alpha: 0.15),
                          AppColors.consistencyScore.withValues(alpha: 0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            AppColors.consistencyScore.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.consistencyScore
                                .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.auto_graph_rounded,
                            color: AppColors.consistencyScore,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Consistency Score',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                consistencyScore > 0
                                    ? '${consistencyScore.round()}/100'
                                    : 'Complete quizzes to see your score',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppColors.consistencyScore,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 16,
                          color: AppColors.consistencyScore,
                        ),
                      ],
                    ),
                  ),
                )
                    .animate(delay: 600.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.1, duration: 400.ms),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
          ],
        ),
      ),
    );
  }
}
