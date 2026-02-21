import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/quiz_category.dart';
import '../../providers/auth_provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/quiz/screens/quiz_intro_screen.dart';
import '../../features/quiz/screens/quiz_screen.dart';
import '../../features/results/screens/result_screen.dart';
import '../../features/results/screens/dashboard_screen.dart';
import '../../features/leaderboard/screens/leaderboard_screen.dart';
import '../../features/legal/screens/privacy_policy_screen.dart';
import '../../widgets/splash_screen.dart';

GoRouter createAppRouter(Ref ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    redirect: (context, state) {
      // Show splash screen while loading
      if (authState.isLoading) return '/splash';
      
      // After loading, redirect from splash to appropriate screen
      if (state.matchedLocation == '/splash') {
        return authState.canAccessApp ? '/' : '/login';
      }

      final canAccessApp = authState.canAccessApp;
      final isOnLogin = state.matchedLocation == '/login';
      final isOnSettings = state.matchedLocation == '/settings';
      final isOnPrivacyPolicy = state.matchedLocation == '/privacy-policy';

      // If not logged in and not guest, and not on login/settings/privacy-policy, redirect to login
      if (!canAccessApp && !isOnLogin && !isOnSettings && !isOnPrivacyPolicy) return '/login';

      // If logged in or guest and on login page, redirect to home
      if (canAccessApp && isOnLogin) return '/';

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/privacy-policy',
        name: 'privacyPolicy',
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: '/quiz/:category/intro',
        name: 'quizIntro',
        builder: (context, state) {
          final slug = state.pathParameters['category']!;
          final category = QuizCategory.fromSlug(slug);
          return QuizIntroScreen(category: category);
        },
      ),
      GoRoute(
        path: '/quiz/:category/play',
        name: 'quizPlay',
        builder: (context, state) {
          final slug = state.pathParameters['category']!;
          final category = QuizCategory.fromSlug(slug);
          return QuizScreen(category: category);
        },
      ),
      GoRoute(
        path: '/quiz/:category/result',
        name: 'quizResult',
        builder: (context, state) {
          final slug = state.pathParameters['category']!;
          final category = QuizCategory.fromSlug(slug);
          return ResultScreen(category: category);
        },
      ),
      GoRoute(
        path: '/dashboard',
        name: 'dashboard',
        builder: (context, state) => const DashboardScreen(),
      ),
      GoRoute(
        path: '/leaderboard',
        name: 'leaderboard',
        builder: (context, state) => const LeaderboardScreen(),
      ),
    ],
  );
}

// Router provider that rebuilds when auth state changes
final appRouterProvider = Provider<GoRouter>((ref) {
  return createAppRouter(ref);
});
