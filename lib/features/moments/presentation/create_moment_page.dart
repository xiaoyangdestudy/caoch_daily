import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../shared/design/app_colors.dart';
import '../application/moments_provider.dart';
import '../domain/moment_model.dart';

class CreateMomentPage extends ConsumerStatefulWidget {
  const CreateMomentPage({super.key});

  @override
  ConsumerState<CreateMomentPage> createState() => _CreateMomentPageState();
}

class _CreateMomentPageState extends ConsumerState<CreateMomentPage> {
  final _contentController = TextEditingController();
  final _locationController = TextEditingController();
  final _tagController = TextEditingController();
  final _imagePicker = ImagePicker();

  final List<String> _imagePaths = [];
  final List<String> _tags = [];

  bool _isSubmitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    _locationController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  /// 选择图片（从相册）
  Future<void> _pickImages() async {
    if (_imagePaths.length >= 9) {
      _showError('最多只能添加9张图片');
      return;
    }

    try {
      final images = await _imagePicker.pickMultiImage(
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (images.isNotEmpty) {
        final remaining = 9 - _imagePaths.length;
        final toAdd = images.take(remaining);

        setState(() {
          _imagePaths.addAll(toAdd.map((img) => img.path));
        });

        if (images.length > remaining) {
          _showError('已选择最多9张图片，超出部分已忽略');
        }
      }
    } catch (e) {
      _showError('选择图片失败，请重试');
    }
  }

  /// 拍照
  Future<void> _takePicture() async {
    if (_imagePaths.length >= 9) {
      _showError('最多只能添加9张图片');
      return;
    }

    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _imagePaths.add(image.path);
        });
      }
    } catch (e) {
      _showError('拍照失败，请重试');
    }
  }

  /// 显示图片选择方式对话框
  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.candyBlue),
              title: const Text('从相册选择'),
              onTap: () {
                Navigator.pop(context);
                _pickImages();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.candyPink),
              title: const Text('拍照'),
              onTap: () {
                Navigator.pop(context);
                _takePicture();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _removeImage(int index) {
    setState(() {
      _imagePaths.removeAt(index);
    });
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isNotEmpty) {
      if (!_tags.contains(tag)) {
        setState(() {
          _tags.add(tag);
          _tagController.clear();
        });
      } else {
        _tagController.clear();
      }
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  Future<void> _submit() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      _showError('请输入动态内容');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final input = CreateMomentInput(
        content: content,
        imagePaths: _imagePaths,
        tags: _tags,
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
      );

      await ref.read(momentsProvider.notifier).createMoment(input);

      if (mounted) {
        context.pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('动态发布成功')),
        );
      }
    } catch (e) {
      _showError('发布失败: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '发布动态',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.candyBlue,
                disabledBackgroundColor: Colors.grey.shade300,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('发布'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 内容输入
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _contentController,
                maxLines: 5,
                maxLength: 500,
                decoration: const InputDecoration(
                  hintText: '分享此刻的想法...',
                  hintStyle: TextStyle(color: Colors.black38),
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 图片选择和预览
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '图片',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${_imagePaths.length}/9',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemCount: _imagePaths.length < 9
                        ? _imagePaths.length + 1
                        : _imagePaths.length,
                    itemBuilder: (context, index) {
                      // 添加图片按钮
                      if (index == _imagePaths.length && _imagePaths.length < 9) {
                        return GestureDetector(
                          onTap: _showImageSourceDialog,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  color: Colors.grey.shade400,
                                  size: 32,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '添加图片',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // 图片预览
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(_imagePaths[index]),
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => _removeImage(index),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.black54,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 标签
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('标签', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _tagController,
                          decoration: const InputDecoration(
                            hintText: '输入标签',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 8),
                          ),
                          onSubmitted: (_) => _addTag(),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_circle, color: AppColors.candyBlue),
                        onPressed: _addTag,
                      ),
                    ],
                  ),
                  if (_tags.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _tags.map((tag) {
                        return Chip(
                          label: Text('#$tag', style: const TextStyle(fontSize: 12)),
                          onDeleted: () => _removeTag(tag),
                          deleteIcon: const Icon(Icons.close, size: 16),
                          backgroundColor: AppColors.candyBlue.withAlpha(26),
                          labelStyle: const TextStyle(color: AppColors.candyBlue),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 位置
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 20,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.location_on_outlined,
                    color: Colors.black54,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        hintText: '添加位置（可选）',
                        hintStyle: TextStyle(color: Colors.black38),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '提示：记录生活的每个精彩瞬间',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
