import 'package:freezed_annotation/freezed_annotation.dart';

part 'moment_model.freezed.dart';
part 'moment_model.g.dart';

/// 个人动态模型
@freezed
class Moment with _$Moment {
  const factory Moment({
    required String id,
    required String content,
    required DateTime createdAt,
    @Default([]) List<String> imageUrls,
    @Default(0) int likes,
    String? location,
    List<String>? tags,
  }) = _Moment;

  factory Moment.fromJson(Map<String, dynamic> json) =>
      _$MomentFromJson(json);
}

/// 创建动态的输入数据
class CreateMomentInput {
  final String content;
  final List<String> imageUrls;
  final String? location;
  final List<String>? tags;

  const CreateMomentInput({
    required this.content,
    this.imageUrls = const [],
    this.location,
    this.tags,
  });
}
