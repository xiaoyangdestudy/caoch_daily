import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_routes.dart';
import '../../../shared/providers/api_provider.dart';
import '../../../features/profile/application/user_profile_provider.dart';
import '../../../features/review/application/review_providers.dart';
import 'widgets/auth_widgets.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final api = ref.read(apiClientProvider);
      final username = _usernameController.text.trim();
      final password = _passwordController.text;

      // 注册（注册成功后会自动登录）
      await api.register(username, password);

      if (!mounted) return;

      // 刷新认证状态
      ref.invalidate(authStateProvider);
      ref.invalidate(currentUsernameProvider);
      ref.invalidate(userProfileProvider);

      // 注册成功后，从服务器同步数据（对于新用户，这会确保本地数据被清空）
      try {
        final reviewRepo = ref.read(reviewRepositoryProvider);
        await reviewRepo.syncFromServer();
        print('✓ 已从服务器同步数据');

        // 刷新所有数据Provider，强制重新加载
        ref.invalidate(reviewRepositoryProvider);
        ref.invalidate(reviewEntriesProvider);

      } catch (e) {
        print('⚠️ 同步数据失败: $e');
        // 同步失败不影响注册流程，但仍然刷新Provider
        ref.invalidate(reviewRepositoryProvider);
        ref.invalidate(reviewEntriesProvider);
      }

      if (mounted) {
        // 注册成功，跳转到首页
        context.go(AppRoutes.home);
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _goToLogin() {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          const AuthBackground(),

          // Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Back Button (Custom for this dark theme)
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AuthColors.textWhite),
                        onPressed: _goToLogin,
                      ),
                    ),
                    
                    const SizedBox(height: 10),

                    // Logo & Title
                    const AuthLogo(),
                    const SizedBox(height: 20),
                    ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        colors: [
                          AuthColors.neonGreen,
                          AuthColors.electricBlue,
                        ],
                      ).createShader(bounds),
                      child: const Text(
                        '加入我们，开启健康新生活',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Register Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                        child: Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: AuthColors.cardBg,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AuthColors.neonGreen.withValues(alpha: 0.2),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Username Field
                                AuthTextField(
                                  controller: _usernameController,
                                  label: '用户名',
                                  hint: '请输入用户名',
                                  icon: Icons.person_outline_rounded,
                                  enabled: !_isLoading,
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return '请输入用户名';
                                    }
                                    if (value.trim().length < 3) {
                                      return '用户名至少需要3个字符';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 20),

                                // Password Field
                                AuthTextField(
                                  controller: _passwordController,
                                  label: '密码',
                                  hint: '请输入密码（至少6位）',
                                  icon: Icons.lock_outline_rounded,
                                  isPassword: true,
                                  enabled: !_isLoading,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: _submit,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '请输入密码';
                                    }
                                    if (value.length < 6) {
                                      return '密码至少需要6个字符';
                                    }
                                    return null;
                                  },
                                ),

                                // Error Message
                                AnimatedSize(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: _errorMessage != null
                                      ? Padding(
                                          padding: const EdgeInsets.only(top: 16),
                                          child: Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: Colors.red.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  Icons.error_outline_rounded,
                                                  color: Colors.red[400],
                                                  size: 18,
                                                ),
                                                const SizedBox(width: 10),
                                                Expanded(
                                                  child: Text(
                                                    _errorMessage!,
                                                    style: TextStyle(
                                                      color: Colors.red[300],
                                                      fontSize: 13,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ),

                                const SizedBox(height: 24),

                                // Info Box
                                Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AuthColors.neonGreen.withValues(alpha: 0.05),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AuthColors.neonGreen.withValues(alpha: 0.1)),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.cloud_outlined,
                                        color: AuthColors.neonGreen,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 10),
                                      const Expanded(
                                        child: Text(
                                          '数据将安全地同步到云端',
                                          style: TextStyle(
                                            color: AuthColors.textGray,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Register Button
                                AuthButton(
                                  onPressed: _submit,
                                  isLoading: _isLoading,
                                  text: '注 册',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '已有账号？',
                          style: TextStyle(
                            color: AuthColors.textGray,
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: _isLoading ? null : _goToLogin,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                          child: const Text(
                            '立即登录',
                            style: TextStyle(
                              color: AuthColors.neonGreen,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
