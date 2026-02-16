import 'quiz_category.dart';

enum QuestionType {
  multipleChoice,
  textInput,
  tapTarget,
  sequenceRecall,
  stroopColor,
  patternMatch,
}

class Question {
  const Question({
    required this.id,
    required this.category,
    required this.type,
    required this.prompt,
    this.options,
    required this.correctAnswer,
    this.imageUrl,
    this.timeLimitMs,
    this.metadata = const {},
  });

  final String id;
  final QuizCategory category;
  final QuestionType type;
  final String prompt;
  final List<String>? options;
  final String correctAnswer;
  final String? imageUrl;
  final int? timeLimitMs;
  final Map<String, dynamic> metadata;

  Question copyWith({
    String? id,
    QuizCategory? category,
    QuestionType? type,
    String? prompt,
    List<String>? options,
    String? correctAnswer,
    String? imageUrl,
    int? timeLimitMs,
    Map<String, dynamic>? metadata,
  }) {
    return Question(
      id: id ?? this.id,
      category: category ?? this.category,
      type: type ?? this.type,
      prompt: prompt ?? this.prompt,
      options: options ?? this.options,
      correctAnswer: correctAnswer ?? this.correctAnswer,
      imageUrl: imageUrl ?? this.imageUrl,
      timeLimitMs: timeLimitMs ?? this.timeLimitMs,
      metadata: metadata ?? this.metadata,
    );
  }

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      category: QuizCategory.values.firstWhere(
        (c) => c.name == json['category'],
      ),
      type: QuestionType.values.firstWhere(
        (t) => t.name == json['type'],
      ),
      prompt: json['prompt'] as String,
      options: (json['options'] as List<dynamic>?)?.cast<String>(),
      correctAnswer: json['correctAnswer'] as String,
      imageUrl: json['imageUrl'] as String?,
      timeLimitMs: json['timeLimitMs'] as int?,
      metadata: (json['metadata'] as Map<String, dynamic>?) ?? {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category': category.name,
      'type': type.name,
      'prompt': prompt,
      'options': options,
      'correctAnswer': correctAnswer,
      'imageUrl': imageUrl,
      'timeLimitMs': timeLimitMs,
      'metadata': metadata,
    };
  }
}
