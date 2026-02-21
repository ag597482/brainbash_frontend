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

  /// Builds question_responses for game result APIs (same shape for auth and guest).
  static List<Map<String, dynamic>> _questionResponses(QuizResult result) {
    if (result.category.isReflexTimeGame) {
      return result.answers
          .map((a) => <String, dynamic>{
                'time_taken': a.responseTimeMs / 1000.0,
              })
          .toList();
    }
    return result.answers
        .map((a) {
          final outcome = a.userAnswer.trim().isEmpty
              ? 'unsolved'
              : (a.isCorrect ? 'correct' : 'incorrect');
          return <String, dynamic>{
            'time_taken': a.responseTimeMs / 1000.0,
            'outcome': outcome,
          };
        })
        .toList();
  }

  /// Submits game result to POST /api/game/result. Returns backend score/accuracy/etc.
  Future<GameResultResponse?> submitGameResult(QuizResult result) async {
    final gametype = result.category.backendGameType;
    if (gametype == null) return null;

    final response = await apiClient.post<Map<String, dynamic>>(
      '/api/game/result',
      data: {
        'gametype': gametype,
        'question_responses': _questionResponses(result),
      },
    );
    final data = response.data;
    if (data == null) return null;
    return GameResultResponse.fromJson(Map<String, dynamic>.from(data as Map));
  }

  /// Submits guest game result to POST /api/game/guest/result. No auth. Returns same score shape.
  Future<GameResultResponse?> submitGuestGameResult(QuizResult result) async {
    final gametype = result.category.backendGameType;
    if (gametype == null) return null;

    final response = await apiClient.post<Map<String, dynamic>>(
      '/api/game/guest/result',
      data: {
        'gametype': gametype,
        'question_responses': _questionResponses(result),
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
