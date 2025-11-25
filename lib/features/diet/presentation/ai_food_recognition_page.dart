import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../shared/design/app_colors.dart';
import '../../../shared/design/app_shadows.dart';
import '../application/diet_providers.dart';
import '../domain/diet_models.dart';

class AiFoodRecognitionPage extends ConsumerStatefulWidget {
  const AiFoodRecognitionPage({super.key});

  @override
  ConsumerState<AiFoodRecognitionPage> createState() =>
      _AiFoodRecognitionPageState();
}

class _AiFoodRecognitionPageState extends ConsumerState<AiFoodRecognitionPage> {
  CameraController? _controller;
  bool _isAnalyzing = false;
  bool _hasResult = false;
  bool _isCameraInitialized = false;
  bool _isSaving = false;
  MealType _selectedMealType = MealType.breakfast;
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Camera initialization failed: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePictureAndAnalyze() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    try {
      setState(() {
        _isAnalyzing = true;
      });

      await Future.delayed(const Duration(milliseconds: 500));
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _hasResult = true;
        });
      }
    } catch (e) {
      debugPrint('Error taking picture: $e');
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _saveResult() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);
    final notifier = ref.read(dietRecordsProvider.notifier);
    final item = FoodItem(
      id: _uuid.v4(),
      name: '牛油果吐司',
      calories: 320,
      protein: 12,
      carbs: 45,
      fat: 18,
    );
    final record = MealRecord(
      id: _uuid.v4(),
      mealType: _selectedMealType,
      timestamp: DateTime.now(),
      items: [item],
      notes: 'AI 摄入识别',
    );

    await notifier.addMeal(record);

    if (mounted) {
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('已添加到饮食日记')));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: _isCameraInitialized
                ? CameraPreview(_controller!)
                : Container(
                    color: Colors.grey.shade900,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white24),
                    ),
                  ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                  const Text(
                    'AI 识别',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
          ),
          if (_isAnalyzing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.candyOrange),
                    SizedBox(height: 16),
                    Text(
                      '正在分析食物...',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (_hasResult)
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: AppShadows.cardSoft,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.candyOrange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: AppColors.candyOrange,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '识别成功',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '牛油果吐司',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _NutrientItem(label: '热量', value: '320', unit: 'kcal'),
                        _NutrientItem(label: '蛋白质', value: '12', unit: 'g'),
                        _NutrientItem(label: '碳水', value: '45', unit: 'g'),
                        _NutrientItem(label: '脂肪', value: '18', unit: 'g'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      children: MealType.values.map((type) {
                        final selected = type == _selectedMealType;
                        return ChoiceChip(
                          label: Text(type.label),
                          selected: selected,
                          onSelected: (_) => setState(() {
                            _selectedMealType = type;
                          }),
                          selectedColor: AppColors.candyOrange,
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveResult,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                '添加到日记',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (!_isAnalyzing && !_hasResult)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 48),
                child: GestureDetector(
                  onTap: _takePictureAndAnalyze,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NutrientItem extends StatelessWidget {
  const _NutrientItem({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Colors.black87,
          ),
        ),
        Text(
          unit,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.black38,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }
}
