import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/design/app_colors.dart';

class AppShellPage extends StatefulWidget {
  const AppShellPage({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<AppShellPage> createState() => _AppShellPageState();
}

class _AppShellPageState extends State<AppShellPage> {
  void _onDestinationSelected(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: widget.navigationShell,
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x19000000),
            offset: Offset(0, -12),
            blurRadius: 40,
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

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.candyBlue.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: selected ? AppColors.candyBlue : Colors.grey,
            ),
          ),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: selected ? AppColors.candyBlue : Colors.grey.shade600,
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }
}
