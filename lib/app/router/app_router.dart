import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/splash/presentation/splash_page.dart';
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
  // 只创建一次 GoRouter，路由守卫通过 redirect 处理
  return GoRouter(
    debugLogDiagnostics: true,
    initialLocation: AppRoutes.splash,
    redirect: (context, state) async {
      final location = state.matchedLocation;

      // Splash 页面始终可访问
      if (location == AppRoutes.splash) {
        return null;
      }

      // 登录页和注册页无需守卫
      if (location == AppRoutes.login || location == AppRoutes.register) {
        return null;
      }

      // 读取最新的认证状态
      final container = ProviderScope.containerOf(context);
      final authState = await container.read(authStateProvider.future);
      final hasCompletedOnboarding =
          container.read(hasCompletedOnboardingProvider);

      // 未登录时，重定向到登录页
      if (!authState) {
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
        name: 'splash',
        builder: (context, state) => const SplashPage(),
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
                    _buildShellPageTransition(state, const DashboardPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.review,
                name: 'review',
                pageBuilder: (context, state) =>
                    _buildShellPageTransition(state, const ReviewPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.moments,
                name: 'moments',
                pageBuilder: (context, state) =>
                    _buildShellPageTransition(state, const MomentsPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.stats,
                name: 'stats',
                pageBuilder: (context, state) =>
                    _buildShellPageTransition(state, const StatsPage()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                name: 'profile',
                pageBuilder: (context, state) =>
                    _buildShellPageTransition(state, const ProfilePage()),
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

CustomTransitionPage<void> _buildShellPageTransition(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final eased = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: eased,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.98, end: 1).animate(eased),
          child: child,
        ),
      );
    },
  );
}
