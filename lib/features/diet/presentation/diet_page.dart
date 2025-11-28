import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/router/app_routes.dart';
import '../../../shared/design/app_colors.dart';
import '../../../shared/design/app_shadows.dart';
import '../application/diet_providers.dart';
import '../domain/diet_models.dart';

class DietPage extends ConsumerStatefulWidget {
  const DietPage({super.key});

  @override
  ConsumerState<DietPage> createState() => _DietPageState();
}

class _DietPageState extends ConsumerState<DietPage> {
  DateTime _selectedDate = DateTime.now();
  static const int _dailyGoal = 2000;

  bool _isSameDay(DateTime date) {
    return date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day;
  }

  Map<MealType, List<MealRecord>> _groupByMeal(List<MealRecord> records) {
    final map = {for (final meal in MealType.values) meal: <MealRecord>[]};
    for (final record in records) {
      if (_isSameDay(record.timestamp)) {
        map[record.mealType]?.add(record);
      }
    }
    for (final entry in map.entries) {
      entry.value.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    }
    return map;
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  Future<void> _openAddSheet({MealType? initialType}) async {
    final result = await showModalBottomSheet<_MealFormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _AddMealSheet(
          initialMealType: initialType ?? MealType.breakfast,
          selectedDate: _selectedDate,
        );
      },
    );

