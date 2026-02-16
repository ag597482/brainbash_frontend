import 'package:go_router/go_router.dart';

import '../../models/quiz_category.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/quiz/screens/quiz_intro_screen.dart';
import '../../features/quiz/screens/quiz_screen.dart';
import '../../features/results/screens/result_screen.dart';
import '../../features/results/screens/dashboard_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
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
  ],
);
