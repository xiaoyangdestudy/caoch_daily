// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sleep_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

SleepRecord _$SleepRecordFromJson(Map<String, dynamic> json) {
  return _SleepRecord.fromJson(json);
}

/// @nodoc
mixin _$SleepRecord {
  String get id => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  DateTime get bedtime => throw _privateConstructorUsedError;
  DateTime get wakeTime => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  int? get sleepQuality => throw _privateConstructorUsedError;

  /// Serializes this SleepRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of SleepRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SleepRecordCopyWith<SleepRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SleepRecordCopyWith<$Res> {
  factory $SleepRecordCopyWith(
    SleepRecord value,
    $Res Function(SleepRecord) then,
  ) = _$SleepRecordCopyWithImpl<$Res, SleepRecord>;
  @useResult
  $Res call({
    String id,
    DateTime date,
    DateTime bedtime,
    DateTime wakeTime,
    String? note,
    int? sleepQuality,
  });
}

/// @nodoc
class _$SleepRecordCopyWithImpl<$Res, $Val extends SleepRecord>
    implements $SleepRecordCopyWith<$Res> {
  _$SleepRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SleepRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? bedtime = null,
    Object? wakeTime = null,
    Object? note = freezed,
    Object? sleepQuality = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            date: null == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            bedtime: null == bedtime
                ? _value.bedtime
                : bedtime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            wakeTime: null == wakeTime
                ? _value.wakeTime
                : wakeTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
            sleepQuality: freezed == sleepQuality
                ? _value.sleepQuality
                : sleepQuality // ignore: cast_nullable_to_non_nullable
                      as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SleepRecordImplCopyWith<$Res>
    implements $SleepRecordCopyWith<$Res> {
  factory _$$SleepRecordImplCopyWith(
    _$SleepRecordImpl value,
    $Res Function(_$SleepRecordImpl) then,
  ) = __$$SleepRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    DateTime date,
    DateTime bedtime,
    DateTime wakeTime,
    String? note,
    int? sleepQuality,
  });
}

/// @nodoc
class __$$SleepRecordImplCopyWithImpl<$Res>
    extends _$SleepRecordCopyWithImpl<$Res, _$SleepRecordImpl>
    implements _$$SleepRecordImplCopyWith<$Res> {
  __$$SleepRecordImplCopyWithImpl(
    _$SleepRecordImpl _value,
    $Res Function(_$SleepRecordImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of SleepRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? bedtime = null,
    Object? wakeTime = null,
    Object? note = freezed,
    Object? sleepQuality = freezed,
  }) {
    return _then(
      _$SleepRecordImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        bedtime: null == bedtime
            ? _value.bedtime
            : bedtime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        wakeTime: null == wakeTime
            ? _value.wakeTime
            : wakeTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
        sleepQuality: freezed == sleepQuality
            ? _value.sleepQuality
            : sleepQuality // ignore: cast_nullable_to_non_nullable
                  as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SleepRecordImpl extends _SleepRecord {
  const _$SleepRecordImpl({
    required this.id,
    required this.date,
    required this.bedtime,
    required this.wakeTime,
    this.note,
    this.sleepQuality,
  }) : super._();

  factory _$SleepRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$SleepRecordImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime date;
  @override
  final DateTime bedtime;
  @override
  final DateTime wakeTime;
  @override
  final String? note;
  @override
  final int? sleepQuality;

  @override
  String toString() {
    return 'SleepRecord(id: $id, date: $date, bedtime: $bedtime, wakeTime: $wakeTime, note: $note, sleepQuality: $sleepQuality)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SleepRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.bedtime, bedtime) || other.bedtime == bedtime) &&
            (identical(other.wakeTime, wakeTime) ||
                other.wakeTime == wakeTime) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.sleepQuality, sleepQuality) ||
                other.sleepQuality == sleepQuality));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, date, bedtime, wakeTime, note, sleepQuality);

  /// Create a copy of SleepRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SleepRecordImplCopyWith<_$SleepRecordImpl> get copyWith =>
      __$$SleepRecordImplCopyWithImpl<_$SleepRecordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SleepRecordImplToJson(this);
  }
}

abstract class _SleepRecord extends SleepRecord {
  const factory _SleepRecord({
    required final String id,
    required final DateTime date,
    required final DateTime bedtime,
    required final DateTime wakeTime,
    final String? note,
    final int? sleepQuality,
  }) = _$SleepRecordImpl;
  const _SleepRecord._() : super._();

  factory _SleepRecord.fromJson(Map<String, dynamic> json) =
      _$SleepRecordImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get date;
  @override
  DateTime get bedtime;
  @override
  DateTime get wakeTime;
  @override
  String? get note;
  @override
  int? get sleepQuality;

  /// Create a copy of SleepRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SleepRecordImplCopyWith<_$SleepRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
