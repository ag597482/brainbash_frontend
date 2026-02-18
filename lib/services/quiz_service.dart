import 'api_client.dart';
import '../models/game_result_response.dart';
import '../models/question.dart';
import '../models/quiz_category.dart';
import '../models/quiz_result.dart';

class QuizService {
  QuizService({required this.apiClient});

  final ApiClient apiClient;

  Future<List<Question>> fetchQuestions(QuizCategory category) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/quiz/${category.name}/questions',
    );
    final data = response.data!;
    final questions = (data['questions'] as List)
        .map((q) => Question.fromJson(q as Map<String, dynamic>))
        .toList();
    return questions;
  }

  /// Submits game result to POST /api/game/result. Returns backend score/accuracy/etc.
  Future<GameResultResponse?> submitGameResult(QuizResult result) async {
    final gametype = result.category.backendGameType;
    if (gametype == null) return null;

    final questionResponses = result.category.isReflexTimeGame
        ? result.answers
            .map((a) => <String, dynamic>{
                  'time_taken': a.responseTimeMs / 1000.0,
                })
            .toList()
        : result.answers
            .map((a) => <String, dynamic>{
                  'time_taken': a.responseTimeMs / 1000.0,
                  'outcome': a.isCorrect ? 'correct' : 'incorrect',
                })
            .toList();

    final response = await apiClient.post<Map<String, dynamic>>(
      '/api/game/result',
      data: {
        'gametype': gametype,
        'question_responses': questionResponses,
      },
    );
    final data = response.data;
    if (data == null) return null;
    return GameResultResponse.fromJson(Map<String, dynamic>.from(data as Map));
  }

  Future<List<QuizResult>> getHistory(QuizCategory category) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '/quiz/${category.name}/history',
    );
    final data = response.data!;
    return (data['results'] as List)
        .map((r) => QuizResult.fromJson(r as Map<String, dynamic>))
        .toList();
  }
}
