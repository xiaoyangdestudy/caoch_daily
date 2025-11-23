import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/app_routes.dart';
import '../../../shared/design/app_colors.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  int step = 0;

  static const _steps = [
    _OnboardingStep(
      title: '轻松管理健康',
      desc: '记录运动、饮食和睡眠，让 AI 帮你看见每个细小的进步。',
      emoji: '🥑',
      gradient: [AppColors.candyMint, Color(0xFFE0F7FF)],
    ),
    _OnboardingStep(
      title: '每日闪光复盘',
      desc: '晚上 3 分钟，回顾今日高光，生成明日行动计划。',
      emoji: '✨',
      gradient: [Color(0xFFF3E8FF), Color(0xFFFFB3D9)],
    ),
    _OnboardingStep(
      title: '看见成长轨迹',
      desc: '阅读、学习不再断更，让成长的每一步都色彩斑斓。',
      emoji: '🚀',
      gradient: [Color(0xFFFFF7CC), AppColors.candyLime],
    ),
  ];

  void _next() {
    if (step < _steps.length - 1) {
      setState(() => step++);
    } else {
      context.go(AppRoutes.home);
    }
  }

  void _skip() => context.go(AppRoutes.home);

  @override
  Widget build(BuildContext context) {
    final info = _steps[step];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: info.gradient,
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
                      foregroundColor: Colors.black54,
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
                            color: Colors.white.withOpacity(0.6),
                            shape: BoxShape.circle,
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                offset: Offset(0, 12),
                                blurRadius: 30,
                              ),
                            ],
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
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        info.desc,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
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
                                ? Colors.black87
                                : Colors.black26,
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
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
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
  });

  final String title;
  final String desc;
  final String emoji;
  final List<Color> gradient;
}
