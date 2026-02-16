import 'api_client.dart';
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

  Future<QuizResult> submitResult(QuizResult result) async {
    final response = await apiClient.post<Map<String, dynamic>>(
      '/quiz/results',
      data: result.toJson(),
    );
    return QuizResult.fromJson(response.data!);
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
