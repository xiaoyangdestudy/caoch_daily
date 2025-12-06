import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../dashboard/application/dashboard_providers.dart';
import '../../diet/application/diet_providers.dart';
import '../../profile/application/user_profile_provider.dart';
import '../../sleep/application/sleep_providers.dart';
import '../../sports/application/sports_providers.dart';
import '../../work/application/work_providers.dart';

class AppShellPage extends ConsumerStatefulWidget {
  const AppShellPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShellPage> createState() => _AppShellPageState();
}

class _AppShellPageState extends ConsumerState<AppShellPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _switchController;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _warmupCoreData());
    _switchController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..value = 1;
    final curve = CurvedAnimation(
      parent: _switchController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _fadeAnimation = Tween<double>(begin: 0.92, end: 1).animate(curve);
    _scaleAnimation = Tween<double>(begin: 0.98, end: 1).animate(curve);
  }

  void _warmupCoreData() {
    Future.wait([
      ref.read(workoutListProvider.future),
      ref.read(dietRecordsProvider.future),
      ref.read(sleepRecordsProvider.future),
      ref.read(focusSessionsProvider.future),
      ref.read(userProfileProvider.future),
    ]).catchError((_) {
      // 预加载失败时静默，避免影响导航流畅性
    });
    ref.read(dashboardOverviewProvider);
  }

  void _onDestinationSelected(int index) {
    _switchController.forward(from: 0);
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  void dispose() {
    _switchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: widget.navigationShell,
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: _BottomBar(
          currentIndex: widget.navigationShell.currentIndex,
          onChanged: _onDestinationSelected,
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.currentIndex, required this.onChanged});

  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? theme.colorScheme.surface.withOpacity(0.9)
                : Colors.white.withOpacity(0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(
                color: theme.colorScheme.outline.withOpacity(0.1),
                width: 0.5,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                offset: const Offset(0, -2),
                blurRadius: 16,
                spreadRadius: 0,
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                icon: Icons.home_filled,
                label: '首页',
                index: 0,
                currentIndex: currentIndex,
                onTap: () => onChanged(0),
              ),
              _NavItem(
                icon: Icons.playlist_add_check_rounded,
                label: '复盘',
                index: 1,
                currentIndex: currentIndex,
                onTap: () => onChanged(1),
              ),
              _NavItem(
                icon: Icons.photo_library_outlined,
                label: '动态',
                index: 2,
                currentIndex: currentIndex,
                onTap: () => onChanged(2),
              ),
              _NavItem(
                icon: Icons.query_stats_rounded,
                label: '统计',
                index: 3,
                currentIndex: currentIndex,
                onTap: () => onChanged(3),
              ),
              _NavItem(
                icon: Icons.person_outline,
                label: '我的',
                index: 4,
                currentIndex: currentIndex,
                onTap: () => onChanged(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.currentIndex,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final int index;
  final int currentIndex;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final selected = index == currentIndex;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 使用 Stack 避免颜色插值问题
            SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 背景层 - 使用 AnimatedOpacity 而不是 AnimatedContainer
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    opacity: selected ? 1.0 : 0.0,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  // Icon 层 - 使用 AnimatedSwitcher 实现平滑过渡
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeInOut,
                    switchOutCurve: Curves.easeInOut,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: Icon(
                      icon,
                      key: ValueKey('$index-$selected'),
                      size: 24,
                      color: selected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              style: TextStyle(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
                height: 1.2,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
