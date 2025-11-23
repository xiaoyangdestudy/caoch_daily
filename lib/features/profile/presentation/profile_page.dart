import 'package:flutter/material.dart';

import '../../../shared/design/app_colors.dart';
import '../../../shared/design/app_shadows.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  static const _menuItems = [
    _ProfileMenuData(
      label: '健康目标设置',
      category: '目标',
      hint: '运动/饮食/睡眠阈值',
      icon: Icons.fitness_center,
      color: AppColors.candyPink,
    ),
    _ProfileMenuData(
      label: '工作 & 学习目标',
      category: '目标',
      hint: '专注任务与时间块',
      icon: Icons.work_outline,
      color: AppColors.candyBlue,
    ),
    _ProfileMenuData(
      label: '阅读清单',
      category: '目标',
      hint: '打造你的知识库',
      icon: Icons.menu_book_outlined,
      color: AppColors.candyPurple,
    ),
    _ProfileMenuData(
      label: '通知提醒',
      category: '偏好',
      hint: '复盘与打卡提醒',
      icon: Icons.notifications_active,
      color: AppColors.candyYellow,
    ),
    _ProfileMenuData(
      label: 'AI 风格设置',
      category: '偏好',
      hint: '选择激励语气',
      icon: Icons.auto_fix_high_outlined,
      color: AppColors.candyOrange,
    ),
    _ProfileMenuData(
      label: '隐私与数据',
      category: '隐私',
      hint: '导出 / 删除数据',
      icon: Icons.lock_outline,
      color: AppColors.candyGreen,
    ),
    _ProfileMenuData(
      label: '帮助与反馈',
      category: '支持',
      hint: '对话开发者团队',
      icon: Icons.help_outline,
      color: AppColors.candyMint,
    ),
    _ProfileMenuData(
      label: '关于',
      category: '支持',
      hint: '了解日常教练',
      icon: Icons.info_outline,
      color: AppColors.candyBlue,
    ),
  ];

  static const _quickActions = [
    _QuickActionData(label: '同步数据', icon: Icons.sync),
    _QuickActionData(label: '导出报告', icon: Icons.share_rounded),
    _QuickActionData(label: '切换主题', icon: Icons.color_lens_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: _ProfileContent(
            quickActions: _quickActions,
          ),
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.quickActions});

  final List<_QuickActionData> quickActions;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    '个人中心 👤',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '让习惯、偏好与数据，都在这里被照顾',
                    style: TextStyle(fontSize: 14, color: Colors.black54),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final action in quickActions) ...[
                  IconButton(
                    icon: Icon(action.icon),
                    onPressed: () {},
                    tooltip: action.label,
                    iconSize: 22,
                    color: Colors.black87,
                  ),
                ],
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        const _ProfileHeroCard(),
        const SizedBox(height: 20),
        _MenuPager(items: ProfilePage._menuItems),
        const SizedBox(height: 16),
        const Center(
          child: Text(
            'v1.0.0 日常教练',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.black38,
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuPager extends StatelessWidget {
  const _MenuPager({required this.items});

  final List<_ProfileMenuData> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final item in items) ...[
          _ProfileMenuTile(data: item),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.candyBlue, AppColors.candyLime],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: const [
          BoxShadow(
            color: Color(0x332EC4B6),
            offset: Offset(0, 18),
            blurRadius: 30,
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                  border: Border.all(color: Colors.white, width: 3),
                ),
                alignment: Alignment.center,
                child: const Text('🥑', style: TextStyle(fontSize: 34)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Alex Designer',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text(
                        '改变自己的第 28 天',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.candyBlue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                ),
                onPressed: () {},
                child: const Text(
                  '编辑资料',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({required this.data});

  final _ProfileMenuData data;

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      colors: [data.color, data.color.withOpacity(0.8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {},
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 88),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: data.color.withOpacity(0.25),
                offset: const Offset(0, 8),
                blurRadius: 16,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(data.icon, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data.category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                        letterSpacing: 1.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      data.label,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.hint,
                      style: const TextStyle(fontSize: 12, color: Colors.white70),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.chevron_right_rounded, color: Colors.white70, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuData {
  const _ProfileMenuData({
    required this.label,
    required this.category,
    required this.hint,
    required this.icon,
    required this.color,
  });

  final String label;
  final String category;
  final String hint;
  final IconData icon;
  final Color color;
}

class _QuickActionData {
  const _QuickActionData({required this.label, required this.icon});

  final String label;
  final IconData icon;
}
