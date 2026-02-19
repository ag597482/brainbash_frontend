import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dashboard_leaderboard.dart';
import '../providers/auth_provider.dart';
import '../services/dashboard_service.dart';

final dashboardServiceProvider = Provider<DashboardService>((ref) {
  return DashboardService(apiClient: ref.watch(apiClientProvider));
});

/// Fetches leaderboard data from GET /api/dashboard.
/// Invalidate to refresh (e.g. after returning from a quiz).
final dashboardLeaderboardProvider =
    FutureProvider<DashboardLeaderboardResponse>((ref) {
  ref.watch(authProvider); // refetch when auth changes
  return ref.read(dashboardServiceProvider).getDashboard();
});
