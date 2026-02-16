import 'api_client.dart';
import '../models/user_profile.dart';

class StatsService {
  StatsService({required this.apiClient});

  final ApiClient apiClient;

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
