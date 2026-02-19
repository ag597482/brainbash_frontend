import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/dashboard_leaderboard.dart';
import '../../../models/quiz_category.dart';
import '../../../providers/dashboard_provider.dart';

/// Backend game type keys in display order.
const _gameTypeKeys = [
  'processing_speed',
  'working_memory',
  'logical_reasoning',
  'math_reasoning',
  'reflex_time',
  'attention_control',
];

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  String _selectedGameType = _gameTypeKeys.first;

  @override
  void initState() {
    super.initState();
    // Refetch leaderboard data every time user opens this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(dashboardLeaderboardProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardLeaderboardProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardLeaderboardProvider);
            await ref.read(dashboardLeaderboardProvider.future);
          },
          child: CustomScrollView(
            slivers: [
            SliverAppBar(
              pinned: true,
              title: const Text('Leaderboard'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => context.pop(),
                tooltip: 'Back',
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Text(
                  'Select a game to see top sessions',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ),
            ),
            // Game type selector
            SliverToBoxAdapter(
              child: _GameTypeSelector(
                selectedKey: _selectedGameType,
                onSelected: (key) => setState(() => _selectedGameType = key),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
            dashboardAsync.when(
              data: (data) {
                final entries = data.entriesFor(_selectedGameType);
                if (entries.isEmpty) {
                  return SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyLeaderboard(
                      gameType: _selectedGameType,
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final entry = entries[index];
                        return _LeaderboardTile(
                          rank: index + 1,
                          entry: entry,
                          gameType: _selectedGameType,
                        )
                            .animate()
                            .fadeIn(duration: 200.ms, delay: (50 * index).ms)
                            .slideY(begin: 0.05, end: 0, duration: 250.ms, delay: (50 * index).ms);
                      },
                      childCount: entries.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.cloud_off_rounded,
                          size: 48,
                          color: AppColors.textHint,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Could not load leaderboard',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          err.toString(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () =>
                              ref.invalidate(dashboardLeaderboardProvider),
                          icon: const Icon(Icons.refresh_rounded, size: 20),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
          ),
        ),
      ),
    );
  }
}

class _GameTypeSelector extends StatelessWidget {
  const _GameTypeSelector({
    required this.selectedKey,
    required this.onSelected,
  });

  final String selectedKey;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: _gameTypeKeys.map((key) {
          final category = QuizCategory.fromBackendGameType(key);
          final isSelected = key == selectedKey;
          final label = category?.label ?? _formatKey(key);
          final icon = category?.icon ?? Icons.sports_esports_rounded;
          final color = category?.color ?? AppColors.primary;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Material(
              color: isSelected
                  ? color.withValues(alpha: 0.18)
                  : Theme.of(context).cardTheme.color,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                onTap: () => onSelected(key),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? color : AppColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 20,
                        color: isSelected ? color : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? color : AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  static String _formatKey(String key) {
    return key.replaceAll('_', ' ').split(' ').map((s) {
      if (s.isEmpty) return s;
      return '${s[0].toUpperCase()}${s.substring(1).toLowerCase()}';
    }).join(' ');
  }
}

class _LeaderboardTile extends StatelessWidget {
  const _LeaderboardTile({
    required this.rank,
    required this.entry,
    required this.gameType,
  });

  final int rank;
  final LeaderboardEntry entry;
  final String gameType;

  @override
  Widget build(BuildContext context) {
    final category = QuizCategory.fromBackendGameType(gameType);
    final color = category?.color ?? AppColors.primary;
    final score = entry.sessionScore.score;
    final accuracy = entry.sessionScore.accuracy;
    final questions = entry.sessionScore.questions;
    final correct = entry.sessionScore.correct;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: color.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Rank
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _rankColor(rank).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Text(
                '$rank',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: _rankColor(rank),
                    ),
              ),
            ),
            const SizedBox(width: 12),
            // Avatar
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withValues(alpha: 0.15),
              backgroundImage: entry.user.photo != null && entry.user.photo!.isNotEmpty
                  ? NetworkImage(entry.user.photo!)
                  : null,
              child: entry.user.photo == null || entry.user.photo!.isEmpty
                  ? Text(
                      entry.user.name.isNotEmpty
                          ? entry.user.name[0].toUpperCase()
                          : '?',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                          ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            // Name & stats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.user.name,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Score ${score.toStringAsFixed(1)} · $correct/$questions correct · ${(accuracy * 100).toStringAsFixed(0)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Score badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                score.toStringAsFixed(0),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _rankColor(int rank) {
    if (rank == 1) return const Color(0xFFFFD700); // gold
    if (rank == 2) return const Color(0xFFC0C0C0); // silver
    if (rank == 3) return const Color(0xFFCD7F32); // bronze
    return AppColors.primary;
  }
}

class _EmptyLeaderboard extends StatelessWidget {
  const _EmptyLeaderboard({required this.gameType});

  final String gameType;

  @override
  Widget build(BuildContext context) {
    final category = QuizCategory.fromBackendGameType(gameType);
    final label = category?.label ?? gameType.replaceAll('_', ' ');
    final icon = category?.icon ?? Icons.emoji_events_rounded;
    final color = category?.color ?? AppColors.primary;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 48, color: color.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 20),
            Text(
              'No sessions yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to post a score in $label!',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
