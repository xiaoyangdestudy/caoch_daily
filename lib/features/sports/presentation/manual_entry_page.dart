import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../shared/design/app_colors.dart';
import '../../../shared/design/app_shadows.dart';
import '../application/sports_providers.dart';
import '../domain/workout_record.dart';

class ManualEntryPage extends ConsumerStatefulWidget {
  const ManualEntryPage({super.key});

  @override
  ConsumerState<ManualEntryPage> createState() => _ManualEntryPageState();
}

class _ManualEntryPageState extends ConsumerState<ManualEntryPage> {
  final _formKey = GlobalKey<FormState>();

  WorkoutType _selectedType = WorkoutType.run;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  final _distanceController = TextEditingController();
  final _durationController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _distanceController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveRecord() async {
    if (_formKey.currentState!.validate()) {
      final startTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final record = WorkoutRecord(
        id: const Uuid().v4(),
        type: _selectedType,
        startTime: startTime,
        durationMinutes: int.parse(_durationController.text),
        distanceKm: double.parse(_distanceController.text),
        caloriesKcal: int.parse(_caloriesController.text),
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      await ref.read(workoutListProvider.notifier).addRecord(record);
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        title: const Text(
          '记录运动',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w900),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: CircleAvatar(
            backgroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.black87),
              onPressed: () => context.pop(),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildSectionTitle('运动类型'),
            const SizedBox(height: 16),
            _buildTypeSelector(),
            const SizedBox(height: 32),
            _buildSectionTitle('时间与日期'),
            const SizedBox(height: 16),
            _buildDateTimePicker(context),
            const SizedBox(height: 32),
            _buildSectionTitle('运动数据'),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildModernInput(
                    controller: _distanceController,
                    label: '距离',
                    suffix: 'km',
                    icon: Icons.map_outlined,
                    color: AppColors.candyBlue,
                    shadows: AppShadows.blue3d,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? '请输入距离' : null,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildModernInput(
                    controller: _durationController,
                    label: '时长',
                    suffix: 'min',
                    icon: Icons.timer_outlined,
                    color: AppColors.candyPurple,
                    shadows: AppShadows.purple3d,
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? '请输入时长' : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildModernInput(
              controller: _caloriesController,
              label: '消耗卡路里',
              suffix: 'kcal',
              icon: Icons.local_fire_department_outlined,
              color: AppColors.candyOrange,
              shadows: AppShadows.orange3d,
              keyboardType: TextInputType.number,
              validator: (v) => v == null || v.trim().isEmpty ? '请输入消耗' : null,
            ),
            const SizedBox(height: 32),
            _buildSectionTitle('备注 (可选)'),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppShadows.white3d,
              ),
              child: TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  hintText: '写点什么...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(20),
                ),
                maxLines: 3,
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0xFF0F172A),
                      offset: Offset(0, 8),
                      blurRadius: 0,
                    ),
                    BoxShadow(
                      color: Color(0x33000000),
                      offset: Offset(0, 18),
                      blurRadius: 30,
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(28),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(28),
                    onTap: _saveRecord,
                    child: const SizedBox(
                      height: 56,
                      child: Center(
                        child: Text(
                          '保存记录',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w800,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTypeSelector() {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: WorkoutType.values.length,
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final type = WorkoutType.values[index];
          final isSelected = _selectedType == type;
          return GestureDetector(
            onTap: () => setState(() => _selectedType = type),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 80,
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : AppShadows.white3d,
                border: isSelected
                    ? null
                    : Border.all(color: Colors.transparent),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    type.iconPath,
                    width: 32,
                    height: 32,
                    color: isSelected ? Colors.white : Colors.black87,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.fitness_center,
                      color: isSelected ? Colors.white : Colors.black87,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    type.label,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateTimePicker(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (date != null) setState(() => _selectedDate = date);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppShadows.white3d,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 20,
                    color: AppColors.candyBlue,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${_selectedDate.month}月${_selectedDate.day}日',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: _selectedTime,
              );
              if (time != null) setState(() => _selectedTime = time);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: AppShadows.white3d,
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time_rounded,
                    size: 20,
                    color: AppColors.candyPurple,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _selectedTime.format(context),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernInput({
    required TextEditingController controller,
    required String label,
    required String suffix,
    required IconData icon,
    required Color color,
    required List<BoxShadow> shadows,
    TextInputType keyboardType = const TextInputType.numberWithOptions(
      decimal: true,
    ),
    String? Function(String?)? validator,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: shadows,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  validator: validator,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: '0',
                  ),
                ),
              ),
              Text(
                suffix,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
