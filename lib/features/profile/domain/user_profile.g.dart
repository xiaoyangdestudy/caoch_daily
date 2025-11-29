// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UpdateProfileRequestImpl _$$UpdateProfileRequestImplFromJson(
  Map<String, dynamic> json,
) => _$UpdateProfileRequestImpl(
  nickname: json['nickname'] as String?,
  avatar: json['avatar'] as String?,
  signature: json['signature'] as String?,
  email: json['email'] as String?,
);

Map<String, dynamic> _$$UpdateProfileRequestImplToJson(
  _$UpdateProfileRequestImpl instance,
) => <String, dynamic>{
  'nickname': instance.nickname,
  'avatar': instance.avatar,
  'signature': instance.signature,
  'email': instance.email,
};
