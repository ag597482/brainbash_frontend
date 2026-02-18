import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user_profile.dart';
import '../models/user_stats_api.dart';
import '../models/quiz_category.dart';
import '../core/utils/scoring_engine.dart';
import '../services/stats_service.dart';
import 'auth_provider.dart';

final statsServiceProvider = Provider<StatsService>((ref) {
  return StatsService(apiClient: ref.watch(apiClientProvider));
});

/// Fetches user stats from GET /api/user/stats (overall_score + category avg/max). Use ref.refresh to reload.
final apiUserStatsProvider = FutureProvider<UserStatsApiResponse?>((ref) async {
  final auth = ref.watch(authProvider);
  if (!auth.isAuthenticated) return null;

  final statsService = ref.watch(statsServiceProvider);
  try {
    return await statsService.getApiUserStats();
  } catch (_) {
    return null;
  }
});

/// Cached user profile (no /stats call). Use auth user when available.
final userStatsProvider = FutureProvider<UserProfile?>((ref) async {
  final auth = ref.watch(authProvider);
  if (!auth.isAuthenticated) return null;
  return auth.user;
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

/// Overall brain score from /api/user/stats when available, else fallback from user profile.
final overallScoreProvider = Provider<double>((ref) {
  final apiStatsAsync = ref.watch(apiUserStatsProvider);
  final profileAsync = ref.watch(userStatsProvider);

  return apiStatsAsync.when(
    data: (apiStats) {
      if (apiStats != null && apiStats.overallScore > 0) {
        return apiStats.overallScore;
      }
      return profileAsync.when(
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
    },
    loading: () => profileAsync.when(
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
    ),
    error: (_, __) => profileAsync.when(
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
    ),
  );
});