    if (result != null && mounted) {
      await ref
          .read(dietRecordsProvider.notifier)
          .createEntry(
            mealType: result.mealType,
            name: result.name,
            calories: result.calories,
            protein: result.protein,
            carbs: result.carbs,
            fat: result.fat,
            timestamp: result.timestamp,
            notes: result.note,
          );
    }
  }

  Future<void> _openRecordOptions() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit_note_rounded),
                title: const Text(
                  '手动录入',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _openAddSheet();
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded),
                title: const Text(
                  'AI 识别',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  Navigator.pop(context);
                  if (mounted) {
                    context.push(AppRoutes.aiFoodRecognition);
                  }
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recordsAsync = ref.watch(dietRecordsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openRecordOptions,
        backgroundColor: Colors.black,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          '记录饮食',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/dashboard_background.png'),
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 0,
              floating: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.only(left: 16),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.8),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.black87),
                    onPressed: () => context.pop(),
                  ),
                ),
              ),
              title: const Text(
                '饮食记录',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w900,
                ),
              ),
              centerTitle: true,
            ),
            SliverToBoxAdapter(
              child: recordsAsync.when(
                data: (records) {
                  final grouped = _groupByMeal(records);
                  final consumed = grouped.values
                      .expand((element) => element)
                      .fold<int>(
                        0,
                        (prev, record) => prev + record.totalCalories,
                      );

                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _CalorieSummaryCard(
                          consumed: consumed,
                          goal: _dailyGoal,
                          selectedDate: _selectedDate,
                          onSelectDate: _pickDate,
                        ),
                        const SizedBox(height: 24),
                        for (final meal in MealType.values) ...[
                          _MealSection(
                            type: meal,
                            records: grouped[meal] ?? [],
                            onAdd: () => _openAddSheet(initialType: meal),
                            onDelete: (id) =>
                                ref.read(dietRecordsProvider.notifier).remove(id),
                          ),
                          const SizedBox(height: 16),
                        ],
                        const SizedBox(height: 80),
                      ],
                    ),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => Padding(
                  padding: const EdgeInsets.all(32),
                  child: Text('加载失败：$error'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalorieSummaryCard extends StatelessWidget {
  const _CalorieSummaryCard({
    required this.consumed,
    required this.goal,
    required this.selectedDate,
    required this.onSelectDate,
  });

  final int consumed;
  final int goal;
  final DateTime selectedDate;
  final VoidCallback onSelectDate;

  @override
  Widget build(BuildContext context) {
    final progress = (consumed / goal).clamp(0.0, 1.0);
    final remaining = (goal - consumed).clamp(0, goal);
    final dateLabel = DateFormat('yyyy年MM月dd日').format(selectedDate);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.candyOrange, Color(0xFFFFAB91)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: AppShadows.orange3d,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '今日摄入',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$consumed',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 6, left: 4),
                          child: Text(
                            'kcal',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: onSelectDate,
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    icon: const Icon(Icons.calendar_today, size: 16),
                    label: Text(dateLabel),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: progress,
                          color: Colors.white,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          strokeWidth: 6,
                        ),
                        const Icon(
                          Icons.local_fire_department_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '目标 $goal kcal',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  remaining > 0 ? '还差 $remaining' : '已超出 ${remaining.abs()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MealSection extends StatelessWidget {
  const _MealSection({
    required this.type,
    required this.records,
    required this.onAdd,
    required this.onDelete,
  });

  final MealType type;
  final List<MealRecord> records;
  final VoidCallback onAdd;
  final ValueChanged<String> onDelete;

  int get _totalCalories =>
      records.fold(0, (sum, record) => sum + record.totalCalories);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppShadows.white3d,
        border: Border.all(color: Colors.white),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.candyOrange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(type.icon, color: AppColors.candyOrange, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                type.label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              const Spacer(),
              Text(
                '$_totalCalories kcal',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              IconButton(
                onPressed: onAdd,
                icon: const Icon(Icons.add_circle_outline_rounded),
              ),
            ],
          ),
          if (records.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                '还没有记录${type.label}，点击右侧添加',
                style: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else ...[
            const SizedBox(height: 16),
            for (final record in records)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _MealRecordTile(
                  record: record,
                  onDelete: () => onDelete(record.id),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _MealRecordTile extends StatelessWidget {
  const _MealRecordTile({required this.record, required this.onDelete});

  final MealRecord record;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final item = record.items.isNotEmpty
        ? record.items.first
        : const FoodItem(
            id: '',
            name: '未知食物',
            calories: 0,
            protein: 0,
            carbs: 0,
            fat: 0,
          );
    final timeLabel = DateFormat('HH:mm').format(record.timestamp);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: const Text('🥗', style: TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$timeLabel · ${item.calories} kcal · '
                  'P ${item.protein.toStringAsFixed(1)}g · '
                  'C ${item.carbs.toStringAsFixed(1)}g · '
                  'F ${item.fat.toStringAsFixed(1)}g',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black45,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (record.notes?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 4),
                  Text(
                    record.notes!,
                    style: const TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline, color: Colors.black38),
          ),
        ],
      ),
    );
  }
}

class _MealFormResult {
  _MealFormResult({
    required this.mealType,
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.timestamp,
    this.note,
  });

  final MealType mealType;
  final String name;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final DateTime timestamp;
  final String? note;
}

class _AddMealSheet extends StatefulWidget {
  const _AddMealSheet({
    required this.initialMealType,
    required this.selectedDate,
  });

  final MealType initialMealType;
  final DateTime selectedDate;

  @override
  State<_AddMealSheet> createState() => _AddMealSheetState();
}

class _AddMealSheetState extends State<_AddMealSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _calorieController = TextEditingController();
  final TextEditingController _proteinController = TextEditingController();
  final TextEditingController _carbController = TextEditingController();
  final TextEditingController _fatController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  late MealType _mealType = widget.initialMealType;
  late TimeOfDay _timeOfDay = TimeOfDay.now();

  @override
  void dispose() {
    _nameController.dispose();
    _calorieController.dispose();
    _proteinController.dispose();
    _carbController.dispose();
    _fatController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _timeOfDay,
    );
    if (time != null) {
      setState(() => _timeOfDay = time);
    }
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;

    final timestamp = DateTime(
      widget.selectedDate.year,
      widget.selectedDate.month,
      widget.selectedDate.day,
      _timeOfDay.hour,
      _timeOfDay.minute,
    );

    final result = _MealFormResult(
      mealType: _mealType,
      name: _nameController.text.trim(),
      calories: int.parse(_calorieController.text.trim()),
      protein: double.tryParse(_proteinController.text.trim()) ?? 0,
      carbs: double.tryParse(_carbController.text.trim()) ?? 0,
      fat: double.tryParse(_fatController.text.trim()) ?? 0,
      timestamp: timestamp,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );

    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text(
                        '添加饮食记录',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 48,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (_, index) {
                        final type = MealType.values[index];
                        final selected = type == _mealType;
                        return ChoiceChip(
                          selected: selected,
                          onSelected: (_) => setState(() => _mealType = type),
                          label: Text(type.label),
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: selected ? Colors.white : Colors.black54,
                          ),
                          selectedColor: AppColors.candyOrange,
                          backgroundColor: Colors.grey.shade100,
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemCount: MealType.values.length,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: '食物名称'),
                    validator: (value) =>
                        value == null || value.trim().isEmpty ? '请输入名称' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _calorieController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: '热量（kcal）'),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '请输入热量';
                      }
                      return int.tryParse(value.trim()) == null
                          ? '请输入数字'
                          : null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _proteinController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: '蛋白质 (g)',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _carbController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: '碳水 (g)',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _fatController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: '脂肪 (g)',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _pickTime,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time_filled,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '记录时间 ${_timeOfDay.format(context)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _noteController,
                    decoration: const InputDecoration(labelText: '备注（可选）'),
                    maxLines: 2,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _submit,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      child: const Text('保存'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
