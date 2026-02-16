import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile.dart';
import '../models/quiz_category.dart';
import '../core/utils/scoring_engine.dart';
import '../services/stats_service.dart';
import 'auth_provider.dart';

final statsServiceProvider = Provider<StatsService>((ref) {
  return StatsService(apiClient: ref.watch(apiClientProvider));
});

/// Fetches user stats from backend. Use ref.refresh to reload.
final userStatsProvider = FutureProvider<UserProfile?>((ref) async {
  final auth = ref.watch(authProvider);
  if (!auth.isAuthenticated) return null;

  final statsService = ref.watch(statsServiceProvider);
  try {
    return await statsService.getUserStats();
  } catch (_) {
    return auth.user;
  }
});

/// Derives the consistency score from all response times across categories.
final consistencyScoreProvider = Provider<double>((ref) {
  final statsAsync = ref.watch(userStatsProvider);
  return statsAsync.when(
    data: (profile) {
      if (profile == null || profile.allResponseTimes.isEmpty) return 0.0;
      return ScoringEngine.computeConsistencyScore(profile.allResponseTimes);
    },
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});

/// Overall brain score: average of all category normalized scores.
final overallScoreProvider = Provider<double>((ref) {
  final statsAsync = ref.watch(userStatsProvider);
  return statsAsync.when(
    data: (profile) {
      if (profile == null) return 0.0;
      final scores = QuizCategory.playable
          .map((c) => profile.categoryStats[c]?.lastScore)
          .whereType<double>()
          .toList();
      if (scores.isEmpty) return 0.0;
      return scores.reduce((a, b) => a + b) / scores.length;
    },
    loading: () => 0.0,
    error: (_, __) => 0.0,
  );
});
