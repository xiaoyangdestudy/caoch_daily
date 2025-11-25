import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/review/presentation/review_page.dart';
import '../../features/shell/presentation/app_shell_page.dart';
import '../../features/stats/presentation/stats_page.dart';
import '../../features/sports/presentation/sports_page.dart';
import '../../features/diet/presentation/diet_page.dart';
import '../../features/diet/presentation/ai_food_recognition_page.dart';
import '../../features/sports/presentation/manual_entry_page.dart';
import '../../features/sleep/presentation/sleep_page.dart';
import '../../features/work/presentation/work_page.dart';
import '../../shared/providers/preferences_provider.dart';
import 'app_routes.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final hasCompletedOnboarding = ref.watch(hasCompletedOnboardingProvider);

  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: hasCompletedOnboarding ? AppRoutes.home : AppRoutes.onboarding,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        redirect: (_, __) =>
            hasCompletedOnboarding ? AppRoutes.home : AppRoutes.onboarding,
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.sports,
        name: 'sports',
        builder: (context, state) => const SportsPage(),
        routes: [
          GoRoute(
            path: 'manual-entry',
            builder: (context, state) => const ManualEntryPage(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.diet,
        name: 'diet',
        builder: (context, state) => const DietPage(),
        routes: [
          GoRoute(
            path: 'ai-recognition',
            builder: (context, state) => const AiFoodRecognitionPage(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.sleep,
        name: 'sleep',
        builder: (context, state) => const SleepPage(),
      ),
      GoRoute(
        path: AppRoutes.work,
        name: 'work',
        builder: (context, state) => const WorkPage(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShellPage(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                name: 'home',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: DashboardPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.review,
                name: 'review',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ReviewPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.stats,
                name: 'stats',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: StatsPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: 'profile',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: ProfilePage()),
              ),
            ],
          ),
        ],
      ),
    ],
    errorPageBuilder: (context, state) => MaterialPage(
      child: Scaffold(body: Center(child: Text('页面走丢了：${state.error}'))),
    ),
  );
});
