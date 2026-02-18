/// Response from POST /api/game/result.
class GameResultResponse {
  const GameResultResponse({
    required this.score,
    required this.questions,
    required this.correct,
    required this.accuracy,
    required this.avgTime,
  });

  final double score;
  final int questions;
  final int correct;
  /// Accuracy as 0..1 (multiply by 100 for percent).
  final double accuracy;
  /// Average time per question in seconds.
  final double avgTime;

  factory GameResultResponse.fromJson(Map<String, dynamic> json) {
    return GameResultResponse(
      score: (json['score'] as num?)?.toDouble() ?? 0,
      questions: (json['questions'] as num?)?.toInt() ?? 0,
      correct: (json['correct'] as num?)?.toInt() ?? 0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0,
      avgTime: (json['avgTime'] as num?)?.toDouble() ?? 0,
    );
  }
}
