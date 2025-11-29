import 'package:flutter/material.dart';

/// 统一的高饱和色彩系统，对应 daily-coach-ai 的 Dopamine Palette
class AppColors {
  const AppColors._();

  // Candy Colors (Light Mode)
  static const candyPink = Color(0xFFFFC0CB);
  static const candyOrange = Color(0xFFFFB347);
  static const candyBlue = Color(0xFF87CEEB);
  static const candyPurple = Color(0xFFE0B0FF);
  static const candyGreen = Color(0xFF98FF98);
  static const candyYellow = Color(0xFFFFEB99);

  // Backgrounds
  static const background = Color(0xFF0F172A); // Deep Dark Blue/Grey
  static const backgroundDark = Color(0xFF020617); // Almost Black
  static const surface = Color(0xFF1E293B); // Lighter Dark Blue/Grey
  static const surfaceLight = Color(0xFF334155); // Even Lighter

  // Neon Accents
  static const neonGreen = Color(0xFF00FF94);
  static const neonBlue = Color(0xFF00E5FF);
  static const neonPurple = Color(0xFFBD00FF);
  static const neonPink = Color(0xFFFF0055);
  static const neonOrange = Color(0xFFFF9100);

  // Text
  static const textPrimary = Color(0xFFF8FAFC);
  static const textSecondary = Color(0xFF94A3B8);
  static const textTertiary = Color(0xFF64748B);

  // Functional
  static const error = Color(0xFFFF453A);
  static const success = Color(0xFF00FF94);
  static const warning = Color(0xFFFF9100);

  // Gradients
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [neonBlue, neonPurple],
  );

  static const secondaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [neonGreen, neonBlue],
  );

  static const fireGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [neonOrange, neonPink],
  );
}
