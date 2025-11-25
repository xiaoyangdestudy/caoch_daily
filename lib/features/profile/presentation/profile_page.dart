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
                child: _HeaderBar(
                  nickname: state.overview.nickname,
                  onScan: () => _showFeatureComing(context),
                  onSettings: () => _showSupportSheet(
                    context,
                    _SupportSheetType.about,
                    version: state.version,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: _ProfileHeroCard(
                  overview: state.overview,
                  onEdit: () => _openEditSheet(context, ref, state),
                  onTimeline: () => _showFeatureComing(context),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
                child: _UpgradeBanner(onTap: () => _showFeatureComing(context)),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              sliver: SliverToBoxAdapter(
                child: _GoalSection(
                  goals: state.goals,
                  onRecord: notifier.recordGoalProgress,
                  onAdjust: (goal) => _showGoalSheet(context, ref, goal),
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

  Future<void> _showGoalSheet(
    BuildContext context,
    WidgetRef ref,
    ProfileGoal goal,
  ) async {
    final target = await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _GoalEditSheet(goal: goal),
    );
    if (target != null) {
      ref.read(profileProvider.notifier).updateGoalTarget(goal.id, target);
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

class _HeaderBar extends StatelessWidget {
  const _HeaderBar({
    required this.nickname,
    required this.onScan,
    required this.onSettings,
  });

  final String nickname;
  final VoidCallback onScan;
  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '个人中心 👤',
                style: TextStyle(
                  fontSize: 14,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$nickname，今天也要好好生活',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        _RoundIconButton(icon: Icons.qr_code_scanner, onTap: onScan),
        const SizedBox(width: 12),
        _RoundIconButton(icon: Icons.settings_outlined, onTap: onSettings),
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
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppShadows.white3d,
        ),
        child: Icon(icon, color: Colors.black87),
      ),
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({
    required this.overview,
    required this.onEdit,
    required this.onTimeline,
  });

  final ProfileOverview overview;
  final VoidCallback onEdit;
  final VoidCallback onTimeline;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          colors: [AppColors.candyPurple, AppColors.candyBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: AppShadows.purple3d,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      overview.nickname,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      overview.encourageText,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              _EmojiBadge(
                emoji: overview.emoji,
                streakDays: overview.streakDays,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 24,
            runSpacing: 12,
            children: overview.stats
                .map((stat) => _StatBadge(stat: stat))
                .toList(),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onEdit,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('编辑资料'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: onTimeline,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white54),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('打卡日历'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmojiBadge extends StatelessWidget {
  const _EmojiBadge({required this.emoji, required this.streakDays});

  final String emoji;
  final int streakDays;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 96,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white.withValues(alpha: 0.15),
        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          Text(
            '$streakDays 天',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            '连续改变',
            style: TextStyle(color: Colors.white70, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({required this.stat});

  final ProfileStat stat;

  @override
  Widget build(BuildContext context) {
    final suffix = stat.suffix != null ? stat.suffix! : '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            stat.value + suffix,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat.label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _UpgradeBanner extends StatelessWidget {
  const _UpgradeBanner({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [AppColors.candyYellow, AppColors.candyOrange],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: AppShadows.yellow3d,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.workspace_premium, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    '升级 Dopamine Pro',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '解锁 AI 周报、个性化提醒与多设备同步。',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white70),
          ],
        ),
      ),
    );
  }
}

class _GoalSection extends StatelessWidget {
  const _GoalSection({
    required this.goals,
    required this.onRecord,
    required this.onAdjust,
  });

  final List<ProfileGoal> goals;
  final void Function(String id) onRecord;
  final ValueChanged<ProfileGoal> onAdjust;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '我的目标',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...goals.map(
          (goal) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _GoalCard(
              goal: goal,
              onRecord: () => onRecord(goal.id),
              onAdjust: () => onAdjust(goal),
            ),
          ),
        ),
      ],
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.goal,
    required this.onRecord,
    required this.onAdjust,
  });

  final ProfileGoal goal;
  final VoidCallback onRecord;
  final VoidCallback onAdjust;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: AppShadows.cardSoft,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: goal.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: goal.color.withValues(alpha: 0.35)),
                ),
                child: Icon(goal.icon, color: goal.color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      goal.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      goal.description,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onAdjust,
                icon: const Icon(Icons.tune_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: goal.progress,
              minHeight: 10,
              backgroundColor: goal.color.withValues(alpha: 0.12),
              valueColor: AlwaysStoppedAnimation(goal.color),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                goal.progressLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                goal.isFinished ? '本周达成 ✅' : '继续加油',
                style: TextStyle(
                  color: goal.isFinished ? Colors.green : Colors.black45,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Text(
                '目标 ${goal.target} ${goal.unit}',
                style: const TextStyle(color: Colors.black38),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: goal.isFinished ? null : onRecord,
            style: FilledButton.styleFrom(
              backgroundColor: goal.isFinished
                  ? Colors.grey.shade200
                  : goal.color,
              foregroundColor: goal.isFinished ? Colors.black54 : Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Text(goal.isFinished ? '今日已记' : '记一次'),
          ),
        ],
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

class _GoalEditSheet extends StatefulWidget {
  const _GoalEditSheet({required this.goal});

  final ProfileGoal goal;

  @override
  State<_GoalEditSheet> createState() => _GoalEditSheetState();
}

class _GoalEditSheetState extends State<_GoalEditSheet> {
  late final TextEditingController _targetController;
  int _selectedQuick = 0;

  static const _quickTargets = [3, 4, 5, 7, 10];

  @override
  void initState() {
    super.initState();
    _targetController = TextEditingController(
      text: widget.goal.target.toString(),
    );
  }

  @override
  void dispose() {
    _targetController.dispose();
    super.dispose();
  }

  void _submit() {
    final value = int.tryParse(_targetController.text.trim());
    if (value == null || value <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入正确的目标次数')));
      return;
    }
    Navigator.of(context).pop(value);
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
          Text(
            '调整「${widget.goal.title}」',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            widget.goal.description,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _targetController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '每周目标 (${widget.goal.unit})',
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: List.generate(_quickTargets.length, (index) {
              final value = _quickTargets[index];
              final selected = _selectedQuick == index;
              return ChoiceChip(
                label: Text('$value${widget.goal.unit}'),
                selected: selected,
                onSelected: (_) {
                  setState(() {
                    _selectedQuick = index;
                    _targetController.text = value.toString();
                  });
                },
              );
            }),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('保存目标'),
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
