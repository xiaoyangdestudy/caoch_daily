import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/design/app_colors.dart';
import '../../../shared/design/app_shadows.dart';
import '../../../shared/providers/api_provider.dart';
import '../../../app/router/app_routes.dart';
import '../../review/application/review_providers.dart';
import '../../sports/application/sports_providers.dart';
import '../../diet/application/diet_providers.dart';
import '../../sleep/application/sleep_providers.dart';
import '../../work/application/work_providers.dart';
import '../../moments/application/moments_provider.dart';
import '../application/profile_provider.dart';
import '../application/user_profile_provider.dart';
import '../domain/profile_model.dart';
import '../domain/user_profile.dart';
import 'edit_profile_page.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);
    final userProfileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/dashboard_background.png'),
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                  child: userProfileAsync.when(
                    data: (userProfile) => _ProfileHeader(
                      overview: state.overview,
                      userProfile: userProfile,
                      onScan: () => _showFeatureComing(context),
                      onSettings: () => _showSupportSheet(
                        context,
                        _SupportSheetType.about,
                        version: state.version,
                      ),
                      onEdit: () => _navigateToEditProfile(context),
                      onTimeline: () => _showFeatureComing(context),
                    ),
                    loading: () => _ProfileHeader(
                      overview: state.overview,
                      userProfile: null,
                      onScan: () => _showFeatureComing(context),
                      onSettings: () => _showSupportSheet(
                        context,
                        _SupportSheetType.about,
                        version: state.version,
                      ),
                      onEdit: () => _navigateToEditProfile(context),
                      onTimeline: () => _showFeatureComing(context),
                    ),
                    error: (_, __) => _ProfileHeader(
                      overview: state.overview,
                      userProfile: null,
                      onScan: () => _showFeatureComing(context),
                      onSettings: () => _showSupportSheet(
                        context,
                        _SupportSheetType.about,
                        version: state.version,
                      ),
                      onEdit: () => _navigateToEditProfile(context),
                      onTimeline: () => _showFeatureComing(context),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                sliver: SliverToBoxAdapter(
                  child: _ProfileMenuSection(
                    title: '偏好设置',
                    children: [
                      _ProfileMenuItem(
                        icon: Icons.notifications_none_rounded,
                        label: '通知提醒',
                        description: '每日 08:00 推送 · 睡前复盘提醒',
                        type: _MenuItemType.toggle,
                        switchValue: state.preferences.notificationsEnabled,
                        onSwitchChanged: notifier.toggleNotifications,
                      ),
                      _ProfileMenuItem(
                        icon: Icons.auto_awesome,
                        label: '每日 AI Digest',
                        description: '总结今日表现并生成建议',
                        type: _MenuItemType.toggle,
                        switchValue: state.preferences.dailyDigestEnabled,
                        onSwitchChanged: notifier.toggleDailyDigest,
                      ),
                      _ProfileMenuItem(
                        icon: Icons.palette_outlined,
                        label: 'AI 风格设置',
                        description: state.preferences.aiStyle.description,
                        valueText: state.preferences.aiStyle.label,
                        onTap: () => _showAiStyleSheet(
                          context,
                          ref,
                          state.preferences.aiStyle,
                        ),
                      ),
                      _ProfileMenuItem(
                        icon: Icons.dark_mode_outlined,
                        label: '深色模式',
                        description: '实验功能，跟随系统切换',
                        type: _MenuItemType.toggle,
                        switchValue: state.preferences.followSystemTheme,
                        onSwitchChanged: notifier.toggleFollowSystemTheme,
                      ),
                    ],
                  ),
                ),
              ),
              // 数据同步Section
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                sliver: SliverToBoxAdapter(
                  child: _DataSyncSection(),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 120),
                  child: Column(
                    children: [
                      Text(
                        '保持好奇，保持行动',
                        style: TextStyle(
                          color: Colors.black.withValues(alpha: 0.45),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        state.version,
                        style: const TextStyle(
                          color: Colors.black38,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToEditProfile(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const EditProfilePage(),
      ),
    );
  }

  Future<void> _showAiStyleSheet(
    BuildContext context,
    WidgetRef ref,
    AiCoachStyle current,
  ) async {
    final style = await showModalBottomSheet<AiCoachStyle>(
      context: context,
      showDragHandle: true,
      builder: (_) => _AiStyleSheet(current: current),
    );
    if (style != null) {
      ref.read(profileProvider.notifier).setAiStyle(style);
    }
  }

  void _showSupportSheet(
    BuildContext context,
    _SupportSheetType type, {
    required String version,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _SupportSheet(type: type, version: version),
    );
  }

  void _showFeatureComing(BuildContext context) {
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..removeCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text('功能还在打磨中，敬请期待 ✨')));
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.overview,
    required this.userProfile,
    required this.onScan,
    required this.onSettings,
    required this.onEdit,
    required this.onTimeline,
  });

  final ProfileOverview overview;
  final UserProfile? userProfile;
  final VoidCallback onScan;
  final VoidCallback onSettings;
  final VoidCallback onEdit;
  final VoidCallback onTimeline;

  @override
  Widget build(BuildContext context) {
    // 优先使用用户资料中的昵称，否则使用默认昵称
    final displayName = userProfile?.nickname ?? userProfile?.username ?? overview.nickname;
    final signature = userProfile?.signature ?? overview.encourageText;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              '个人中心',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            Row(
              children: [
                _RoundIconButton(icon: Icons.qr_code_scanner, onTap: onScan),
                const SizedBox(width: 12),
                _RoundIconButton(icon: Icons.settings_outlined, onTap: onSettings),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            // 头像
            GestureDetector(
              onTap: onEdit,
              child: _AsyncAvatarImage(
                key: ValueKey(userProfile?.avatar ?? 'default'),
                avatarBase64: userProfile?.avatar,
                fallbackEmoji: overview.emoji,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: onEdit,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.edit,
                            size: 16,
                            color: Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    signature,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withValues(alpha: 0.5),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppShadows.cardSoft,
            border: Border.all(color: Colors.white),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: overview.stats.map((stat) => _SimpleStatItem(stat: stat)).toList(),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: onEdit,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.black87,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.edit_outlined, size: 20),
                label: const Text('编辑资料'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onTimeline,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  backgroundColor: Colors.white.withValues(alpha: 0.5),
                  side: BorderSide(color: Colors.black.withValues(alpha: 0.1)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.calendar_month_outlined, size: 20),
                label: const Text('打卡日历'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SimpleStatItem extends StatelessWidget {
  const _SimpleStatItem({required this.stat});

  final ProfileStat stat;

  @override
  Widget build(BuildContext context) {
    final suffix = stat.suffix != null ? stat.suffix! : '';
    return Column(
      children: [
        Text(
          stat.value + suffix,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          stat.label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.black.withValues(alpha: 0.4),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.black87, size: 22),
      ),
    );
  }
}

enum _MenuItemType { link, toggle }

class _ProfileMenuSection extends StatelessWidget {
  const _ProfileMenuSection({required this.title, required this.children});

  final String title;
  final List<_ProfileMenuItem> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white),
            boxShadow: AppShadows.cardSoft,
          ),
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 72,
                    color: Color(0xFFE2E8F0),
                  ),
                children[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    this.description,
    this.valueText,
    this.onTap,
    this.type = _MenuItemType.link,
    this.switchValue,
    this.onSwitchChanged,
  });

  final IconData icon;
  final String label;
  final String? description;
  final String? valueText;
  final VoidCallback? onTap;
  final _MenuItemType type;
  final bool? switchValue;
  final ValueChanged<bool>? onSwitchChanged;

  @override
  Widget build(BuildContext context) {
    final trailing = type == _MenuItemType.toggle
        ? Switch.adaptive(
            value: switchValue ?? false,
            onChanged: onSwitchChanged,
            thumbColor: WidgetStatePropertyAll(AppColors.candyBlue),
            trackColor: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.selected)
                  ? AppColors.candyBlue.withValues(alpha: 0.35)
                  : Colors.grey.shade300,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (valueText != null)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(
                    valueText!,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const Icon(Icons.chevron_right, color: Colors.black26),
            ],
          );

    return InkWell(
      onTap: type == _MenuItemType.link ? onTap : null,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.candyPurple.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.candyPurple, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      description!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black45,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _ProfileEditResult {
  const _ProfileEditResult({
    required this.nickname,
    required this.encourageText,
    required this.emoji,
  });

  final String nickname;
  final String encourageText;
  final String emoji;
}

class _ProfileEditSheet extends StatefulWidget {
  const _ProfileEditSheet({
    required this.initialName,
    required this.initialEncourage,
    required this.initialEmoji,
  });

  final String initialName;
  final String initialEncourage;
  final String initialEmoji;

  @override
  State<_ProfileEditSheet> createState() => _ProfileEditSheetState();
}

class _ProfileEditSheetState extends State<_ProfileEditSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _encourageController;
  late String _selectedEmoji;

  static const _emojis = ['🧠', '🔥', '🌈', '🚀', '🌿', '🦾', '🧘🏻‍♂️'];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _encourageController = TextEditingController(text: widget.initialEncourage);
    _selectedEmoji = widget.initialEmoji;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _encourageController.dispose();
    super.dispose();
  }

  void _submit() {
    final nickname = _nameController.text.trim();
    final encourage = _encourageController.text.trim();
    if (nickname.isEmpty || encourage.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('昵称和激励文案都不能为空哦')));
      return;
    }
    Navigator.of(context).pop(
      _ProfileEditResult(
        nickname: nickname,
        encourageText: encourage,
        emoji: _selectedEmoji,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '编辑个人资料',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: '昵称',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _encourageController,
            decoration: const InputDecoration(
              labelText: '激励文案',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const Text('选择代表你的表情', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _emojis.map((emoji) {
              final selected = emoji == _selectedEmoji;
              return GestureDetector(
                onTap: () => setState(() => _selectedEmoji = emoji),
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: selected
                        ? AppColors.candyBlue.withValues(alpha: 0.12)
                        : Colors.grey.shade100,
                    border: Border.all(
                      color: selected
                          ? AppColors.candyBlue
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(emoji, style: const TextStyle(fontSize: 28)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('保存'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiStyleSheet extends StatelessWidget {
  const _AiStyleSheet({required this.current});

  final AiCoachStyle current;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '选择 AI 教练语气',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          ...AiCoachStyle.values.map(
            (style) => ListTile(
              onTap: () => Navigator.of(context).pop(style),
              leading: Text(style.emoji, style: const TextStyle(fontSize: 28)),
              title: Text(style.label),
              subtitle: Text(style.description),
              trailing: Icon(
                style == current ? Icons.check_circle : Icons.circle_outlined,
                color: style == current ? AppColors.candyBlue : Colors.black26,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _SupportSheetType { privacy, support, about }

class _SupportSheet extends StatelessWidget {
  const _SupportSheet({required this.type, required this.version});

  final _SupportSheetType type;
  final String version;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final title = () {
      switch (type) {
        case _SupportSheetType.privacy:
          return '隐私与数据';
        case _SupportSheetType.support:
          return '帮助与反馈';
        case _SupportSheetType.about:
          return '关于日常教练';
      }
    }();

    final body = () {
      switch (type) {
        case _SupportSheetType.privacy:
          return const [
            Text('我们会在导出数据前进行二次验证，确保数据只发送到你的邮箱。'),
            SizedBox(height: 12),
            Text('如需删除账号，请使用注册邮箱联系 support@dailycoach.app。'),
          ];
        case _SupportSheetType.support:
          return const [
            Text('遇到问题或想要提出改进建议，可以通过以下渠道：'),
            SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.mail_outline),
              title: Text('support@dailycoach.app'),
              subtitle: Text('邮件 24 小时内回复'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.telegram),
              title: Text('Telegram 社区'),
              subtitle: Text('搜索 daily-coach 加入讨论'),
            ),
          ];
        case _SupportSheetType.about:
          return [
            Text('当前版本：$version'),
            const SizedBox(height: 12),
            const Text('日常教练是一款开源的 AI Lifestyle Coach，欢迎在 GitHub 参与共建。'),
          ];
      }
    }();

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 16, 24, bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 12),
          ...body,
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('我知道了'),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== 数据同步Section ====================

class _DataSyncSection extends ConsumerWidget {
  const _DataSyncSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.watch(apiClientProvider);
    final usernameAsync = ref.watch(currentUsernameProvider);

    return usernameAsync.when(
      data: (username) {
        final isAuthenticated = api.isAuthenticated && username != null;

        if (isAuthenticated) {
          // 已登录状态
          return _ProfileMenuSection(
            title: '数据同步',
            children: [
              _ProfileMenuItem(
                icon: Icons.account_circle_outlined,
                label: '已登录',
                description: '用户：$username',
                valueText: '已同步',
              ),
              _ProfileMenuItem(
                icon: Icons.cloud_sync,
                label: '同步数据',
                description: '将本地数据同步到云端',
                onTap: () => _handleSync(context, ref),
              ),
              _ProfileMenuItem(
                icon: Icons.logout,
                label: '退出登录',
                description: '本地数据会保留',
                onTap: () => _handleLogout(context, ref),
              ),
            ],
          );
        } else {
          // 未登录状态
          return _ProfileMenuSection(
            title: '数据同步',
            children: [
              _ProfileMenuItem(
                icon: Icons.cloud_outlined,
                label: '登录/注册',
                description: '登录后数据将同步到云端，可在多设备间共享',
                onTap: () => _handleAuth(context, ref),
              ),
            ],
          );
        }
      },
      loading: () => _ProfileMenuSection(
        title: '数据同步',
        children: const [
          _ProfileMenuItem(
            icon: Icons.cloud_outlined,
            label: '加载中...',
            description: '正在检查登录状态',
          ),
        ],
      ),
      error: (_, __) => _ProfileMenuSection(
        title: '数据同步',
        children: [
          _ProfileMenuItem(
            icon: Icons.cloud_outlined,
            label: '登录/注册',
            description: '登录后数据将同步到云端',
            onTap: () => _handleAuth(context, ref),
          ),
        ],
      ),
    );
  }

  // 处理登录/注册
  Future<void> _handleAuth(BuildContext context, WidgetRef ref) async {
    final result = await context.push<bool>(AppRoutes.login);

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('登录成功！')),
      );

      // 刷新所有相关Provider
      ref.invalidate(authStateProvider);
      ref.invalidate(currentUsernameProvider);
      ref.invalidate(userProfileProvider); // 加载新用户的资料
      ref.invalidate(reviewRepositoryProvider);
      ref.invalidate(reviewEntriesProvider);
    }
  }

  // 处理同步
  Future<void> _handleSync(BuildContext context, WidgetRef ref) async {
    // 显示加载对话框
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('正在同步数据...'),
              ],
            ),
          ),
        ),
      ),
    );

    try {
      // 同步Review数据（示例）
      final reviewRepo = ref.read(reviewRepositoryProvider);
      await reviewRepo.syncToServer();

      // TODO: 同步其他数据
      // await workoutRepo.syncToServer();
      // await mealRepo.syncToServer();
      // await sleepRepo.syncToServer();
      // await focusRepo.syncToServer();

      if (context.mounted) {
        Navigator.of(context).pop(); // 关闭加载对话框

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ 同步成功！'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // 关闭加载对话框

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('同步失败：$e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // 处理登出
  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认退出登录'),
        content: const Text('退出后本地数据会保留，下次登录可快速恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('退出'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final api = ref.read(apiClientProvider);

      // 退出登录（清除token和认证状态）
      await api.logout();

      // 刷新认证状态和所有数据Provider
      // 注意：不清除本地数据，因为已有userId隔离，同一用户重新登录可快速恢复
      ref.invalidate(authStateProvider);
      ref.invalidate(currentUsernameProvider);
      ref.invalidate(userProfileProvider); // 清除用户资料缓存
      ref.invalidate(reviewEntriesProvider);
      ref.invalidate(workoutListProvider);
      ref.invalidate(dietRecordsProvider);
      ref.invalidate(sleepRecordsProvider);
      ref.invalidate(focusSessionsProvider);
      ref.invalidate(momentsProvider);

      if (context.mounted) {
        // 跳转到登录页
        context.go(AppRoutes.login);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('已退出登录')),
        );
      }
    }
  }
}

/// 异步头像解码 - 在后台线程解码 Base64，避免阻塞主线程
class _AsyncAvatarImage extends StatelessWidget {
  const _AsyncAvatarImage({
    super.key,
    required this.avatarBase64,
    required this.fallbackEmoji,
  });

  final String? avatarBase64;
  final String fallbackEmoji;

  /// 在后台线程解码 Base64
  static Future<Uint8List> _decodeBase64(String base64String) async {
    return compute<String, Uint8List>(_decodeBase64Isolate, base64String);
  }

  /// Isolate 中执行的解码函数
  static Uint8List _decodeBase64Isolate(String base64String) {
    // 移除 data:image/xxx;base64, 前缀
    final pureBase64 = base64String.contains(',')
        ? base64String.split(',').last
        : base64String;
    return base64Decode(pureBase64);
  }

  @override
  Widget build(BuildContext context) {
    if (avatarBase64 == null || avatarBase64!.isEmpty) {
      // 无头像，显示 emoji
      return _buildEmojiAvatar(context);
    }

    return FutureBuilder<Uint8List>(
      future: _decodeBase64(avatarBase64!),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData) {
          // 解码成功，显示图片
          return Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppShadows.purple3d,
              image: DecorationImage(
                image: MemoryImage(snapshot.data!),
                fit: BoxFit.cover,
              ),
            ),
          );
        } else if (snapshot.hasError) {
          // 解码失败，显示 emoji
          return _buildEmojiAvatar(context);
        } else {
          // 加载中，显示占位符
          return Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.candyPurple.withOpacity(0.3),
              borderRadius: BorderRadius.circular(24),
              boxShadow: AppShadows.purple3d,
            ),
            alignment: Alignment.center,
            child: const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
      },
    );
  }

  Widget _buildEmojiAvatar(BuildContext context) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.candyPurple,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.purple3d,
      ),
      alignment: Alignment.center,
      child: Text(
        fallbackEmoji,
        style: const TextStyle(fontSize: 40),
      ),
    );
  }
}
