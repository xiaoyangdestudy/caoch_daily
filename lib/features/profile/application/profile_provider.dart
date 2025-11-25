import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/design/app_colors.dart';
import '../domain/profile_model.dart';

class ProfileNotifier extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    return ProfileState(
      overview: ProfileOverview(
        nickname: 'Alex',
        emoji: '🧠',
        encourageText: '改变自己的第 28 天',
        streakDays: 28,
        stats: const [
          ProfileStat(label: '活跃天数', value: '28'),
          ProfileStat(label: '完成目标', value: '12'),
          ProfileStat(label: '日均专注', value: '4.5', suffix: 'h'),
        ],
      ),
      goals: const [
        ProfileGoal(
          id: 'health',
          title: '健康目标',
          description: '每周 4 次燃脂训练',
          icon: Icons.favorite_rounded,
          color: AppColors.candyPink,
          completed: 3,
          target: 4,
          unit: '次',
        ),
        ProfileGoal(
          id: 'focus',
          title: '工作&学习',
          description: '工作日保持 4 小时深度专注',
          icon: Icons.bolt,
          color: AppColors.candyOrange,
          completed: 17,
          target: 20,
          unit: '小时',
        ),
        ProfileGoal(
          id: 'reading',
          title: '阅读清单',
          description: '本月完成 3 本新书',
          icon: Icons.menu_book_rounded,
          color: AppColors.candyBlue,
          completed: 1,
          target: 3,
          unit: '本',
        ),
      ],
      preferences: const ProfilePreferences(
        notificationsEnabled: true,
        dailyDigestEnabled: true,
        followSystemTheme: true,
        aiStyle: AiCoachStyle.mentor,
      ),
      version: 'v1.0.0 日常教练',
    );
  }

  void updateProfile({String? nickname, String? encourageText, String? emoji}) {
    state = state.copyWith(
      overview: state.overview.copyWith(
        nickname: nickname,
        encourageText: encourageText,
        emoji: emoji,
      ),
    );
  }

  void toggleNotifications(bool enabled) {
    state = state.copyWith(
      preferences: state.preferences.copyWith(notificationsEnabled: enabled),
    );
  }

  void toggleDailyDigest(bool enabled) {
    state = state.copyWith(
      preferences: state.preferences.copyWith(dailyDigestEnabled: enabled),
    );
  }

  void toggleFollowSystemTheme(bool enabled) {
    state = state.copyWith(
      preferences: state.preferences.copyWith(followSystemTheme: enabled),
    );
  }

  void setAiStyle(AiCoachStyle style) {
    state = state.copyWith(
      preferences: state.preferences.copyWith(aiStyle: style),
    );
  }

  void recordGoalProgress(String goalId) {
    final goals = [...state.goals];
    final index = goals.indexWhere((goal) => goal.id == goalId);
    if (index == -1) return;

    final goal = goals[index];
    if (goal.isFinished) {
      return;
    }
    final updated = goal.copyWith(completed: goal.completed + 1);
    goals[index] = updated;
    state = state.copyWith(goals: goals);
  }

  void updateGoalTarget(String goalId, int target) {
    if (target <= 0) {
      return;
    }
    final goals = [...state.goals];
    final index = goals.indexWhere((goal) => goal.id == goalId);
    if (index == -1) return;
    var goal = goals[index];
    final clippedCompleted = goal.completed.clamp(0, target);
    goal = goal.copyWith(target: target, completed: clippedCompleted);
    goals[index] = goal;
    state = state.copyWith(goals: goals);
  }
}

final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(
  ProfileNotifier.new,
);
