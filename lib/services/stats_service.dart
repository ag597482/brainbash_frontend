import 'api_client.dart';
import '../models/user_profile.dart';
import '../models/user_stats_api.dart';

class StatsService {
  StatsService({required this.apiClient});

  final ApiClient apiClient;

  /// Fetches user stats from GET /api/user/stats (overall_score + per-category avg_score, max_score).
  Future<UserStatsApiResponse> getApiUserStats() async {
    final response = await apiClient.get<Map<String, dynamic>>('/api/user/stats');
    return UserStatsApiResponse.fromJson(response.data!);
  }

  Future<UserProfile> getUserStats() async {
    final response = await apiClient.get<Map<String, dynamic>>('/stats');
    return UserProfile.fromJson(response.data!);
  }

  Future<List<Map<String, dynamic>>> getLeaderboard() async {
    final response = await apiClient.get<Map<String, dynamic>>('/stats/leaderboard');
    final data = response.data!;
    return (data['leaderboard'] as List).cast<Map<String, dynamic>>();
  }
}
