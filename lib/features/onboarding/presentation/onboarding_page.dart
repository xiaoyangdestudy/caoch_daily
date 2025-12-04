import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../shared/design/app_colors.dart';
import '../../../shared/providers/preferences_provider.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  int step = 0;

  static const _steps = [
    _OnboardingStep(
      title: '轻松管理健康',
      desc: '记录运动、饮食和睡眠，让 AI 帮你看见每个细小的进步。',
      emoji: '🥑',
      gradient: [AppColors.candyMint, Color(0xFFE0F7FF)],
      darkGradient: [AppColors.background, AppColors.backgroundDark],
    ),
    _OnboardingStep(
      title: '每日闪光复盘',
      desc: '晚上 3 分钟，回顾今日高光，生成明日行动计划。',
      emoji: '✨',
      gradient: [Color(0xFFF3E8FF), Color(0xFFFFB3D9)],
      darkGradient: [AppColors.backgroundDark, AppColors.surface],
    ),
    _OnboardingStep(
      title: '看见成长轨迹',
      desc: '阅读、学习不再断更，让成长的每一步都色彩斑斓。',
      emoji: '🚀',
      gradient: [Color(0xFFFFF7CC), AppColors.candyLime],
      darkGradient: [AppColors.surface, AppColors.background],
    ),
  ];

  Future<void> _completeOnboarding() async {
    await ref.read(preferencesServiceProvider).setOnboardingCompleted();
    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  void _next() {
    if (step < _steps.length - 1) {
      setState(() => step++);
    } else {
      _completeOnboarding();
    }
  }

  void _skip() => _completeOnboarding();

  @override
  Widget build(BuildContext context) {
    final info = _steps[step];
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark ? info.darkGradient : info.gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _skip,
                    style: TextButton.styleFrom(
                      foregroundColor: isDark ? Colors.white70 : Colors.black54,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    child: const Text('跳过'),
                  ),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          key: ValueKey(step),
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.6),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: isDark ? Colors.black26 : Colors.black12,
                                offset: const Offset(0, 12),
                                blurRadius: 30,
                              ),
                            ],
                            border: isDark ? Border.all(color: Colors.white10) : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            info.emoji,
                            style: const TextStyle(fontSize: 96),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        info.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        info.desc,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: isDark ? Colors.white70 : Colors.black54,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _steps.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 10,
                          width: step == index ? 32 : 10,
                          decoration: BoxDecoration(
                            color: step == index
                                ? (isDark ? AppColors.neonBlue : Colors.black87)
                                : (isDark ? Colors.white24 : Colors.black26),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _next,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: isDark ? AppColors.neonBlue : Colors.black,
                          foregroundColor: isDark ? Colors.black : Colors.white,
                          textStyle: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Text(step == _steps.length - 1 ? '立即开启' : '下一步'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingStep {
  const _OnboardingStep({
    required this.title,
    required this.desc,
    required this.emoji,
    required this.gradient,
    required this.darkGradient,
  });

  final String title;
  final String desc;
  final String emoji;
  final List<Color> gradient;
  final List<Color> darkGradient;
}
