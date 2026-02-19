import '../models/dashboard_leaderboard.dart';
import 'api_client.dart';

class DashboardService {
  const DashboardService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  /// GET /api/dashboard — returns leaderboards per game type.
  Future<DashboardLeaderboardResponse> getDashboard() async {
    final response = await _apiClient.get<Map<String, dynamic>>('/api/dashboard');
    final data = response.data;
    if (data == null) {
      return const DashboardLeaderboardResponse();
    }
    return DashboardLeaderboardResponse.fromJson(data);
  }
}
