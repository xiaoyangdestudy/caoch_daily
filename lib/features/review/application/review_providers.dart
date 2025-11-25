import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/providers/preferences_provider.dart';
import '../data/review_repository.dart';
import '../domain/review_record.dart';

final reviewRepositoryProvider = Provider((ref) {
  final store = ref.watch(localStoreProvider);
  return ReviewRepository(store);
});

final reviewEntriesProvider =
    AsyncNotifierProvider<ReviewEntriesNotifier, List<ReviewEntry>>(
      ReviewEntriesNotifier.new,
    );

class ReviewEntriesNotifier extends AsyncNotifier<List<ReviewEntry>> {
  late final ReviewRepository _repository;
  final Uuid _uuid = const Uuid();

  @override
  Future<List<ReviewEntry>> build() async {
    _repository = ref.watch(reviewRepositoryProvider);
    return _repository.fetchAll();
  }

  Future<void> addReview({
    required String mood,
    required List<String> highlights,
    required List<String> improvements,
    required List<String> plans,
    String? note,
  }) async {
    final entry = ReviewEntry(
      id: _uuid.v4(),
      date: DateTime.now(),
      mood: mood,
      highlights: highlights,
      improvements: improvements,
      tomorrowPlans: plans,
      note: note,
      aiSummary: _buildSummary(highlights, improvements, plans),
    );

    await _repository.save(entry);
    state = AsyncValue.data(await _repository.fetchAll());
  }

  String _buildSummary(
    List<String> highlights,
    List<String> improvements,
    List<String> plans,
  ) {
    final good = highlights.isNotEmpty ? highlights.first : '继续保持当下的节奏';
    final improve = improvements.isNotEmpty ? improvements.first : '保持休息';
    final plan = plans.isNotEmpty ? plans.first : '坚持完成核心任务';
    return '今日亮点：$good；需要关注：$improve；明日计划：$plan。';
  }
}
