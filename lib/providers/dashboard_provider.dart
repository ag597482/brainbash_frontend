import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dashboard_leaderboard.dart';
import '../providers/auth_provider.dart';
import '../services/dashboard_service.dart';

final dashboardServiceProvider = Provider<DashboardService>((ref) {
  return DashboardService(apiClient: ref.watch(apiClientProvider));
});

/// Fetches leaderboard data from GET /api/dashboard.
/// Invalidate to refresh (e.g. after returning from a quiz).
/// For guest users returns empty data (no auth API call).
final dashboardLeaderboardProvider =
    FutureProvider<DashboardLeaderboardResponse>((ref) async {
  final auth = ref.watch(authProvider);
  if (auth.isGuest) return const DashboardLeaderboardResponse();
  return ref.read(dashboardServiceProvider).getDashboard();
});
