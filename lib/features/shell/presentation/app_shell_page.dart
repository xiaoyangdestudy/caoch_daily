import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../shared/design/app_colors.dart';
import '../../../shared/design/app_shadows.dart';
import '../../dashboard/domain/record_type.dart';
import '../../dashboard/presentation/widgets/quick_record_sheet.dart';

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

  void _openQuickSheet() {
    showQuickRecordSheet(context, initialType: RecordType.exercise);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.transparent,
      body: widget.navigationShell,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: GestureDetector(
        onTap: _openQuickSheet,
        child: Container(
          width: 78,
          height: 78,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.candyYellow, AppColors.candyOrange],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: AppShadows.yellow3d,
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.white54, Colors.transparent],
                      ),
                    ),
                  ),
                ),
              ),
              const Center(
                child: Icon(Icons.add, size: 36, color: Colors.white),
              ),
            ],
          ),
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
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final gap = constraints.maxWidth >= 320 ? 72.0 : 32.0;
          final sideWidth = (constraints.maxWidth - gap) / 2;
          return Row(
            children: [
              SizedBox(
                width: sideWidth,
                child: _NavGroup(
                  alignment: WrapAlignment.start,
                  children: [
                    _NavItem(
                      icon: Icons.home_filled,
                      label: '首页',
                      index: 0,
                      currentIndex: currentIndex,
                      onTap: () => onChanged(0),
                    ),
                    _NavItem(
                      icon: Icons.query_stats_rounded,
                      label: '统计',
                      index: 2,
                      currentIndex: currentIndex,
                      onTap: () => onChanged(2),
                    ),
                  ],
                ),
              ),
              SizedBox(width: gap),
              SizedBox(
                width: sideWidth,
                child: _NavGroup(
                  alignment: WrapAlignment.end,
                  children: [
                    _NavItem(
                      icon: Icons.playlist_add_check_rounded,
                      label: '复盘',
                      index: 1,
                      currentIndex: currentIndex,
                      onTap: () => onChanged(1),
                    ),
                    _NavItem(
                      icon: Icons.person_outline,
                      label: '我的',
                      index: 3,
                      currentIndex: currentIndex,
                      onTap: () => onChanged(3),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _NavGroup extends StatelessWidget {
  const _NavGroup({required this.children, required this.alignment});

  final List<Widget> children;
  final WrapAlignment alignment;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 8,
      alignment: alignment,
      children: children,
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
