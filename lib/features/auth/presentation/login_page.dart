import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router/app_routes.dart';
import '../../../shared/providers/api_provider.dart';
import '../../../shared/providers/preferences_provider.dart';
import '../../../features/review/application/review_providers.dart';
import 'widgets/auth_widgets.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _rememberPassword = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  void _loadSavedCredentials() {
    final prefsService = ref.read(preferencesServiceProvider);
    final shouldRemember = prefsService.shouldRememberPassword;
    final savedUsername = prefsService.savedUsername;
    final savedPassword = prefsService.savedPassword;

    if (shouldRemember && savedUsername != null && savedPassword != null) {
      setState(() {
        _rememberPassword = true;
        _usernameController.text = savedUsername;
        _passwordController.text = savedPassword;
      });
    }
  }

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

      // 登录
      await api.login(username, password);

      if (!mounted) return;

      // 保存账号密码（如果勾选了记住密码）
      final prefsService = ref.read(preferencesServiceProvider);
      await prefsService.saveCredentials(
        username: username,
        password: password,
        remember: _rememberPassword,
      );

      // 刷新认证状态
      ref.invalidate(authStateProvider);
      ref.invalidate(currentUsernameProvider);

      // 登录成功后，从服务器同步数据
      try {
        final reviewRepo = ref.read(reviewRepositoryProvider);
        await reviewRepo.syncFromServer();
        print('✓ 已从服务器同步数据');

        // 刷新所有数据Provider，强制重新加载
        ref.invalidate(reviewRepositoryProvider);
        ref.invalidate(reviewEntriesProvider);

      } catch (e) {
        print('⚠️ 同步数据失败: $e');
        // 同步失败不影响登录流程，但仍然刷新Provider
        ref.invalidate(reviewRepositoryProvider);
        ref.invalidate(reviewEntriesProvider);
      }

      if (mounted) {
        // 登录成功，跳转到首页
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

  void _goToRegister() {
    context.push(AppRoutes.register);
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
                    const SizedBox(height: 20),

                    // Logo & Slogan
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
                        '即刻开练，释放你的多巴胺！',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: Colors.white, // Required for ShaderMask
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Login Card
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
                                  hint: '邮箱 / 手机号',
                                  icon: Icons.person_outline_rounded,
                                  enabled: !_isLoading,
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return '请输入用户名';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 20),

                                // Password Field
                                AuthTextField(
                                  controller: _passwordController,
                                  label: '密码',
                                  hint: '请输入密码',
                                  icon: Icons.lock_outline_rounded,
                                  isPassword: true,
                                  enabled: !_isLoading,
                                  textInputAction: TextInputAction.done,
                                  onSubmitted: _submit,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '请输入密码';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 12),

                                // Remember Password & Forgot Password
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Remember Password
                                    Row(
                                      children: [
                                        SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: Checkbox(
                                            value: _rememberPassword,
                                            onChanged: _isLoading
                                                ? null
                                                : (value) {
                                                    setState(() {
                                                      _rememberPassword = value ?? false;
                                                    });
                                                  },
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            side: BorderSide(
                                              color: AuthColors.textGray,
                                              width: 1.5,
                                            ),
                                            activeColor: AuthColors.neonGreen,
                                            checkColor: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        GestureDetector(
                                          onTap: _isLoading
                                              ? null
                                              : () {
                                                  setState(() {
                                                    _rememberPassword = !_rememberPassword;
                                                  });
                                                },
                                          child: const Text(
                                            '记住密码',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: AuthColors.textGray,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Forgot Password
                                    TextButton(
                                      onPressed: () {
                                        // TODO: Implement forgot password
                                      },
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                        minimumSize: Size.zero,
                                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      ),
                                      child: const Text(
                                        '忘记密码？',
                                        style: TextStyle(
                                          color: AuthColors.brightOrange,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                  ],
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

                                const SizedBox(height: 30),

                                // Login Button
                                AuthButton(
                                  onPressed: _submit,
                                  isLoading: _isLoading,
                                  text: '登 录',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Social Login & Register
                    Column(
                      children: [
                        // Social Icons (Mock)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _SocialIcon(
                              icon: Icons.wechat, // Using material icons as placeholder
                              onTap: () {},
                            ),
                            const SizedBox(width: 20),
                            _SocialIcon(
                              icon: Icons.alternate_email, // Using material icons as placeholder
                              onTap: () {},
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              '还没有账户？',
                              style: TextStyle(
                                color: AuthColors.textGray,
                                fontSize: 14,
                              ),
                            ),
                            TextButton(
                              onPressed: _isLoading ? null : _goToRegister,
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                              ),
                              child: const Text(
                                '立即注册',
                                style: TextStyle(
                                  color: AuthColors.neonGreen,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
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

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SocialIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.1),
          border: Border.all(color: Colors.transparent),
        ),
        child: Icon(
          icon,
          color: AuthColors.textGray,
          size: 20,
        ),
      ),
    );
  }
}
