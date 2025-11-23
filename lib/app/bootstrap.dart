import 'dart:async';

import 'package:flutter/widgets.dart';

/// 应用启动入口，负责公共初始化（如依赖注入、绑定等）
Future<void> bootstrap(FutureOr<Widget> Function() builder) async {
  WidgetsFlutterBinding.ensureInitialized();

  final app = await builder();
  runApp(app);
}
