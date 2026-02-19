/// Response from GET /api/dashboard — leaderboards per game type.

class LeaderboardUser {
  const LeaderboardUser({
    required this.id,
    this.gaid,
    required this.name,
    this.email,
    this.photo,
  });

  final String id;
  final String? gaid;
  final String name;
  final String? email;
  final String? photo;

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    return LeaderboardUser(
      id: json['_id'] as String? ?? '',
      gaid: json['gaid'] as String?,
      name: json['name'] as String? ?? 'Unknown',
      email: json['email'] as String?,
      photo: json['photo'] as String?,
    );
  }
}

class SessionScore {
  const SessionScore({
    this.score = 0,
    this.questions = 0,
    this.correct = 0,
    this.accuracy = 0,
    this.avgTime,
  });

  final double score;
  final int questions;
  final int correct;
  final double accuracy;
  final double? avgTime;

  factory SessionScore.fromJson(Map<String, dynamic> json) {
    return SessionScore(
      score: (json['Score'] as num?)?.toDouble() ?? 0,
      questions: json['Questions'] as int? ?? 0,
      correct: json['Correct'] as int? ?? 0,
      accuracy: (json['Accuracy'] as num?)?.toDouble() ?? 0,
      avgTime: (json['AvgTime'] as num?)?.toDouble(),
    );
  }
}

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.sessionId,
    required this.user,
    required this.sessionScore,
    this.timestamp,
  });

  final String sessionId;
  final LeaderboardUser user;
  final SessionScore sessionScore;
  final DateTime? timestamp;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      sessionId: json['session_id'] as String? ?? '',
      user: LeaderboardUser.fromJson(
        (json['user'] as Map<String, dynamic>? ?? {}),
      ),
      sessionScore: SessionScore.fromJson(
        (json['session_score'] as Map<String, dynamic>? ?? {}),
      ),
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String)
          : null,
    );
  }
}

/// Keys match backend: attention_control, logical_reasoning, math_reasoning,
/// processing_speed, reflex_time, working_memory.
class DashboardLeaderboardResponse {
  const DashboardLeaderboardResponse({
    this.attentionControl = const [],
    this.logicalReasoning = const [],
    this.mathReasoning = const [],
    this.processingSpeed = const [],
    this.reflexTime = const [],
    this.workingMemory = const [],
  });

  final List<LeaderboardEntry> attentionControl;
  final List<LeaderboardEntry> logicalReasoning;
  final List<LeaderboardEntry> mathReasoning;
  final List<LeaderboardEntry> processingSpeed;
  final List<LeaderboardEntry> reflexTime;
  final List<LeaderboardEntry> workingMemory;

  factory DashboardLeaderboardResponse.fromJson(Map<String, dynamic> json) {
    List<LeaderboardEntry> parseList(dynamic value) {
      if (value is! List) return [];
      return value
          .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return DashboardLeaderboardResponse(
      attentionControl: parseList(json['attention_control']),
      logicalReasoning: parseList(json['logical_reasoning']),
      mathReasoning: parseList(json['math_reasoning']),
      processingSpeed: parseList(json['processing_speed']),
      reflexTime: parseList(json['reflex_time']),
      workingMemory: parseList(json['working_memory']),
    );
  }

  /// Get entries for a backend game type key (e.g. 'processing_speed').
  List<LeaderboardEntry> entriesFor(String gameType) {
    switch (gameType) {
      case 'attention_control':
        return attentionControl;
      case 'logical_reasoning':
        return logicalReasoning;
      case 'math_reasoning':
        return mathReasoning;
      case 'processing_speed':
        return processingSpeed;
      case 'reflex_time':
        return reflexTime;
      case 'working_memory':
        return workingMemory;
      default:
        return [];
    }
  }
}
