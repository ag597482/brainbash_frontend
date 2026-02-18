import 'quiz_category.dart';

/// Per-category scores from /api/user/stats.
class CategoryScoreStats {
  const CategoryScoreStats({
    required this.avgScore,
    required this.maxScore,
  });

  final double avgScore;
  final double maxScore;

  factory CategoryScoreStats.fromJson(Map<String, dynamic> json) {
    return CategoryScoreStats(
      avgScore: (json['avg_score'] as num?)?.toDouble() ?? 0,
      maxScore: (json['max_score'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Response from GET /api/user/stats.
class UserStatsApiResponse {
  const UserStatsApiResponse({
    required this.overallScore,
    required this.categoryScores,
  });

  final double overallScore;
  final Map<QuizCategory, CategoryScoreStats> categoryScores;

  factory UserStatsApiResponse.fromJson(Map<String, dynamic> json) {
    final categoryScores = <QuizCategory, CategoryScoreStats>{};
    final raw = json;
    for (final key in raw.keys) {
      if (key == 'overall_score') continue;
      if (raw[key] is! Map<String, dynamic>) continue;
      final cat = QuizCategory.fromBackendGameType(key);
      if (cat != null) {
        categoryScores[cat] = CategoryScoreStats.fromJson(
          raw[key] as Map<String, dynamic>,
        );
      }
    }
    return UserStatsApiResponse(
      overallScore: (json['overall_score'] as num?)?.toDouble() ?? 0,
      categoryScores: categoryScores,
    );
  }
}
