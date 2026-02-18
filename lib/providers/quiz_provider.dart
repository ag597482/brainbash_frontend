import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/question.dart';
import '../models/quiz_category.dart';
import '../models/quiz_result.dart';
import '../models/quiz_session.dart';
import '../core/utils/scoring_engine.dart';
import '../services/quiz_service.dart';
import 'auth_provider.dart';

final quizServiceProvider = Provider<QuizService>((ref) {
  return QuizService(apiClient: ref.watch(apiClientProvider));
});

class QuizSessionNotifier extends StateNotifier<QuizSession?> {
  QuizSessionNotifier(this._quizService) : super(null);

  final QuizService _quizService;

  /// Initialize a new quiz session for the given category with provided questions.
  void initSession(QuizCategory category, List<Question> questions) {
    state = QuizSession(
      category: category,
      questions: questions,
      status: SessionStatus.notStarted,
    );
  }

  /// Start the session.
  void startSession() {
    if (state == null) return;
    state = state!.copyWith(
      status: SessionStatus.inProgress,
      startedAt: DateTime.now(),
    );
  }

  /// Record an answer for the current question.
  void recordAnswer(String userAnswer, int responseTimeMs) {
    if (state == null || state!.currentQuestion == null) return;

    final question = state!.currentQuestion!;
    final record = AnswerRecord(
      questionId: question.id,
      userAnswer: userAnswer,
      correctAnswer: question.correctAnswer,
      isCorrect: userAnswer.trim().toLowerCase() ==
          question.correctAnswer.trim().toLowerCase(),
      responseTimeMs: responseTimeMs,
      answeredAt: DateTime.now(),
    );

    final newAnswers = [...state!.answers, record];
    final newIndex = state!.currentIndex + 1;
    final isComplete = newIndex >= state!.totalQuestions;

    state = state!.copyWith(
      answers: newAnswers,
      currentIndex: newIndex,
      status: isComplete ? SessionStatus.completed : state!.status,
      completedAt: isComplete ? DateTime.now() : null,
    );
  }

  /// Build a QuizResult from the completed session.
  QuizResult? buildResult() {
    if (state == null || state!.status != SessionStatus.completed) return null;

    final session = state!;
    final rawMetrics = _buildRawMetrics(session);
    final normalizedScore = ScoringEngine.normalizeForCategory(
      session.category,
      rawMetrics,
    );

    return QuizResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      category: session.category,
      normalizedScore: normalizedScore,
      rawMetrics: rawMetrics,
      totalQuestions: session.totalQuestions,
      correctAnswers: session.correctAnswers,
      avgResponseTimeMs: session.avgResponseTimeMs,
      responseTimes: session.responseTimes,
      completedAt: session.completedAt ?? DateTime.now(),
      answers: session.answers,
    );
  }

  Map<String, dynamic> _buildRawMetrics(QuizSession session) {
    switch (session.category) {
      case QuizCategory.processingSpeed:
        return {'avgResponseMs': session.avgResponseTimeMs};
      case QuizCategory.workingMemory:
        final maxLen = session.answers
            .where((a) => a.isCorrect)
            .length;
        return {'maxSequenceLength': maxLen.clamp(3, 12)};
      case QuizCategory.logicalReasoning:
        return {'accuracyPercent': session.accuracyPercent};
      case QuizCategory.mathReasoning:
        return {
          'accuracyPercent': session.accuracyPercent,
          'avgTimeSeconds': session.avgResponseTimeMs / 1000,
        };
      case QuizCategory.reactionTime:
        return {'avgReactionMs': session.avgResponseTimeMs};
      case QuizCategory.attentionControl:
        final errorRate = session.answers.isEmpty
            ? 0.0
            : session.answers.where((a) => !a.isCorrect).length /
                session.answers.length;
        return {'errorRate': errorRate};
      case QuizCategory.consistencyScore:
        return {'responseTimes': session.responseTimes};
    }
  }

  /// Submit result to POST /api/game/result and merge response (score, questions, correct, accuracy, avgTime) into result.
  Future<QuizResult?> submitResult() async {
    final result = buildResult();
    if (result == null) return null;
    try {
      final apiResponse = await _quizService.submitGameResult(result);
      if (apiResponse != null) {
        final merged = result.copyWith(
          normalizedScore: apiResponse.score,
          totalQuestions: apiResponse.questions,
          correctAnswers: apiResponse.correct,
          avgResponseTimeMs: apiResponse.avgTime * 1000,
        );
        return merged;
      }
      return result;
    } catch (_) {
      return result;
    }
  }

  /// Abandon the current session.
  void abandon() {
    if (state != null) {
      state = state!.copyWith(status: SessionStatus.abandoned);
    }
  }

  /// Clear the session.
  void clear() {
    state = null;
  }
}

final quizSessionProvider =
    StateNotifierProvider<QuizSessionNotifier, QuizSession?>((ref) {
  return QuizSessionNotifier(ref.watch(quizServiceProvider));
});

/// The latest result after a quiz is completed.
final latestResultProvider = StateProvider<QuizResult?>((ref) => null);
