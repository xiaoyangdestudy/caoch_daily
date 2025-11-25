// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'review_record.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ReviewEntry _$ReviewEntryFromJson(Map<String, dynamic> json) {
  return _ReviewEntry.fromJson(json);
}

/// @nodoc
mixin _$ReviewEntry {
  String get id => throw _privateConstructorUsedError;
  DateTime get date => throw _privateConstructorUsedError;
  String get mood => throw _privateConstructorUsedError;
  List<String> get highlights => throw _privateConstructorUsedError;
  List<String> get improvements => throw _privateConstructorUsedError;
  List<String> get tomorrowPlans => throw _privateConstructorUsedError;
  String? get aiSummary => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;

  /// Serializes this ReviewEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ReviewEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ReviewEntryCopyWith<ReviewEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReviewEntryCopyWith<$Res> {
  factory $ReviewEntryCopyWith(
    ReviewEntry value,
    $Res Function(ReviewEntry) then,
  ) = _$ReviewEntryCopyWithImpl<$Res, ReviewEntry>;
  @useResult
  $Res call({
    String id,
    DateTime date,
    String mood,
    List<String> highlights,
    List<String> improvements,
    List<String> tomorrowPlans,
    String? aiSummary,
    String? note,
  });
}

/// @nodoc
class _$ReviewEntryCopyWithImpl<$Res, $Val extends ReviewEntry>
    implements $ReviewEntryCopyWith<$Res> {
  _$ReviewEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ReviewEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? mood = null,
    Object? highlights = null,
    Object? improvements = null,
    Object? tomorrowPlans = null,
    Object? aiSummary = freezed,
    Object? note = freezed,
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
            mood: null == mood
                ? _value.mood
                : mood // ignore: cast_nullable_to_non_nullable
                      as String,
            highlights: null == highlights
                ? _value.highlights
                : highlights // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            improvements: null == improvements
                ? _value.improvements
                : improvements // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            tomorrowPlans: null == tomorrowPlans
                ? _value.tomorrowPlans
                : tomorrowPlans // ignore: cast_nullable_to_non_nullable
                      as List<String>,
            aiSummary: freezed == aiSummary
                ? _value.aiSummary
                : aiSummary // ignore: cast_nullable_to_non_nullable
                      as String?,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ReviewEntryImplCopyWith<$Res>
    implements $ReviewEntryCopyWith<$Res> {
  factory _$$ReviewEntryImplCopyWith(
    _$ReviewEntryImpl value,
    $Res Function(_$ReviewEntryImpl) then,
  ) = __$$ReviewEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    DateTime date,
    String mood,
    List<String> highlights,
    List<String> improvements,
    List<String> tomorrowPlans,
    String? aiSummary,
    String? note,
  });
}

/// @nodoc
class __$$ReviewEntryImplCopyWithImpl<$Res>
    extends _$ReviewEntryCopyWithImpl<$Res, _$ReviewEntryImpl>
    implements _$$ReviewEntryImplCopyWith<$Res> {
  __$$ReviewEntryImplCopyWithImpl(
    _$ReviewEntryImpl _value,
    $Res Function(_$ReviewEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ReviewEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? date = null,
    Object? mood = null,
    Object? highlights = null,
    Object? improvements = null,
    Object? tomorrowPlans = null,
    Object? aiSummary = freezed,
    Object? note = freezed,
  }) {
    return _then(
      _$ReviewEntryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        date: null == date
            ? _value.date
            : date // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        mood: null == mood
            ? _value.mood
            : mood // ignore: cast_nullable_to_non_nullable
                  as String,
        highlights: null == highlights
            ? _value._highlights
            : highlights // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        improvements: null == improvements
            ? _value._improvements
            : improvements // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        tomorrowPlans: null == tomorrowPlans
            ? _value._tomorrowPlans
            : tomorrowPlans // ignore: cast_nullable_to_non_nullable
                  as List<String>,
        aiSummary: freezed == aiSummary
            ? _value.aiSummary
            : aiSummary // ignore: cast_nullable_to_non_nullable
                  as String?,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ReviewEntryImpl extends _ReviewEntry {
  const _$ReviewEntryImpl({
    required this.id,
    required this.date,
    required this.mood,
    final List<String> highlights = const [],
    final List<String> improvements = const [],
    final List<String> tomorrowPlans = const [],
    this.aiSummary,
    this.note,
  }) : _highlights = highlights,
       _improvements = improvements,
       _tomorrowPlans = tomorrowPlans,
       super._();

  factory _$ReviewEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReviewEntryImplFromJson(json);

  @override
  final String id;
  @override
  final DateTime date;
  @override
  final String mood;
  final List<String> _highlights;
  @override
  @JsonKey()
  List<String> get highlights {
    if (_highlights is EqualUnmodifiableListView) return _highlights;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_highlights);
  }

  final List<String> _improvements;
  @override
  @JsonKey()
  List<String> get improvements {
    if (_improvements is EqualUnmodifiableListView) return _improvements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_improvements);
  }

  final List<String> _tomorrowPlans;
  @override
  @JsonKey()
  List<String> get tomorrowPlans {
    if (_tomorrowPlans is EqualUnmodifiableListView) return _tomorrowPlans;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_tomorrowPlans);
  }

  @override
  final String? aiSummary;
  @override
  final String? note;

  @override
  String toString() {
    return 'ReviewEntry(id: $id, date: $date, mood: $mood, highlights: $highlights, improvements: $improvements, tomorrowPlans: $tomorrowPlans, aiSummary: $aiSummary, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReviewEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.mood, mood) || other.mood == mood) &&
            const DeepCollectionEquality().equals(
              other._highlights,
              _highlights,
            ) &&
            const DeepCollectionEquality().equals(
              other._improvements,
              _improvements,
            ) &&
            const DeepCollectionEquality().equals(
              other._tomorrowPlans,
              _tomorrowPlans,
            ) &&
            (identical(other.aiSummary, aiSummary) ||
                other.aiSummary == aiSummary) &&
            (identical(other.note, note) || other.note == note));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    date,
    mood,
    const DeepCollectionEquality().hash(_highlights),
    const DeepCollectionEquality().hash(_improvements),
    const DeepCollectionEquality().hash(_tomorrowPlans),
    aiSummary,
    note,
  );

  /// Create a copy of ReviewEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ReviewEntryImplCopyWith<_$ReviewEntryImpl> get copyWith =>
      __$$ReviewEntryImplCopyWithImpl<_$ReviewEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReviewEntryImplToJson(this);
  }
}

abstract class _ReviewEntry extends ReviewEntry {
  const factory _ReviewEntry({
    required final String id,
    required final DateTime date,
    required final String mood,
    final List<String> highlights,
    final List<String> improvements,
    final List<String> tomorrowPlans,
    final String? aiSummary,
    final String? note,
  }) = _$ReviewEntryImpl;
  const _ReviewEntry._() : super._();

  factory _ReviewEntry.fromJson(Map<String, dynamic> json) =
      _$ReviewEntryImpl.fromJson;

  @override
  String get id;
  @override
  DateTime get date;
  @override
  String get mood;
  @override
  List<String> get highlights;
  @override
  List<String> get improvements;
  @override
  List<String> get tomorrowPlans;
  @override
  String? get aiSummary;
  @override
  String? get note;

  /// Create a copy of ReviewEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ReviewEntryImplCopyWith<_$ReviewEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
