import 'package:flutter/material.dart';

import '../../../shared/design/app_colors.dart';

enum RecordType { exercise, diet, sleep, work, reading }

extension RecordTypeX on RecordType {
  String get label {
    switch (this) {
      case RecordType.exercise:
        return '运动';
      case RecordType.diet:
        return '饮食';
      case RecordType.sleep:
        return '睡眠';
      case RecordType.work:
        return '工作';
      case RecordType.reading:
        return '阅读';
    }
  }

  IconData get icon {
    switch (this) {
      case RecordType.exercise:
        return Icons.fitness_center;
      case RecordType.diet:
        return Icons.restaurant_rounded;
      case RecordType.sleep:
        return Icons.nights_stay_rounded;
      case RecordType.work:
        return Icons.work_outline;
      case RecordType.reading:
        return Icons.menu_book_rounded;
    }
  }

  Color get color {
    switch (this) {
      case RecordType.exercise:
        return AppColors.candyPink;
      case RecordType.diet:
        return AppColors.candyYellow;
      case RecordType.sleep:
        return AppColors.candyBlue;
      case RecordType.work:
        return AppColors.candyPurple;
      case RecordType.reading:
        return AppColors.candyGreen;
    }
  }

  bool get prefersDarkText =>
      this == RecordType.diet || this == RecordType.sleep;
}
