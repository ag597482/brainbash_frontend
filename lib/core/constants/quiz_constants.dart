class QuizConstants {
  QuizConstants._();

  // General quiz settings
  static const int defaultQuestionCount = 10;
  static const int defaultTimeLimitSeconds = 30;

  // Processing Speed
  static const int processingSpeedTimeLimitMs = 5000;
  static const int processingSpeedQuestionCount = 15;

  // Working Memory
  static const int workingMemoryStartLength = 3;
  static const int workingMemoryMaxLength = 12;
  static const int workingMemoryDisplayTimeMs = 1000; // per digit

  // Logical Reasoning
  static const int logicalReasoningTimeLimitSeconds = 45;
  static const int logicalReasoningQuestionCount = 10;

  // Math Reasoning
  static const int mathReasoningTimeLimitSeconds = 60;
  static const int mathReasoningQuestionCount = 8;

  // Reaction Time
  static const int reactionTimeTrials = 5;
  static const int reactionTimeMinDelayMs = 1000;
  static const int reactionTimeMaxDelayMs = 5000;

  // Attention Control
  static const int attentionControlTrials = 20;
  static const int attentionControlTimeLimitSeconds = 60;

  // Scoring thresholds (for normalization to 0-100)
  static const double excellentThreshold = 90.0;
  static const double goodThreshold = 70.0;
  static const double averageThreshold = 50.0;
  static const double belowAverageThreshold = 30.0;

  // Reaction time benchmarks (ms)
  static const double reactionExcellentMs = 200.0;
  static const double reactionGoodMs = 300.0;
  static const double reactionAverageMs = 400.0;
  static const double reactionSlowMs = 600.0;
}
