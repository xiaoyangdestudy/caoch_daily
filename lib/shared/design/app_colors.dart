import 'package:flutter/material.dart';

/// 统一的高饱和色彩系统，对应 daily-coach-ai 的 Dopamine Palette
class AppColors {
  const AppColors._();

  static const candyPink = Color(0xFFFF5E9F);
  static const candyPinkDark = Color(0xFFD63D7B);
  static const candyPurple = Color(0xFF9D00FF);
  static const candyPurpleDark = Color(0xFF7A00C7);
  static const candyBlue = Color(0xFF2EC4B6);
  static const candyBlueDark = Color(0xFF1E9E92);
  static const candyGreen = Color(0xFF4EFF85);
  static const candyGreenDark = Color(0xFF2DDB63);
  static const candyLime = Color(0xFFD4FF00);
  static const candyLimeDark = Color(0xFFA6C700);
  static const candyYellow = Color(0xFFFFD600);
  static const candyYellowDark = Color(0xFFD1AF00);
  static const candyOrange = Color(0xFFFF9F1C);
  static const candyOrangeDark = Color(0xFFD67D00);
  static const candyMint = Color(0xFF00F5D4);
  static const surface = Color(0xFFF0F4F8);

  static const meshGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF9A9E),
      Color(0xFFFECFEF),
      Color(0xFFE0C3FC),
      Color(0xFFA1C4FD),
      Color(0xFFC2E9FB),
    ],
  );
}
