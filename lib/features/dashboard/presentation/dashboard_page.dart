import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';

import '../../../app/router/app_routes.dart';
import '../../../shared/design/app_colors.dart';
import '../../../shared/design/app_shadows.dart';
import '../application/dashboard_providers.dart';
import '../domain/dashboard_overview.dart';
import '../domain/record_type.dart';
import '../../profile/application/profile_provider.dart';
import '../../profile/application/user_profile_provider.dart';
import 'widgets/quick_record_sheet.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  String get _dateLabel {
    final now = DateTime.now();
    const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    final weekday = weekdays[now.weekday - 1];
    return '${now.month}月${now.day}日 · $weekday';
  }

  void _openRecordSheet(BuildContext context, RecordType type) {
    showQuickRecordSheet(context, initialType: type);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overviewState = ref.watch(dashboardOverviewProvider);
    final overview = overviewState.data;
    final nickname = overview?.nickname ?? 'Alex';
    final hasError = overviewState.error != null;
    final showSkeleton =
        overviewState.isLoading && overview == null && !hasError;
    final cards = hasError
        ? _initialCardStats
        : (overview?.cards ?? _initialCardStats);
    final summaryText = hasError
        ? '数据加载失败，请稍后重试。'
        : overview?.summary ?? '今日数据加载中...记得随手记录。';
    final vitality = hasError ? 0 : overview?.vitalityScore ?? 0;

    // Get user avatar/emoji - 优先使用服务器头像，否则使用本地 emoji
    final userProfileAsync = ref.watch(userProfileProvider);
    final profileState = ref.watch(profileProvider);
    final userEmoji = profileState.overview.emoji;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: CustomScrollView(
            key: ValueKey(showSkeleton),
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _dateLabel,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              nickname,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: colorScheme.onSurface,
                                height: 1.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Review Button
                      Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              offset: const Offset(0, 2),
                              blurRadius: 8,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: () => context.go(AppRoutes.review),
                          icon: const Icon(Icons.note_alt_outlined),
                          color: AppColors.primary,
                          tooltip: '每日复盘',
                        ),
                      ),
                      const SizedBox(width: 8),
                      // User Avatar/Emoji
                      _buildUserAvatar(
                        userProfileAsync,
                        userEmoji,
                        colorScheme,
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: _HeroCard(
                    summary: summaryText,
                    vitality: vitality,
                    isLoading: showSkeleton,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final card = cards[index];
                    return DashboardStatCard(
                      title: card.type.label,
                      type: card.type,
                      value: card.value,
                      subValue: card.subValue,
                      progress: card.progress,
                      darkText: card.type.prefersDarkText,
                      isLoading: showSkeleton,
                      onTap: () {
                        if (card.type == RecordType.exercise) {
                          context.push(AppRoutes.sports);
                        } else if (card.type == RecordType.diet) {
                          context.push(AppRoutes.diet);
                        } else if (card.type == RecordType.sleep) {
                          context.push(AppRoutes.sleep);
                        } else if (card.type == RecordType.work) {
                          context.push(AppRoutes.work);
                        } else {
                          _openRecordSheet(context, card.type);
                        }
                      },
                    );
                  }, childCount: cards.length),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.summary,
    required this.vitality,
    required this.isLoading,
  });

  final String summary;
  final int vitality;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 200,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondaryLight,
            AppColors.secondary,
            AppColors.secondaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.3),
            offset: const Offset(0, 8),
            blurRadius: 24,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 2),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Top right decorative circle
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Bottom left decorative circle
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.03),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Center decorative circle
          Positioned(
            top: 60,
            right: 30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.white.withOpacity(0.1), Colors.transparent],
                ),
              ),
            ),
          ),
          // Glassmorphism overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.15),
                    Colors.white.withOpacity(0.05),
                    Colors.transparent,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '活力值',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withOpacity(0.9),
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 280),
                          child: isLoading
                              ? const _SkeletonBlock(
                                  key: ValueKey('hero-vitality-loading'),
                                  width: 72,
                                  height: 40,
                                  borderRadius: 16,
                                )
                              : Text(
                                  vitality.toString(),
                                  key: ValueKey('hero-vitality-$vitality'),
                                  style: const TextStyle(
                                    fontSize: 52,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1.0,
                                  ),
                                ),
                        ),
                      ],
                    ),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.3),
                            offset: const Offset(0, 4),
                            blurRadius: 12,
                            spreadRadius: 0,
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            offset: const Offset(0, 2),
                            blurRadius: 8,
                            spreadRadius: 0,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: const Text('🔥', style: TextStyle(fontSize: 28)),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.95),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, 2),
                        blurRadius: 8,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.secondaryLight,
                              AppColors.secondary,
                            ],
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Text('😎', style: TextStyle(fontSize: 16)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: isLoading
                              ? Column(
                                  key: const ValueKey('hero-summary-loading'),
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    _SkeletonBlock(
                                      width: double.infinity,
                                      height: 14,
                                      borderRadius: 10,
                                    ),
                                    SizedBox(height: 6),
                                    _SkeletonBlock(
                                      width: 180,
                                      height: 14,
                                      borderRadius: 10,
                                    ),
                                  ],
                                )
                              : Text(
                                  summary,
                                  key: ValueKey('hero-summary-$summary'),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                    height: 1.3,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const List<DashboardCardStat> _initialCardStats = [
  DashboardCardStat(
    type: RecordType.exercise,
    value: '0',
    subValue: 'min',
    progress: 0,
    rawValue: 0,
  ),
  DashboardCardStat(
    type: RecordType.diet,
    value: '0',
    subValue: 'kcal',
    progress: 0,
    rawValue: 0,
  ),
  DashboardCardStat(
    type: RecordType.sleep,
    value: '0',
    subValue: 'hr',
    progress: null,
    rawValue: 0,
  ),
  DashboardCardStat(
    type: RecordType.work,
    value: '0',
    subValue: 'hr',
    progress: 0,
    rawValue: 0,
  ),
];

class DashboardStatCard extends StatefulWidget {
  const DashboardStatCard({
    super.key,
    required this.title,
    required this.type,
    required this.value,
    this.subValue,
    this.progress,
    this.onTap,
    this.darkText = false,
    this.isLoading = false,
  });

  final String title;
  final RecordType type;
  final String value;
  final String? subValue;
  final double? progress;
  final VoidCallback? onTap;
  final bool darkText;
  final bool isLoading;

  @override
  State<DashboardStatCard> createState() => _DashboardStatCardState();
}

class _DashboardStatCardState extends State<DashboardStatCard> {
  bool _isPressed = false;

  List<BoxShadow> get _shadows {
    switch (widget.type) {
      case RecordType.exercise:
        return AppShadows.pink3d;
      case RecordType.diet:
        return AppShadows.yellow3d;
      case RecordType.sleep:
        return AppShadows.blue3d;
      case RecordType.work:
        return AppShadows.purple3d;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: widget.type.gradient,
            borderRadius: BorderRadius.circular(22),
            boxShadow: _isPressed
                ? _shadows
                      .map(
                        (s) => BoxShadow(
                          color: s.color.withOpacity(s.color.opacity * 0.5),
                          blurRadius: s.blurRadius * 0.5,
                          offset: s.offset * 0.5,
                          spreadRadius: s.spreadRadius,
                        ),
                      )
                      .toList()
                : _shadows,
          ),
          child: Stack(
            children: [
              // Subtle shine effect
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(
                            widget.darkText ? 0.4 : 0.2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.type.icon,
                          color: widget.darkText
                              ? Colors.black87
                              : Colors.white,
                          size: 16,
                        ),
                      ),
                      if (widget.progress != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(
                              widget.darkText ? 0.4 : 0.2,
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${(widget.progress! * 100).round()}%',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: widget.darkText
                                  ? Colors.black.withOpacity(0.8)
                                  : Colors.white.withOpacity(0.95),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: widget.darkText
                              ? Colors.black.withOpacity(0.7)
                              : Colors.white.withOpacity(0.9),
                        ),
                      ),
                      const SizedBox(height: 1),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: widget.isLoading
                            ? Column(
                                key: ValueKey('loading-${widget.type.name}'),
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const _SkeletonBlock(
                                    width: 56,
                                    height: 26,
                                    borderRadius: 10,
                                  ),
                                  if (widget.subValue != null)
                                    const Padding(
                                      padding: EdgeInsets.only(top: 6),
                                      child: _SkeletonBlock(
                                        width: 32,
                                        height: 12,
                                        borderRadius: 999,
                                      ),
                                    ),
                                ],
                              )
                            : Row(
                                key: ValueKey(
                                  'value-${widget.type.name}-${widget.value}-${widget.subValue ?? ''}',
                                ),
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    widget.value,
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w900,
                                      color: widget.darkText
                                          ? Colors.black87
                                          : Colors.white,
                                    ),
                                  ),
                                  if (widget.subValue != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 4,
                                        left: 4,
                                      ),
                                      child: Text(
                                        widget.subValue!,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: widget.darkText
                                              ? Colors.black.withOpacity(0.6)
                                              : Colors.white.withOpacity(0.7),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                      ),
                      if (widget.progress != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(
                              widget.darkText ? 0.1 : 0.3,
                            ),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: widget.progress!.clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: widget.darkText
                                    ? Colors.black87
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 构建用户头像/emoji显示
Widget _buildUserAvatar(
  AsyncValue<dynamic> userProfileAsync,
  String fallbackEmoji,
  ColorScheme colorScheme,
) {
  return userProfileAsync.when(
    data: (userProfile) {
      final avatar = userProfile?.avatar;

      // 如果有服务器头像，显示头像（异步解码）
      if (avatar != null && avatar.isNotEmpty) {
        return FutureBuilder<Uint8List>(
          future: compute<String, Uint8List>(_decodeAvatarBase64, avatar),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      offset: const Offset(0, 4),
                      blurRadius: 12,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 24,
                  backgroundImage: MemoryImage(snapshot.data!),
                ),
              );
            } else {
              // 解码中或失败，显示默认 emoji
              return _buildDefaultEmojiAvatar(fallbackEmoji);
            }
          },
        );
      }

      // 没有头像，显示默认emoji
      return _buildDefaultEmojiAvatar(fallbackEmoji);
    },
    loading: () => _buildDefaultEmojiAvatar(fallbackEmoji),
    error: (_, __) => _buildDefaultEmojiAvatar(fallbackEmoji),
  );
}

/// 在 Isolate 中解码 Base64 头像
Uint8List _decodeAvatarBase64(String avatarString) {
  final pureBase64 = avatarString.contains(',')
      ? avatarString.split(',').last
      : avatarString;
  return base64Decode(pureBase64);
}

/// 构建默认Emoji头像
Widget _buildDefaultEmojiAvatar(String emoji) {
  return Container(
    width: 48,
    height: 48,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.primaryLight, AppColors.primary],
      ),
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.3),
          offset: const Offset(0, 4),
          blurRadius: 12,
          spreadRadius: 0,
        ),
      ],
    ),
    alignment: Alignment.center,
    child: Text(emoji, style: const TextStyle(fontSize: 24)),
  );
}

class _SkeletonBlock extends StatelessWidget {
  const _SkeletonBlock({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(
      context,
    ).colorScheme.surfaceVariant.withOpacity(0.5);
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}
