import 'package:flutter/material.dart';
import '../../shared/design/app_colors.dart';

/// Modern gradient mesh background for the app
/// 现代化渐变网格背景
class MeshBackground extends StatefulWidget {
  const MeshBackground({super.key, required this.child});

  final Widget child;

  @override
  State<MeshBackground> createState() => _MeshBackgroundState();
}

class _MeshBackgroundState extends State<MeshBackground>
    with TickerProviderStateMixin {
  late final AnimationController _controller1;
  late final AnimationController _controller2;
  late final AnimationController _controller3;

  @override
  void initState() {
    super.initState();
    _controller1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    _controller2 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _controller3 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        // Background gradient
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        AppColors.darkBackground,
                        AppColors.darkSurface,
                      ]
                    : [
                        AppColors.lightBackground,
                        AppColors.lightSurface,
                      ],
              ),
            ),
          ),
        ),
        // Subtle decorative circles - top right
        AnimatedBuilder(
          animation: _controller1,
          builder: (context, child) {
            return Positioned(
              top: -80 + (_controller1.value * 20),
              right: -80 + (_controller1.value * 15),
              child: child!,
            );
          },
          child: Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isDark
                    ? [
                        AppColors.primaryLight.withOpacity(0.12),
                        AppColors.primaryLight.withOpacity(0.02),
                        Colors.transparent,
                      ]
                    : [
                        AppColors.primary.withOpacity(0.08),
                        AppColors.primary.withOpacity(0.02),
                        Colors.transparent,
                      ],
              ),
            ),
          ),
        ),
        // Subtle decorative circles - bottom left
        AnimatedBuilder(
          animation: _controller2,
          builder: (context, child) {
            return Positioned(
              bottom: -100 + (_controller2.value * 25),
              left: -100 + (_controller2.value * 15),
              child: child!,
            );
          },
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isDark
                    ? [
                        AppColors.secondaryLight.withOpacity(0.12),
                        AppColors.secondaryLight.withOpacity(0.02),
                        Colors.transparent,
                      ]
                    : [
                        AppColors.secondary.withOpacity(0.08),
                        AppColors.secondary.withOpacity(0.02),
                        Colors.transparent,
                      ],
              ),
            ),
          ),
        ),
        // Subtle decorative circle - center right
        AnimatedBuilder(
          animation: _controller3,
          builder: (context, child) {
            return Positioned(
              top: MediaQuery.of(context).size.height * 0.4 +
                  (_controller3.value * 30),
              right: -60 + (_controller3.value * 10),
              child: child!,
            );
          },
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: isDark
                    ? [
                        AppColors.work.withOpacity(0.1),
                        AppColors.work.withOpacity(0.02),
                        Colors.transparent,
                      ]
                    : [
                        AppColors.work.withOpacity(0.06),
                        AppColors.work.withOpacity(0.01),
                        Colors.transparent,
                      ],
              ),
            ),
          ),
        ),
        SafeArea(child: widget.child),
      ],
    );
  }
}
