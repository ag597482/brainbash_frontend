import 'quiz_category.dart';

class CategoryStats {
  const CategoryStats({
    required this.category,
    this.lastScore,
    this.bestScore,
    this.avgScore,
    this.totalAttempts = 0,
    this.lastAttemptAt,
  });

  final QuizCategory category;
  final double? lastScore;
  final double? bestScore;
  final double? avgScore;
  final int totalAttempts;
  final DateTime? lastAttemptAt;

  bool get hasAttempted => totalAttempts > 0;

  factory CategoryStats.fromJson(Map<String, dynamic> json) {
    return CategoryStats(
      category: QuizCategory.values.firstWhere(
        (c) => c.name == json['category'],
      ),
      lastScore: (json['lastScore'] as num?)?.toDouble(),
      bestScore: (json['bestScore'] as num?)?.toDouble(),
      avgScore: (json['avgScore'] as num?)?.toDouble(),
      totalAttempts: json['totalAttempts'] as int? ?? 0,
      lastAttemptAt: json['lastAttemptAt'] != null
          ? DateTime.parse(json['lastAttemptAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category.name,
      'lastScore': lastScore,
      'bestScore': bestScore,
      'avgScore': avgScore,
      'totalAttempts': totalAttempts,
      'lastAttemptAt': lastAttemptAt?.toIso8601String(),
    };
  }
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    this.email,
    this.avatarUrl,
    this.overallScore,
    this.streak = 0,
    this.categoryStats = const {},
    this.allResponseTimes = const [],
  });

  final String id;
  final String name;
  final String? email;
  final String? avatarUrl;
  final double? overallScore;
  final int streak;
  final Map<QuizCategory, CategoryStats> categoryStats;
  final List<double> allResponseTimes;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final statsMap = <QuizCategory, CategoryStats>{};
    if (json['categoryStats'] != null) {
      for (final entry in (json['categoryStats'] as Map<String, dynamic>).entries) {
        final category = QuizCategory.values.firstWhere(
          (c) => c.name == entry.key,
        );
        statsMap[category] = CategoryStats.fromJson(
          entry.value as Map<String, dynamic>,
        );
      }
    }

    // Support both API response (user_id, picture) and stored format (id, avatarUrl)
    final id = json['user_id'] as String? ?? json['id'] as String?;
    final name = json['name'] as String? ?? '';
    final email = json['email'] as String?;
    final avatarUrl = json['picture'] as String? ?? json['avatarUrl'] as String?;

    return UserProfile(
      id: id ?? '',
      name: name.isNotEmpty ? name : (email ?? 'User'),
      email: email,
      avatarUrl: avatarUrl,
      overallScore: (json['overallScore'] as num?)?.toDouble(),
      streak: json['streak'] as int? ?? 0,
      categoryStats: statsMap,
      allResponseTimes:
          (json['allResponseTimes'] as List?)?.cast<double>() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'avatarUrl': avatarUrl,
      'overallScore': overallScore,
      'streak': streak,
      'categoryStats': categoryStats.map(
        (k, v) => MapEntry(k.name, v.toJson()),
      ),
      'allResponseTimes': allResponseTimes,
    };
  }
}
