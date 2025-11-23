import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/workout_record.dart';

class WorkoutRepository {
  static const String _storageKey = 'workout_records';

  Future<List<WorkoutRecord>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList.map((e) => WorkoutRecord.fromJson(e)).toList();
  }

  Future<void> add(WorkoutRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await getAll();
    records.insert(0, record); // Add to top
    
    final jsonList = records.map((e) => e.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  Future<void> delete(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await getAll();
    records.removeWhere((e) => e.id == id);
    
    final jsonList = records.map((e) => e.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }
}
