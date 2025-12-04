import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';
import 'theme/mesh_background.dart';

class LifeCoachApp extends ConsumerWidget {
  const LifeCoachApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(goRouterProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: '日常教练',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.light, // Default to light mode
      routerConfig: router,
      builder: (context, child) =>
          MeshBackground(child: child ?? const SizedBox.shrink()),
    );
  }
}
