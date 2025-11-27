import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design/app_colors.dart';
import '../../../shared/design/app_shadows.dart';
import '../application/profile_provider.dart';
import '../domain/profile_model.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: _ProfileHeader(
                  overview: state.overview,
                  onScan: () => _showFeatureComing(context),
                  onSettings: () => _showSupportSheet(
                    context,
                    _SupportSheetType.about,
                    version: state.version,
                  ),
                  onEdit: () => _openEditSheet(context, ref, state),
                  onTimeline: () => _showFeatureComing(context),
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
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              sliver: SliverToBoxAdapter(
                child: _ProfileMenuSection(
                  title: '隐私与支持',
                  children: [
                    _ProfileMenuItem(
                      icon: Icons.privacy_tip_outlined,
                      label: '隐私与数据',
                      description: '导出 / 删除账号',
                      onTap: () => _showSupportSheet(
                        context,
                        _SupportSheetType.privacy,
                        version: state.version,
                      ),
                    ),
                    _ProfileMenuItem(
                      icon: Icons.chat_bubble_outline,
                      label: '帮助与反馈',
                      description: '联系教练团队',
                      onTap: () => _showSupportSheet(
                        context,
                        _SupportSheetType.support,
                        version: state.version,
                      ),
                    ),
                    _ProfileMenuItem(
                      icon: Icons.info_outline,
                      label: '关于日常教练',
                      description: '了解版本与开源协议',
                      valueText: state.version,
                      onTap: () => _showSupportSheet(
                        context,
                        _SupportSheetType.about,
                        version: state.version,
                      ),
                    ),
                  ],
                ),
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
    );
  }

  Future<void> _openEditSheet(
    BuildContext context,
    WidgetRef ref,
    ProfileState state,
  ) async {
    final result = await showModalBottomSheet<_ProfileEditResult>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _ProfileEditSheet(
        initialName: state.overview.nickname,
        initialEncourage: state.overview.encourageText,
        initialEmoji: state.overview.emoji,
      ),
    );
    if (result != null) {
      ref
          .read(profileProvider.notifier)
          .updateProfile(
            nickname: result.nickname,
            encourageText: result.encourageText,
            emoji: result.emoji,
          );
    }
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
    required this.onScan,
    required this.onSettings,
    required this.onEdit,
    required this.onTimeline,
  });

  final ProfileOverview overview;
  final VoidCallback onScan;
  final VoidCallback onSettings;
  final VoidCallback onEdit;
  final VoidCallback onTimeline;

  @override
  Widget build(BuildContext context) {
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
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.candyPurple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.candyPurple.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                overview.emoji,
                style: const TextStyle(fontSize: 40),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    overview.nickname,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    overview.encourageText,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black.withValues(alpha: 0.5),
                      height: 1.4,
                    ),
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppShadows.cardSoft,
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
            color: Colors.white,
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
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: Colors.black87),
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
