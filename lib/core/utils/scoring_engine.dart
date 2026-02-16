import 'dart:math';
import '../../models/quiz_category.dart';

/// Normalizes raw metrics into 0-100 scores and computes consistency.
class ScoringEngine {
  ScoringEngine._();

  /// Normalize a processing speed average response time (ms) to 0-100.
  /// Lower time = higher score. Range: 500ms (100) to 5000ms (0).
  static double normalizeProcessingSpeed(double avgResponseMs) {
    return _inverseNormalize(avgResponseMs, 500, 5000);
  }

  /// Normalize working memory max sequence length to 0-100.
  /// Range: 3 digits (0) to 12 digits (100).
  static double normalizeWorkingMemory(int maxSequenceLength) {
    return _linearNormalize(maxSequenceLength.toDouble(), 3, 12);
  }

  /// Logical reasoning accuracy is already a percentage.
  static double normalizeLogicalReasoning(double accuracyPercent) {
    return accuracyPercent.clamp(0.0, 100.0);
  }

  /// Math reasoning: weighted combination of accuracy and speed.
  static double normalizeMathReasoning(double accuracyPercent, double avgTimeSeconds) {
    final accuracyScore = accuracyPercent.clamp(0.0, 100.0);
    final speedBonus = _inverseNormalize(avgTimeSeconds, 5, 60);
    return (accuracyScore * 0.7 + speedBonus * 0.3).clamp(0.0, 100.0);
  }

  /// Normalize reaction time (ms) to 0-100.
  /// Range: 150ms (100) to 800ms (0).
  static double normalizeReactionTime(double avgReactionMs) {
    return _inverseNormalize(avgReactionMs, 150, 800);
  }

  /// Normalize attention control error rate to 0-100.
  /// Lower error rate = higher score.
  static double normalizeAttentionControl(double errorRate) {
    return _inverseNormalize(errorRate, 0, 0.5) ;
  }

  /// Compute consistency score from response time standard deviations.
  /// Lower variance = higher consistency = higher score.
  static double computeConsistencyScore(List<double> responseTimes) {
    if (responseTimes.length < 2) return 0.0;
    final mean = responseTimes.reduce((a, b) => a + b) / responseTimes.length;
    final variance = responseTimes.map((t) => pow(t - mean, 2)).reduce((a, b) => a + b) / responseTimes.length;
    final stdDev = sqrt(variance);
    final coefficientOfVariation = mean > 0 ? stdDev / mean : 1.0;
    return _inverseNormalize(coefficientOfVariation, 0.05, 0.8);
  }

  /// Normalize a score for a given category from its raw metric.
  static double normalizeForCategory(QuizCategory category, Map<String, dynamic> rawMetrics) {
    switch (category) {
      case QuizCategory.processingSpeed:
        return normalizeProcessingSpeed(rawMetrics['avgResponseMs'] as double);
      case QuizCategory.workingMemory:
        return normalizeWorkingMemory(rawMetrics['maxSequenceLength'] as int);
      case QuizCategory.logicalReasoning:
        return normalizeLogicalReasoning(rawMetrics['accuracyPercent'] as double);
      case QuizCategory.mathReasoning:
        return normalizeMathReasoning(
          rawMetrics['accuracyPercent'] as double,
          rawMetrics['avgTimeSeconds'] as double,
        );
      case QuizCategory.reactionTime:
        return normalizeReactionTime(rawMetrics['avgReactionMs'] as double);
      case QuizCategory.attentionControl:
        return normalizeAttentionControl(rawMetrics['errorRate'] as double);
      case QuizCategory.consistencyScore:
        return computeConsistencyScore(
          (rawMetrics['responseTimes'] as List).cast<double>(),
        );
    }
  }

  /// Linear normalization: value in [minVal, maxVal] -> [0, 100].
  static double _linearNormalize(double value, double minVal, double maxVal) {
    return ((value - minVal) / (maxVal - minVal) * 100).clamp(0.0, 100.0);
  }

  /// Inverse normalization: lower value = higher score.
  static double _inverseNormalize(double value, double bestVal, double worstVal) {
    return ((worstVal - value) / (worstVal - bestVal) * 100).clamp(0.0, 100.0);
  }
}
