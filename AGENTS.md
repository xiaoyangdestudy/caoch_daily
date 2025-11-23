# Repository Guidelines

## 项目结构与模块组织
核心 Flutter 业务代码位于 `lib/`，建议按 `feature/`、`widgets/`、`services/` 子目录拆分以保持关注点分离，公共主题与常量放入 `lib/shared/`。测试镜像 `lib` 的目录放在 `test/`，便于一对一验证。静态资源集中在 `assets/` 与 `资源/`，新增后必须同步 `pubspec.yaml` 的 `assets:` 段并执行 `flutter pub get`。原生平台代码分别在 `android/`、`ios/`、`macos/`、`linux/`、`windows/`，Web 构建在 `web/`，修改这些目录时需确保与 `lib` 层 API 契约一致。产品、设计与架构参考 `需求文档.md`、`页面设计.md`、`软件架构.md`，提交前确认实现与文档一致。

## 构建与开发命令
- `flutter pub get`：安装或刷新 `pubspec.yaml` 中的依赖与资源声明。
- `flutter run -d chrome` / `flutter run -d linux`：在指定设备快速调试，保持热重载开启。
- `flutter build apk --release` 与 `flutter build web`：生成发布包，提交前至少验证一次 release 构建。
- `dart format lib test`：在提交前统一格式；CI 也会执行同样命令。

## 编码风格与命名约定
仓库启用了 `analysis_options.yaml` 中的 `package:flutter_lints/flutter.yaml`，所有 Dart 代码需遵循 2 空格缩进、UpperCamelCase 类名、lowerCamelCase 方法与变量、SCREAMING_SNAKE_CASE 常量。业务目录命名使用中英文结合但保持简洁，例如 `feature_daily/`、`user_profile/`。独立 widget 请包含用途后缀（如 `SummaryCard`），服务类以 `Service` 结尾。注释采用简洁中文描述背景或约束，不要解释显而易见的代码。

## 测试规范
默认使用 `flutter test` 运行单元与 widget 测试；新增功能必须至少包含一个正向和一个异常场景。覆盖率通过 `flutter test --coverage` 查看，核心模块（状态管理、服务调用）应保持 ≥80%。测试文件命名遵循 `<feature>_<type>_test.dart`，组装 `group('描述')` 与 `test('行为')`，必要时使用 `setUp` 复用初始化逻辑。

## 提交与合并请求
现有历史展示了短句式中文 commit，例如“基本的框架”“我的页面完善成功”；继续采用祈使语、说明单一变化点，必要时在正文列出详细说明或关联问题编号。Pull Request 需包含：变更概述、测试方式与结果、关联 Issue/需求文档段落、UI 变更截图或录屏（若有）。保持分支命名 `feature/<模块>`、`fix/<问题>`，在获得至少一名审核者的同意并通过 CI 后方可合并。

## 安全与配置
敏感配置（如 API Key）需通过各平台原生安全存储或本地 `--dart-define` 注入，禁止写入仓库。调试日志默认使用 `debugPrint` 并在生产构建关闭 verbose 日志；不要将真实用户数据写入版本控制的示例文件。遇到需要新增第三方插件时，先讨论对包体积和权限的影响并记录在 PR 中。
