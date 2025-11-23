// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'workout_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

WorkoutRecord _$WorkoutRecordFromJson(Map<String, dynamic> json) {
  return _WorkoutRecord.fromJson(json);
}

/// @nodoc
mixin _$WorkoutRecord {
  String get id => throw _privateConstructorUsedError;
  WorkoutType get type => throw _privateConstructorUsedError;
  DateTime get startTime => throw _privateConstructorUsedError;
  int get durationMinutes => throw _privateConstructorUsedError;
  double get distanceKm => throw _privateConstructorUsedError;
  int get caloriesKcal => throw _privateConstructorUsedError;
  String? get notes => throw _privateConstructorUsedError;

  /// Serializes this WorkoutRecord to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of WorkoutRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $WorkoutRecordCopyWith<WorkoutRecord> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutRecordCopyWith<$Res> {
  factory $WorkoutRecordCopyWith(
    WorkoutRecord value,
    $Res Function(WorkoutRecord) then,
  ) = _$WorkoutRecordCopyWithImpl<$Res, WorkoutRecord>;
  @useResult
  $Res call({
    String id,
    WorkoutType type,
    DateTime startTime,
    int durationMinutes,
    double distanceKm,
    int caloriesKcal,
    String? notes,
  });
}

/// @nodoc
class _$WorkoutRecordCopyWithImpl<$Res, $Val extends WorkoutRecord>
    implements $WorkoutRecordCopyWith<$Res> {
  _$WorkoutRecordCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of WorkoutRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? startTime = null,
    Object? durationMinutes = null,
    Object? distanceKm = null,
    Object? caloriesKcal = null,
    Object? notes = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as WorkoutType,
            startTime: null == startTime
                ? _value.startTime
                : startTime // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            durationMinutes: null == durationMinutes
                ? _value.durationMinutes
                : durationMinutes // ignore: cast_nullable_to_non_nullable
                      as int,
            distanceKm: null == distanceKm
                ? _value.distanceKm
                : distanceKm // ignore: cast_nullable_to_non_nullable
                      as double,
            caloriesKcal: null == caloriesKcal
                ? _value.caloriesKcal
                : caloriesKcal // ignore: cast_nullable_to_non_nullable
                      as int,
            notes: freezed == notes
                ? _value.notes
                : notes // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$WorkoutRecordImplCopyWith<$Res>
    implements $WorkoutRecordCopyWith<$Res> {
  factory _$$WorkoutRecordImplCopyWith(
    _$WorkoutRecordImpl value,
    $Res Function(_$WorkoutRecordImpl) then,
  ) = __$$WorkoutRecordImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    WorkoutType type,
    DateTime startTime,
    int durationMinutes,
    double distanceKm,
    int caloriesKcal,
    String? notes,
  });
}

/// @nodoc
class __$$WorkoutRecordImplCopyWithImpl<$Res>
    extends _$WorkoutRecordCopyWithImpl<$Res, _$WorkoutRecordImpl>
    implements _$$WorkoutRecordImplCopyWith<$Res> {
  __$$WorkoutRecordImplCopyWithImpl(
    _$WorkoutRecordImpl _value,
    $Res Function(_$WorkoutRecordImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of WorkoutRecord
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? type = null,
    Object? startTime = null,
    Object? durationMinutes = null,
    Object? distanceKm = null,
    Object? caloriesKcal = null,
    Object? notes = freezed,
  }) {
    return _then(
      _$WorkoutRecordImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as WorkoutType,
        startTime: null == startTime
            ? _value.startTime
            : startTime // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        durationMinutes: null == durationMinutes
            ? _value.durationMinutes
            : durationMinutes // ignore: cast_nullable_to_non_nullable
                  as int,
        distanceKm: null == distanceKm
            ? _value.distanceKm
            : distanceKm // ignore: cast_nullable_to_non_nullable
                  as double,
        caloriesKcal: null == caloriesKcal
            ? _value.caloriesKcal
            : caloriesKcal // ignore: cast_nullable_to_non_nullable
                  as int,
        notes: freezed == notes
            ? _value.notes
            : notes // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$WorkoutRecordImpl implements _WorkoutRecord {
  const _$WorkoutRecordImpl({
    required this.id,
    required this.type,
    required this.startTime,
    required this.durationMinutes,
    required this.distanceKm,
    required this.caloriesKcal,
    this.notes,
  });

  factory _$WorkoutRecordImpl.fromJson(Map<String, dynamic> json) =>
      _$$WorkoutRecordImplFromJson(json);

  @override
  final String id;
  @override
  final WorkoutType type;
  @override
  final DateTime startTime;
  @override
  final int durationMinutes;
  @override
  final double distanceKm;
  @override
  final int caloriesKcal;
  @override
  final String? notes;

  @override
  String toString() {
    return 'WorkoutRecord(id: $id, type: $type, startTime: $startTime, durationMinutes: $durationMinutes, distanceKm: $distanceKm, caloriesKcal: $caloriesKcal, notes: $notes)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$WorkoutRecordImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.startTime, startTime) ||
                other.startTime == startTime) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.distanceKm, distanceKm) ||
                other.distanceKm == distanceKm) &&
            (identical(other.caloriesKcal, caloriesKcal) ||
                other.caloriesKcal == caloriesKcal) &&
            (identical(other.notes, notes) || other.notes == notes));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    type,
    startTime,
    durationMinutes,
    distanceKm,
    caloriesKcal,
    notes,
  );

  /// Create a copy of WorkoutRecord
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$WorkoutRecordImplCopyWith<_$WorkoutRecordImpl> get copyWith =>
      __$$WorkoutRecordImplCopyWithImpl<_$WorkoutRecordImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$WorkoutRecordImplToJson(this);
  }
}

abstract class _WorkoutRecord implements WorkoutRecord {
  const factory _WorkoutRecord({
    required final String id,
    required final WorkoutType type,
    required final DateTime startTime,
    required final int durationMinutes,
    required final double distanceKm,
    required final int caloriesKcal,
    final String? notes,
  }) = _$WorkoutRecordImpl;

  factory _WorkoutRecord.fromJson(Map<String, dynamic> json) =
      _$WorkoutRecordImpl.fromJson;

  @override
  String get id;
  @override
  WorkoutType get type;
  @override
  DateTime get startTime;
  @override
  int get durationMinutes;
  @override
  double get distanceKm;
  @override
  int get caloriesKcal;
  @override
  String? get notes;

  /// Create a copy of WorkoutRecord
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$WorkoutRecordImplCopyWith<_$WorkoutRecordImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
