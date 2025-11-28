// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MomentImpl _$$MomentImplFromJson(Map<String, dynamic> json) => _$MomentImpl(
  id: json['id'] as String,
  userId: json['userId'] as String,
  username: json['username'] as String,
  userAvatar: json['userAvatar'] as String?,
  content: json['content'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  imageUrls:
      (json['imageUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  likes: (json['likes'] as num?)?.toInt() ?? 0,
  commentsCount: (json['commentsCount'] as num?)?.toInt() ?? 0,
  isLiked: json['isLiked'] as bool? ?? false,
  location: json['location'] as String?,
  tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
);

Map<String, dynamic> _$$MomentImplToJson(_$MomentImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'username': instance.username,
      'userAvatar': instance.userAvatar,
      'content': instance.content,
      'createdAt': instance.createdAt.toIso8601String(),
      'imageUrls': instance.imageUrls,
      'likes': instance.likes,
      'commentsCount': instance.commentsCount,
      'isLiked': instance.isLiked,
      'location': instance.location,
      'tags': instance.tags,
    };
