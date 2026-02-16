import 'question.dart';
import 'quiz_category.dart';

class AnswerRecord {
  const AnswerRecord({
    required this.questionId,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.responseTimeMs,
    required this.answeredAt,
  });

  final String questionId;
  final String userAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final int responseTimeMs;
  final DateTime answeredAt;

  Map<String, dynamic> toJson() {
    return {
      'questionId': questionId,
      'userAnswer': userAnswer,
      'correctAnswer': correctAnswer,
      'isCorrect': isCorrect,
      'responseTimeMs': responseTimeMs,
      'answeredAt': answeredAt.toIso8601String(),
    };
  }

  factory AnswerRecord.fromJson(Map<String, dynamic> json) {
    return AnswerRecord(
      questionId: json['questionId'] as String,
      userAnswer: json['userAnswer'] as String,
      correctAnswer: json['correctAnswer'] as String,
      isCorrect: json['isCorrect'] as bool,
      responseTimeMs: json['responseTimeMs'] as int,
      answeredAt: DateTime.parse(json['answeredAt'] as String),
    );
  }
}

enum SessionStatus { notStarted, inProgress, completed, abandoned }

class QuizSession {
  const QuizSession({
    required this.category,
    required this.questions,
    this.currentIndex = 0,
    this.answers = const [],
    this.status = SessionStatus.notStarted,
    this.startedAt,
    this.completedAt,
  });

  final QuizCategory category;
  final List<Question> questions;
  final int currentIndex;
  final List<AnswerRecord> answers;
  final SessionStatus status;
  final DateTime? startedAt;
  final DateTime? completedAt;

  int get totalQuestions => questions.length;
  int get correctAnswers => answers.where((a) => a.isCorrect).length;
  bool get isComplete => currentIndex >= totalQuestions || status == SessionStatus.completed;

  Question? get currentQuestion =>
      currentIndex < questions.length ? questions[currentIndex] : null;

  double get accuracyPercent =>
      answers.isEmpty ? 0 : (correctAnswers / answers.length) * 100;

  double get avgResponseTimeMs => answers.isEmpty
      ? 0
      : answers.map((a) => a.responseTimeMs).reduce((a, b) => a + b) /
          answers.length;

  List<double> get responseTimes =>
      answers.map((a) => a.responseTimeMs.toDouble()).toList();

  QuizSession copyWith({
    QuizCategory? category,
    List<Question>? questions,
    int? currentIndex,
    List<AnswerRecord>? answers,
    SessionStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return QuizSession(
      category: category ?? this.category,
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
