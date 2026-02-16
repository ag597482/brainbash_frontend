import 'quiz_category.dart';
import 'quiz_session.dart';

class QuizResult {
  const QuizResult({
    required this.id,
    required this.category,
    required this.normalizedScore,
    required this.rawMetrics,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.avgResponseTimeMs,
    required this.responseTimes,
    required this.completedAt,
    this.answers = const [],
  });

  final String id;
  final QuizCategory category;
  final double normalizedScore;
  final Map<String, dynamic> rawMetrics;
  final int totalQuestions;
  final int correctAnswers;
  final double avgResponseTimeMs;
  final List<double> responseTimes;
  final DateTime completedAt;
  final List<AnswerRecord> answers;

  double get accuracyPercent =>
      totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      id: json['id'] as String,
      category: QuizCategory.values.firstWhere(
        (c) => c.name == json['category'],
      ),
      normalizedScore: (json['normalizedScore'] as num).toDouble(),
      rawMetrics: json['rawMetrics'] as Map<String, dynamic>,
      totalQuestions: json['totalQuestions'] as int,
      correctAnswers: json['correctAnswers'] as int,
      avgResponseTimeMs: (json['avgResponseTimeMs'] as num).toDouble(),
      responseTimes: (json['responseTimes'] as List).cast<double>(),
      completedAt: DateTime.parse(json['completedAt'] as String),
      answers: (json['answers'] as List?)
              ?.map((a) => AnswerRecord.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category.name,
      'normalizedScore': normalizedScore,
      'rawMetrics': rawMetrics,
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
      'avgResponseTimeMs': avgResponseTimeMs,
      'responseTimes': responseTimes,
      'completedAt': completedAt.toIso8601String(),
      'answers': answers.map((a) => a.toJson()).toList(),
    };
  }
}
