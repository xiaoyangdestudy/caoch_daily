import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/providers/preferences_provider.dart';
import '../../../shared/providers/api_provider.dart';
import '../data/diet_repository.dart';
import '../domain/diet_models.dart';

final dietRepositoryProvider = Provider((ref) {
  final store = ref.watch(localStoreProvider);
  final api = ref.watch(apiClientProvider);
  return DietRepository(store, api);
});

final dietRecordsProvider =
    AsyncNotifierProvider<DietRecordsNotifier, List<MealRecord>>(
      DietRecordsNotifier.new,
    );

class DietRecordsNotifier extends AsyncNotifier<List<MealRecord>> {
  late final DietRepository _repository;
  final Uuid _uuid = const Uuid();

  @override
  Future<List<MealRecord>> build() async {
    _repository = ref.watch(dietRepositoryProvider);
    return _repository.fetchAll();
  }

  Future<void> addMeal(MealRecord record) async {
    await _repository.save(record);
    state = AsyncValue.data(await _repository.fetchAll());
  }

  Future<void> createEntry({
    required MealType mealType,
    required String name,
    required int calories,
    double protein = 0,
    double carbs = 0,
    double fat = 0,
    DateTime? timestamp,
    String? notes,
  }) async {
    final item = FoodItem(
      id: _uuid.v4(),
      name: name,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
    );
    final record = MealRecord(
      id: _uuid.v4(),
      mealType: mealType,
      timestamp: timestamp ?? DateTime.now(),
      notes: notes,
      items: [item],
    );
    await addMeal(record);
  }

  Future<void> remove(String id) async {
    await _repository.delete(id);
    state = AsyncValue.data(await _repository.fetchAll());
  }
}
