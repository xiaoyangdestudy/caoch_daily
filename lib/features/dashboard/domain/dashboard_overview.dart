import 'record_type.dart';

/// 首页卡片的展示数据
class DashboardCardStat {
  const DashboardCardStat({
    required this.type,
    required this.value,
    this.subValue,
    this.progress,
    required this.rawValue,
  });

  final RecordType type;
  final String value;
  final String? subValue;
  final double? progress;
  final double rawValue;
}

/// 首页综合数据
class DashboardOverview {
  const DashboardOverview({
    required this.nickname,
    required this.summary,
    required this.vitalityScore,
    required this.cards,
  });

  final String nickname;
  final String summary;
  final int vitalityScore;
  final List<DashboardCardStat> cards;

  bool get hasAnyRecord {
    return cards.any((card) => card.rawValue > 0);
  }
}

/// Provider 对外暴露的状态
class DashboardOverviewState {
  const DashboardOverviewState._({
    required this.isLoading,
    this.data,
    this.error,
  });

  const DashboardOverviewState.loading()
    : this._(isLoading: true, data: null, error: null);

  const DashboardOverviewState.data(DashboardOverview data)
    : this._(isLoading: false, data: data, error: null);

  const DashboardOverviewState.error(Object error)
    : this._(isLoading: false, data: null, error: error);

  final bool isLoading;
  final DashboardOverview? data;
  final Object? error;
}
