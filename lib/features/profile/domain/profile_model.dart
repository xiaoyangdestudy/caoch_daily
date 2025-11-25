import 'package:flutter/material.dart';

/// AI 教练的语气风格，用于偏好设置中供用户切换
enum AiCoachStyle { gentle, mentor, challenger }

extension AiCoachStyleX on AiCoachStyle {
  String get label {
    switch (this) {
      case AiCoachStyle.gentle:
        return '温柔鼓励';
      case AiCoachStyle.mentor:
        return '专业导师';
      case AiCoachStyle.challenger:
        return '强度锻炼';
    }
  }

  String get description {
    switch (this) {
      case AiCoachStyle.gentle:
        return '以朋友口吻轻声提醒，适合刚起步的习惯养成。';
      case AiCoachStyle.mentor:
        return '提供结构化建议，像导师一样给出拆解方案。';
      case AiCoachStyle.challenger:
        return '强调目标结果，用更直白的语言督促执行。';
    }
  }

  String get emoji {
    switch (this) {
      case AiCoachStyle.gentle:
        return '🌈';
      case AiCoachStyle.mentor:
        return '🧠';
      case AiCoachStyle.challenger:
        return '⚡';
    }
  }
}

class ProfileStat {
  const ProfileStat({required this.label, required this.value, this.suffix});

  final String label;
  final String value;
  final String? suffix;
}

class ProfileOverview {
  const ProfileOverview({
    required this.nickname,
    required this.emoji,
    required this.encourageText,
    required this.stats,
    required this.streakDays,
  });

  final String nickname;
  final String emoji;
  final String encourageText;
  final List<ProfileStat> stats;
  final int streakDays;

  ProfileOverview copyWith({
    String? nickname,
    String? emoji,
    String? encourageText,
    List<ProfileStat>? stats,
    int? streakDays,
  }) {
    return ProfileOverview(
      nickname: nickname ?? this.nickname,
      emoji: emoji ?? this.emoji,
      encourageText: encourageText ?? this.encourageText,
      stats: stats ?? this.stats,
      streakDays: streakDays ?? this.streakDays,
    );
  }
}

class ProfileGoal {
  const ProfileGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.completed,
    required this.target,
    required this.unit,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final int completed;
  final int target;
  final String unit;

  double get progress {
    if (target == 0) {
      return 0;
    }
    final ratio = completed / target;
    return ratio.clamp(0, 1).toDouble();
  }

  bool get isFinished => completed >= target;

  String get progressLabel => '$completed/$target $unit';

  ProfileGoal copyWith({
    String? id,
    String? title,
    String? description,
    IconData? icon,
    Color? color,
    int? completed,
    int? target,
    String? unit,
  }) {
    return ProfileGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      completed: completed ?? this.completed,
      target: target ?? this.target,
      unit: unit ?? this.unit,
    );
  }
}

class ProfilePreferences {
  const ProfilePreferences({
    required this.notificationsEnabled,
    required this.dailyDigestEnabled,
    required this.followSystemTheme,
    required this.aiStyle,
  });

  final bool notificationsEnabled;
  final bool dailyDigestEnabled;
  final bool followSystemTheme;
  final AiCoachStyle aiStyle;

  ProfilePreferences copyWith({
    bool? notificationsEnabled,
    bool? dailyDigestEnabled,
    bool? followSystemTheme,
    AiCoachStyle? aiStyle,
  }) {
    return ProfilePreferences(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyDigestEnabled: dailyDigestEnabled ?? this.dailyDigestEnabled,
      followSystemTheme: followSystemTheme ?? this.followSystemTheme,
      aiStyle: aiStyle ?? this.aiStyle,
    );
  }
}

class ProfileState {
  const ProfileState({
    required this.overview,
    required this.goals,
    required this.preferences,
    required this.version,
  });

  final ProfileOverview overview;
  final List<ProfileGoal> goals;
  final ProfilePreferences preferences;
  final String version;

  ProfileState copyWith({
    ProfileOverview? overview,
    List<ProfileGoal>? goals,
    ProfilePreferences? preferences,
    String? version,
  }) {
    return ProfileState(
      overview: overview ?? this.overview,
      goals: goals ?? this.goals,
      preferences: preferences ?? this.preferences,
      version: version ?? this.version,
    );
  }
}
