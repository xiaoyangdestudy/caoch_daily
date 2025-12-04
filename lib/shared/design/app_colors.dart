import 'package:flutter/material.dart';

/// Modern, professional color system inspired by mainstream apps
/// 现代化、专业的配色系统，参考主流应用设计
class AppColors {
  const AppColors._();

  // ========== Light Mode Colors ==========

  // Backgrounds (浅色模式背景)
  static const lightBackground = Color(0xFFFFFFFF); // Pure white
  static const lightSurface = Color(0xFFF8F9FA); // Very light grey
  static const lightSurfaceVariant = Color(0xFFF1F3F5); // Light grey
  static const lightBorder = Color(0xFFE5E7EB); // Border color

  // Text (浅色模式文字)
  static const lightTextPrimary = Color(0xFF1F2937); // Almost black
  static const lightTextSecondary = Color(0xFF6B7280); // Medium grey
  static const lightTextTertiary = Color(0xFF9CA3AF); // Light grey
  static const lightTextDisabled = Color(0xFFD1D5DB); // Very light grey

  // ========== Dark Mode Colors ==========

  // Backgrounds (深色模式背景)
  static const darkBackground = Color(0xFF0F172A); // Deep blue-grey
  static const darkSurface = Color(0xFF1E293B); // Lighter dark
  static const darkSurfaceVariant = Color(0xFF334155); // Even lighter
  static const darkBorder = Color(0xFF475569); // Border color

  // Text (深色模式文字)
  static const darkTextPrimary = Color(0xFFF1F5F9); // Almost white
  static const darkTextSecondary = Color(0xFFCBD5E1); // Light grey
  static const darkTextTertiary = Color(0xFF94A3B8); // Medium grey
  static const darkTextDisabled = Color(0xFF64748B); // Dark grey

  // ========== Brand Colors ==========

  // Primary (主色 - 蓝紫色系)
  static const primary = Color(0xFF6366F1); // Indigo
  static const primaryLight = Color(0xFF818CF8); // Light indigo
  static const primaryDark = Color(0xFF4F46E5); // Dark indigo
  static const primaryContainer = Color(0xFFEEF2FF); // Very light indigo bg

  // Secondary (次要色 - 绿色系，用于积极状态)
  static const secondary = Color(0xFF10B981); // Emerald
  static const secondaryLight = Color(0xFF34D399); // Light emerald
  static const secondaryDark = Color(0xFF059669); // Dark emerald
  static const secondaryContainer = Color(0xFFECFDF5); // Very light emerald bg

  // ========== Feature Module Colors ==========
  // 功能模块配色（柔和、专业）

  // Exercise/Sports (运动 - 橙色系)
  static const exercise = Color(0xFFF97316); // Orange
  static const exerciseLight = Color(0xFFFB923C);
  static const exerciseDark = Color(0xFFEA580C);
  static const exerciseContainer = Color(0xFFFFF7ED);

  // Diet (饮食 - 绿色系)
  static const diet = Color(0xFF10B981); // Emerald
  static const dietLight = Color(0xFF34D399);
  static const dietDark = Color(0xFF059669);
  static const dietContainer = Color(0xFFECFDF5);

  // Sleep (睡眠 - 蓝色系)
  static const sleep = Color(0xFF3B82F6); // Blue
  static const sleepLight = Color(0xFF60A5FA);
  static const sleepDark = Color(0xFF2563EB);
  static const sleepContainer = Color(0xFFEFF6FF);

  // Work/Focus (工作 - 紫色系)
  static const work = Color(0xFF8B5CF6); // Violet
  static const workLight = Color(0xFFA78BFA);
  static const workDark = Color(0xFF7C3AED);
  static const workContainer = Color(0xFFF5F3FF);

  // Reading (阅读 - 粉色系)
  static const reading = Color(0xFFEC4899); // Pink
  static const readingLight = Color(0xFFF472B6);
  static const readingDark = Color(0xFFDB2777);
  static const readingContainer = Color(0xFFFDF2F8);

  // ========== Semantic Colors ==========
  // 语义化颜色

  static const success = Color(0xFF10B981); // Green
  static const successLight = Color(0xFF34D399);
  static const successContainer = Color(0xFFECFDF5);

  static const warning = Color(0xFFF59E0B); // Amber
  static const warningLight = Color(0xFFFBBF24);
  static const warningContainer = Color(0xFFFFFBEB);

  static const error = Color(0xFFEF4444); // Red
  static const errorLight = Color(0xFFF87171);
  static const errorDark = Color(0xFFDC2626); // Dark red
  static const errorContainer = Color(0xFFFEF2F2);

  static const info = Color(0xFF3B82F6); // Blue
  static const infoLight = Color(0xFF60A5FA);
  static const infoContainer = Color(0xFFEFF6FF);

  // ========== Special Effects ==========
  // 特殊效果

  // Overlays
  static const overlayLight = Color(0x0A000000); // 4% black
  static const overlayMedium = Color(0x1F000000); // 12% black
  static const overlayHeavy = Color(0x3D000000); // 24% black

  static const overlayDarkLight = Color(0x0AFFFFFF); // 4% white
  static const overlayDarkMedium = Color(0x1FFFFFFF); // 12% white
  static const overlayDarkHeavy = Color(0x3DFFFFFF); // 24% white

  // Gradients (渐变)
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  static const successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [secondary, secondaryLight],
  );

  static const warmGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF97316), Color(0xFFFBBF24)],
  );

  // ========== Legacy Colors (for backward compatibility) ==========
  // 保留旧的颜色名称以保持向后兼容

  @Deprecated('Use primary instead')
  static const candyPurple = primary;

  @Deprecated('Use exercise instead')
  static const candyPink = exercise;

  @Deprecated('Use warning instead')
  static const candyOrange = warning;

  @Deprecated('Use sleep instead')
  static const candyBlue = sleep;

  @Deprecated('Use diet instead')
  static const candyGreen = diet;

  @Deprecated('Use dietDark instead')
  static const candyGreenDark = dietDark;

  @Deprecated('Use warningLight instead')
  static const candyYellow = warningLight;

  static const candyMint = Color(0xFFB2F7EF); // Mint color for backward compatibility
  static const candyLime = Color(0xFFD4FF88); // Lime color for backward compatibility

  @Deprecated('Use darkBackground instead')
  static const background = darkBackground;

  static const backgroundDark = Color(0xFF020617); // Almost black, for backward compatibility

  @Deprecated('Use darkSurface instead')
  static const surface = darkSurface;

  @Deprecated('Use darkTextPrimary instead')
  static const textPrimary = darkTextPrimary;

  @Deprecated('Use darkTextSecondary instead')
  static const textSecondary = darkTextSecondary;

  @Deprecated('Use darkTextTertiary instead')
  static const textTertiary = darkTextTertiary;

  @Deprecated('Use primaryLight instead')
  static const neonBlue = primaryLight;

  @Deprecated('Use work instead')
  static const neonPurple = work;
}
