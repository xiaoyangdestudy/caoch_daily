import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../application/user_profile_provider.dart';
import '../domain/user_profile.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _signatureController = TextEditingController();
  final _emailController = TextEditingController();

  String? _avatarBase64;
  File? _avatarFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 初始化表单字段
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileAsync = ref.read(userProfileProvider);
      profileAsync.whenData((profile) {
        if (profile != null) {
          _nicknameController.text = profile.nickname ?? '';
          _signatureController.text = profile.signature ?? '';
          _emailController.text = profile.email ?? '';
          setState(() {
            _avatarBase64 = profile.avatar;
          });
        }
      });
    });
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _signatureController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      final file = File(pickedFile.path);
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);

      setState(() {
        _avatarFile = file;
        _avatarBase64 = 'data:image/jpeg;base64,$base64String';
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await ref.read(userProfileProvider.notifier).updateProfile(
            nickname: _nicknameController.text.trim().isEmpty
                ? null
                : _nicknameController.text.trim(),
            avatar: _avatarBase64,
            signature: _signatureController.text.trim().isEmpty
                ? null
                : _signatureController.text.trim(),
            email: _emailController.text.trim().isEmpty
                ? null
                : _emailController.text.trim(),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('资料更新成功')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('更新失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('编辑个人资料'),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveProfile,
              child: const Text('保存'),
            ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) => _buildForm(profile),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('加载失败: $error')),
      ),
    );
  }

  Widget _buildForm(UserProfile? profile) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 头像
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                    backgroundImage: _avatarFile != null
                        ? FileImage(_avatarFile!)
                        : _avatarBase64 != null
                            ? MemoryImage(
                                base64Decode(_avatarBase64!.split(',').last),
                              )
                            : null,
                    child: _avatarFile == null && _avatarBase64 == null
                        ? Icon(
                            Icons.person,
                            size: 60,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      child: Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // 用户名（只读）
          TextFormField(
            initialValue: profile?.username ?? '',
            decoration: const InputDecoration(
              labelText: '用户名',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.account_circle),
            ),
            enabled: false,
          ),
          const SizedBox(height: 16),

          // 昵称
          TextFormField(
            controller: _nicknameController,
            decoration: const InputDecoration(
              labelText: '昵称',
              hintText: '输入你的昵称',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.badge),
            ),
            maxLength: 30,
          ),
          const SizedBox(height: 16),

          // 个性签名
          TextFormField(
            controller: _signatureController,
            decoration: const InputDecoration(
              labelText: '个性签名',
              hintText: '写一句话介绍自己',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.format_quote),
            ),
            maxLength: 100,
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          // 邮箱
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: '邮箱',
              hintText: '输入你的邮箱地址',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.email),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value != null &&
                  value.isNotEmpty &&
                  !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return '请输入有效的邮箱地址';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),

          // 提示信息
          Card(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '个人资料将同步到云端，方便在多设备间切换',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
