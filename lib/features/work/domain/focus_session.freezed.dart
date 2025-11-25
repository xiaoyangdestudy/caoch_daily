// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'focus_session.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

FocusSession _$FocusSessionFromJson(Map<String, dynamic> json) {
  return _FocusSession.fromJson(json);
}

/// @nodoc
mixin _$FocusSession {
  String get id => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  DateTime get endTime => throw _privateConstructorUsedError;
  int get targetMinutes => throw _privateConstructorUsedError;
  String? get taskName => throw _privateConstructorUsedError;
  bool get completed => throw _privateConstructorUsedError;

  /// Serializes this FocusSession to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of FocusSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $FocusSessionCopyWith<FocusSession> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FocusSessionCopyWith<$Res> {
  factory $FocusSessionCopyWith(
    FocusSession value,
    $Res Function(FocusSession) then,
  ) = _$FocusSessionCopyWithImpl<$Res, FocusSession>;
  @useResult
  $Res call({
    String id,
    DateTime startTime,
    DateTime endTime,
    int targetMinutes,
    String? taskName,
    bool completed,
  });
}

/// @nodoc
class _$FocusSessionCopyWithImpl<$Res, $Val extends FocusSession>
    implements $FocusSessionCopyWith<$Res> {
  _$FocusSessionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of FocusSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? targetMinutes = null,
    Object? taskName = freezed,
    Object? completed = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            endTime: null == endTime
                ? _value.endTime
                : endTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            targetMinutes: null == targetMinutes
                ? _value.targetMinutes
                : targetMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            taskName: freezed == taskName
                ? _value.taskName
                : taskName // ignore: cast_nullable_to_non_nullable
                      as String?,
            completed: null == completed
                ? _value.completed
                : completed // ignore: cast_nullable_to_non_nullable
                      as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$FocusSessionImplCopyWith<$Res>
    implements $FocusSessionCopyWith<$Res> {
  factory _$$FocusSessionImplCopyWith(
    _$FocusSessionImpl value,
    $Res Function(_$FocusSessionImpl) then,
  ) = __$$FocusSessionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    DateTime startTime,
    DateTime endTime,
    int targetMinutes,
    String? taskName,
    bool completed,
  });
}

/// @nodoc
class __$$FocusSessionImplCopyWithImpl<$Res>
    extends _$FocusSessionCopyWithImpl<$Res, _$FocusSessionImpl>
    implements _$$FocusSessionImplCopyWith<$Res> {
  __$$FocusSessionImplCopyWithImpl(
    _$FocusSessionImpl _value,
    $Res Function(_$FocusSessionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of FocusSession
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? startTime = null,
    Object? endTime = null,
    Object? targetMinutes = null,
    Object? taskName = freezed,
    Object? completed = null,
  }) {
    return _then(
      _$FocusSessionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        endTime: null == endTime
            ? _value.endTime
            : endTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        targetMinutes: null == targetMinutes
            ? _value.targetMinutes
            : targetMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        taskName: freezed == taskName
            ? _value.taskName
            : taskName // ignore: cast_nullable_to_non_nullable
                  as String?,
        completed: null == completed
            ? _value.completed
            : completed // ignore: cast_nullable_to_non_nullable
                  as bool,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$FocusSessionImpl extends _FocusSession {
  const _$FocusSessionImpl({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.targetMinutes,
    this.taskName,
    this.completed = false,
  }) : super._();

  factory _$FocusSessionImpl.fromJson(Map<String, dynamic> json) =>
      _$$FocusSessionImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime startTime;
  @override
  final DateTime endTime;
  @override
  final int targetMinutes;
  @override
  final String? taskName;
  @override
  @JsonKey()
  final bool completed;

  @override
  String toString() {
    return 'FocusSession(id: $id, startTime: $startTime, endTime: $endTime, targetMinutes: $targetMinutes, taskName: $taskName, completed: $completed)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FocusSessionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.endTime, endTime) || other.endTime == endTime) &&
            (identical(other.targetMinutes, targetMinutes) ||
                other.targetMinutes == targetMinutes) &&
            (identical(other.taskName, taskName) ||
                other.taskName == taskName) &&
            (identical(other.completed, completed) ||
                other.completed == completed));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    startTime,
    endTime,
    targetMinutes,
    taskName,
    completed,
  );

  /// Create a copy of FocusSession
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$FocusSessionImplCopyWith<_$FocusSessionImpl> get copyWith =>
      __$$FocusSessionImplCopyWithImpl<_$FocusSessionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FocusSessionImplToJson(this);
  }
}

abstract class _FocusSession extends FocusSession {
  const factory _FocusSession({
    required final String id,
    required final DateTime startTime,
    required final DateTime endTime,
    required final int targetMinutes,
    final String? taskName,
    final bool completed,
  }) = _$FocusSessionImpl;
  const _FocusSession._() : super._();

  factory _FocusSession.fromJson(Map<String, dynamic> json) =
      _$FocusSessionImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get startTime;
  @override
  DateTime get endTime;
  @override
  int get targetMinutes;
  @override
  String? get taskName;
  @override
  bool get completed;

  /// Create a copy of FocusSession
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$FocusSessionImplCopyWith<_$FocusSessionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
