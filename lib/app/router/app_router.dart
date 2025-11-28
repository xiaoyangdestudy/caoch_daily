import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/auth/presentation/register_page.dart';
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
import '../../features/moments/presentation/moments_page.dart';
import '../../features/moments/presentation/create_moment_page.dart';
import '../../shared/providers/preferences_provider.dart';
import '../../shared/providers/api_provider.dart';
import 'app_routes.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final hasCompletedOnboarding = ref.watch(hasCompletedOnboardingProvider);
  final authStateAsync = ref.watch(authStateProvider);

  // 等待认证状态加载完成
  return authStateAsync.when(
    data: (isAuthenticated) => _buildRouter(
      isAuthenticated: isAuthenticated,
      hasCompletedOnboarding: hasCompletedOnboarding,
    ),
    loading: () => _buildLoadingRouter(),
    error: (_, __) => _buildRouter(
      isAuthenticated: false,
      hasCompletedOnboarding: hasCompletedOnboarding,
    ),
  );
});

/// 创建路由（认证状态已加载）
GoRouter _buildRouter({
  required bool isAuthenticated,
  required bool hasCompletedOnboarding,
}) {
  // 确定初始路由
  String initialLocation;
  if (!isAuthenticated) {
    initialLocation = AppRoutes.login;
  } else if (!hasCompletedOnboarding) {
    initialLocation = AppRoutes.onboarding;
  } else {
    initialLocation = AppRoutes.home;
  }

  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: initialLocation,
    redirect: (context, state) {
      final location = state.matchedLocation;

      // 登录页和注册页无需守卫
      if (location == AppRoutes.login || location == AppRoutes.register) {
        return null;
      }

      // 未登录时，重定向到登录页
      if (!isAuthenticated) {
        return AppRoutes.login;
      }

      // 已登录但未完成引导，且不在onboarding页面
      if (!hasCompletedOnboarding && location != AppRoutes.onboarding) {
        return AppRoutes.onboarding;
      }

      return null; // 允许访问
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        redirect: (_, __) => initialLocation,
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
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
      GoRoute(
        path: AppRoutes.createMoment,
        name: 'createMoment',
        builder: (context, state) => const CreateMomentPage(),
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
                path: AppRoutes.moments,
                name: 'moments',
                pageBuilder: (context, state) =>
                    const NoTransitionPage(child: MomentsPage()),
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
}

/// 创建加载中路由（认证状态加载中）
GoRouter _buildLoadingRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    ],
  );
}
