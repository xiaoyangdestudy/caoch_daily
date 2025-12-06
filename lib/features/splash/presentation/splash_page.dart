import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../shared/providers/api_provider.dart';
import '../../../shared/providers/preferences_provider.dart';

/// Splash Screen - 显示启动图并在后台完成初始化
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _progressController.forward();
      }
    });
    _initializeAndNavigate();
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  /// 初始化应用并导航到相应页面
  Future<void> _initializeAndNavigate() async {
    try {
      // 启动画面至少保持 2 秒
      await Future.delayed(const Duration(seconds: 2));

      // 等待认证状态加载
      final authState = await ref.read(authStateProvider.future);
      final hasCompletedOnboarding = ref.read(hasCompletedOnboardingProvider);

      if (!mounted) return;

      // 根据状态决定跳转页面
      final targetRoute = !authState
          ? AppRoutes.login
          : (!hasCompletedOnboarding ? AppRoutes.onboarding : AppRoutes.home);

      context.go(targetRoute);
    } catch (_) {
      if (mounted) {
        context.go(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 填满屏幕的背景图（必要时按比例裁切，杜绝黑边）
          Image.asset(
            'assets/images/startScreen.png',
            fit: BoxFit.cover,
            alignment: Alignment.center,
            filterQuality: FilterQuality.high,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).padding.bottom + 64,
            child: FadeTransition(
              opacity: _progressController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 32,
                    height: 32,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '正在加载你的专属数据...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
